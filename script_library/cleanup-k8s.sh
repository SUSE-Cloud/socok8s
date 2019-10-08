#!/bin/bash

set -x

# TODO(evrardjp): Instead of removing ALL the charts, we should
# list all the charts to remove and delete them in parallel
# Delete helm charts releases
helm ls -a | awk 'NR > 1 {print $1 }' | xargs helm delete $line --purge

# Delete dangling deployments
for NS in openstack ceph; do
    kubectl get deployments -n ${NS} -o name | xargs kubectl delete -n ${NS} --ignore-not-found=true
done

# If deployments didn't kill everything, let's go deeper.
for NS in openstack ceph nfs; do
    kubectl get pods -n ${NS} -o name | xargs kubectl delete -n ${NS} --now --ignore-not-found=true
    kubectl get pdb -n ${NS} -o name | xargs kubectl delete -n ${NS}  --ignore-not-found=true
    kubectl get replicaset -n ${NS} -o name | xargs kubectl delete -n ${NS}  --ignore-not-found=true
    kubectl get job -n ${NS} -o name | xargs kubectl delete -n ${NS}  --ignore-not-found=true
done

# DO NOT USE clusterrolebinding, else you will delete all rolebindings, even the suse: and system: ones,
# even when scoped in the namespace.
kubectl get -n openstack rolebinding.rbac.authorization.k8s.io -o name | xargs kubectl -n openstack delete

# Remove extra data
kubectl delete clusterrolebinding PrivilegedRoleBinding
kubectl delete clusterrolebinding NonResourceUrlRoleBinding
kubectl delete clusterrolebinding ingress-kube-system-ingress

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

# ignore pv's for ucp if they still exist (kubectl get pv -n does not filter for namespace unfortunatelly)
for NS in openstack ceph docker-registry; do
    for pv in $(kubectl get pv -o jsonpath="{.items[?(@.spec.claimRef.namespace!=\"ucp\")].metadata.name}"); do
        kubectl delete pv $pv -n $NS || true;
    done
done

for NS in openstack ceph docker-registry; do
    for configmap in $(kubectl get configmap -n $NS | awk ' NR > 1 { print $1 ; }'); do
        kubectl delete configmap $configmap -n $NS ;
    done
done


echo "Removing suse socok8s files in /tmp"

pushd /tmp
  rm -f socok8s-*
  # TODO(evrardjp): When uniform filenames are used (starting with socok8s-) we can only keep the OSH templated files here.
  for  filename in suse-mariadb.yaml suse-rabbitmq.yaml suse-keystone.yaml suse-memcached.yaml suse-glance.yaml suse-horizon.yaml suse-cinder.yaml suse-ovs.yaml suse-libvirt.yaml suse-nova.yaml suse-ingress-kube-system.yaml suse-ingress-namespace.yaml suse-heat.yaml; do
      rm -f /tmp/$filename;
  done
popd
