.. _ose-summary:

Process Summary
===============

Once you know the details about the individual steps needed to deploy the
environment on KVM host it is useful to see them in a brief format:

Deploy OSH (without Airship)
++++++++++++++++++++++++++++

.. code-block:: console

  run.sh setup_everything

This command launch in order

1. deploy_caasp
2. configure_ccp_deployer
3. deploys_ses_rook
4. setup_caasp_workers_for_openstack
5. patch_upstream
6. build_images
7. deploy_osh


Deploy OSH With Airship
+++++++++++++++++++++++

First we call setup_hosts

.. code-block:: console

  run.sh setup_kvm_hosts

This command launch the following steps.

1. deploy_caasp
2. configure_ccp_deployer
3. deploys_ses_rook

Then launch airship setup

.. code-block:: console

  run.sh setup_airship

1. setup_caasp_workers_for_openstack
2. deploy_airship

