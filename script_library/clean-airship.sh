#!/bin/bash

set -x

# default action is clean everything
clean_action=${1:-"clean_images_clean_openstack_clean_ucp_clean_rest"}

helm_delete_timeout=${2:-"300"}

if [[ ${clean_action} == *"clean_ucp"* ]]; then
    #delete ucp helm charts
    helm ls -a | grep ucp | awk 'NR >= 1 {print $1 }' | xargs -r helm delete --timeout ${helm_delete_timeout} $line --purge
fi

if [[ ${clean_action} == *"clean_rest"* ]]; then
    helm delete --timeout ${helm_delete_timeout} --purge airship-ingress-kube-system
fi

if [[ ${clean_action} == *"clean_openstack"* ]]; then
    #delete opennstack helm charts
    helm ls -a | grep openstack | awk 'NR >= 1 {print $1 }' | xargs -r helm delete --timeout ${helm_delete_timeout} $line --purge
fi

sleep 30

#in case the helm delete didn't do its job
if [[ ${clean_action} == *"clean_ucp"* ]]; then
    kubectl delete --all --ignore-not-found deployments -n ucp --grace-period=0 --force
    kubectl delete --all --ignore-not-found pods -n ucp --grace-period=0 --force
    kubectl delete --all --ignore-not-found pvc -n ucp --grace-period=0 --force
fi

#in case the helm delete didn't do its job
if [[ ${clean_action} == *"clean_openstack"* ]]; then
    kubectl delete --all --ignore-not-found deployments -n openstack --grace-period=0 --force
    kubectl delete --all --ignore-not-found pods -n openstack --grace-period=0 --force
    kubectl delete --all --ignore-not-found pvc -n openstack --grace-period=0 --force
fi

# delete pv only when pvc in both ucp and openstack are deleted first as same pv is shared
# between 2 namespaces and delete will be stuck if not all related pvc are deleted first.
if [[ ${clean_action} == *"clean_ucp"* && ${clean_action} == *"clean_openstack"*  ]]; then
    kubectl delete --all --ignore-not-found pv -n openstack --grace-period=0 --force
    kubectl delete --all --ignore-not-found pv -n ucp --grace-period=0 --force
fi

if [[ ${clean_action} == *"clean_rest"* ]]; then
    kubectl delete pod -n kube-system --ignore-not-found -l app=ingress-api,application=ingress,component=server --grace-period=0 --force
    kubectl delete pod -n kube-system --ignore-not-found -l application=ingress,component=error-pages --grace-period=0 --force

    kubectl delete configmap --namespace kube-system --ignore-not-found airship-ingress-kube-system-nginx-cluster --grace-period=0 --force
fi

if [[ ${clean_action} == *"clean_ucp"* ]]; then
    kubectl delete --all --ignore-not-found configmaps --namespace=ucp --grace-period=0 --force
    kubectl delete serviceaccount --all --ignore-not-found -n ucp
    kubectl delete secret --all --ignore-not-found -n ucp
    kubectl get jobs -n ucp -o name | xargs -r kubectl delete -n ucp --grace-period=0 --force
fi

if [[ ${clean_action} == *"clean_openstack"* ]]; then
    kubectl delete --all --ignore-not-found configmaps --namespace=openstack --grace-period=0 --force
    kubectl delete serviceaccount --all --ignore-not-found -n openstack
    kubectl delete secret --all --ignore-not-found -n openstack
    kubectl get jobs -n openstack -o name | xargs -r kubectl delete -n openstack --grace-period=0 --force
fi


if [[ ${clean_action} == *"clean_rest"* ]]; then
    kubectl delete sc --ignore-not-found general --grace-period=0 --force
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
    kubectl get -n openstack rolebinding.rbac.authorization.k8s.io -o name | xargs -r kubectl -n openstack delete
    kubectl delete namespace --ignore-not-found openstack
    kubectl label node --all openstack-control-plane-
    kubectl label node --all ucp-control-plane-
    kubectl label node --all openstack-compute-node-
    kubectl label node --all openvswitch-
    kubectl label node --all openstack-helm-node-class-
fi

if [[ ${clean_action} == *"clean_rest"* ]]; then
    kubectl delete namespace --ignore-not-found ceph --grace-period=0 --force
fi

if [[ ${clean_action} == *"clean_ucp"* ]]; then
    kubectl delete namespace --ignore-not-found ucp
    kubectl label node --all ucp-control-plane-
    kubectl label node --all kube-ingress-
fi

if [[ ${clean_action} == *"clean_images"* ]]; then
    # Need to keep them idempotent
    if [[ $(docker images -a | grep "airship" | wc -c) > 0 ]]; then
        docker images -a | grep "airship" | awk '{print $3}' | xargs -r docker rmi -f
    fi
fi

if [[ ${clean_action} == *"clean_ucp"* ]]; then
    sudo rm -rf /opt/airship
    sudo rm -rf ${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace/secrets
fi

if [[ ${clean_action} == *"clean_openstack"* ]]; then
    sudo rm -rf /opt/openstack
fi
