#!/bin/bash

# exit if vars is not set
socok8s_absolute_dir=${socok8s_absolute_dir:?"socok8s_absolute_dir is undefined"}

function run_ansible(){
    set -x

    ansible_command="ansible-playbook"

    # ansible-runner default locations
    if [[ -z ${ANSIBLE_RUNNER_DIR+x} ]]; then
        echo "ANSIBLE_RUNNER_DIR env var is not set, defaulting to '~/suse-osh-deploy'"
        export ANSIBLE_RUNNER_DIR="${HOME}/suse-osh-deploy"
    fi

    extravarsfile=${ANSIBLE_RUNNER_DIR}/env/extravars
    inventorydir=${ANSIBLE_RUNNER_DIR}/inventory/

    # This creates a structure that's similar to ansible-runner tool
    if [[ ! -d ${ANSIBLE_RUNNER_DIR} ]]; then
        mkdir -p "${ANSIBLE_RUNNER_DIR}"/{env,inventory} || true
        echo "Adding an empty inventory by default"
        cp "${socok8s_absolute_dir}"/examples/workdir/inventory/hosts.yml "${inventorydir}"
    fi

    #Add extra debugging info if necessary
    if [[ ${OSH_DEVELOPER_MODE:-"False"} == "True" ]]; then
        # This is set in the current shell env vars, instead of
        # ${ANSIBLE_RUNNER_DIR}/env/envvars, to be non persistent between runs
        export ANSIBLE_STDOUT_CALLBACK=debug
        export ANSIBLE_VERBOSITY=3
    fi

    if [[ -f ${extravarsfile} ]]; then
        echo "Extra variables file exists: $(realpath "${extravarsfile}"). Loading its vars in ansible-playbook call."
        ansible_command="$ansible_command -e @${extravarsfile}"
    fi

    if [[ ${USE_ARA:-False} == "True" ]]; then
        echo "Loading ARA"
        # shellcheck disable=1090
        source "${HOME}"/.socok8svenv/ara.rc
    fi

    pushd "${socok8s_absolute_dir}" || exit
        ${ansible_command} -i "${inventorydir}" "$@" -v
    popd || exit
    set +x
}
