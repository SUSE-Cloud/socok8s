#!/usr/bin/env bash

set -e
# bootstrap-ansible-if-necessary installs ansible in a virtualenv
# should it be required. It can probably go away when ansible 2.7
# is packaged for all the distributions.

function install_ansible (){
    # NOTE(toabctl): ${SOCOK8S_WORKSPACE_BASEDIR} and ${SOCOK8S_ENVNAME} are always set
    local socok8s_workspace=${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace
    if [[ ! -d ${socok8s_workspace}/.ansiblevenv/ ]]; then
        virtualenv ${socok8s_workspace}/.ansiblevenv/
        source ${socok8s_workspace}/.ansiblevenv/bin/activate
        pip install --upgrade pip
        pip install --upgrade -r $(dirname "$0")/script_library/requirements.txt
    else
        echo "Found virtualenv at ${socok8s_workspace}/.ansiblevenv . Using that"
        source ${socok8s_workspace}/.ansiblevenv/bin/activate
    fi
}
