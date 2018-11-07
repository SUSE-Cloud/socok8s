#!/bin/bash

USER_VARIABLES_LOCATION=~/suse-osh-deploy/user_variables.yml
if [ ! -f ${USER_VARIABLES_LOCATION} ]; then
    export ansible_playbook="ansible-playbook "
else
    echo "Loading user_variables..."
    export ansible_playbook="ansible-playbook -e @${USER_VARIABLES_LOCATION} "
fi
