#!/bin/bash

set -x

helm_delete_timeout=${1:-"300"}
deep_clean=${2:-"no"}

delete_helm_charts(){
  #defaulting to non empty to avoid mistakes
  whattodelete=${1:-"deletethis"}
  helm ls -a | grep $whattodelete | awk 'NR >= 1 {print $1 }' | xargs -r helm delete --timeout ${helm_delete_timeout} --purge $line
}

delete_folder_if_exists() {
  #defaulting to non empty to avoid mistakes
  folder=${1:-"deletethis"}
  if [[ -d $folder ]]; then
      sudo rm -rf $folder
  fi
}

# Purge helm charts
delete_helm_charts ucp
delete_helm_charts airship-ingress-kube-system
delete_helm_charts openstack

sleep 30

# Delete remnants
kubectl delete namespace openstack --grace-period=0 --force
kubectl delete namespace ucp --grace-period=0 --force
kubectl delete namespace ceph --grace-period=0 --force

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

# Deep clean into k8s system, containers cache, and user files.
if [[ ${deep_clean} == "yes" ]]; then
    kubectl delete pod -n kube-system --ignore-not-found --grace-period=0 \
      -l app=ingress-api,application=ingress,component=server --force
    kubectl delete pod -n kube-system --ignore-not-found --grace-period=0 \
      -l application=ingress,component=error-pages --force
    kubectl delete configmap -n kube-system --grace-period=0 --ignore-not-found \
      airship-ingress-kube-system-nginx-cluster --force
    #kubectl delete sc --ignore-not-found general --grace-period=0 --force
    #kubectl delete clusterrolebinding --ignore-not-found PrivilegedRoleBinding
    #kubectl delete clusterrolebinding --ignore-not-found NonResourceUrlRoleBinding
    if [[ $(docker images -a | grep "airship" | wc -c) > 0 ]]; then
        docker images -a | grep "airship" | awk '{print $3}' | xargs -r docker rmi -f
    fi
    if [[ -d ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace/ ]]; then
        rm -rf ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace/
    fi
    delete_folder_if_exists "/etc/libvirt/qemu/"
fi

