.. _ose-targethosts:

Prepare the Target Hosts
========================

.. blockdiag::

   blockdiag {

     localhost [label="Prepare localhost"]
     caasp [label="Deploy CaaSP\n(optional)"]
     deployer [label="Deploy deployer\n(optional)"]
     ses [label="Deploy SES\n(optional)"]
     enroll_caasp [label="Enroll CaaSP\n(optional)"]
     setup_caasp_workers [label="Set up CaaSP\nfor OpenStack"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build docker images\n(for developers)"]
     deploy [label="Deploy OpenStack"]
     configure_deployment [label="Configure deployment"]

     localhost -> ses;

     group {
       color = "red"
       label = "Set up KVM hosts"
       caasp -> deployer;
       deployer -> ses [folded];
       ses -> enroll_caasp;
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


Apply these commands if you are running on local workstation and want to construct
your environment from scratch.

.. warning::

   You must export the right environment variables for `run.sh` to work with
   the `kvm` deployment mechanism. Verify that they are set
   appropriately. See :ref:`configurekvmdeploymentmechanism`.

The script run.sh
-----------------

This is the script that launch the Ansible scripts to deploy socok8s through
some commands.

Each command launch an specific function in one of scripts allocated in
/script_library. This function will run one of the Ansible playbooks allocated
in /playbooks

For instance, deploy will to call the function deploy_airship() in
/script_library/deployment-actions-common.sh that after prepare some variables
will run the Ansible playbook allocated in
/playbooks/generic-deploy_airship.yml This script can launch one or more
additional scripts (roles) allocated in the shared library in /playbooks/roles

In separate steps
-----------------

Create the :term:`CaaSP` cluster nodes on your KVM host:

.. code-block:: console

   ./run.sh deploy_caasp

Configure the deployer node:

.. code-block:: console

   ./run.sh configure_ccp_deployer

Configure SES-ROOK:

.. code-block:: console

   ./run.sh deploy_ses_rook

In a single step
----------------

Alternatively, you can do all of the above in one step:

.. code-block:: console

   ./run.sh setup_kvm_hosts

Cleanup of Nodes
----------------

To cleanup provisioned cluster and deployer nodes, use following step. This will
remove resources created by terraform (domains, disks, volumes etc.), cleanup
CaaSP cluster related local skuba configuration.

.. code-block:: console

   ./run.sh clean_caasp