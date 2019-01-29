#!/bin/bash



function run_ansible(){
    set -x
    # ansible-runner default locations
    if [[ -z ${ANSIBLE_RUNNER_DIR+x} ]]; then
        echo "ANSIBLE_RUNNER_DIR env var is not set, defaulting to '~/suse-osh-deploy'"
        ANSIBLE_RUNNER_DIR="${HOME}/suse-osh-deploy"
    fi

    extravarsfile=${ANSIBLE_RUNNER_DIR}/env/extravars
    inventorydir=${ANSIBLE_RUNNER_DIR}/inventory/

    # This creates a structure that's similar to ansible-runner tool
    if [[ ! -d ${ANSIBLE_RUNNER_DIR} ]]; then
        mkdir -p ${ANSIBLE_RUNNER_DIR}/{env,inventory} || true
    fi

    #Add extra debugging info if necessary
    if [[ ${OSH_DEVELOPER_MODE:-"False"} == "True" ]]; then
        # This is set in the current shell env vars, instead of
        # ${ANSIBLE_RUNNER_DIR}/env/envvars, to be non persistent between runs
        export ANSIBLE_STDOUT_CALLBACK=debug
        export ANSIBLE_VERBOSITY=3
    fi

    if [[ -f ${extravarsfile} ]]; then
        echo "Extra variables file exists: $(realpath ${extravarsfile}). Loading its vars in ansible-playbook call."
        extra_vars="-e @${extravarsfile}"
    fi

    if [[ -f ${inventorydir} ]]; then
        echo "Inventory directory (${inventorydir}) exists, adding it to the ansible-playbook call."
        inventory="-i ${inventorydir}"
    fi

    pushd ${socok8s_absolute_dir}
        ansible-playbook ${extra_vars:-} ${inventory:-} $@ -v
    popd
    set +x
}
