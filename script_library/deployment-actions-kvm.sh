#!/bin/bash

# Ensure variables are always set before going forward.
# Will prevent this script to be runned unless called from run.sh (by design)
set -o nounset

set -o errexit

echo "Deploying on KVM"

function deploy_ses(){
    echo "This just runs ses configuration logic. Please create a SES node manually first."
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-deploy_ses_aio.yml
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
    echo "Now deploy SUSE version of OSH"
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-deploy_osh.yml
}
function deploy_airship(){
    echo "Now deploy SUSE version of Airship"
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-deploy_airship.yml
}
function clean_k8s(){
    echo "DANGER ZONE. Set the env var 'DELETE_ANYWAY' to 'YES' to delete everything in your userspace."
    if [[ ${DELETE_ANYWAY:-"NO"} == "YES" ]]; then
        run_ansible ${socok8s_absolute_dir}/playbooks/generic-clean_k8s.yml
    fi
}
function clean_airship(){
    echo "DANGER ZONE. Set the env var 'DELETE_ANYWAY' to 'YES' to delete airship related everything in your userspace."
    if [[ ${DELETE_ANYWAY:-"NO"} == "YES" ]]; then
        run_ansible ${socok8s_absolute_dir}/playbooks/generic-clean_airship.yml
    fi
}
function clean_kvm(){
    echo "Not implemented"
}
function clean_userfiles(){
    echo "DANGER ZONE. Set the env var 'DELETE_ANYWAY' to delete everything in your userspace."
    if [[ ${DELETE_ANYWAY:-"NO"} == "YES" ]]; then
        echo "DELETE_ANYWAY is set, deleting user files"
        rm -rf ~/suse-socok8s-deploy/
    fi
}
function teardown(){
    clean_kvm
    clean_userfiles
}
