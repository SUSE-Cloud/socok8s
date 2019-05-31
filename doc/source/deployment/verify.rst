.. _verifyinstallation:

Verify OpenStack Operation
==========================

The cloud deployment includes Rally testing for the core Airship UCP and
OpenStack services by default.

At this point, your `Deployer` node should have an OpenStack configuration file,
and the OpenStackClient (OSC) command line interface should be installed.

Test access to the OpenStack service via the VIP and determine that the OpenStack
services are functioning as expected by running the following commands:

.. code-block:: console

   export OS_CLOUD='openstack'
   openstack endpoint list
   openstack server list
