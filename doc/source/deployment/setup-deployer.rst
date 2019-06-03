.. _setupdeployer:

Set Up Deployer
=================

.. blockdiag::

   blockdiag {
     default_fontsize = 11;
     deployer [label="Setup deployer"]
     ses_integration [label="SES Integration"]
     configure [label="Configure\nCloud"]
     setup_caasp_workers [label="Setup CaaS Platform\nworker nodes"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build Docker images\n(for developers)"]
     deploy_airship [label="Deploy Airship"]
     deploy_openstack [label="Deploy OpenStack"]

     group {
       deployer
       color="red"
     }

     deployer -> ses_integration;
     ses_integration -> configure;
     configure -> setup_caasp_workers;

     group {
       color = "#EEEEEE"
       label = "Cloud Deployment"
       setup_caasp_workers -> patch_upstream;
       patch_upstream -> build_images;
       build_images -> deploy_airship [folded];
       setup_caasp_workers -> deploy_airship;
       deploy_airship -> deploy_openstack;
     }
   }


Base Software
-------------

The following software must be installed on your `Deployer`:

  * ansible>=2.7.0
  * gcc
  * git
  * jq
  * python3-netaddr
  * python-virtualenv

Create SUSE Containerized OpenStack Workspace
---------------------------------------------

All the deployment artifacts are stored in a :term:`workspace`. By default,
the workspace is a directory located in the user's home directory on the
Deployer. Set up your workspace with the following steps:

1. Create a directory in your home directory that ends in -workspace.
2. Export SOCOK8S_ENVNAME=<directory name prefix> to set your workspace.
3. To change your workspace parent directory, export `SOCOK8S_WORKSPACE_BASEDIR`
   with the base directory where your workspace is located.

.. code-block:: console

  mkdir ~/socok8s-workspace
  export SOCOK8S_ENVNAME=socok8s
  export SOCOK8S_WORKSPACE_BASEDIR=~/socok8s-workspace


Cloning repository
-----------------------

To get started, clone the socok8s GitHub repository. This repository uses
submodules, so you need to get all the code to make sure the playbooks work.

::

   git clone --recursive https://github.com/SUSE-Cloud/socok8s.git

Alternatively, one can fetch/update the tree of the submodules by running:

::

   git submodule update --init --recursive


SSH Key Preparation
-------------------

Create an SSH key on the Deployer node, and add the public key to each CaaS
Platform worker node.

.. note ::

  1. To generate the key, you can use ssh-keygen -t rsa

  2. To copy the ssh key to each node, use the ssh-copy-id command,
     for example: ssh-copy-id root@192.168.122.1

  Test this by connecting to the node via SSH and executing a command with ‘sudo’.
  Neither operation should require a password.

Passwordless sudo
-----------------

If installing as a non-root user, you will need to give your user passwordless
sudo on the Deployer.

.. code-block:: console

   sudo visudo

Add the following.

.. code-block:: console

   <username> ALL=(ALL) NOPASSWD: ALL

Add the above line after "#includedir /etc/sudoers.d". replace <username> with
your username.

Configure Ansible
-----------------

Use ARA (recommended)
~~~~~~~~~~~~~~~~~~~~~

Ansible Run Analysis (ARA) makes Ansible runs easier to visualize, understand,
and troubleshoot. To use ARA, set the following environment variable before
running `run.sh`.

.. code-block:: console

   export USE_ARA='True'

To set up ARA permanently for your user on `Deployer`, create an Ansible
configuration file loading ARA plugins:

.. code-block:: console

   python -m ara.setup.ansible | tee ~/.ansible.cfg

For more details on the ARA web interface, see
https://ara.readthedocs.io/en/stable/webserver.html.

Enable Pipelining (recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can improve SSH connections by enabling pipelining:

.. code-block:: console

   cat << EOF >> ~/.ansible.cfg
   [ssh_connection]
   pipelining = True
   EOF
