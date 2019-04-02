#!/bin/bash

set -x

# default action is clean everything
clean_action=${1:-"clean_images_clean_openstack_clean_ucp_clean_rest"}

if [[ ${clean_action} == *"clean_ucp"* ]]; then
    #delete ucp helm charts
    helm ls -a | grep ucp | awk 'NR >= 1 {print $1 }' | xargs helm delete $line --purge
fi

if [[ ${clean_action} == *"clean_rest"* ]]; then
    helm delete --purge airship-ingress-kube-system
fi

if [[ ${clean_action} == *"clean_openstack"* ]]; then
    #delete opennstack helm charts
    helm ls -a | grep openstack | awk 'NR >= 1 {print $1 }' | xargs helm delete $line --purge
fi

sleep 30

#in case the helm delete didn't do its job
if [[ ${clean_action} == *"clean_ucp"* ]]; then
    kubectl delete --all --ignore-not-found --timeout=300s deployments -n ucp
    kubectl delete --all --ignore-not-found --timeout=300s pods -n ucp
    kubectl delete --all --ignore-not-found --timeout=300s pvc -n ucp
fi

#in case the helm delete didn't do its job
if [[ ${clean_action} == *"clean_openstack"* ]]; then
    kubectl delete --all --ignore-not-found deployments -n openstack
    kubectl delete --all --ignore-not-found --timeout=300s pods -n openstack
    kubectl delete --all --ignore-not-found --timeout=300s pvc -n openstack
fi

# delete pv only when pvc in both ucp and openstack are deleted first as same pv is shared
# between 2 namespaces and delete will be stuck if not all related pvc are deleted first.
if [[ ${clean_action} == *"clean_ucp"* && ${clean_action} == *"clean_openstack"*  ]]; then
    kubectl delete --all --ignore-not-found --timeout=300s pv -n openstack
    kubectl delete --all --ignore-not-found --timeout=300s pv -n ucp
fi

if [[ ${clean_action} == *"clean_rest"* ]]; then
    kubectl delete pod -n kube-system --ignore-not-found -l app=ingress-api,application=ingress,component=server
    kubectl delete pod -n kube-system --ignore-not-found -l application=ingress,component=error-pages

    kubectl --ignore-not-found delete configmap --namespace kube-system airship-ingress-kube-system-nginx-cluster
fi

if [[ ${clean_action} == *"clean_ucp"* ]]; then
    kubectl delete --all --ignore-not-found configmaps --namespace=ucp
    kubectl delete serviceaccount --all --ignore-not-found -n ucp
    kubectl delete secret --all --ignore-not-found -n ucp
fi

if [[ ${clean_action} == *"clean_openstack"* ]]; then
    kubectl delete --all --ignore-not-found configmaps --namespace=openstack
    kubectl delete serviceaccount --all --ignore-not-found -n openstack
    kubectl delete secret --all --ignore-not-found -n openstack
fi


if [[ ${clean_action} == *"clean_rest"* ]]; then
    kubectl delete sc --ignore-not-found general
    kubectl delete serviceaccount --all --ignore-not-found -n ceph
    kubectl delete secret --all --ignore-not-found -n ceph
fi


if [[ ${clean_action} == *"clean_rest"* ]]; then
    # Remove extra data
    kubectl delete clusterrolebinding --ignore-not-found PrivilegedRoleBinding
    kubectl delete clusterrolebinding --ignore-not-found NonResourceUrlRoleBinding
fi

if [[ ${clean_action} == *"clean_openstack"* ]]; then
    # DO NOT USE clusterrolebinding, else you will delete all rolebindings, even the suse: and system: ones,
    # even when scoped in the namespace.
    kubectl get -n openstack rolebinding.rbac.authorization.k8s.io -o name | xargs kubectl -n openstack delete
    kubectl get jobs -n openstack -o name | xargs kubectl delete -n openstack
    kubectl delete namespace --ignore-not-found openstack
fi

if [[ ${clean_action} == *"clean_rest"* ]]; then
    kubectl delete namespace --ignore-not-found ceph
fi

if [[ ${clean_action} == *"clean_ucp"* ]]; then
    kubectl get jobs -n ucp -o name | xargs kubectl delete -n ucp
    kubectl delete namespace --ignore-not-found ucp
fi

if [[ ${clean_action} == *"clean_images"* ]]; then
    # Need to keep them idempotent
    if [[ $(docker images -a | grep "airship" | wc -c) > 0 ]]; then
        docker images -a | grep "airship" | awk '{print $3}' | xargs docker rmi -f
    fi
fi

if [[ ${clean_action} == *"clean_ucp"* ]]; then
    sudo rm -rf /opt/airship-*
    sudo rm -rf ${ANSIBLE_RUNNER_DIR}/secrets
fi

if [[ ${clean_action} == *"clean_openstack"* ]]; then
    sudo rm -rf /opt/openstack-helm*
fi
