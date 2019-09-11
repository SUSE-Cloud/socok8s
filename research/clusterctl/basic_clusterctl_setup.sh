#!/bin/bash

##################################################################################################################
# This script will setup clusterctl with openstack provider. It uses minikube for local k8s cluster setup.
# Minikube uses none (bare-metal) driver which does not require a VM creation for hosting the cluster.
# Scipt needs to be executed on SLES 15-SP1 only as we are adding package repos for that specific version.
# Assumption is that node is already registered via SUSEConnect so that default repos are available on this node.
##################################################################################################################

#set -x
set -e

#sudo netconfig update -f # update resolv.conf in order to access internet

#sudo SUSEConnect -r <SLE_activation_code> -e <email_address>

INSTALL_ROOT=~/dev/go

OS_MATCH=$(egrep "SLES|15-SP1" /etc/os-release | wc -l)

if [ $OS_MATCH != 2 ]; then
  echo "****** Incorrect OS or version ******"
  echo "This script is expected to run on SLES 15-SP1 system only"
  return
fi

# Following repo added for kubectl rpm
sudo zypper lr socok8s_sle15sp1 || sudo zypper addrepo -G http://download.opensuse.org/repositories/Cloud:/socok8s:/master/SLE_15_SP1 socok8s_sle15sp1
# Following repo added for go1.13 rpm
sudo zypper lr go_sle15sp1 || sudo zypper addrepo -G http://download.opensuse.org/repositories/devel:/languages:/go/SLE_15-SP1/ go_sle15sp1
# Following repo added for docker rpm
sudo zypper lr SLE-Module-Containers15-SP1-Updates || sudo SUSEConnect --product sle-module-containers/15.1/x86_64
# Following repo added for minikube rpm
sudo zypper lr SUSE_Package_Hub_15_SP1_x86_64:SUSE-PackageHub-15-SP1-Pool || sudo SUSEConnect --product PackageHub/15.1/x86_64

sudo zypper ref

#sudo zypper up

sudo zypper install -y kubectl minikube go1.13 docker

# sudo usermod --append --groups libvirt `whoami`

#curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
#sudo install docker-machine-driver-kvm2 /usr/local/bin/

export GOPATH="$INSTALL_ROOT"

mkdir -p $GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack

CTL_BIN_PATH="$GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack/bin"

rpm -q git-core || sudo zypper install -y git-core make


if [ ! -f "$CTL_BIN_PATH/clusterctl" ]; then
  pushd ${GOPATH}/src/sigs.k8s.io/cluster-api-provider-openstack/
  # openstack provider code is rapidly changing so need to refer to relatively stable release code
  git clone https://github.com/kubernetes-sigs/cluster-api-provider-openstack $GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack
  git checkout -b release-0.1 -t origin/release-0.1
  make clusterctl
  popd
fi

export PATH=$PATH:$CTL_BIN_PATH


function find_clouds_yaml {
  if [ -z "$CLUSTERCTL_CLOUDS_YAML" ]; then
    CLUSTERCTL_CLOUDS_YAML=`ls ./clouds.yaml ~/.config/openstack/clouds.yaml /etc/openstack/clouds.yaml 2>/dev/null| head -1`
    if [ -z "$CLUSTERCTL_CLOUDS_YAML" -o ! -f "$CLUSTERCTL_CLOUDS_YAML" ]; then
      echo "ERROR: Unable to find clouds.yaml. Set CLUSTERCTL_CLOUDS_YAML to it's absolute path."
      exit 1
    fi
  fi
}

