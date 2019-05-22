.. _reference:

=========
Reference
=========

This chapter contains extra reference information (more details) about the
`socok8s GitHub repository <https://github.com/SUSE-Cloud/socok8s>`_.

For information on how to deploy SUSE Containerized OpenStack, refer to
:ref:`deploymentguide`.

For information on how to manage and operate SUSE Containerized OpenStack, refer
to :ref:`operationsdocumentation`.

For information on how to contribute to SUSE Containerized OpenStack, refer to
:ref:`developerdocumentation`.


.. _projecthistory:

Project history
===============

This project started as a way to build and test the OpenStack-Helm charts for
SUSE, on SUSE products: The Container as a Service Platform (CaaSP) and
the SUSE Enterprise Storage (SES).

It started as a series of shell scripts and Ansible playbooks, choosing the
simplest and fastest way to bring a test infrastructure for the upstream
charts.  It was easier to start with a shell script
than writing a CLI in <insert language here>, mostly because
the shell script organically grew out of its usage and CI needs.

The mechanism of deployment was flexible from the beginning to allow developers
to test their changes independently. It would allow them to override specific
parts of the deployment, like other users or customers would want to do.

Project goals
=============

* Simplicity
* Stability
* Use the latest stable products from SUSE
* Carry the minimum amount of code to support upstream work on SUSE products
* Be packagable/installable offline
* Leverage upstream first

Design considerations
=====================

Workspace
---------

In order to not pollute the developer/CI machine (called `localhost`),
all the data relevant for a deployment (like any eventual override) is stored
in a user-space |socok8s_workspace_default| folder, with unprivileged access.

This also supports the use case of running behind a corporate firewall. The
`localhost` can connect to a bastion host with the "deployment" actions
happening behind the firewall.

run.sh
------

Instead of running a series of scripts, unrelated to each other, and
hard to remember for a deployer, SOCok8s takes the approach of a
single shell script to drive from A to Z a deployment.

The single point of access brings multiple features:

* It's now possible to always ensure shell environment
  variables are always set, while keeping the functional
  behaviour in its own dedicated shell script.
* It's now possible to ensure `localhost` have all the
  system requirements before deploying, without asking
  for user intervention.

run.sh is a bash script, because it is a very commonly
installed software on the 'localhost' node, independent
of the distribution or of its version.
It allows to install higher level requirements,
like ansible, until we package socok8s differently.

Each of the steps in `run.sh` are written in a way they represent a
user facing feature. While what happens behind the scenes could
change, the user interface is, in theory, stable.
It therefore allows a 'swap and replace' of any of the user facing
functions.

The current interface of `run.sh` is flexible enough to work for many
different cases, and is semantically close to the actions that will happen
to deploy OpenStack. `run.sh` itself is just an interface, behind the
scenes, it runs a `DEPLOYMENT_MECHANISM` dependant script starting the
appropriate ansible playbooks for the step called.

Technology stack
----------------

See project goals.

Why...
======

... Ansible?
   Using Ansible is more robust than having written socok8s fully on shell
   scripts. Its ecosystem allows a nice interface to track deployment
   progress with ARA, run in a CI/CD like Zuul or Tower/AWX.

... OpenStack on top of Kubernetes on top of OpenStack by default in `run.sh`?
   We have a cloud for our Engineers, and that cloud is used for CI.
   From that point, creating a node for testing is as simple as doing an API
   call, and creating a stack of nodes is simple as re-using an existing Heat
   stack.

   The `run.sh` was mainly used for developers and CI. This is why the `run.sh`
   script still points to `openstack` as the default `DEPLOYMENT_MECHANISM`.

... OpenStack on top of Kubernetes?
   Robust structure

... Installing from sources?
   Neither the socok8s repo nor the OpenStack-Helm project's repositories
   have been packaged for Leap/SLE 15 yet.

Image building process
======================

Upstream process
----------------

The OpenStack-Helm project tries to be neutral about the images by
providing the ability for deployers to override any image used in the
charts.

However, the OpenStack-Helm project has a repository,
`openstack-helm-images <https://github.com/openstack/openstack-helm-images>_`,
containing a reference implementation for the images. That repository
holds the images used for the OpenStack-Helm project charts. All its images
are built with Docker.

