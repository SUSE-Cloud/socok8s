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

sudo minikube status | grep 'Running' || sudo minikube start --vm-driver=none

export GOPATH="$INSTALL_ROOT"

mkdir -p $GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack

CTL_BIN_PATH="$GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack/bin"

rpm -q git-core || sudo zypper install -y git-core make

pushd ${GOPATH}/src/sigs.k8s.io/cluster-api-provider-openstack/

if [ ! -f "$CTL_BIN_PATH/clusterctl" ]; then
  # openstack provider code is rapidly changing so need to refer to relatively stable release code
  git clone https://github.com/kubernetes-sigs/cluster-api-provider-openstack $GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack
  git checkout -b release-0.1 -t origin/release-0.1
  make clusterctl
fi

if [ -f "$CTL_BIN_PATH/clusterctl" ]; then
  echo "******************************************************************************************"
  echo "Clusterctl with openstack provider is now available at $CTL_BIN_PATH/clusterctl"
  echo "******************************************************************************************"
  PATH=$PATH:$CTL_BIN_PATH
  export PATH  # Will work only when parent shell is used e.g. with dotspace notation ". ~/basic_clusterctl_setup.sh"
  $CTL_BIN_PATH/clusterctl help
fi

popd