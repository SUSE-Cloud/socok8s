=========================
Select OpenStack services
=========================

SUSE Containerized OpenStack currently deploys OpenStack Cinder,
Glance, Heat, Horizon, Keystone, Neutron, Nova.

SUSE Containerized OpenStack deployment will automatically add the following
host rules to the /etc/hosts file on the deployer:

.. code-block:: console

   172.16.1.100 identity.openstack.svc.cluster.local
   172.16.1.100 image.openstack.svc.cluster.local
   172.16.1.100 volume.openstack.svc.cluster.local
   172.16.1.100 compute.openstack.svc.cluster.local
   172.16.1.100 network.openstack.svc.cluster.local
   172.16.1.100 dashboard.openstack.svc.cluster.local
   172.16.1.100 nova-novncproxy.openstack.svc.cluster.local
   172.16.1.100 orchestration.openstack.svc.cluster.local

You can access OpenStack service public endpoints using the host names listed
in the /etc/hosts directory. For example, access OpenStack Horizon (dashboard)
at http://dashboard.openstack.svc.cluster.local.

You can access Horizon and other OpenStack service APIs on a different system
by adding the entries above to DNS or /etc/hosts on that system.
