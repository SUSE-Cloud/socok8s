#!/bin/bash



function run_ansible(){
    set -x
    # ansible-runner default locations
    if [[ -z ${ANSIBLE_RUNNER_DIR+x} ]]; then
        echo "ANSIBLE_RUNNER_DIR env var is not set, defaulting to '~/suse-socok8s-deploy'"
        export ANSIBLE_RUNNER_DIR="${HOME}/suse-socok8s-deploy"
    fi

    extravarsfile=${ANSIBLE_RUNNER_DIR}/env/extravars
    inventorydir=${ANSIBLE_RUNNER_DIR}/inventory/

    # This creates a structure that's similar to ansible-runner tool
    [[ ! -d ${ANSIBLE_RUNNER_DIR}/env ]] && mkdir -p ${ANSIBLE_RUNNER_DIR}/env
    if [[ ! -d ${ANSIBLE_RUNNER_DIR}/inventory ]]; then
        mkdir -p ${ANSIBLE_RUNNER_DIR}/inventory
        # Ensure default groupnames exist. It also DRY so that we automatically connect on hosts as root.
        # However don't force this by default if people already have an inventory.
        cp ${socok8s_absolute_dir}/examples/workdir/inventory/hosts.yml ${inventorydir}/default-inventory.yml
    fi

    if [[ -f ${extravarsfile} ]]; then
        echo "Extra variables file exists: $(realpath ${extravarsfile}). Loading its vars in ansible-playbook call."
        extra_vars="-e @${extravarsfile}"
    fi

    if [[ ${USE_ARA:-False} == "True" ]]; then
        echo "Loading ARA"
        source ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/ara.rc
    fi

    pushd ${socok8s_absolute_dir}
        ansible-playbook ${extra_vars:-} -i ${inventorydir} $@ -v
    popd
    set +x
}
