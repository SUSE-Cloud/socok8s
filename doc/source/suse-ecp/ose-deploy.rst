Set Up OpenStack
================

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
       color = "#EEEEEE"
       label = "Set up hosts"
       ses -> caasp;
       caasp -> deployer [folded];
       deployer -> enroll_caasp;
     }
     enroll_caasp -> configure_deployment [folded];
     localhost -> configure_deployment[folded];

     configure_deployment -> setup_caasp_workers;

     group {
       color = "red"
       label = "OpenStack deployment"
       setup_caasp_workers -> deploy, patch_upstream [folded];
       patch_upstream -> build_images;
       build_images -> deploy;
     }
   }

You can either run the following steps separately or run them in a single step
all at the same time.

In separate steps
-----------------

Configuring CaaSP
~~~~~~~~~~~~~~~~~

Run the following to configure the CaaSP nodes for OpenStack:

.. code-block:: console

   ./run.sh setup_caasp_workers_for_openstack

This will update your CaaSP workers to:

* Point to your `deployer` host in `/etc/hosts`
* Copy your registry certificates (if developer mode is enabled)
* Create some directories of your workers with read/write mode for OpenStack
  software

Run developer plays
~~~~~~~~~~~~~~~~~~~

If you are a developer and want to apply upstream patches (but not
carry your own fork), you might want to run:

.. code-block:: console

   export SOCOK8S_DEVELOPER_MODE='True'
   ./run.sh patch_upstream

Build your own images by running:

.. code-block:: console

   export SOCOK8S_DEVELOPER_MODE='True'
   ./run.sh build_images

Deploy OpenStack
~~~~~~~~~~~~~~~~

.. tip::

   If you are a Helm chart developer, you can run OpenStack-Helm deployment
   on top of CaaSP without Airship:

   .. code-block:: console

      ./run.sh deploy_osh

To deploy OpenStack using Airship, run:

.. code-block:: console

   ./run.sh deploy

In a single step
----------------

All of the above steps can be summarized in a single command (Do not run
both separate and single step).

For Airship deployment
~~~~~~~~~~~~~~~~~~~~~~

Run the following to deploy Airship:

.. code-block:: console

   ./run.sh setup_airship

If you want to patch upstream Helm charts or build your own images, run the
following:

.. code-block:: console

   export SOCOK8S_DEVELOPER_MODE='True'
   ./run.sh setup_airship

.. note::

   Those steps might take several minutes to finish. If you want to know what
   is happening, check out the operations guide page on :ref:`deploymentprogress`.

For OpenStack-Helm only (developers)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Run the following to deploy OpenStack-Helm only:

.. code-block:: console

   ./run.sh setup_openstack

If you want to patch upstream Helm charts and/or build your own images, run the
run the following:

.. code-block:: console

   export SOCOK8S_DEVELOPER_MODE='True'
   ./run.sh setup_openstack

Verify the installation
~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`verifyinstallation` page has information for testing your SUSE
Containerized OpenStack installation.

Uninstalling SUSE Containerized OpenStack
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See the :ref:`uninstall` page for instructions.
