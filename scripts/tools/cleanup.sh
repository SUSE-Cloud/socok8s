#!/bin/bash

set -x

TOOLS_SCRIPTS_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

delete_folder_if_exists() {
  #defaulting to non empty to avoid mistakes
  folder=${1:-"deletethis"}
  if [[ -d $folder ]]; then
      rm -rf $folder
  fi
}


# Remove all apps
# Triggers finalizers of argocd, to cleanup the app contents.
kubectl get -n argocd apps -o name | xargs kubectl delete -n argocd

# Delete remnants.
# This should wait for previous step.
pushd ${TOOLS_SCRIPTS_PATH}/../../
    kubectl delete -k argocd-install
popd

kubectl label node --all openstack-control-plane-
kubectl label node --all ucp-control-plane-
kubectl label node --all openstack-compute-node-
kubectl label node --all openvswitch-
kubectl label node --all openstack-helm-node-class-

delete_folder_if_exists "/opt/airship"
delete_folder_if_exists "/opt/openstack"
delete_folder_if_exists "/var/lib/openstack-helm"
delete_folder_if_exists "/var/lib/nova"
rm -f /tmp/socok8s-*

## Deep clean into k8s system, containers cache, and user files.
#if [[ ${deep_clean} == "yes" ]]; then
#    kubectl delete pod -n kube-system --ignore-not-found --grace-period=0 \
#      -l app=ingress-api,application=ingress,component=server --force
#    kubectl delete pod -n kube-system --ignore-not-found --grace-period=0 \
#      -l application=ingress,component=error-pages --force
#    kubectl delete configmap -n kube-system --grace-period=0 --ignore-not-found \
#      airship-ingress-kube-system-nginx-cluster --force
#    #kubectl delete sc --ignore-not-found general --grace-period=0 --force
#    #kubectl delete clusterrolebinding --ignore-not-found PrivilegedRoleBinding
#    #kubectl delete clusterrolebinding --ignore-not-found NonResourceUrlRoleBinding
#    if [[ $(docker images -a | grep "airship" | wc -c) > 0 ]]; then
#        docker images -a | grep "airship" | awk '{print $3}' | xargs -r docker rmi -f
#    fi
#    if [[ -d ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace/ ]]; then
#        rm -rf ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace/
#    fi
#    delete_folder_if_exists "/etc/libvirt/qemu/"
#fi

