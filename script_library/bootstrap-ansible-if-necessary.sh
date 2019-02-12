#!/usr/bin/env bash

set -e
# bootstrap-ansible-if-necessary installs ansible in a virtualenv
# should it be required. It can probably go away when ansible 2.7
# is packaged for all the distributions.

function install_ansible (){
    if [[ ! -d ~/.socok8svenv ]]; then
        virtualenv ~/.socok8svenv
    fi
    source ~/.socok8svenv/bin/activate
    pip install --upgrade -r $(dirname "$0")/script_library/requirements.txt
    python -m ara.setup.env > ~/.socok8svenv/ara.rc
}
