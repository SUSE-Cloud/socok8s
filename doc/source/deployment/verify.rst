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

OpenStack Tempest Testing
=========================

After the deployment of SUSE Containerized OpenStack has completed, it is possible to run
OpenStack Tempest tests against the core services in the deployment using the `run.sh` script.
Before running Tempest tests, it will be necessary to manually configure OpenStack network
resources and provide a few configuration parameters in the ${WORKDIR}/env/extravars file.

Setting Up An External Network And Subnet in OpenStack
------------------------------------------------------

To set up an external network and subnet in OpenStack, the following commands can be run from a
shell on the `Deployer` node.

.. code-block:: console

   export OS_CLOUD=openstack
   openstack network create --provider-network-type flat --provider-physical-network external \ 
     --external public
   openstack subnet create --network public --subnet-range 192.168.100.0/24 --allocation-pool \
     start=192.168.100.10,end=192.168.100.200 --gateway 192.168.100.1 --no-dhcp public-subnet

.. note::

   The external public network is expected to be able to reach the internet. The above values 
   will vary based on your network environment. 

Once the public network and subnet have been created in OpenStack, their names will need to be
made known to Tempest by adding the following keys in the ${WORKDIR}/env/extravars file:

.. code-block:: yaml

   openstack_external_network_name: "public"
   openstack_external_subnet_name: "public-subnet"

Tempest will also need to know the CIDR block from which to allocate project IPv4 subnets. This
value should be specified with the following key in the extravars file:

.. code-block:: yaml

   openstack_project_network_cidr: "192.0.4.0/24"

Configuring Tempest Test Parameters
-----------------------------------

By default, the implementation of Tempest in SUSE Containerized OpenStack will run smoke tests
for all deployed services including compute, identity, image, network, and volume, using 4
workers. 

To modify the number of workers, add the following key with a value of your choosing to the
extravars file:

.. code-block:: yaml

   tempest_workers: 6

To disable tests for specific OpenStack components, any or all of the following keys can be
added to the extravars file:

.. code-block:: yaml

   tempest_enable_cinder_service: false
   tempest_enable_glance_service: false
   tempest_enable_nova_service: false
   tempest_enable_neutron_service: false

To run all Tempest tests instead of just smoke tests, add the following key to the extravars
file:

.. code-block:: yaml

   tempest_test_type: "all"

Using a Blacklist
-----------------

To exclude specifc tests from the collection of tests being run against the deployment, they
can be added to the blacklist file located at

.. code-block:: console

   socok8s/playbooks/roles/airship-deploy-tempest/files/tempest_blacklist

When adding tests to the blacklist, each test should be listed on a new line and should be
formatted like the following example:

.. code-block:: console

   - (?:tempest\.api\.identity\.v3\.test_domains\.DefaultDomainTestJSON\.test_default_domain_exists)

By default, the blacklist file provided with SUSE Containerized OpenStack will be used when
running Tempest tests. If desired, use of a blacklist can be disabled by adding the following key
to ${WORKDIR}/env/extravars:

.. code-block:: yaml

   use_blacklist: false

Running Tempest Tests
---------------------

Once all of the OpenStack network resources have been created and all configuration parameters have
been provided in ${WORKDIR}/env/extravars, Tempest testing can be started by running the following
command from the root of the socok8s directory:

.. code-block:: console

   ./run.sh test

Once the Tempest pods have been deployed, testing will begin immediately. You can check the progress
of the test pod at any time by running

.. code-block:: console

   kubectl get pods -n openstack | grep tempest-run

Example output:

.. code-block:: console

   airship-tempest-run-tests-hq6jg                          1/1     Running       0          33m

A status of 'Running' indicates that testing is still in progress. Once testing is complete, the status
of the airship-tempest-run-tests pod will change to 'Complete', indicating that all tests passed, or
'Error', indicating that at least one test has failed.

Tempest Test Results
--------------------

All test results can be viewed by retrieving the logs from the airship-tempest-run-tests pod by running
the following command:

.. code-block:: console

   kubectl logs -n openstack airship-tempest-run-tests-hq6jg

.. note::

   The logs can be viewed at any time, even while a current test batch is still running. 

Once testing is complete, the logs will conclude with a summary of all passed, skipped, and failed tests
similar to the following:

.. code-block:: console

   ======
   Totals
   ======
   Ran: 78 tests in 104.0000 sec.
    - Passed: 62
    - Skipped: 16
    - Expected Fail: 0
    - Unexpected Success: 0
    - Failed: 0
   Sum of execute time for each test: 56.3147 sec.

   ==============
   Worker Balance
   ==============
    - Worker 0 (19 tests) => 0:01:44.140828
    - Worker 1 (20 tests) => 0:01:02.484599
    - Worker 2 (18 tests) => 0:00:29.100245
    - Worker 3 (21 tests) => 0:01:28.449495
   
