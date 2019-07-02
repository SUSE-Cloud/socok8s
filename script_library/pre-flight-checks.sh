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

    # Needed for the Ansible ARA check step
    if [ ! -d ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace ]; then
        echo "Creating workspace directory at ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace"
        mkdir -p ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace
    fi
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

check_caasp4_skuba_available(){
    echo "Checking for CaaSP 4 that SUSE/skuba is available"
    if ! [ -d submodules/skuba ]; then
        echo "submodules/skuba directory not available. Can not deploy CaaSP 4"
        exit
    fi
}
check_caasp4_terraform_available(){
    echo "Checking for CaaSP 4 that terraform is available"
    command -v ${TERRAFORM_BINARY_PATH} 1> /dev/null
    if [ $? -ne 0 ]; then
        echo "${TERRAFORM_BINARY_PATH} executable not in \$PATH. Can not deploy CaaSP 4"
        exit
    fi
}
check_openstack_environment_is_ready_for_deploy (){
    echo "Running OpenStack pre-flight checks"
    check_openstack_env_vars_set #Do not try to grep without ensuring the vars are set
    type -p openstack > /dev/null  || (echo "Please install openstack and heat CLI in your PATH"; exit 5)
    openstack stack delete --help > /dev/null || (echo "Please install heat client in your PATH"; exit 6)
    openstack keypair list | grep ${KEYNAME} > /dev/null || (echo "keyname not found. export KEYNAME=" && exit 2)
}

check_python_requirement (){
    if ! python3 -c "import ${1}" > /dev/null 2>&1; then
        echo "Missing python requirement ${1}."
        echo "Install from your system packages or set SOCOK8S_USE_VIRTUALENV=True to install requirements into a virtualenv."
        exit 1
    fi
}

check_ansible_requirements (){
    if [[ "${SOCOK8S_USE_VIRTUALENV:-False}" == "True" ]]; then
        install_ansible
    fi
    # Ansible is required
    if ! type -p ansible-playbook > /dev/null 2>&1; then
        echo "Ansible is not installed."
        echo "Install from your system packages or set SOCOK8S_USE_VIRTUALENV=True to install ansible and other requirements into a virtualenv."
        exit 1
    fi
    # We need ansible version 2.7 minimum
    if [[ $(ansible --version | awk 'NR==1 { gsub(/[.]/,""); print substr($2,0,2); }' ) -lt "27" ]]; then
        echo "Insufficent version of ansible: 2.7 or greater is required."
        echo "Install from your system packages or set SOCOK8S_USE_VIRTUALENV=True to install ansible and other requirements into a virtualenv."
        exit 1
    fi
    # In the ansible venv, we should have jmespath and netaddr
    check_python_requirement 'jmespath'
    check_python_requirement 'netaddr'
    check_python_requirement 'openstack'
    # If ara is requested
    if [[ ${USE_ARA:-False} == "True" ]]; then
        check_python_requirement 'ara'
        python3 -m ara.setup.env > ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace/ara.rc
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
    type -p jq > /dev/null || (echo "Please install jq"; exit 7)
}

validate_cli_options (){
   if [ -z ${1+x} ];then
       echo "Please provide valid option."
       exit 1
   fi

   OPTIONS=(deploy test update_openstack add_openstack_compute remove_openstack_compute remove_deployment deploy_network deploy_ses deploy_caasp deploy_caasp4 deploy_caasp4 configure_ccp_deployer deploy_ccp_deployer enroll_caasp_workers patch_upstream build_images deploy_osh setup_caasp_workers_for_openstack setup_hosts setup_openstack setup_airship setup_everything teardown clean_caasp4 clean_k8s clean_airship_not_images gather_logs)

   action=$1
   isvalid=false
   for value in ${OPTIONS[@]} ; do
      if [[ "$value" == "$action" ]]; then
         isvalid=true
         break;
      fi
   done
   if [[ "$isvalid" == "false" ]]; then
      echo "Invalid option, Check --help for valid options"
      exit 1
   fi
   return 0
}

if [ -z ${1+x} ]; then
    echo "Please provide a preflight check name. No preflight checks given"
else
    $1
fi
