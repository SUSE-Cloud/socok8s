.. _ose-targethosts:

Prepare the Target Hosts
========================

.. blockdiag::

   blockdiag {

     localhost [label="Prepare localhost"]
     ses [label="Deploy SES\n(optional)"]
     caasp [label="Deploy CaaSP\n(optional)"]
     deployer [label="Deploy deployer\n(optional)"]
     enroll_caasp [label="Enroll CaaSP\n(optional)"]
     setup_caasp_workers [label="Set up CaaSP\nfor OpenStack"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build docker images\n(for developers)"]
     deploy [label="Deploy OpenStack"]
     configure_deployment [label="Configure deployment"]

     localhost -> ses;

     group {
       color = "red"
       label = "Set up hosts"
       ses -> caasp;
       caasp -> deployer [folded];
       deployer -> enroll_caasp;
     }
     enroll_caasp -> configure_deployment [folded];
     localhost -> configure_deployment[folded];

     configure_deployment -> setup_caasp_workers;

     group {
       color = "#EEEEEE"
       label = "Openstack deployment"
       setup_caasp_workers -> deploy, patch_upstream [folded];
       patch_upstream -> build_images;
       build_images -> deploy;
     }
   }

.. important::

   Skip this step if you are bringing your own :term:`SES`,
   :term:`CaaSP`, and deployer environment (recommended).

Apply these commands if you are running on OpenStack and want to construct
your environment from scratch.

.. warning::

   You must export the right environment variables for `run.sh` to work with
   the `openstack` deployment mechanism. Verify that they are set
   appropriately. See :ref:`configureopenstackdeploymentmechanism`.

In separate steps
-----------------

Create your SES node. The SES All-In-One (AIO) node has the following
requirements:

*  (v)CPU: 6
*  Memory: 16GB
*  Storage: 80GB
*  When SES is deployed as AIO, two additional 60GB storage disks must be added
   to the node for OSD.

Create network:

.. code-block:: console

   ./run.sh deploy_network

Configure SES-AIO:

.. code-block:: console

   ./run.sh deploy_ses

Create the :term:`CaaSP` cluster nodes in the cloud:

.. code-block:: console

   ./run.sh deploy_caasp

Create the deployer node:

.. code-block:: console

   ./run.sh deploy_ccp_deployer

Enroll all the :term:`CaaSP` nodes into their roles (master, admin, and workers):

.. code-block:: console

   ./run.sh enroll_caasp_workers

In a single step
----------------

Alternatively, you can do all of the above in one step:

.. code-block:: console

   ./run.sh setup_hosts
