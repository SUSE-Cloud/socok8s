Intro
=====

This project automates the deployment of OpenStack-Helm (OSH) on SUSE
Container as a Service Platform (CaaSP) and SUSE Enterprise Storage
(SES) via a series of shell scripts and Ansible playbooks.

General requirements
====================

Cloning this repository
-----------------------

To get started, you need to clone this repository. This repository uses
submodules, so you need to get all the code to make sure the playbooks
work.

::

   git clone --recursive https://github.com/SUSE-Cloud/socok8s.git

Alternatively, one can fetch/update the tree of the submodules by
running:

::

   git submodule update --init --recursive

Deployment on SUSE engcloud
===========================

Installing base software on your local machine
----------------------------------------------

On the system you plan to deploy OSH from, you’ll need to install some
software and create local configuration.

You need to have the following software installed:

-  ipcalc
-  jq
-  git
-  python-virtualenv

Optionally (but recommended), you can preinstall the following:

-  ansible>=2.7.0
-  python-openstackclient
-  python-requests
-  python-jmespath
-  python-openstacksdk
-  python-netaddr

Make sure to install the variant of the packages that matches the Python
release that ansible is using. (E.g. on Tumbleweed ansible is using
Python 3, so install the “python3-” variant of the packages)

If those aren’t installed, they will be installed in a venv in
~/.socok8svenv

Configure engcloud
------------------

You can access the engcloud web UI at https://engcloud.prv.suse.net/.
For more information, see
https://wiki.microfocus.net/index.php/SUSE/ECP.

Make sure your environment have an openstack client configuration file.
For that, you can create the ``~/.config/openstack/clouds.yaml``.

Replace the username and password with your appropriate credentials in
the following example:

::

   clouds:
     engcloud:
       region_name: CustomRegion
       auth:
         auth_url: https://engcloud.prv.suse.net:5000/v3
         username: foctodoodle # your username here
         password: my-super-secret-password # your password here or add it into secure.yaml
         project_name: cloud
         project_domain_name: default
         user_domain_name: ldap_users
       identity_api_version: 3
       cacert: /usr/share/pki/trust/anchors/SUSE_Trust_Root.crt.pem
   ansible:
     use_hostnames: True
     expand_hostvars: False
     fail_on_errors: True

If you don’t have the SUSE root certificate installed, check
http://ca.suse.de/. Or you can set ``insecure: True`` (not recommended).

You’ll also need to pre-create some configuration in engcloud. It’s
convention here to use your username as part of the name of objects you
create.

Create a keypair on engcloud (using either the engcloud web interface or
OpenStack CLI’s ``openstack keypair create``) for accessing the
instances created. Remember the name of this keypair (which appears as
``foctodoodle-key`` in the example below)

Now create a network, a subnet, a router and a connection to the
floating network:

::

   export OS_CLOUD=engcloud
   export PREFIX=foctodoodle
   openstack network create ${PREFIX}-net
   openstack subnet create --network ${PREFIX}-net --subnet-range 192.168.100.0/24 ${PREFIX}-subnet
   openstack router create ${PREFIX}-router
   openstack router set --external-gateway floating ${PREFIX}-router
   openstack router add subnet ${PREFIX}-router ${PREFIX}-subnet

Define the following environment variables prior to running the socok8s
scripts:

::

   # assuming you followed the example for clouds.yaml
   export OS_CLOUD=engcloud
   # the name of the keypair you created
   export KEYNAME=foctodoodle-key
   # your username plus whatever else you'd like, will be used for naming
   # objects you create in engcloud
   export PREFIX=foctodoodle
   # the name of the subnet you created
   export INTERNAL_SUBNET=${PREFIX}-subnet

Prior to executing scripts, be aware that you may need to do some
cleanup prior to retrying scripts or playbooks should they fail. In some
steps a delete.sh script is provided to clean up any created resources.
Reconfirming that you’ve done all the previous steps to set up now will
save you some time later.

Run deploy on engcloud
----------------------

To begin a deployment from scratch, go to the root of your socok8s clone
and run:

::

   ./run.sh

The default action for ``run.sh`` is to do a ``setup_everything`` on
openstack. This means the ``run.sh`` script will run all of top level
actions.

Re-deploying OSH
----------------

If you only want to redeploy the last step, openstack-helm, you can run
the following:

::

   ### (Optional): Cleanup k8s from all previous deployment code
   ./run.sh clean_k8s

::

   ### Re-deploy OpenStack-Helm
   ./run.sh deploy_osh


   ### (Optional): Cleanup Airship and Openstack-Helm artifacts 
   from all previous deployment
   ./run.sh clean_airship

   ### Re-deploy Airship
   ./run.sh deploy_airship

Reference: run.sh
=================

Actions
-------

The ``run.sh`` script accepts ``actions`` in the form of positional
arguments:

::

   ./run.sh <action>

Here are the actions available:

