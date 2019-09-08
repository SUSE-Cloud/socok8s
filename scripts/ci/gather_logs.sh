#!/bin/bash
# This wraps the tools scripts which gather logs for the default
# kubeconfig.

CI_SCRIPTS_PATH="$(dirname "$(readlink -f "${0}")")"

pushd ${CI_SCRIPTS_PATH}/../../
    # Do not gather kubernetes logs if kubeconfig doesn't exist.
    source scripts/dev/set_kubeconfig.sh && \
    source scripts/tools/gather_logs.sh
