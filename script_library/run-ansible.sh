#!/bin/bash



function run_ansible(){
    set -x

    if [[ -f ${extravarsfile} ]]; then
        echo "Extra variables file exists: $(realpath ${extravarsfile}). Loading its vars in ansible-playbook call."
        extra_vars="-e @${extravarsfile}"
    fi

    if [[ -f ${inventorydir} ]]; then
        echo "Inventory directory (${inventorydir}) exists, adding it to the ansible-playbook call."
        inventory="-i ${inventorydir}"
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
