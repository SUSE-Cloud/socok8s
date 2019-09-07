#!/usr/bin/env bash

set -o pipefail
set -o errexit

if [[ -f ${SOCOK8S_WORKSPACE}/kubeconfig ]]; then
    KUBECTLARGS="--kubeconfig ${SOCOK8S_WORKSPACE}/kubeconfig"
fi

unready=$(kubectl ${KUBECTLARGS:-} get nodes -o json | \
jq -r '.items[] |
  {
    node: .metadata.labels."kubernetes.io/hostname",
    ready: .status.conditions[]| select (.type == "Ready" and .status == "False")
  }
')

if [[ `echo ${unready} | tr -d '[:space:]' | wc -l` -gt 0 ]]; then
    echo "Some nodes are unready:"
    echo $unready | jq -r '.node'
    exit 1
else
    echo "All nodes ready."
fi
