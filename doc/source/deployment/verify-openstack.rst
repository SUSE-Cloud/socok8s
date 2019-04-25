Verify OpenStack operation
==========================

Your `deployer` node should now have a configuration file to use OpenStack.

Test it:

.. code-block:: console

   export OS_CLOUD='openstack_helm'
   openstack endpoint list
   openstack server list