The `openstack-helm-images` repository provides Dockerfiles directly for all the
non-OpenStack images.

For the OpenStack images, `openstack-helm-images` contains shell scripts,
situated in `openstack/loci/`. The `build.sh` script is a thin wrapper around
<<<<<<< HEAD
`LOCI`. `LOCI` is the official OpenStack project to build OCI compliant
images of OpenStack projects. It uses `docker build` to construct images from
OpenStack sources and their requirements are expressed in `bindep` files
(`bindep.txt` for rpm/apt packages, `pydep.txt` for python packages).
The `build.sh` runs `LOCI` for the master branch. Other branches can be built
using `build-{branchname}.sh` where `branchname` is the name of the OpenStack
branch (for example, `rocky`). See also :ref:`buildlociimages`.

In the future, `openstack-helm-images` could theoretically add images for
OpenStack which would be based on packages, by simply providing the appropriate
Dockerfiles.
=======
`LOCI`. `LOCI` is the official OpenStack project to build lightweight Open
Container Initiative (OCI) compliant images of OpenStack projects. It uses
`docker build` to construct images from OpenStack sources. Their requirements
are expressed in `bindep` files (`bindep.txt` for rpm/apt packages, `pydep.txt`
for python packages). The `build.sh` script runs `LOCI` for the master branch.
Other branches can be built using `build-{branchname}.sh` where `branchname` is
the name of the OpenStack release (for example, `rocky`). See also :ref:`buildlociimages`.

In the future, `openstack-helm-images` could add images for OpenStack that
would be based on packages by simply providing the appropriate Dockerfiles.
There is no announced plan to offer such a resource.
>>>>>>> doc: transfer edits from source_tech_preview to source

Additionally, some images are not built in `openstack-helm-images`, and they
are directly consumed/fetched from upstream projects official dockerfiles,
like xrally.

socok8s process
---------------

socok8s leverages the existing OSH-images code.

When running the `build_images` step, the `localhost` asks the `deployer` to
build images based on the code that was checked in on the `deployer` node
using the `vars/manifest.yml` file.

For the non-LOCI images, the `suse-build-images` role invoked in the
`build_images` step is running a `docker build` command.

For the LOCI images, the `suse-build-images` role runs the command
available in `openstack-helm-images` calling the LOCI build.

OpenStack-Helm chart overrides
==============================

Helm chart values overriding principle
--------------------------------------

