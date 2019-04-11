#!/bin/bash
#
# This is a wrapper to the real code in _run.sh
# This run.sh script is auto generated by the Makefile using
# argbash templating.  This allows us to generate bash completion,
# documentation and argument parsing and an argument help output.
#
# https://argbash.io/
#
#
# DEFINE_SCRIPT_DIR
# ARG_OPTIONAL_BOOLEAN([quiet], [q], [suppress noisy output], [off])
# ARG_OPTIONAL_BOOLEAN([pre], [p], [Run preflight only], [off])
# ARG_POSITIONAL_SINGLE([command], [The command you want to run.], [setup_everything])
# ARG_TYPE_GROUP_SET([commands], [COMMAND], [command], [add_compute,build_images,deploy_airship,deploy_osh,clean_airship,clean_airship_not_images,clean_k8s,deploy_caasp,deploy_ccp_deployer,deploy_ses,enroll_caasp_workers,patch_upstream,setup_airship,setup_caasp_workers_for_openstack,setup_everything,setup_hosts,setup_openstack,teardown,update_airship_osh], [index])
#
# ARG_USE_ENV([DEPLOYMENT_MECHANISM], [openstack], [The deployment type you want])
# ARG_USE_ENV([SOCOK8S_DEVELOPER_MODE], [False], [Enable SOCOK8S script developer mode])
# ARG_USE_ENV([USE_ARA], [False], [Use ARA?])
#
# ARG_VERSION([echo $0 v0.1])
# ARG_HELP([This script is used to bootstrap the socok8s dev env. To build the documentation, run tox -edocs], [This is a longer description that should get filled in.])
# ARGBASH_SET_INDENT([  ])
# ARGBASH_GO


# [ <-- needed because of Argbash

# printf "Value of '%s': %s\\n" 'command' "$_arg_command"
#

if [ "$_arg_quiet" = "on" ]; then
    QUIET="-q"
fi
. "$script_dir/run.sh"

# ] <-- needed because of Argbash
