#!/bin/bash

set -x

for line in $(helm ls -a | awk 'NR > 1 {print $1 }'); do
    helm delete $line --purge;
done

for NS in openstack ceph nfs; do
   helm ls --namespace $NS --short | xargs -r -L1 -P2 helm delete --purge
done

rm -rf /var/lib/openstack-helm/*
rm -rf /var/lib/nova/*
#rm -rf /var/lib/libvirt/*
rm -rf /etc/libvirt/qemu/*
findmnt --raw | awk '/^\/var\/lib\/kubelet\/pods/ { print $1 }' | xargs -r -L1 -P16 sudo umount -f -l

for NS in openstack ceph docker-registry; do
    for pvc in $(kubectl get pvc -n $NS | awk ' NR > 1 { print $1 ; }'); do
        kubectl delete pvc $pvc -n $NS ;
    done
done

for NS in openstack ceph docker-registry; do
    for pv in $(kubectl get pv -n $NS | awk ' NR > 1 { print $1 ; }'); do
        kubectl delete pv $pv -n $NS || true;
    done
done

for NS in openstack ceph docker-registry; do
    for configmap in $(kubectl get configmap -n $NS | awk ' NR > 1 { print $1 ; }'); do
        kubectl delete configmap $configmap -n $NS ;
    done
done

echo "Removing dangling k8s jobs"
kubectl get jobs -n openstack  | awk 'NR>1 {system("kubectl delete jobs -n openstack "$1" --grace-period=0 --force --ignore-not-found=true")}'

echo "Removing dangling k8s replicasets"
kubectl get replicasets -n openstack  | awk 'NR>1 {system("kubectl delete replicasets -n openstack "$1" --grace-period=0 --force --ignore-not-found=true")}'

echo "Removing dangling k8s PodDisruptionBudget"
kubectl get pdb -n openstack  | awk 'NR>1 {system("kubectl delete pdb -n openstack "$1" --grace-period=0 --force --ignore-not-found=true")}'


echo "Removing dangling k8s pods"
kubectl get pods -n openstack  | awk 'NR>1 {system("kubectl delete pods -n openstack "$1" --grace-period=0 --force --ignore-not-found=true")}'

echo "Removing dangling k8s daemonsets"
kubectl get daemonsets -n openstack  | awk 'NR>1 {system("kubectl delete daemonsets -n openstack "$1" --grace-period=0 --force --ignore-not-found=true")}'

echo "Removing dangling k8s replicasets"
kubectl get deployments -n openstack  | awk 'NR>1 {system("kubectl delete deployments -n openstack "$1" --grace-period=0 --force --ignore-not-found=true")}'

echo "Removing suse socok8s files in /tmp"

for filename in suse-mariadb.yaml suse-rabbitmq.yaml suse-keystone.yaml suse-memcached.yaml suse-glance.yaml suse-horizon.yaml suse-cinder.yaml suse-ovs.yaml suse-libvirt.yaml suse-nova.yaml suse-ingress-kube-system.yaml suse-ingress-namespace.yaml suse-heat.yaml; do
    rm -f /tmp/$filename;
done
