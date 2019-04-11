#!/bin/bash

# m4_ignore(
echo "This is just a parsing library template, not the library - pass the parent script 'ass.m4' to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.8.0
# ARG_POSITIONAL_SINGLE([command], [The command you want to run.], [setup_everything])
# ARG_TYPE_GROUP_SET([commands], [COMMAND], [command], [add_compute,build_images,deploy_airship,deploy_osh,clean_airship,clean_airship_not_images,clean_k8s,deploy_caasp,deploy_ccp_deployer,deploy_ses,enroll_caasp_workers,patch_upstream,setup_airship,setup_caasp_workers_for_openstack,setup_everything,setup_hosts,setup_openstack,teardown,update_airship_osh], [index])
# ARG_USE_ENV([DEPLOYMENT_MECHANISM], [openstack], [The deployment type you want])
# ARG_USE_ENV([USE_ARA], [False], [Use ARA?])

# ARG_DEFAULTS_POS
# ARG_HELP([This script is used to bootstrap the socok8s dev env. To build the documentation, run tox -edocs])
# ARGBASH_GO
