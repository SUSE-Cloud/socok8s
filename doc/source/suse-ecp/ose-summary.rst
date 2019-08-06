.. _ose-summary:

Process Summary
===============

Once you know the details about the individual steps needed to deploy the
environment in ECP it is useful to see them in a brief format:

Deploy OSH (without Airship)
++++++++++++++++++++++++++++

.. code-block:: console

  run.sh setup_everything

This command launch in order

1. deploy_network
2. deploy_ses
3. deploy_caasp
4. deploy_ccp_deployer
5. configure_ccp_deployer
6. enroll_caasp_workers
7. setup_caasp_workers_for_openstack
8. patch_upstream
9. build_images
10. deploy_osh


Deploy OSH With Airship
+++++++++++++++++++++++

First we call setup_hosts

.. code-block:: console

  run.sh setup_hosts

This command launch the following steps.

1. deploy_network
2. deploy_ses
3. deploy_caasp
4. deploy_ccp_deployer
5. configure_ccp_deployer
6. enroll_caasp_workers

Then launch airship setup

.. code-block:: console

  run.sh setup_airship

1. setup_caasp_workers_for_openstack
2. deploy_airship

