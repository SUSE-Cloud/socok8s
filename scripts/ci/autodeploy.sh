#!/bin/bash
# This wraps the dev scripts to deploy the deploy tooling by making some of
# the actions automatic.

set -x

CI_SCRIPTS_PATH="$(dirname $(readlink -f "${BASH_SOURCE[0]}" ))"

pushd ${CI_SCRIPTS_PATH}/../../
    # Do not try to deploy on k8s if kubeconfig doesn't exist.
    source scripts/dev/set_kubeconfig.sh && \
    source scripts/setup-autodeployer.sh
