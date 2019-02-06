#!/bin/bash

# Ensure variables are always set before going forward.
# Will prevent this script to be runned unless called from run.sh (by design)
set -o nounset

set -o errexit

echo "Deploying on KVM"

function deploy_ses(){
    echo "This is not supported yet. Please create a node manually and run ses-ansible on it."
    run_ansible -i inventory-ses.ini ${socok8s_absolute_dir}/2_deploy_ses_aio/play.yml
    echo "ses-ansible deploy is successful"
}
function deploy_caasp(){
    echo "This is not supported yet. Check at kubic-automation tooling."
}
function deploy_ccp_deployer() {
    echo "This is not supported yet. Please create a node with Leap15/SLE15 manually"
}
function enroll_caasp_workers() {
    echo "This is not supported yet. If you used kubic-automation, you can re-use the work done in openstack for enrollment."
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
function deploy_airship(){
    echo "Now deploy SUSE version of Airship"
    run_ansible -i inventory-airship.ini ${socok8s_absolute_dir}/8_deploy_airship/play.yml
}
function clean_k8s(){
    echo "DANGER ZONE. Set the env var 'DELETE_ANYWAY' to 'YES' to delete everything in your userspace."
    if [[ ${DELETE_ANYWAY:-"NO"} == "YES" ]]; then
        ansible -m script -a "script_library/cleanup-k8s.sh" osh-deployer -i inventory-osh.ini
    fi
}
function clean_kvm(){
    echo "Not implemented"
}
function clean_userfiles(){
    echo "DANGER ZONE. Set the env var 'DELETE_ANYWAY' to delete everything in your userspace."
    if [[ ${DELETE_ANYWAY:-"NO"} == "YES" ]]; then
        rm -rf ~/suse-osh-deploy/*
    fi
}
function teardown(){
    clean_kvm
    clean_userfiles
}
