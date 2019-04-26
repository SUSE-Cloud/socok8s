Verify OpenStack operation
==========================

The cloud deployment includes Rally testing for the core Airship UCP and
Openstack services by default.

Your `deployer` node should now have a configuration file to use OpenStack
and have Openstack CLI installed.

To test if you can access the Openstack service via the vip and if the
services are functioning as expected, you can:

.. code-block:: console

   export OS_CLOUD='openstack'
   openstack endpoint list
   openstack server list
