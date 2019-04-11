#!/usr/bin/env bash

set -e
# bootstrap-ansible-if-necessary installs ansible in a virtualenv
# should it be required. It can probably go away when ansible 2.7
# is packaged for all the distributions.

function install_ansible (){
    if [[ -z ${ANSIBLE_RUNNER_DIR:-} ]]; then
        ANSIBLE_RUNNER_DIR=~/suse-socok8s-deploy
    fi
    if [[ ! -d ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/ ]]; then
        virtualenv ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/
    fi
    source ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/bin/activate

    pip install ${QUIET:-} --upgrade -r $(dirname "$0")/script_library/requirements.txt
    python -m ara.setup.env > ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/ara.rc
}
