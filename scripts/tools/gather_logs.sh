#!/bin/bash
# Gather logs for the default cluster configured in KUBECONFIG
# for multiple namespaces.
# Namespaces can be provided in arguments else, the default list
# would be used.

namespacelistarg=$@
if [[ -z "${namespacelistarg}" ]]; then
  namespacelistarg="kube-system argocd"
fi

# TODO:Get app deploy status

function get_pod_logs {
  nspace=$1
  for line in $(kubectl -n ${nspace} get pods -o name); do
      echo "Gathering logs for $line"
      kubectl -n ${nspace} logs ${line} > ${line//\//-}.log || true
  done
}

for nspace in ${namespacelistarg}; do
  kubectl -n ${nspace} get all -o yaml > ${nspace}.yaml
  get_pod_logs ${nspace}
done
