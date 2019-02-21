#delete ucp helm charts

helm ls -a | grep ucp | awk 'NR >= 1 {print $1 }' | xargs helm delete $line --purge

#helm delete --purge airship-armada
#helm delete --purge airship-barbican
#helm delete --purge airship-deckhand
#helm delete --purge airship-ingress-ucp
#helm delete --purge airship-keystone-ucp
#helm delete --purge airship-mariadb
#helm delete --purge airship-memcached
#helm delete --purge airship-postgresql
#helm delete --purge airship-rabbitmq
#helm delete --purge airship-shipyard
helm delete --purge airship-ingress-kube-system

#delete opennstack helm charts
helm ls -a | grep openstack | awk 'NR >= 1 {print $1 }' | xargs helm delete $line --purge

#helm delete --purge airship-glance
#helm delete --purge airship-glance-rabbitmq
#helm delete --purge airship-keystone
#helm delete --purge airship-keystone-rabbitmq
#helm delete --purge airship-libvirt
#helm delete --purge airship-neutron
#helm delete --purge airship-neutron-rabbitmq
#helm delete --purge airship-nova
#helm delete --purge airship-nova-rabbitmq
#helm delete --purge airship-openstack-ingress-controller
#helm delete --purge airship-openstack-mariadb
#helm delete --purge airship-openstack-memcached
#helm delete --purge airship-openvswitch
#helm delete --purge airship-heat-rabbitmq
#helm delete --purge airship-heat
#helm delete --purge airship-openstack-ceph-config

sleep 30

#in case the helm delete didn't do its job
kubectl delete --all deployments -n ucp
kubectl delete --all deployments -n openstack
# make sure all pods are deleted especially test pods
kubectl delete --all pods -n ucp
kubectl delete --all pods -n openstack
kubectl delete pod -n kube-system --ignore-not-found -l app=ingress-api,application=ingress,component=server
kubectl delete pod -n kube-system --ignore-not-found -l application=ingress,component=error-pages

kubectl delete --all pvc -n ucp
kubectl delete --all pvc -n openstack
kubectl delete --all pv -n ucp
kubectl delete --all pv -n openstack

kubectl delete --all configmaps --namespace=ucp
kubectl delete --all configmaps --namespace=openstack

kubectl delete sc --ignore-not-found general
kubectl delete secret --all -n openstack
kubectl delete secret --all -n ucp
kubectl delete secret --all -n ceph


# DO NOT USE clusterrolebinding, else you will delete all rolebindings, even the suse: and system: ones,
# even when scoped in the namespace.
kubectl get -n openstack rolebinding.rbac.authorization.k8s.io -o name | xargs kubectl -n openstack delete

# Remove extra data
kubectl delete clusterrolebinding --ignore-not-found PrivilegedRoleBinding
kubectl delete clusterrolebinding --ignore-not-found NonResourceUrlRoleBinding

# Need to keep them idempotent
if [[ $(docker images -a | grep "airship" | wc -c) > 0 ]]; then
    docker images -a | grep "airship" | awk '{print $3}' | xargs docker rmi -f
fi

