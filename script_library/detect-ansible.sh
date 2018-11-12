#!/bin/bash

BASEDIR=$(dirname "$0")

USER_VARIABLES_LOCATION=~/suse-osh-deploy/user_variables.yml
if [ -f $BASEDIR/user_variables.yml ]; then
    USER_VARIABLES_LOCATION=$BASEDIR/user_variables.yml
fi

if [ ! -f ${USER_VARIABLES_LOCATION} ]; then
    export ansible_playbook="ansible-playbook "
else
    echo "Loading user_variables..."
    export ansible_playbook="ansible-playbook -e @${USER_VARIABLES_LOCATION} "
fi