function ensure_clouds_yaml_cacert {
  # populate clouds.yaml cacert if empty (required by Ubuntu image)
  if [ -z "$CLUSTERCTL_CLOUDS_YAML" ]; then
    CLUSTERCTL_CLOUDS_YAML=`ls ./clouds.yaml ~/.config/openstack/clouds.yaml /etc/openstack/clouds.yaml 2>/dev/null| head -1`
    if [ -z "$CLUSTERCTL_CLOUDS_YAML" -o ! -f "$CLUSTERCTL_CLOUDS_YAML" ]; then
      echo "ERROR: Unable to find clouds.yaml. Set CLUSTERCTL_CLOUDS_YAML to it's absolute path."
      exit 1
    fi
  fi
  CLUSTERCTL_CLOUDS_YAML=$(readlink -f $CLUSTERCTL_CLOUDS_YAML)
  if [ "`yq read $CLUSTERCTL_CLOUDS_YAML clouds.$CLUSTERCTL_OS_CLOUD.cacert`" == "null" ]; then
    auth_endpoint=`yq read $CLUSTERCTL_CLOUDS_YAML clouds.$CLUSTERCTL_OS_CLOUD.auth.auth_url | sed "s,https*://\([^/]*\).*,\1,g"`
    echo -n | openssl s_client -showcerts -connect $auth_endpoint 2>/dev/null > $CLUSTERCTL_CONFDIR/$CLUSTERCTL_OS_CLOUD.pem
    cp $CLUSTERCTL_CLOUDS_YAML $CLUSTERCTL_CONFDIR/clouds.yaml.cacert
    CLUSTERCTL_CLOUDS_YAML=$CLUSTERCTL_CONFDIR/clouds.yaml.cacert
    yq write --inplace $CLUSTERCTL_CLOUDS_YAML clouds.$CLUSTERCTL_OS_CLOUD.cacert $CLUSTERCTL_CONFDIR/$CLUSTERCTL_OS_CLOUD.pem
  fi
}

