=========================
Select OpenStack services
=========================

SUSE Containerized OpenStack currently deploys OpenStack Cinder,
Glance, Heat, Horizon, Keystone, Neutron, Nova.

SUSE Containerized OpenStack deployment will automatically add the following
host rules to the /etc/hosts file on the deployer:

.. code-block:: console

   10.10.10.10 identity.openstack.svc.cluster.local
   10.10.10.10 image.openstack.svc.cluster.local
   10.10.10.10 volume.openstack.svc.cluster.local
   10.10.10.10 compute.openstack.svc.cluster.local
   10.10.10.10 network.openstack.svc.cluster.local
   10.10.10.10 dashboard.openstack.svc.cluster.local
   10.10.10.10 nova-novncproxy.openstack.svc.cluster.local
   10.10.10.10 orchestration.openstack.svc.cluster.local

You can access OpenStack service public endpoints using the host names listed
in the /etc/hosts directory. For example, access OpenStack Horizon (dashboard)
at http://dashboard.openstack.svc.cluster.local.

You can access Horizon and other OpenStack service APIs from a different system
by adding the entries above to DNS or /etc/hosts on that system.
