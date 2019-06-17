#!/bin/bash



function run_ansible(){
    set -x

    # NOTE(toabctl): ${SOCOK8S_WORKSPACE_BASEDIR} and ${SOCOK8S_ENVNAME} are always set
    local socok8s_workspace=${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace

    extravarsfile=${socok8s_workspace}/env/extravars
    inventorydir=${socok8s_workspace}/inventory/

    # This creates a structure that's similar to ansible-runner tool
    [[ ! -d ${socok8s_workspace}/env ]] && mkdir -p ${socok8s_workspace}/env
    if [[ ! -d ${socok8s_workspace}/inventory ]]; then
        mkdir -p ${socok8s_workspace}/inventory
        # Ensure default groupnames exist. It also DRY so that we automatically connect on hosts as root.
        # However don't force this by default if people already have an inventory.
        cp ${socok8s_absolute_dir}/examples/workdir/inventory/hosts.yml ${inventorydir}/default-inventory.yml
        # create a group_vars dir called all. There you can put extra variables
        # into files and these vars will be available for all hosts
        # Note: This is different to extravars - extravars can not be overwritten
        # but the vars in group_vars/all/ can be overwritten
        mkdir -p ${inventorydir}/group_vars/all/
    fi

    if [[ -f ${extravarsfile} ]]; then
        echo "Extra variables file exists: $(realpath ${extravarsfile}). Loading its vars in ansible-playbook call."
        extra_vars="-e @${extravarsfile}"
    fi

    if [[ ${USE_ARA:-False} == "True" ]]; then
        echo "Loading ARA"
        source ${socok8s_workspace}/ara.rc
    fi

    pushd ${socok8s_absolute_dir}
        # ANSIBLE_RETRY_FILES_SAVE_PATH sets a location where ansible retry files should be located
        # We are setting it explicitely to the socok8s_workspace directory which is user-writable
        ANSIBLE_RETRY_FILES_SAVE_PATH=${socok8s_workspace} ansible-playbook ${extra_vars:-} -i ${inventorydir} $@ -v
    popd
    set +x
}
