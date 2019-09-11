#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset

SCRIPTS_PATH="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"

pushd ${SCRIPTS_PATH}/../
    kubectl apply -k argocd-install
    echo "The password for argoCD is:" $(kubectl get -n argocd pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep argocd-server)
