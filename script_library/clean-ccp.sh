#delete ucp helm charts
helm delete --purge airship-armada
helm delete --purge airship-barbican
helm delete --purge airship-deckhand
helm delete --purge airship-ingress-ucp
helm delete --purge airship-keystone-ucp
helm delete --purge airship-mariadb
helm delete --purge airship-memcached
helm delete --purge airship-postgresql
helm delete --purge airship-rabbitmq
helm delete --purge airship-shipyard
helm delete --purge airship-ingress-kube-system

#delete opennstack helm charts
helm delete --purge airship-glance
helm delete --purge airship-glance-rabbitmq
helm delete --purge airship-keystone
helm delete --purge airship-keystone-rabbitmq
helm delete --purge airship-libvirt
helm delete --purge airship-neutron
helm delete --purge airship-neutron-rabbitmq
helm delete --purge airship-nova
helm delete --purge airship-nova-rabbitmq
helm delete --purge airship-openstack-ingress-controller
helm delete --purge airship-openstack-mariadb
helm delete --purge airship-openstack-memcached
helm delete --purge airship-openvswitch
helm delete --purge airship-heat-rabbitmq
helm delete --purge airship-heat
#TODO add this when we provision the ceph config as part of airship flow. 
#helm delete --purge airship-openstack-ceph-config
sleep 30
kubectl delete --all deployments -n ucp
kubectl delete --all deployments -n openstack
# make sure all pods are deleted especially test pods
kubectl delete --all pods -n ucp
kubectl delete --all pods -n openstack
kubectl delete --all pvc -n ucp
kubectl delete --all pvc -n openstack
kubectl delete --all pv -n ucp
kubectl delete --all pv -n openstack
kubectl delete --all configmaps --namespace=ucp

#TODO can't delete all ceph-etc config until it is part of airship flow
#kubectl delete --all configmaps --namespace=openstack
kubectl delete configmap airship-openstack-ingress-controller-nginx -n openstack
kubectl delete configmap airship-openstack-mariadb-airship-openstack-mariadb-mariadb-ingress -n openstack
kubectl delete configmap airship-openstack-mariadb-mariadb-state -n openstack