-  deploy_ses
-  deploy_caasp
-  deploy_ccp_deployer
-  enroll_caasp_workers: This makes sure the caasp workers are part of
   the cluster, by using kubic automation. It also then ensures the
   security groups have been removed on the ports to allow the vip to
   exist on those nodes
-  setup_hosts: This combines all the steps to deploy the requirements
   of an socok8s deployment. In other words, it runs: deploy_ses,
   deploy_caasp, deploy_ccp_deployer, enroll_caasp_workers.
-  patch_upstream: This allows developers (please set developer mode!)
   to cherry-picking upstream patches on top of upstream repos.
-  build_images: This allows developer to build images for internal
   consumption. Used in CI.
-  deploy_osh: Self explanatory.
-  deploy_airship: Deploys Airship Undercloud Control Plane (CP) and
   Openstack Helm (OpenStack CP).
-  setup_everything: From A to Z.
-  teardown: Destroys all the nodes in an openstack environment. Set the
   env var ‘DELETE_ANYWAY’ to ‘YES’ to delete everything in your
   userspace.
-  clean_k8s: Removes all k8s definitions that were introduced during
   deployment (Experimental!)
-  clean_airship: Removes all Airship and Openstack-Helm artifacts that
   were introduced during deployment (Experimental!)

env variables
-------------

``run.sh`` behaviour can be modified with environment variables.

``DEPLOYMENT_MECHANISM`` contains the target destination of the deploy
tooling. Currently set to ``openstack`` by default, but will later
include a ``baremetal`` and ``kvm``.

``OSH_DEVELOPER_MODE`` determines if you want to enter developer mode or
not. This adds a step for patching upstream code, builds images and then
continues the deployment.

``USE_ARA`` determines if you want to store records in ARA. Set its
value to ‘True’ for using ARA.

Reference: Architecture and inventories
=======================================

By default, it is expected these playbooks and scripts would run on a
CI/developer machine.

In order to not pollute the developer/CI machine (called further
‘localhost’), all the data relevant for a deployment (like any eventual
override) will be stored in user-space, unpriviledged access (this means
the ~/suse-osh-deploy folder for now). Any hardware and software
distribution can be used, as long as ‘localhost’ is able to run git, and
ansible (see requirements). This also helps the story of running behind
a corporate firewall: the ‘developer’ can be (connecting to) a bastion
host, while the real actions happen behind the firewall.

This SoCok8s deployment mechanism requires therefore another entity,
another machine, to orchestrate kubernetes commands. This machine is
named the ``deployer`` node. The ``deployer`` node will be in charge of
running the OSH code, and manage the kubernetes configuration.

The ``deployer`` node is expected to run SLE15 or openSUSE Leap 15.

The deployer node can be the same as the ``localhost`` (developer/CI
machine), but it is not a requirement.

The deployer node (currently) needs access to the SES machines through
SSH to fetch the keys. In the future, this SSH connection might be
skipped if the ``localhost`` have knowledge of these keys.

Example inventories and conventions
-----------------------------------

In order for a deployer to bring its own inventory, we have defined a
set of convention about inventory groupnames.

This is WIP and might change in the future. We want to move to a single
inventory file, with different group names.

-  All nodes belonging to the SES deployment should be listed under the
   ``ses_nodes`` group. First node in this group must be a monitor node
   with the appropriate ceph keyrings in ``/etc/ceph/``.

-  The inventory for SES nodes is stored in ``inventory-ses.ini`` by
   default.

-  The CI/developer machine is always named ``localhost``.

-  The ``deployer`` node is listed in a group ``airship-deployer``. In order
   to not extend the length of the deployment, the ``osh-deployer``
   group should contain only one node. We might support multiple
   ``airship-deployer`` nodes for muliple k8s deployments later.

-  The inventory for the ``deployer`` node is stored in
   ``inventory-osh.ini`` by default.

-  Example inventories and user variables can be found in the
   ``examples/`` directory.

Deployment using KVM
====================

This is not currently supported, but is a planned future addition.

Deployment on bare-metal
========================

This is not currently supported, but is a planned future addition.

Re-using a manually-installed SES and CAASP
===========================================

While a fully automated baremetal or VM based installation is not
currently supported, selected parts of the automated install process can
be used to configure existing SES and CAASP nodes. Here is an overview
of how to do this. Note that these instructions are a work in progress
and do not currently provide a comprehensive overview of installing SES
and CAASP themselves.

Manually installing nodes
-------------------------

Install SLES12SP3 with the SES5 extension from the SLES12SP3 ISO. Please
ensure that your SES system has a second disk device available.

Install a CAASP admin, master, and two worker nodes manually from the
CAASP ISO, setting the hostname on each node at install time. Visit the
admin web interface and configure it, being sure to install Tiller.

You will also want a system that acts as a deployer, which should have
SSH access via keys to the CAASP and SES nodes. Note that the playbooks
currently expect to use the root user on the remote systems and you may
have better luck running the playbooks as the root user on your deployer
as well.

Manually running Stage 2 to configure SES
-----------------------------------------

