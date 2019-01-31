#!/bin/bash

# Ensure variables are always set before going forward.
# Will prevent this script to be runned unless called from run.sh (by design)
set -o nounset

set -o errexit

echo "Deploying on OpenStack"

source ${scripts_absolute_dir}/pre-flight-checks.sh check_openstack_environment_is_ready_for_deploy
source ${scripts_absolute_dir}/pre-flight-checks.sh check_openstack_env_vars_set

function deploy_ses(){
    echo "Starting a SES deploy"
    ${socok8s_absolute_dir}/1_ses_node_on_openstack/create.sh
    echo "ses node created on openstack successfully"
    ${socok8s_absolute_dir}/2_deploy_ses_aio/run.sh
    echo "ses-ansible deploy is successful"
}
function deploy_caasp(){
    echo "Starting caasp deploy"
    ${socok8s_absolute_dir}/3_caasp_nodes_on_openstack_heat/create.sh
    echo "CaaSP deployed successfully"
}
function deploy_ccp_deployer() {
    echo "Creating CCP deploy node"
    ${socok8s_absolute_dir}/4_osh_node_on_openstack/create.sh
}
function enroll_caasp_workers() {
    echo "Enrolling caasp worker nodes into the cluster"
    run_ansible -i inventory-osh.ini ${socok8s_absolute_dir}/5_automate_caasp_enroll/play.yml
    echo "Run series of checks"
    run_ansible -i inventory-osh.ini ${socok8s_absolute_dir}/6_preflight_checks/play.yml
    echo "Ensure CaaSP workers are ready for OSH"
    run_ansible -i inventory-osh.ini -t workersetup ${socok8s_absolute_dir}/7_deploy_osh/play.yml
}
function patch_upstream(){
    echo "Running dev-patcher"
    echo "Nothing will happen if developer mode is not set"
    echo "TODO: Separate this into a different playbook"
    run_ansible -i inventory-osh.ini -t upstream_patching ${socok8s_absolute_dir}/7_deploy_osh/play.yml
}
function build_images(){
    echo "Running image builder"
    echo "Nothing will happen if developer mode is not set"
    echo "TODO: Separate this into a different playbook"
    run_ansible -i inventory-osh.ini -e "build_osh_images=yes" ${socok8s_absolute_dir}/7_deploy_osh/play.yml
}
function deploy_osh(){
    echo "Now deploy SUSE version of OSH"
    run_ansible -i inventory-osh.ini -t deploy ${socok8s_absolute_dir}/7_deploy_osh/play.yml
}
function teardown(){
    clean_openstack
    clean_userfiles
}
function clean_k8s(){
    echo "DANGER ZONE. Set the env var 'DELETE_ANYWAY' to 'YES' to delete everything in your userspace."
    if [[ ${DELETE_ANYWAY:-"NO"} == "YES" ]]; then
        ansible -m script -a "script_library/cleanup-k8s.sh" osh-deployer -i inventory-osh.ini
    fi
}
function clean_openstack(){
    echo "Deleting on OpenStack"
    ${socok8s_absolute_dir}/4_osh_node_on_openstack/delete.sh
    echo "Delete Caasp nodes"
    ${socok8s_absolute_dir}/3_caasp_nodes_on_openstack_heat/delete.sh || true
    ${socok8s_absolute_dir}/3_caasp_nodes_on_openstack_manually/delete.sh || true
    echo "Delete SES node"
    ${socok8s_absolute_dir}/1_ses_node_on_openstack/delete.sh
}
function clean_userfiles(){
    echo "DANGER ZONE. Set the env var 'DELETE_ANYWAY' to delete everything in your userspace."
    if [[ ${DELETE_ANYWAY:-"NO"} == "YES" ]]; then
        rm -rf ~/suse-osh-deploy/*
    fi
}
