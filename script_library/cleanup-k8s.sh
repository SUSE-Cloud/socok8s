#!/bin/bash

set -x

for line in $(helm ls -a | awk 'NR > 1 {print $1 }'); do
    helm delete $line --purge;
done

reserved_namespaces=" kube-system kube-public default "
deploy_namespaces=()
for namespace_used in $(kubectl get namespaces | awk ' NR > 1 { print $1 ; }'); do
    if [[ ! $reserved_namespaces =~ $namespace_used ]]; then
        deploy_namespaces+=($namespace_used)
    fi
done

echo "deploy namespaces are: ${deploy_namespaces[@]}"

for NS in "${deploy_namespaces[@]}"; do
   helm ls --namespace $NS --short | xargs -r -L1 -P2 helm delete --purge
done

rm -rf /var/lib/openstack-helm/*
rm -rf /var/lib/nova/*
#rm -rf /var/lib/libvirt/*
rm -rf /etc/libvirt/qemu/*
findmnt --raw | awk '/^\/var\/lib\/kubelet\/pods/ { print $1 }' | xargs -r -L1 -P16 sudo umount -f -l

deleted_items=()
echo "deleting persistent volume claims in namespaces: ${deploy_namespaces[@]}"
for NS in "${deploy_namespaces[@]}"; do
    for pvc in $(kubectl get pvc -n $NS | awk ' NR > 1 { print $1 ; }'); do
        kubectl delete pvc $pvc -n $NS;
        deleted_items+=("$NS:$pvc")
    done
done
echo "deleted persistent volume claims : ${deleted_items[@]}"

deleted_items=()
echo "deleting persistent volumes in namespaces: ${deploy_namespaces[@]}"
for NS in "${deploy_namespaces[@]}"; do
    for pv in $(kubectl get pv -n $NS | awk ' NR > 1 { print $1 ; }'); do
        kubectl delete pv $pv -n $NS || true;
        deleted_items+=("$NS:$pv")
    done
done
echo "deleted persistent volumes : ${deleted_items[@]}"

deleted_items=()
echo "deleting configmaps in namespaces: ${deploy_namespaces[@]}"
for NS in "${deploy_namespaces[@]}"; do
    for configmap in $(kubectl get configmap -n $NS | awk ' NR > 1 { print $1 ; }'); do
        kubectl delete configmap $configmap -n $NS;
        deleted_items+=("$NS:$configmap")
    done
done
echo "deleted configmaps : ${deleted_items[@]}"

echo "Removing suse socok8s files in /tmp"

for filename in suse-mariadb.yaml suse-rabbitmq.yaml suse-memcached.yaml suse-glance.yaml suse-cinder.yaml suse-ovs.yaml suse-libvirt.yaml suse-nova.yaml suse-ingress-kube-system.yaml suse-ingress-namespace.yaml; do
    rm -f /tmp/$filename;
done
