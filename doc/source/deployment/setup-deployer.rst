.. _setupdeployer:

Setup Deployer
=================

.. blockdiag::

   blockdiag {
     default_fontsize = 11;
     deployer [label="Setup deployer"]
     configure_soc [label="Configure Openstack Cloud Site"]
     setup_caasp_workers [label="Setup CaaS Platform\nworker nodes"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build Docker images\n(for developers)"]
     deploy_airship [label="Deploy Airship"]
     deploy_openstack [label="Deploy OpenStack"]

     group {
       deployer
       color="red"
     }

     deployer -> configure_soc;
     configure_soc -> setup_caasp_workers;

     group {
       color = "#EEEEEE"
       label = "OpenStack deployment"
       setup_caasp_workers -> patch_upstream;
       patch_upstream -> build_images;
       build_images -> deploy_airship [folded];
       setup_caasp_workers -> deploy_airship;
       deploy_airship -> deploy_openstack;
     }
   }


Base software
-------------

Install the following software on your `dployer`:

  * git
  * ansible>=2.7.0

Cloning repository
-----------------------

To get started, you need to clone this repository. This repository uses
submodules, so you need to get all the code to make sure the playbooks work.

::

   git clone --recursive https://github.com/SUSE-Cloud/socok8s.git

Alternatively, one can fetch/update the tree of the submodules by running:

::

   git submodule update --init --recursive

Configure Ansible
-----------------

Use ARA (recommended)
~~~~~~~~~~~~~~~~~~~~~

To use ARA, set the following environment variable before running `run.sh`.

.. code-block:: console

   export USE_ARA='True'

To setup ARA more permanently for your user on `localhost`, create an ansible
configuration file loading ara plugins:

.. code-block:: console

   python -m ara.setup.ansible | tee ~/.ansible.cfg

For more details on ARA's web interface, please read
https://ara.readthedocs.io/en/stable/webserver.html .

Enable mitogen (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~

To improve deployment speed, enable mitogen strategy and connection plugin.
First install mitogen in your venv (e.g. `~/suse-socok8s-deploy/.ansiblevenv/` or your local
ansible environment), then enable it using environment variables.

Alternatively, enable it for all your ansible calls by adding it to your
ansible configuration:

.. code-block:: console

   cat < EOF >> ~/.ansible.cfg
   strategy_plugins=${HOME}/suse-socok8s-deploy/.ansiblevenv/lib/python3.6/site-packages/ansible_mitogen/plugins/strategy
   strategy = mitogen_linear
   EOF

For more details on mitogen, please read
https://mitogen.readthedocs.io/en/latest/ansible.html .

Enable pipelining (recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You might want to improve SSH connections by enabling pipelining:

.. code-block:: console

   cat < EOF >> ~/.ansible.cfg
   [ssh_connection]
   pipelining = True
   EOF

.. _deploymechanism:

Set a deployment mechanism
--------------------------

This tooling can work with two different mechanisms:

* Bring your own environment
* Deploy everything on top of OpenStack (experimental).

This behaviour can be changed by setting the environment variable
`DEPLOYMENT_MECHANISM`.

For example, if you want to bring your own :term:`CaaSP`/:term:`SES` cluster,
run:

.. code-block:: console

   export DEPLOYMENT_MECHANISM='KVM'

Alternatively, if you want to deploy :term:`CaaSP`, :term:`SES` and
OpenStack on top of an OpenStack environment (for CI for example), run:

.. code-block:: console

   export DEPLOYMENT_MECHANISM='openstack'

OpenStack is the current default behaviour.

.. _configureopenstackdeploymentmechanism:

Configure OpenStack deployment mechanism (experimental)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the case you are not bringing your own environment, this socok8s tooling can
deploy :term:`CaaSP`, :term:`SES`, and/or a deployer on its own with the help of
OpenStack.

Make sure your environment have an openstack client configuration file.
For that, you can create the ``~/.config/openstack/clouds.yaml``.

Replace the username and password with your appropriate credentials in
the following example if you are running on engcloud (SUSE employees):

::

   clouds:
     engcloud:
       region_name: CustomRegion
       auth:
         auth_url: https://keystone_url/v3
         username: foctodoodle # your username here
         password: my-super-secret-password # your password here or add it into secure.yaml
         project_name: cloud
         project_domain_name: default
         user_domain_name: ldap_users # this is just an example, adapt to your needs
       identity_api_version: 3
   ansible:
     use_hostnames: True
     expand_hostvars: False
     fail_on_errors: True

SUSE Employees, you can access the engcloud web UI at https://engcloud.prv.suse.net/.
For more information on how to set up your `clouds.yaml`, see
https://wiki.microfocus.net/index.php/SUSE/ECP.
If you don’t have the SUSE root certificate installed, check
http://ca.suse.de/, install the package, and point to the pem file
in your clouds.yaml, as described in the procedure linked above.

Now pre-create your environment. It is convention here to use your username
as part of the name of objects you create.

Create a keypair on your cloud (named further *engcloud*)
(using either the horizon's web interface or
OpenStack CLI’s ``openstack keypair create``) for accessing the
instances created. Remember the name of this keypair (which appears as
``foctodoodle-key`` in the example below)

Set this for **all** the following scripts in a deployment:

.. code-block:: console

   export OS_CLOUD=engcloud
   # 'engcloud' is the name in the `clouds.yaml`,
   # Set the name of the keypair you created
   export KEYNAME=foctodoodle-key
   # Set the name of the network you will use in the deployment
   export INTERNAL_NETWORK=foctodoodle-net
   # Set the name of the subnet you will use in the deployment
   export INTERNAL_SUBNET=foctodoodle-subnet
   # Set the name of the floating ip network you will use in the deployment
   export EXTERNAL_NETWORK=floating

If you haven't created the internal networks/subnets and appropriate routers
already, do it now (you only have to do it once):

.. code-block:: console

   openstack network create ${INTERNAL_NETWORK}
   openstack subnet create --network ${INTERNAL_NETWORK} --subnet-range 192.168.100.0/24 ${INTERNAL_SUBNET}
   openstack router create ${INTERNAL_NETWORK}-router
   openstack router set --external-gateway floating ${INTERNAL_NETWORK}-router
   openstack router add subnet ${INTERNAL_NETWORK}-router ${INTERNAL_SUBNET}

Reconfirming that you’ve done all the previous steps to set up now will
save you some time later.

With this done, proceed to next section of the documentation,
:ref:`targethosts`.

Configure KVM deployment mechanism
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This deployment mechanism is only for "Bring your own cluster" cases.
There is no additional environment variable to define.

With this done, continue your deployment by reading the
:ref:`configuredeployment` page.
