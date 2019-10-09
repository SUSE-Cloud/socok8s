#!/bin/bash

# Ensure variables are always set before going forward.
# Will prevent this script to be runned unless called from run.sh (by design)
set -o nounset

set -o errexit

echo "Deploying on KVM"

source ${scripts_absolute_dir}/deployment-actions-common.sh

function deploy_network(){
    echo "This is not supported yet on KVM"
}
function deploy_ses(){
    echo "This just runs ses configuration logic. Please create a SES node manually first."
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-deploy_ses_aio.yml
    echo "ses-ansible deploy is successful"
}
function deploy_caasp(){
    source ${scripts_absolute_dir}/pre-flight-checks.sh check_caasp_ssh_agent_running
    echo "Starting CaaSP 4 deploy on libvirt"
    run_ansible ${socok8s_absolute_dir}/playbooks/kvm-deploy_caasp.yml
    echo "CaaSP 4 deployed successfully on libvirt"
}

function deploy_ccp_deployer() {
    echo "Using Terraform deployed LB node for CCP deployer node"
    run_ansible ${socok8s_absolute_dir}/playbooks/kvm-deploy_ccp_deployer.yml
}

function enroll_caasp_workers() {
    echo "This is not supported yet. If you used kubic-automation, you can re-use the work done in openstack for enrollment."
}
function add_compute(){
    echo "Now Add compute"
    tagged_info=" --tags add_compute_node"
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-deploy_airship.yml ${tagged_info}
}
function remove_compute(){
    echo "Now Remove compute"
    run_ansible ${socok8s_absolute_dir}/playbooks/remove_compute.yml -e compute_node_name=$1
}
function clean_caasp(){
    if command -v ${TERRAFORM_BINARY_PATH} && [ -d submodules/skuba ]; then
        echo "Delete CaaSP 4"
        run_ansible ${socok8s_absolute_dir}/playbooks/kvm-delete_caasp.yml
    fi
}
function clean_kvm(){
    echo "Not implemented"
}
function teardown(){
    if [[ ${SOCOK8S_TEMPEST_PARSE_RESULTS} == "True" ]]
    then
      parse_tempest_ci
    fi
    if [[ ${SOCOK8S_GATHER_LOGS:-"NO"} == "YES" ]]
    then
        gather_logs
    fi
    clean_caasp
    clean_kvm
    clean_userfiles
}
