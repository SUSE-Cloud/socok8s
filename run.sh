#!/bin/bash

set -o errexit

if [[ ${OSH_DEVELOPER_MODE:-"False"} == "True" ]]; then
    set -x
fi

scripts_absolute_dir="$( cd "$(dirname "$0")/script_library" ; pwd -P )"
socok8s_absolute_dir="$( cd "$(dirname "$0")" ; pwd -P )"

# USE an env var to setup where to deploy to
# by default, ccp will deploy on openstack for inception style fun (and CI).
DEPLOYMENT_MECHANISM=${DEPLOYMENT_MECHANISM:-"openstack"}

source ${scripts_absolute_dir}/bootstrap-ansible-if-necessary.sh
source ${scripts_absolute_dir}/pre-flight-checks.sh check_jq_present
source ${scripts_absolute_dir}/pre-flight-checks.sh check_ansible_requirements
source ${scripts_absolute_dir}/pre-flight-checks.sh check_git_submodules_are_present

# Bring an ansible runner that allows a userspace environment
source ${scripts_absolute_dir}/run-ansible.sh

pushd ${socok8s_absolute_dir}

# All the deployment actions (deploy steps) are defined in script_library/actions-openstack.sh for example.
source ${scripts_absolute_dir}/deployment-actions-${DEPLOYMENT_MECHANISM}.sh

# When automation is changed to introduce steps,
# replace this line with the following line:
# deployment_action=$1
deployment_action=${1:-"setup_everything"}

case "$deployment_action" in
    "deploy_ses")
        deploy_ses
        ;;
    "deploy_caasp")
        deploy_caasp
        ;;
    "deploy_ccp_deployer")
        # CCP deployer is a node that will be used to control k8s cluster,
        # as we shouldn't do it on caasp cluster (microOS and others)
        deploy_ccp_deployer
        ;;
    "enroll_caasp_workers")
        enroll_caasp_workers
        ;;
    "setup_hosts")
        deploy_ses
        deploy_caasp
        deploy_ccp_deployer
        enroll_caasp_workers
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
    "deploy_airship")
        deploy_airship
        ;;
    "setup_everything")
        deploy_ses
        deploy_caasp
        deploy_ccp_deployer
        enroll_caasp_workers
        patch_upstream
        build_images
        deploy_osh
        ;;
    "teardown")
        teardown
        ;;
    "clean_k8s")
        clean_k8s
        ;;
    *)
        echo "Parameter unknown, read run.sh code."
        ;;
esac
