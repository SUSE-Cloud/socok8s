#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset

SCRIPTS_PATH="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"

pushd ${SCRIPTS_PATH}/../
    kubectl apply -k argocd-install
    echo "The password for argoCD is:" $(kubectl get -n argocd pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep argocd-server)
    # The server might take time to start and accept "Apps". Wait a little, until the pods are ready.
    let podretries=20
    while [[ "$(kubectl get pods -n argocd | awk '/argocd-server/ {print $3}')" != "Running" ]]; do
        if (( ${podretries} == 0 )); then
            echo "Argo server failed to come up on time"
            exit 1
        fi
        sleep 5
        let podretries--
    done

    let crdretries=20
    while [[ "$(kubectl get customresourcedefinition.apiextensions.k8s.io applications.argoproj.io \
             -o jsonpath='{.status.conditions[?(@.reason=="NoConflicts")].status}' )" != "True" ]]; do
        if (( ${crdretries} == 0 )); then
            echo "ArgoCD App CRD fail to come up"
            exit 1
        fi
        sleep 5
        let crdretries--
    done

    kubectl apply -f argocd-install/first-app--the-auto-deployer.yaml