On your deployer, check out this repository. Be sure to import the git
submodules as above. In the top level of the repository, create a file
named .ses_ip containing the IP address of your SES node. Also create a
file named inventory-ses.ini with the following contents:

ses ansible_host= ansible_user=root

On the SES node, you will need to either configure SuSEfirewall2 to
allow access to the SSH port, or disable SuSEfirewall2 entirely. Next,
add a /root/.ssh/authorized_keys file containing the id_rsa.pub from
your deployer. Finally, note that the SES node must have a FQDN in
/etc/hosts, such as mycaasp.local for all steps to succeed.

Now you are ready to run the Stage 2 playbooks. From the top level of
this repository, run ./2_deploy_ses_aio/run.sh.

Manually running Stage 7 to run OpenStack Helm
----------------------------------------------

Prior to running Stage 7, you will need to perform additional
configuration on the deployer.

On the deployer:

-  Create an inventory-osh.ini file in the top level of this repository.
   To do this, copy the file from examples/config/inventory-osh.ini and
   edit it to reflect your environment.

-  Enable and start sshd on your deployer and the location you are
   running the playbooks. [NOTE: this step can be removed or adapted
   subject to merge of PR #29]

-  Add suse_osh_deploy_vip_with_cidr to ~/suse-osh-deploy/env/extravars.
   This should be an IP available on the network you’re using which can
   be used as a VIP.

-  Download the kubeconfig from Velum on the CAASP admin node and copy
   it to ~/suse-osh-deploy/kubeconfig and ~/.kube/config

-  pip install –upgrade pip to avoid segfaults when installing openstack
   clients.

-  pip install jmespath netaddr

On each CAASP node:

-  add id_rsa.pub to root’s authorized_keys file.

Now you are ready to run Stage 7, as follows:

::

   ansible-playbook -v -e @~/suse-osh-deploy/env/extravars <play>

Please also check the etherpad for more documentation:
https://etherpad.nue.suse.com/p/osh_on_caasp

Manually running Airship Deploy
================================

Prior to deploy Airship, you will need to perform additional
configuration on the deployer.

On the deployer:

-  Create the Airship deployment home folder, for example, /opt/socok8s

-  Configure the following environment variables:

   * export ANSIBLE_RUNNER_DIR=/opt/socok8s
   * export OSH_DEVELOPER_MODE=True #enables dev patcher and local image build
   * export DEPLOYMENT_MECHANISM=kvm
   * export DELETE_ANYWAY=YES

-  Create a hosts.yaml file in /opt/socok8s/inventory directory by
   using the examples/config/inventory-airship.yml and editing it to
   reflect your environment.

-  Create the extravars file in /opt/socok8s/env directory with the
   following variables:

   * # BEGIN ANSIBLE MANAGED BLOCK
   * ceph_admin_keyring_b64key: QVFDMXZ6dGNBQUFBQUJBQVJKakhuYkY4VFpublRPL1RXUEROdHc9PQo=
   * ceph_user_keyring_b64key: QVFDMXZ6dGNBQUFBQUJBQVJKakhuYkY4VFpublRPL1RXUEROdHc9PQo=
   * # END ANSIBLE MANAGED BLOCK
   *
   * # Deployment goal is either 'airship' or 'osh'
   * socok8s_deployment_goal: airship
   * # Following cidr entry is an IP available on the network you're
   * # using which can be used as a VIP
   * socok8s_deploy_vip_with_cidr: 172.16.1.100
   * suse_airship_deploy_site_name: soc-minimal
   * redeploy_osh_only: false # true if only wants to redeploy Openstack_Helm

-  Enable and start sshd on your deployer and the location you are
   running the playbooks. [NOTE: this step can be removed or adapted
   subject to merge of PR #29]

-  Download the kubeconfig from Velum on the CAASP admin node and copy
   it to ~/suse-socok8s-deploy/kubeconfig and ~/.kube/config

-  Retrieve the ses_config.yaml from Step 2 or edit the 
   example/config/ses_config.yml and place it in your workspace home
   (e.g. ~/suse-socok8s-deploy/) directory.

-  For each CAASP node, run ssh-copy-id root@your_caasp_node_host
   to add your key to the authorized_keys file.

Now you are ready to deploy Airship, as follows:

::

   ./run.sh deploy_airship


Airship Components Image Build
-------------------------------

Temporarily Airship components (armada, shipyard, deckhand etc.)
images can be builit locally and used in deployment.

When you need to build images and then use in your local deployment,
set folliwng environment variable to keep persistent image build
behavior

*export AIRSHIP_BUILD_LOCAL_IMAGES=True*


If you just need to build images on a playbook execution, pass variable
*airship_local_images_flag=true* to playbook run command.

If you just need is to use previously built airship component images
in your deployment, without need of re-building it, set the following
environment variable only. Make sure that AIRSHIP_BUILD_LOCAL_IMAGES
is *NOT* set or set to *False*.

*export AIRSHIP_USE_LOCAL_IMAGES=True*
