#!/bin/bash

set -o errexit

SSH_AUTH_SOCK=/tmp/shared-ssh-agent

if [[ ! -S ${SSH_AUTH_SOCK} ]]; then
    echo "Starting new agent"
    eval $(ssh-agent -s -a ${SSH_AUTH_SOCK})
else
    export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}
fi

if [[ `ssh-add -L | grep "no identities" | wc -l` -eq 1 ]]; then
    echo "No keys, adding some"
    ssh-add
fi
