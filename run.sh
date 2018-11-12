#!/bin/bash

set -o errexit
set -x

action=${1:-full_deploy}
deploy_mechanism=${2:-openstack}

source script_library/pre-flight-checks.sh general

function deploy_osh(){
    source script_library/detect-ansible.sh
    export ANSIBLE_STDOUT_CALLBACK=debug
    $ansible_playbook ./7_deploy_osh/play.yml -vvvv -i inventory-osh.ini
    echo "SUSE OSH deployed"
}

function pre_deploy_on_openstack(){
    source script_library/pre-flight-checks.sh openstack_early_tests
    echo "Deploying on OpenStack"
    ./1_ses_node_on_openstack/create.sh
    echo "Step 1 success"
    ./2_deploy_ses_aio/run.sh
    echo "Step 2 success"
    ./3_caasp_nodes_on_openstack_heat/create.sh
    echo "Step 3 success"
    ./4_osh_node_on_openstack/create.sh
    echo "Step 4 success"
    source script_library/detect-ansible.sh
    $ansible_playbook ./5_automate_caasp_enroll/play.yml -i inventory-osh.ini
    echo "Step 5 success"
    source script_library/detect-ansible.sh
    $ansible_playbook ./6_preflight_checks/checks.yml -i inventory-osh.ini
    echo "Step 6 success"
}

function pre_deploy_on_kvm(){
    echo "Deploying on KVM"
    echo "NOT IMPLEMENTED"
    exit 1
}

function delete_on_openstack(){
    echo "Deleting on OpenStack"
    ./4_osh_node_on_openstack/delete.sh
    echo "Delete Caasp nodes"
    ./3_caasp_nodes_on_openstack_heat/delete.sh || true
    ./3_caasp_nodes_on_openstack_manually/delete.sh || true
    echo "Delete SES node"
    ./1_ses_node_on_openstack/delete.sh
    exit 0
}

function delete_on_kvm(){
    echo "Deleting on KVM"
    echo "NOT IMPLEMENTED"
    exit 1
}

function clean_k8s(){
    echo "DANGER ZONE"
    read -p "Press Enter or Ctrl-C. Enter will remove all the deployed components on your kubernetes cluster"
    ansible -m script -a "script_library/cleanup-k8s.sh" all -i inventory-osh.ini
}
function delete_user_files(){
    echo "DANGER ZONE"
    read -p "Press Enter or Ctrl-C. Enter will delete userspace files in ~/suse-osh-deploy/"
    rm -rf ~/suse-osh-deploy/*
}

case "$action" in
    "full_deploy")
        pre_deploy_on_$deploy_mechanism
        deploy_osh
        ;;
    "deploy_osh")
        deploy_osh
        ;;
    "teardown")
        delete_on_$deploy_mechanism
        delete_user_files
        ;;
    "clean_k8s")
        clean_k8s
        ;;
    *)
        echo "Usage: ${0} full_deploy|deploy_osh|teardown|clean_k8s"
        echo "full_deploy ensures the requirements are setup and then does the deploy_osh step"
        echo "teardown removes all nodes used for deployment"
        echo "clean_k8s cleans up the kubernetes cluster of all evidence of an OSH deployment"
        ;;
esac
