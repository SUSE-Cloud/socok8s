#!/bin/bash
## This ensures previously created kubeconfig is loaded by setting
## KUBECONFIG env var.

set -o pipefail
set -o errexit
set -o nounset

# Will get some very early failure if some var is unset.
echo "Kubeconfig location is ${SOCOK8S_WORKSPACE}/kubeconfig"

if [[ ! -f ${SOCOK8S_WORKSPACE}/kubeconfig ]]; then
    echo "Kubeconfig not found, exiting"
    exit 1
else
    export KUBECONFIG=${SOCOK8S_WORKSPACE}/kubeconfig
    echo "KUBECONFIG set to ${KUBECONFIG}"
fi
