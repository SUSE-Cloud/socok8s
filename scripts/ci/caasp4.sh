#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset

# Will get some very early failure if some var is unset.
echo "Workspace is ${SOCOK8S_WORKSPACE} - Environment is ${SOCOK8S_ENVNAME}"

CI_SCRIPTS_PATH="$(dirname "$(readlink -f "${0}")")"
TERRAFORM_CONTAINER="registry.suse.de/home/jevrard/branches/suse/templates/images/sle-15-sp1/containers/soc10-clients:latest"
TERRAFORM_USERFILE=${SOCOK8S_WORKSPACE}/tf/terraform.tfvars

function finish {
  if podman ps --format '{{ .Names }}' | grep terraform > /dev/null; then
      podman stop terraform > /dev/null
      podman rm terraform -f > /dev/null
  fi
}

# Start
#######

# Action = deploy or destroy
ACTION=${1:-"deploy"}


echo "Fetching latest terraform container"
podman pull $TERRAFORM_CONTAINER

# Generate terraform config file
################################

if [[ ! -d $(dirname ${TERRAFORM_USERFILE}) ]]; then
    mkdir $(dirname ${TERRAFORM_USERFILE})
fi

sed "s/%SOCOK8S_ENVNAME%/${SOCOK8S_ENVNAME}/g" ${CI_SCRIPTS_PATH}/terraform.tfvars.example > $TERRAFORM_USERFILE

# Add user ssh keys from their keyring
# Make it a csv (don't trail with ', ') and indent with 2 spaces the first line.
ssh-add -L | awk '{ORS=", ";} {print "\"" $1 " " $2 "\"";}' | head -c -2 | sed -e 's/^/  /'> ${SOCOK8S_WORKSPACE}/ssh_keys.csv
sed -i -e "/%SSH_KEYS%/r ${SOCOK8S_WORKSPACE}/ssh_keys.csv" -e "//d" ${TERRAFORM_USERFILE}
rm -f ${SOCOK8S_WORKSPACE}/ssh_keys.csv

#Run terraform container if not yet running
###########################################

# Note: This is just for safety. As the trap deletes the container, we
# should almost never reach this code.
if ! podman ps --format '{{ .Names }}' | grep terraform > /dev/null; then
    containerid=$(podman run -it -d --name terraform \
        -v ${SSH_AUTH_SOCK}:/ssh_auth_sock \
        -v ${SOCOK8S_WORKSPACE}:/workdir \
        -e SSH_AUTH_SOCK=/ssh_auth_sock \
        ${TERRAFORM_CONTAINER} \
        /bin/bash)
    echo "Running new terraform container with ID ${containerid}"
else
    echo "Terraform container already running, reusing"
fi
trap finish INT TERM EXIT


# Find openstack config, and make it available under the container, to
# reuse a single "OS_CLOUD" variable.
# Secrets are destroyed upon successful execution (deletion of the container)
for filepath in ~/.config/openstack/* /etc/openstack/*; do
    if [[ -f $filepath ]]; then
        fname=$(basename $filepath)
        podman cp $filepath terraform:/root/.config/openstack/$fname;
    fi
done

# Now prep and run the terraformcmds script
case ${ACTION:-"deploy"} in
    deploy)
      podman cp ${CI_SCRIPTS_PATH}/terraforming.sh terraform:/workdir/tf/terraformcmds.sh
      podman exec -w /workdir/tf/ -e OS_CLOUD=${OS_CLOUD} -e SSH_AUTH_SOCK=/ssh_auth_sock terraform /workdir/tf/terraformcmds.sh
    ;;
    destroy)
      cat << EOF > ${SOCOK8S_WORKSPACE}/tf/terraformcmds.sh
#!/bin/bash
env | grep OS_
terraform destroy -auto-approve ./
rm -rf ./caasp4-cluster/
EOF
      chmod 750 ${SOCOK8S_WORKSPACE}/tf/terraformcmds.sh
      podman exec -w /workdir/tf/ -e OS_CLOUD=${OS_CLOUD} terraform /workdir/tf/terraformcmds.sh
    ;;
esac

echo "Successfully ${ACTION}ed CaaSP"
