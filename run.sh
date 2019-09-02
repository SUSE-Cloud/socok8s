#!/bin/bash

set -o errexit

usage() {
    echo "deploy                                         -- Deploy SUSE Containerized OpenStack."
    echo "update_openstack                               -- Update OpenStack deployment."
    echo "test                                           -- Deploy and run OpenStack Tempest tests."
    echo "add_openstack_compute                          -- Add OpenStack compute node. Add compute node host(s) in inventory file."
    echo "remove_openstack_compute <compute-node-name>   -- Remove OpenStack compute node. Provide compute node host name with option."
    echo "remove_deployment                              -- Delete all resources related with deployment including images."
}

if [ -z "${1:-}" ]; then
    echo "$0 -h, --help          -- Show help message."
    exit 1
fi

scripts_absolute_dir="$( cd "$(dirname "$0")/script_library" ; pwd -P )"
socok8s_absolute_dir="$( cd "$(dirname "$0")" ; pwd -P )"

deployment_action=$1

while true ; do
    case "$deployment_action" in
      -h|--help) usage ; exit 0 ;;
       *) source ${scripts_absolute_dir}/pre-flight-checks.sh "validate_cli_options $1"
          break ;;
    esac
done

if [[ "${SOCOK8S_DEVELOPER_MODE:-False}" == "True" ]]; then
    set -x
    SOCOK8S_USE_VIRTUALENV=${SOCOK8S_USE_VIRTUALENV:-True}
fi

# USE an env var to setup where to deploy to
# by default, ccp will deploy on kvm
DEPLOYMENT_MECHANISM=${DEPLOYMENT_MECHANISM:-"kvm"}
export DEPLOYMENT_MECHANISM

# The base directory where workspace(s) are created in
SOCOK8S_WORKSPACE_BASEDIR=${SOCOK8S_WORKSPACE_BASEDIR:-~}

# The path to the terraform binary
TERRAFORM_BINARY_PATH=${TERRAFORM_BINARY_PATH:-/usr/bin/terraform}

source ${scripts_absolute_dir}/pre-flight-checks.sh check_common_env_vars_set
source ${scripts_absolute_dir}/bootstrap-ansible-if-necessary.sh
source ${scripts_absolute_dir}/pre-flight-checks.sh check_jq_present
source ${scripts_absolute_dir}/pre-flight-checks.sh check_ansible_requirements
source ${scripts_absolute_dir}/pre-flight-checks.sh check_git_submodules_are_present

# Bring an ansible runner that allows a userspace environment
source ${scripts_absolute_dir}/run-ansible.sh

pushd ${socok8s_absolute_dir}

# All the deployment actions (deploy steps) are defined in script_library/actions-openstack.sh for example.
# For simplificity, the following script contains each action for a deploy mechanism, and each action should
# contain a "master" playbook, which should be named playbooks/${DEPLOYMENT_MECHANISM}-${deployment_action}
source ${scripts_absolute_dir}/deployment-actions-${DEPLOYMENT_MECHANISM}.sh

case "$deployment_action" in
    "deploy_network")
        deploy_network
        ;;
    "deploy_caasp")
        deploy_caasp
        ;;
    "deploy_ccp_deployer")
        # CCP deployer is a node that will be used to control k8s cluster,
        # as we shouldn't do it on caasp cluster (microOS and others)
        deploy_ccp_deployer
        ;;
    "configure_ccp_deployer")
        configure_ccp_deployer
        ;;
    "patch_upstream")
        patch_upstream
        ;;
    "build_images")
        build_images
        ;;
    "deploy_osh")
        deploy_osh
        ;;
    "add_openstack_compute")
        add_compute
        ;;
    "remove_openstack_compute")
        if [ -z ${2+x} ];then
            echo "Please enter compute node host name"
            exit 1
        fi
        read -r -p "WARNING: Please remove all VM(s) from the compute host. Are you sure to continue? [y/n] " user_input
        if [[ $user_input == "y" ]]; then
            remove_compute $2
        else
            exit 0
        fi
        ;;
    "setup_caasp_workers_for_openstack")
        setup_caasp_workers_for_openstack
        ;;
    "setup_hosts")
        deploy_network
        deploy_caasp
        deploy_ccp_deployer
        configure_ccp_deployer
        deploy_ses_rook
        ;;
    "setup_openstack")
        setup_caasp_workers_for_openstack
        patch_upstream
        build_images
        deploy_osh
        ;;
    "setup_airship")
        setup_caasp_workers_for_openstack
        deploy_airship
        ;;
    "deploy")
        deploy_airship
        ;;
    "update_openstack")
        deploy_airship update_airship_osh_site
        ;;
    "setup_everything")
        deploy_network
        deploy_caasp
        deploy_ccp_deployer
        configure_ccp_deployer
        deploy_ses_rook
        setup_caasp_workers_for_openstack
        patch_upstream
        build_images
        deploy_osh
        ;;
    "teardown")
        teardown
        ;;
    "clean_caasp")
        clean_caasp
        ;;
    "clean_k8s")
        clean_k8s
        ;;
    "clean_airship_not_images")
        clean_airship clean_openstack_clean_ucp_clean_rest
        ;;
    "remove_deployment")
        read -r -p "WARNING: Please remove all VM(s) from all compute host(s). This deletes everything that is deployed. Are you sure to continue? [y/n] " user_input
        if [[ $user_input == "y" ]]; then
            clean_airship
        else
            exit 0
        fi
        ;;
    "gather_logs")
        gather_logs
        ;;
    "test")
        deploy_tempest
        ;;
    "deploy_ses_rook")
        deploy_ses_rook
        ;;
    "delete_ses_rook")
        delete_ses_rook
        ;;
    "parse_tempest_ci")
        parse_tempest_output
        ;;
    *)
        echo "Invalid option, Check --help for valid options"
        ;;
esac
