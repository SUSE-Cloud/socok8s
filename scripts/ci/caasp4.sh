#!/bin/bash

set -x

CI_SCRIPTS_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

export TERRAFORM_APPLY_AUTOAPPROVE=yes

pushd ${CI_SCRIPTS_PATH}/../../
    source ${CI_SCRIPTS_PATH}/setup-ssh-agent.sh
    source scripts/dev/caasp4.sh ${1:-deploy}