A Helm chart installation
(See https://helm.sh/docs/using_helm/#customizing-the-chart-before-installing )
accepts an argument named ``--values`` or ``-f``.

This argument expects the filename of a YAML file to be present on the
Helm client machine. It can be specified multiple times, and
the rightmost file will take precedence.

In the following example, the different values of
``socok8s-glance.yaml`` overrides would win over the existing values in
``/tmp/glance.yaml``:

.. code-block:: console

   helm upgrade --install glance ./glance --namespace=openstack \
     --values=/tmp/glance.yaml --values=/tmp/socok8s-glance.yaml

OpenStack-Helm scripts
----------------------

The OpenStack-Helm project provides shell scripts to deploy the Helm charts,
with overrides per context (for example, multinode).

Those shell scripts calling the Helm installation include an environment
variable to allow users to pass extra arguments.

See `this example from the openstack-helm repository <https://github.com/openstack/openstack-helm/blob/c869b4ef4a0e95272155c5d5dd893c72976753cd/tools/deployment/multinode/100-glance.sh#L49>`_.

Customizing OSH charts for SUSE when deploying in OSH only mode
----------------------------------------------------------------

socok8s uses the previously explained environment variable to pass an extra
values file, a SUSE-specific YAML file. All the SUSE-specific files are present
in `playbooks/roles/deploy-osh/templates/` (for example `socok8s-glance.yml`),
**if they are not part of upstream yet**.

How deployers can extend a custom SUSE OSH chart in OSH-only mode
---------------------------------------------------------------

Deployers can pass their own YAML overrides in user space by using `extravars`
to extend Helm chart behavior beyond the SUSE customizations.

These overrides are in `playbooks/roles/deploy-osh/defaults/main.yml`.

Customizing OSH charts for SUSE when deploying with Airship
------------------------------------------------------------

...

How deployers can extend a custom SUSE OSH chart with Airship
-----------------------------------------------------------

...

Summary "deploy on OpenStack" diagrams
======================================

Simplified network diagram
--------------------------

.. nwdiag::

   nwdiag {
     cloud [shape = cloud];
     localhost -- cloud -- deployer;
     network {
       group caasp {
           color = "#EEEEEE";
           caasp-workers;
           caasp-admins;
           caasp-master;
       }
       deployer;
       ses-aio;
     }
   }

OSH deploy on OpenStack process
-------------------------------

Setup hosts
~~~~~~~~~~~

This is the sequence of steps that generates, in OpenStack, the environment
for deploying OSH later.

.. seqdiag::

   seqdiag {
     localhost; cloud; deployer; CaaSP; ses;
     activation = none;
     localhost -> cloud             [label = "Start 12SP3 node"]
     localhost <- cloud             [label = "SES inventory data"]
     localhost -> ses               [label = "Deploy SES" ];
     localhost <- ses               [label = "ses_config data" ];

     localhost -> cloud             [label = "Start CaaSP3 stack"];
     localhost <- cloud             [label = "CaaSP inventory data"];

     localhost -> cloud             [label = "Start Leap 15 node"];
     localhost <- cloud             [label = "Deployer inventory data"];

     localhost -> deployer          [label = "Configure deployer" ];
                  deployer -> CaaSP [label = "Enroll CaaSP nodes"];
                  deployer <- CaaSP [label = "Kubeconfig data"];
   }

Setup OpenStack
~~~~~~~~~~~~~~~

This is the sequence of steps that ends up with your OpenStack-Helm deployment.
The solid lines represent Ansible plays and their connections.

The dotted lines represent extra connections happening on the Ansible targets.

.. seqdiag::

   seqdiag {
     localhost; deployer; CaaSP;
     activation = none;

     === Setup caasp workers for openstack ===
     localhost -> localhost            [label = "Generate certs\nif none given"];
     localhost -> CaaSP                [label = "Setup caasp workers for openstack\n(/etc/hosts, subvolumes, certificates)"];

     === Developer mode ===
     localhost -> deployer             [label = "Run repo patcher" ];
                  deployer --> deployer[label = "Git clone"];
                  deployer --> deployer[label = "Fetch patches\nwith gerrit API"];

     localhost -> deployer             [label = "Copy certificates\nInstall Docker\nRun build images" ];
                  deployer --> deployer[label = "docker build"];
                  deployer --> deployer[label = "push to deployer\nregistry"];

                  deployer --> deployer[label = "Run loci wrapper\n(docker build)"];
                  deployer --> deployer[label = "push to deployer\nregistry"];

     === End of developer mode ===

     localhost -> deployer             [label = "Run deploy-osh" ];
                  deployer --> deployer[label = "Configure VIP\nin /etc/hosts"];
                  deployer --> deployer[label = "Run helm repo"];
                  deployer --> deployer[label = "Build charts"];
                  deployer --> deployer[label = "Generate\nSUSE overrides+\nRun OSH scripts"];
   }


.. _envvars:

Environment variables
=====================

In socok8s
----------

``run.sh`` behavior can be modified with environment variables.

``DEPLOYMENT_MECHANISM`` contains the target destination of the deploy
tooling. Currently set to ``openstack`` by default, but will later
include a ``baremetal`` and ``kvm``.

``SOCOK8S_DEVELOPER_MODE`` determines if you want to enter developer mode or
not. This adds a step for patching upstream code, builds images and then
continues the deployment.

``SOCOK8S_USE_VIRTUALENV`` determines if the script should set up and use a
virtualenv for python and ansible requirements. Without this it is expected
that ansible and the requirements are installed via system packages.
When ``SOCOK8S_DEVELOPER_MODE`` is set to True, this defaults to True, otherwise
this defaults to False.

``USE_ARA`` determines if you want to store records in ARA. Set its
value to 'True' for using ARA.

Ansible environment variables
-----------------------------

You can use Ansible environment variables to alter Ansible behavior, for
example by being more verbose.

OpenStack-Helm environment variables
------------------------------------

OpenStack Helm deployment scripts accepts environment variables to alter their
behavior. Read each of the scripts to know more about their override
mechanisms.
