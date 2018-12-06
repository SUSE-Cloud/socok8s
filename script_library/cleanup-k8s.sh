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


echo "Removing suse socok8s files in /tmp"

for filename in suse-mariadb.yaml suse-rabbitmq.yaml suse-memcached.yaml suse-glance.yaml suse-cinder.yaml suse-ovs.yaml suse-libvirt.yaml suse-nova.yaml suse-ingress-kube-system.yaml suse-ingress-namespace.yaml; do
    rm -f /tmp/$filename;
done
