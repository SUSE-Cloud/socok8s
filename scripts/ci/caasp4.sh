#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset

# Will get some very early failure if some var is unset.
echo "Workspace is ${SOCOK8S_WORKSPACE} - Environment is ${SOCOK8S_ENVNAME}"

CI_SCRIPTS_PATH="$(dirname "$(readlink -f "${0}")")"
TERRAFORM_CONTAINER="registry.suse.de/home/jevrard/branches/suse/templates/images/sle-15-sp1/containers/soc10-clients:latest"

function finish {
  if podman ps --format '{{ .Names }}' | grep terraform > /dev/null; then
      podman stop terraform > /dev/null
      podman rm terraform -f > /dev/null
  fi
}

# Start
#######

# Action = deploy or destroy
ACTION=${1:-deploy}
# PROVIDER = openstack or kvm.
PROVIDER=${DEPLOYMENT_MECHANISM:-openstack}

echo "Fetching latest terraform container"
podman pull $TERRAFORM_CONTAINER

# Generate terraform config file
################################

if [[ ! -d ${SOCOK8S_WORKSPACE}/tf ]]; then
    mkdir -p ${SOCOK8S_WORKSPACE}/tf
fi

sed "s/%SOCOK8S_ENVNAME%/${SOCOK8S_ENVNAME}/g" ${CI_SCRIPTS_PATH}/terraform.tfvars.${PROVIDER}.example > ${SOCOK8S_WORKSPACE}/tf/terraform.tfvars

# Add user ssh keys from their keyring
# Make it a csv (don't trail with ', ') and indent with 2 spaces the first line.
ssh-add -L | awk '{ORS=", ";} {print "\"" $1 " " $2 "\"";}' | head -c -2 | sed -e 's/^/  /'> ${SOCOK8S_WORKSPACE}/ssh_keys.csv
sed -i -e "/%SSH_KEYS%/r ${SOCOK8S_WORKSPACE}/ssh_keys.csv" -e "//d" ${SOCOK8S_WORKSPACE}/tf/terraform.tfvars
rm -f ${SOCOK8S_WORKSPACE}/ssh_keys.csv

#Run terraform container if not yet running
###########################################

# because libvirt provider by default runs on qemu:/// it makes sense to expose
# libvirt socket to the container by default.
if [[ -f /var/run/libvirt/libvirt-sock ]] && [[ "${PROVIDER}" == "kvm" ]]; then
    echo "Auto expose libvirt socket by default"
    provider_args="
      -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock
      -e LIBVIRT_DEFAULT_URI=${LIBVIRT_DEFAULT_URI:-qemu:///system}"
else
    provider_args=""
fi

if ! podman ps --format '{{ .Names }}' | grep terraform > /dev/null; then
    containerid=$(podman run -it -d --name terraform \
        -v ${SSH_AUTH_SOCK}:/ssh_auth_sock \
        -v ${SOCOK8S_WORKSPACE}:/workdir \
        ${provider_args} \
        ${USER_ARGS:-} \
        -e SSH_AUTH_SOCK=/ssh_auth_sock \
        ${TERRAFORM_CONTAINER} \
        /bin/bash)
    echo "Running new terraform container with ID ${containerid}"
else
    # Note: This is just for safety. As the trap deletes the container, we
    # should almost never reach this else bit.
    echo "Terraform container already running, reusing"
fi
trap finish INT TERM EXIT

if [[ "${PROVIDER}" == "openstack" ]]; then
    # Find openstack config, and make it available under the container, to
    # reuse a single "OS_CLOUD" variable.
    # Secrets are destroyed upon successful execution
    # (deletion of the container)
    for filepath in ~/.config/openstack/* /etc/openstack/*; do
        if [[ -f $filepath ]]; then
            fname=$(basename $filepath)
            podman cp $filepath terraform:/root/.config/openstack/$fname;
        fi
    done
elif [[ "${PROVIDER}" == "kvm" ]]; then
    # Please remove all of this when skuba packages its libvirt code in IBS.
    cd ${SOCOK8S_WORKSPACE}
    git clone https://github.com/SUSE/skuba.git skuba-code
    mv skuba-code/ci/infra/libvirt/* tf/
    rm -rf skuba-code
    cd -
fi

# Now copy and run the terraformcmds script
podman cp ${CI_SCRIPTS_PATH}/terraforming-${ACTION}.sh terraform:/workdir/tf/terraformcmds.sh
podman exec -it -w /workdir/tf/ -e OS_CLOUD=${OS_CLOUD} -e SSH_AUTH_SOCK=/ssh_auth_sock terraform /workdir/tf/terraformcmds.sh

echo "Successfully ${ACTION}ed CaaSP"
