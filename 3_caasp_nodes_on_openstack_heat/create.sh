#!/usr/bin/env bash

set -o errexit
set -o pipefail

MAIN_FOLDER="$(readlink -f $(dirname ${0})/..)"
CURRENT_FOLDER="$(readlink -f $(dirname ${0}))"

source ${MAIN_FOLDER}/script_library/pre-flight-checks.sh check_openstack_env_vars_set

CAASP_IMAGE=${CAASP_IMAGE:-"caasp-3.0.0-GM-OpenStack-qcow"}
SERVER_FLAVOR=${SERVER_FLAVOR:-"m1.large"}
SECURITY_GROUP=${SECURITY_GROUP:-"all-incoming"}
EXTERNAL_NETWORK=${EXTERNAL_NETWORK:-"floating"}
INTERNAL_NETWORK=${INTERNAL_NETWORK:-"${PREFIX}-net"}
STACK_NAME="${PREFIX}-$RANDOM"

echo "Stackname will be:"
echo ${STACK_NAME} | tee ${MAIN_FOLDER}/.stackname

pushd ${CURRENT_FOLDER}
    echo "Creating caasp cluster"
    openstack stack create --verbose --wait -t caasp-stack.yaml ${STACK_NAME} \
        --parameter image="${CAASP_IMAGE}" \
        --parameter external_net="${EXTERNAL_NETWORK}" \
        --parameter internal_network="${INTERNAL_NETWORK}" \
        --parameter internal_subnet="${INTERNAL_SUBNET}" \
        --parameter security_group="${SECURITY_GROUP}" \
        --parameter keypair="${KEYNAME}" \
        | tee -a $LOG


    # compatibility for caasp tooling requires the creation of ssh key
    if [ ! -d ../misc-files/ ]; then
        mkdir ../misc-files
    fi
    if [ ! -f ../misc-files/id_shared ]; then
        ssh-keygen -b 2048 -t rsa -f ../misc-files/id_shared -N ""
    fi

    ./tools/generate-environment "$STACK_NAME"
    ./misc-tools/generate-ssh-config environment.json
    PYTHONUNBUFFERED=1 "./misc-tools/wait-for-velum" https://$(jq -r '.dashboardExternalHost' environment.json)
    cp environment.json ${MAIN_FOLDER}
popd

# Disable port security
## Get information of instances ID from stackname
servers=$(openstack server list --name "${STACK_NAME}" -c ID -f value)
for server in $servers; do
    ## Get ports from instances IDs
    serverports=$(openstack port list --server ${server} -c ID -f value)
    for port in $serverports; do
        ## Disable port security on those pesky instances
        openstack port set ${port} --no-security-group --disable-port-security
    done
done

# Create a VIP
openstack port create --network ${INTERNAL_NETWORK} --enable --disable-port-security ${STACK_NAME}-vip
portdetails=$(openstack port show ${STACK_NAME}-vip -c fixed_ips -f value | cut -f 1 -d ',')
vip=$(eval ${portdetails} && echo $ip_address)

# Put the VIP into user variables
set +o pipefail
ANSIBLE_RUNNER_DIR="${HOME}/suse-osh-deploy"
extravarsfile=${ANSIBLE_RUNNER_DIR}/env/extravars

# Ensure the extra vars exists.
# This displays the existing vars file for logging purposes, to ensure the deletion of some lines can
# be recovered by reading scrollback, should that ever be needed.
cat ${extravarsfile} || touch ${extravarsfile}

# Ensure the extra vars file starts with ---
grep -- --- ${extravarsfile} || sed -i '1i---' ${extravarsfile}

# Records new "suse_osh_deploy_vip_with_cidr"
sed -i '/suse_osh_deploy_vip_with_cidr/d' ${extravarsfile}
echo "suse_osh_deploy_vip_with_cidr: \"${vip}/24\"" >> ${extravarsfile}

# Display new content
echo "New extra vars file content"
cat ${extravarsfile}
