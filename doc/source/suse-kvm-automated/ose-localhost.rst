.. _ose-localhost:

Prepare Localhost
=================

.. blockdiag::

   blockdiag {
     default_fontsize = 11;
     localhost [label="Prepare localhost"]
     caasp [label="Deploy CaaSP\n(optional)"]
     deployer [label="Deploy deployer\n(optional)"]
     ses [label="Deploy SES\n(optional)"]
     enroll_caasp [label="Enroll CaaS Platform Nodes"]

     configure [label="Configure\n Cloud"]
     setup_caasp_workers [label="Set up CaaS Platform\nworker nodes"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build Docker images\n(for developers)"]
     deploy_airship [label="Deploy Airship"]
     deploy_openstack [label="Deploy OpenStack"]

     localhost -> ses;

     group {
       localhost
       color="red"
     }

     group {
       color = "#EEEEEE"
       label = "Set up KVM hosts"
       caasp -> deployer;
       deployer -> ses [folded];
       ses -> enroll_caasp;
     }

     enroll_caasp -> configure [folded];

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


Base software
-------------

Install the following software on your `localhost`:

  * jq
  * ipcalc
  * git
  * python3-virtualenv

Optionally, `localhost` can be preinstalled with the following software:

  * ansible>=2.8.0
  * python3-openstackclient
  * python3-requests
  * python3-jmespath
  * python3-openstacksdk
  * python3-netaddr

SUSE Containerized OpenStack only supports the Python3 variant of packages.
Generally, the `python` command invokes Python version 2, which will not work
with SUSE Containerized OpenStack.

If the optional software packages are not installed, they will be installed in a
venv in |socok8s_workspace_default|\ `/.ansiblevenv`.

.. note ::

   The requirements that will be installed in that workspace are:

   .. include :: requirements.txt
      :code:


For CaaSP 4.x KVM deployment, skuba (https://github.com/SUSE/skuba), terraform
and terraform libvirt provider packages are required. Currently deployment
steps automatically configure related package repositories and installs the
appropriate packages if ansible runner (the host where ansible is running) is
SLES-15.0 or SLES-15-SP1 host.

.. note ::

   If your ansible runner OS is not SLES-15 or SLES-15-SP1, then you will
   need to find above packages for your OS distribution and version. Please
   make sure that terrform version is v0.11.x as that's the only working
   version for now.


Cloning this repository
-----------------------

To get started, clone this repository. This repository uses submodules, so you
must get all the code to make sure the playbooks work.

::

   git clone --recursive https://github.com/SUSE-Cloud/socok8s.git

Alternatively, one can fetch/update the tree of the submodules by
running:

::

   git submodule update --init --recursive

Configure Ansible
-----------------

Use ARA (recommended)
~~~~~~~~~~~~~~~~~~~~~

To use ARA, set the following environment variable before running `run.sh`.

.. code-block:: console

   export USE_ARA='True'

To set up ARA more permanently for your user on `localhost`, create an Ansible
configuration file loading ARA plugins:

.. code-block:: console

   python3 -m ara.setup.ansible | tee ~/.ansible.cfg

For more details on ARA's web interface, please read
https://ara.readthedocs.io/en/stable/webserver.html .

Enable pipelining (recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can improve SSH connections by enabling pipelining:

.. code-block:: console

   cat << EOF >> ~/.ansible.cfg
   [ssh_connection]
   pipelining = True
   EOF

.. _deploymechanism:

Defining a workspace
--------------------

`socok8s` can create a :term:`workspace`, install things (eg. Ansible in a
virtualenv), or create resources (for example, Terraform provisioned nodes if
the deployment mechanism is `kvm`). For all of these operations, an
environment variable called `SOCOK8S_ENVNAME` must be set. This variable must
be unique if multiple environments are installed in parallel.

.. code-block:: console

   export SOCOK8S_ENVNAME='soc-east'


Set the deployment mechanism
----------------------------

The SUSE Containerized OpenStack tooling can work with three different mechanisms:

* Bring your own environment
* Deploy everything on top of OpenStack (experimental).
* Deploy everything on top of local KVM host/workstation (experimental).

This behavior can be changed by setting the environment variable
`DEPLOYMENT_MECHANISM`. Its default value is "kvm". When you want
to deploy :term:`CaaSP`, :term:`SES`, and Containerized OpenStack on top of an
local workstation (for developer for example), run:

.. code-block:: console

   export DEPLOYMENT_MECHANISM='kvm'

Difference between Automated vs Bring your own environment (BYOE)
-----------------------------------------------------------------

With `kvm` deployment mechanism in automated kvm mode, CaaSP cluster and
deployer node provisioning and configuration is automated. So there is some
additional configuration and script execution is needed. These steps are not
applicable in BYOE but once needed setup is there, rest of KVM deployment
mechanism to setup Containerized OpenStack is same in both variation.

.. _configurekvmdeploymentmechanism:

Configure KVM Automated deployment mechanism (experimental)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Your localhost (or ansible runner) node can be either inside a VM hosted on your
workstation or workstation directly.

Ensure your workstation has necessary KVM virtualization support (packages and nested
virtualization).

See also
`KVM Host Server
<https://doc.opensuse.org/documentation/leap/virtualization/html/book.virt/cha.qemu.host.html>`_.

For KVM virtualization, KVM guests are managed via libvirt stack. So its
preferred to have an existing libvirt managed network ( e.g. `default`). This
default virtual network provides NAT based connectivity to KVM guests.

This network name is defined via following property and can be overriden if
your network name is different.

.. code-block:: console

   terraform_libvirt_existing_network_name='default'

.. note ::

   We don't provision network as part of the installation. So ensure that correct
   existing network name is provided for your VM/Guests node connectivity.

Provide CIDR for the network IP range for your network.

.. code-block:: console

   terraform_libvirt_network_cidr: "192.168.122.0/24"

If your localhost (ansible runner) node is running in a VM on your workstation,
you must ensure the following.

1. Provide following property to specify your remote libvirt host
`terraform_libvirt_remotehost`. This is the IP of workstation where you intend
to create CaaSP cluster and deployer nodes. If you don't have ansible runner in
a VM, then terraform_libvirt_remotehost needs to be blank so libvirt_uri will be
local (i.e. `qemu:///system` )

e.g.

.. code-block:: console

   terraform_libvirt_remotehost: 192.168.89.30

2. Ensure that from your VM, you can do passwordless ssh via `root` user to your
workstation. This is used by terraform libvirt provider to connect to remote
libvirt via qemu+ssh protocol.

3. You localhost (ansible runner) node is using same network as the one you
provided for KVM setup. This is to ensure that your ansible runner node can
connect to cluster and deployer nodes via ssh post creation.

Proceed to next section of the documentation,
:ref:`ose-targethosts`.