function generate_clusterctl_configuration_files {
  outdir=outdir
  bindir=$GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack/cmd/clusterctl/examples/openstack

  # script requires which binary, does not work with the alias
  if ! hash which 2>/dev/null; then
    sudo zypper install -y which
  fi

  # install a compatible yq
  if ! hash yq 2>/dev/null; then
    curl -L https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64 > $CTL_BIN_PATH/yq
    chmod +x $CTL_BIN_PATH/yq
  fi

  $bindir/generate-yaml.sh \
    --force-overwrite \
    $CLUSTERCTL_CLOUDS_YAML \
    $CLUSTERCTL_OS_CLOUD \
    $CLUSTERCTL_USERDATA_OS \
    $outdir \
    > /dev/null

  # script outputs relative to its location
  mv $bindir/$outdir/* $CLUSTERCTL_CONFDIR
  rm -rf $bindir/$outdir
}

function populate_clusterctl_configuration_files {
  cluster=$CLUSTERCTL_CONFDIR/cluster.yaml
  master=$CLUSTERCTL_CONFDIR/machines.yaml
  workers=$CLUSTERCTL_CONFDIR/machine-deployment.yaml

  # set target cluster name and IP
  yq write  --inplace $cluster metadata.name $CLUSTERCTL_CLUSTER_NAME
  yq write  --inplace $cluster spec.providerSpec.value.clusterConfiguration.controlPlaneEndpoint $CLUSTERCTL_MASTER_FLOATING_IP:6443

  # remove single worker
  yq delete --inplace $master  'items[1]'

  # set machine values
  yq delete --inplace $master  'items[0].metadata.generateName'
  yq write  --inplace $master  'items[0].metadata.name' $CLUSTERCTL_INSTANCE_PREFIX-master-0
  yq write  --inplace $workers 'metadata.name' $CLUSTERCTL_INSTANCE_PREFIX-worker
  yq write  --inplace $master  'items[0].metadata.labels[cluster.k8s.io/cluster-name]' $CLUSTERCTL_CLUSTER_NAME
  yq write  --inplace $workers 'metadata.labels[cluster.k8s.io/cluster-name]' $CLUSTERCTL_CLUSTER_NAME
  yq write  --inplace $workers 'spec.selector.matchLabels[cluster.k8s.io/cluster-name]' $CLUSTERCTL_CLUSTER_NAME
  yq write  --inplace $workers 'spec.template.metadata.labels[cluster.k8s.io/cluster-name]' $CLUSTERCTL_CLUSTER_NAME
  yq write  --inplace $master  'items[0].spec.providerSpec.value.image' $CLUSTERCTL_IMAGE
  yq write  --inplace $workers 'spec.template.spec.providerSpec.value.image' $CLUSTERCTL_IMAGE
  yq write  --inplace $master  'items[0].spec.providerSpec.value.flavor' $CLUSTERCTL_FLAVOR
  yq write  --inplace $workers 'spec.template.spec.providerSpec.value.flavor' $CLUSTERCTL_FLAVOR
  yq write  --inplace $master  'items[0].spec.providerSpec.value.keyName' $CLUSTERCTL_KEYPAIR
  yq write  --inplace $workers 'spec.template.spec.providerSpec.value.keyName' $CLUSTERCTL_KEYPAIR
  yq write  --inplace $master  'items[0].spec.providerSpec.value.floatingIP' $CLUSTERCTL_MASTER_FLOATING_IP
  yq delete --inplace $workers 'spec.template.spec.providerSpec.value.floatingIP'
  yq delete --inplace $master  'items[0].spec.providerSpec.value.networks'
  yq delete --inplace $workers 'spec.template.spec.providerSpec.value.networks'
  IFS=', ' read -r -a array <<< $CLUSTERCTL_NETWORK_IDS
  for i in "${array[@]}"; do
    yq write  --inplace $master  'items[0].spec.providerSpec.value.networks[+].uuid' $i
    yq write  --inplace $workers 'spec.template.spec.providerSpec.value.networks[+].uuid' $i
  done
  yq delete --inplace $master  'items[0].spec.providerSpec.value.securityGroups'
  yq delete --inplace $workers 'spec.template.spec.providerSpec.value.securityGroups'
  IFS=', ' read -r -a array <<< $CLUSTERCTL_SECGROUP_IDS
  for i in "${array[@]}"; do
    yq write  --inplace $master  'items[0].spec.providerSpec.value.securityGroups[+].uuid' $i
    yq write  --inplace $workers 'spec.template.spec.providerSpec.value.securityGroups[+].uuid' $i
  done
  yq write --inplace $workers spec.replicas $CLUSTERCTL_WORKER_COUNT
}

function create_cluster {
  # create target cluster
  sudo $GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack/bin/clusterctl create cluster \
    --bootstrap-type minikube --bootstrap-flags vm-driver=none \
    --provider openstack \
    --cluster $CLUSTERCTL_CONFDIR/cluster.yaml \
    --machines $CLUSTERCTL_CONFDIR/machines.yaml \
    --provider-components $CLUSTERCTL_CONFDIR/provider-components.yaml

  # add workers machinedeployment
  sudo kubectl --kubeconfig kubeconfig apply -f $CLUSTERCTL_CONFDIR/machine-deployment.yaml
}

function scale_workers {
  newcnt=$1

  md="machinedeployment.cluster.k8s.io/`yq read $CLUSTERCTL_CONFDIR/machine-deployment.yaml metadata.name`"
  rev=`sudo kubectl --kubeconfig kubeconfig get $md -o yaml | yq read - metadata.resourceVersion`
  sudo kubectl --kubeconfig kubeconfig scale $md --replicas=$newcnt --resource-version=$rev
}

function delete_cluster {
  sudo $GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack/bin/clusterctl delete cluster \
    --bootstrap-type minikube --bootstrap-flags vm-driver=none \
    --kubeconfig kubeconfig \
    --provider-components $CLUSTERCTL_CONFDIR/provider-components.yaml
}

export CLUSTERCTL_CONFDIR=${CLUSTERCTL_CONFDIR:-~/clusterapi/$CLUSTERCTL_CLUSTER_NAME}

mkdir -p $CLUSTERCTL_CONFDIR
find_clouds_yaml
ensure_clouds_yaml_cacert
generate_clusterctl_configuration_files
populate_clusterctl_configuration_files
create_cluster
#scale_workers 4
#delete_cluster
