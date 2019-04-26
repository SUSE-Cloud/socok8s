#!/usr/bin/env bash

check_common_env_vars_set (){
    # basic checks that are needed for everything else!
    if [ -z ${SOCOK8S_ENVNAME+x} ]; then
        echo "No SOCOK8S_ENVNAME given. export SOCOK8S_ENVNAME=... for setting a env name" && exit 1
    fi
    # NOTE(toabctl): SOCOK8S_WORKSPACE_BASEDIR is always set in run.sh
    if [ -z ${SOCOK8S_WORKSPACE_BASEDIR+x} ]; then
        echo "No SOCOK8S_WORKSPACE_BASEDIR given. export SOCOK8S_WORKSPACE_BASEDIR=... for setting a directory" && exit 1
    fi

    echo "Using ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace as workspace directory"
}

check_openstack_env_vars_set (){
    if [ -z ${OS_CLOUD+x} ]; then
        echo "No OS_CLOUD given. export OS_CLOUD=... corresponding to your clouds.yaml" && exit 1
    fi

    if [ -z ${KEYNAME+x} ]; then
        echo "No KEYNAME given. You must give an openstack security keypair name to add to your server. Please export KEYNAME='<name of your keypair>'." && exit 1
    fi

    if [ -z ${EXTERNAL_NETWORK+x} ]; then
        echo "No EXTERNAL_NETWORK given. Using 'floating'."
        export EXTERNAL_NETWORK="floating"
    fi
}

check_openstack_environment_is_ready_for_deploy (){
    echo "Running OpenStack pre-flight checks"
    check_openstack_env_vars_set #Do not try to grep without ensuring the vars are set
    which openstack > /dev/null  || (echo "Please install openstack and heat CLI in your PATH"; exit 5)
    openstack stack delete --help > /dev/null || (echo "Please install heat client in your PATH"; exit 6)
    openstack keypair list | grep ${KEYNAME} > /dev/null || (echo "keyname not found. export KEYNAME=" && exit 2)
}

check_ansible_requirements (){
    # Ansible is required
    which ansible-playbook > /dev/null || install_ansible
    # We need ansible version 2.7 minimum
    [[ $(ansible --version | awk 'NR==1 { gsub(/[.]/,""); print substr($2,0,2); }' ) -lt "27" ]] && install_ansible
    # In the ansible venv, we should have jmespath and netaddr
    python -c 'import jmespath' || install_ansible
    python -c 'import netaddr' || install_ansible
    python -c 'import openstack' || install_ansible
    # If ara is required, install it.
    if [[ ${USE_ARA:-False} == "True" ]]; then
        python -c 'import ara' || install_ansible
    fi
}

# This function should probably go away when we'll package code into rpm.
check_git_submodules_are_present (){
    if hash git 2>/dev/null && [ -d .git ]; then
        # Only update submodules on first run
        if [[ $(find submodules -type f | wc -l) -eq 0 ]]; then
            git submodule update --init
        fi
    fi
}

check_jq_present (){
    which jq > /dev/null || (echo "Please install jq"; exit 7)
}

if [ -z ${1+x} ]; then
    echo "Please provide a preflight check name. No preflight checks given"
else
    $1
fi
