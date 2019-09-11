#!/bin/bash
## This creates or destroys caasp4 cluster
## Output on create: kubeconfig in $SOCOK8S_WORKSPACE
## Requirements: See README.md

set -o pipefail
set -o errexit
set -o nounset

# Will get some very early failure if some var is unset.
echo "Workspace is ${SOCOK8S_WORKSPACE} - Environment is ${SOCOK8S_ENVNAME}"

DEV_SCRIPTS_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
TERRAFORM_CONTAINER="registry.suse.de/home/jevrard/branches/suse/templates/images/sle-15-sp1/containers/soc10-clients:latest"
export IMAGE_USERNAME=${IMAGE_USERNAME:-sles}
export LIBVIRT_DEFAULT_URI=${LIBVIRT_DEFAULT_URI:-qemu+tcp://192.168.102.196:16509/system}

function finish {
  if podman ps -a --format '{{ .Names }}' | grep terraform-${SOCOK8S_ENVNAME} > /dev/null; then
      podman stop terraform-${SOCOK8S_ENVNAME} > /dev/null || true
      podman rm terraform-${SOCOK8S_ENVNAME} -f > /dev/null || true
  fi
}

# Start
#######

# Action = deploy or destroy
ACTION=${1:-deploy}
# PROVIDER = openstack or libvirt.
PROVIDER=${DEPLOYMENT_MECHANISM:-openstack}

echo "Fetching latest terraform container"
podman pull $TERRAFORM_CONTAINER

# Generate terraform config file
################################

if [[ ! -d ${SOCOK8S_WORKSPACE}/tf ]]; then
    mkdir -p ${SOCOK8S_WORKSPACE}/tf
fi

# Template if not yet templated
if [[ ! -f ${SOCOK8S_WORKSPACE}/tf/terraform.tfvars ]]; then
    envsubst < ${DEV_SCRIPTS_PATH}/terraform.tfvars.${PROVIDER}.example \
        > ${SOCOK8S_WORKSPACE}/tf/terraform.tfvars
fi

# Add user ssh keys from their keyring, live.
# Make it a csv (don't trail with ', ') and indent with 2 spaces the first line.
ssh-add -L | awk '{ORS=", ";} {print "\"" $1 " " $2 "\"";}' | head -c -2 | \
    sed -e 's/^/  /'> ${SOCOK8S_WORKSPACE}/ssh_keys.csv
sed -i -e "/%SSH_KEYS%/r ${SOCOK8S_WORKSPACE}/ssh_keys.csv" -e "//d" \
    ${SOCOK8S_WORKSPACE}/tf/terraform.tfvars
rm -f ${SOCOK8S_WORKSPACE}/ssh_keys.csv

#Run terraform container if not yet running
###########################################

trap finish INT TERM EXIT
if ! podman ps --format '{{ .Names }}' | grep terraform-${SOCOK8S_ENVNAME} > /dev/null; then
    containerid=$(podman run -it -d --name terraform-${SOCOK8S_ENVNAME} \
        -v ${SSH_AUTH_SOCK}:/ssh_auth_sock \
        -v ${SOCOK8S_WORKSPACE}:/workdir \
        ${USER_ARGS:-} \
        -e SSH_AUTH_SOCK=/ssh_auth_sock \
        -e IMAGE_USERNAME=${IMAGE_USERNAME} \
        -e OS_CLOUD=${OS_CLOUD:-""} \
        -e TERRAFORM_APPLY_AUTOAPPROVE=${TERRAFORM_APPLY_AUTOAPPROVE:-""} \
        ${TERRAFORM_CONTAINER} \
        /bin/bash)
    echo "Running new terraform container ${containerid} for ${SOCOK8S_ENVNAME}"
else
    # Note: This is just for safety. As the trap deletes the container, we
    # should almost never reach this else bit.
    echo "Terraform container already running, reusing"
fi

if [[ "${PROVIDER}" == "openstack" ]]; then
    # Find openstack config, and make it available under the container, to
    # reuse a single "OS_CLOUD" variable.
    # Secrets are destroyed upon successful execution
    # (deletion of the container)
    for filepath in ~/.config/openstack/* /etc/openstack/*; do
        if [[ -f $filepath ]]; then
            fname=$(basename $filepath)
            podman cp $filepath terraform-${SOCOK8S_ENVNAME}:/root/.config/openstack/$fname;
        fi
    done
elif [[ "${PROVIDER}" == "libvirt" ]]; then
    # Please remove all of this when skuba packages its libvirt code in IBS.
    cd ${SOCOK8S_WORKSPACE}
    # Do not copy again if it was already copied
    if [[ ! -d skuba-code ]]; then
        git clone https://github.com/SUSE/skuba.git skuba-code
        cp -r $(pwd)/skuba-code/ci/infra/libvirt/* tf/
    fi
    cd -
fi

# Now copy and run the terraformcmds script
podman cp ${DEV_SCRIPTS_PATH}/terraforming-${ACTION}.sh terraform-${SOCOK8S_ENVNAME}:/workdir/tf/terraformcmds.sh
podman exec -it -w /workdir/tf/ terraform-${SOCOK8S_ENVNAME} /workdir/tf/terraformcmds.sh

# Extra hacks for openstack until handled by terraform
if [[ "${PROVIDER}" == "openstack" ]] && [[ "${ACTION}" == "deploy" ]] ; then
    source ${DEV_SCRIPTS_PATH}/${PROVIDER}-temphack.sh
fi

echo "Successfully ${ACTION}ed CaaSP"
