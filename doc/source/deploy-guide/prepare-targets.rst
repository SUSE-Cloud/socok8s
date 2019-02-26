.. _targethosts:

Prepare the target hosts
========================

.. blockdiag::

   blockdiag {

     localhost [label="Prepare localhost"]
     ses [label="Deploy SES\n(optional)"]
     caasp [label="Deploy CaaSP\n(optional)"]
     deployer [label="Deploy deployer\n(optional)"]
     enroll_caasp [label="Enroll CaaSP\n(optional)"]
     setup_caasp_workers [label="Setup CaaSP\nfor OpenStack"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build docker images\n(for developers)"]
     deploy [label="Deploy Airship or\nOpenStack-Helm"]
     configure_deployment [label="Configure deployment"]

     localhost -> ses;

     group {
       color = "red"
       label = "Setup hosts"
       ses -> caasp;
       caasp -> deployer [folded];
       deployer -> enroll_caasp;
     }
     enroll_caasp -> configure_deployment [folded];
     localhost -> configure_deployment[folded];

     configure_deployment -> setup_caasp_workers;

     group {
       color = "#EEEEEE"
       label = "Setup openstack/Setup airship"
       setup_caasp_workers -> deploy, patch_upstream [folded];
       patch_upstream -> build_images;
       build_images -> deploy;
     }
   }

.. note::

   You still need to export the right environment variables for `run.sh`
   to work with the `openstack` deployment mechanism. Check if you have set
   them appropriately. See also :ref:`configureopenstackdeploymentmechanism`.

This step can be skipped if you are bringing your own SES/CaaSP/deployer
environment.

.. note::

   If you bring your own deployer host, you will need to make sure the
   CaaSP tooling can be installed on it. Please search for the
   variable `velum_automation_host_packages` in the code to find the
   latest requirements.

Apply these commands if you are running on OpenStack, and want to construct
your environment from scratch.

In separate steps
-----------------

Create your SES node on OpenStack, and configure SES-AIO on it:

.. code-block:: console

   ./run.sh deploy_ses

Create the CaaSP cluster nodes in the cloud:

.. code-block:: console

   ./run.sh deploy_caasp

Create the deployer node:

.. code-block:: console

   ./run.sh deploy_ccp_deployer

Enroll all the CaaSP nodes into their roles (master, admin, and workers):

.. code-block:: console

   ./run.sh enroll_caasp_workers

In a single step
----------------

Alternatively, you can do all of the above in one step:

.. code-block:: console

   ./run.sh setup_hosts
