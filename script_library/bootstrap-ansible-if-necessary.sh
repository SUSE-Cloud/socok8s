#!/usr/bin/env bash

set -e
# bootstrap-ansible-if-necessary installs ansible in a virtualenv
# should it be required. It can probably go away when ansible 2.7
# is packaged for all the distributions.

function install_ansible (){
    # ansible-runner default locations
    if [[ -z ${ANSIBLE_RUNNER_DIR:-} ]]; then
        echo "ANSIBLE_RUNNER_DIR env var is not set, defaulting to '~/suse-socok8s-deploy'"
        export ANSIBLE_RUNNER_DIR="${HOME}/suse-socok8s-deploy"
    fi

    export extravarsfile=${ANSIBLE_RUNNER_DIR}/env/extravars
    export inventorydir=${ANSIBLE_RUNNER_DIR}/inventory/

    # This creates a structure that's similar to ansible-runner tool
    if [[ ! -d ${ANSIBLE_RUNNER_DIR} ]]; then
        mkdir -p ${ANSIBLE_RUNNER_DIR}/{env,inventory} || true
        echo "Adding an empty inventory by default"
        cp ${socok8s_absolute_dir}/examples/workdir/inventory/hosts.yml ${inventorydir}/skeleton-inventory.yml
    fi

    if [[ ! -d ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/ ]]; then
        virtualenv ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/
    fi
    source ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/bin/activate
    pip install --upgrade -r $(dirname "$0")/script_library/requirements.txt
    python -m ara.setup.env > ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/ara.rc
}
