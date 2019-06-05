#!/bin/bash

function patch_upstream(){
    echo "Running dev-patcher"
    echo "Nothing will happen if developer mode is not set"
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-patch_upstream.yml
}

function build_images(){
    echo "Running image builder"
    echo "Nothing will happen if developer mode is not set"
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-build_images.yml -e "build_osh_images=yes"
}

function setup_caasp_workers_for_openstack(){
    echo "Ensuring caasp workers can be used for openstack"
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-setup_caasp_workers_for_openstack.yml
}

function deploy_osh(){
    echo "Deploying SUSE version of OpenStack Helm"
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-deploy_osh.yml
}

function deploy_airship(){
    echo "Deploying SUSE version of Airship"
    tagged_info=''
    tags='all'
    if [[ "${1:-default}" != 'default' ]]; then
        tagged_info=" --tags $1"
        tags=$1
        echo "Now deploy SUSE version of Airship for specific tags ( ${tags} )"
    fi
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-deploy_airship.yml ${tagged_info}
}

function deploy_tempest(){
    echo "Deploying Tempest"
    run_ansible ${socok8s_absolute_dir}/playbooks/deploy_tempest.yml
}

function clean_airship(){
    clean_action=''
    action_desc='everything'
    if [[ "${1:-default}" != 'default' ]]; then
        clean_action=" -e clean_action=$1"
        action_desc=$1
    fi
    echo "Warning: This will delete all airship artifacts ( ${action_desc} ) in your userspace."
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-clean_airship.yml ${clean_action}
}

function clean_k8s(){
    echo "DANGER ZONE. Set the env var 'DELETE_ANYWAY' to 'YES' to delete everything in your userspace."
    if [[ ${DELETE_ANYWAY:-"NO"} == "YES" ]]; then
        run_ansible ${socok8s_absolute_dir}/playbooks/generic-clean_k8s.yml
    fi
}

function clean_userfiles(){
    echo "DANGER ZONE. Set the env var 'DELETE_ANYWAY' to delete everything in your userspace."
    if [[ ${DELETE_ANYWAY:-"NO"} == "YES" ]]; then
        extra_arg="-e delete_anyway='yes'"
    fi
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-clean_userfiles.yml ${extra_arg:-}
}
function gather_logs(){
    echo "Gathering kubernetes logs"
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-collect-logs.yml
}
