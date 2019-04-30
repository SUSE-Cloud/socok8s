.. _configuredeployment:

Configure Cloud
===============

.. blockdiag::

   blockdiag {
     default_fontsize = 11;
     deployer [label="Setup deployer"]
     ses_integration [label="SES Integration"]
     configure_soc [label="Configure\nCloud"]
     setup_caasp_workers [label="Setup CaaS Platform\nworker nodes"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build Docker images\n(for developers)"]
     deploy_airship [label="Deploy Airship"]
     deploy_openstack [label="Deploy OpenStack"]

     group {
       configure_soc
       color="red"
     }

     deployer -> ses_integration;
     ses_integration -> configure_soc;
     configure_soc -> setup_caasp_workers;

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


This :term: `workspace`, structured like an `ansible-runner` directory,
contains the following deployment artifacts:

| socok8s-workspace
| ├── inventory
| │   └── hosts.yml
| ├── env
| │   └── extravar
| ├── ses_config.yml
| └── kubeconfig


Configure the inventory
-----------------------

You can create an inventory based on the example located in the `examples`
folder.

.. literalinclude:: ../../../examples/workdir/inventory/hosts.yml

As you can see, this inventory example only contains the group names.

For each group, a `hosts:` key should be added, with, as value, each
of the hosts you will need. For example:

.. code-block:: yaml

   airship-openstack-control-workers:
     hosts:
       caasp-worker-001:
         ansible_host: 10.86.1.144

The group `airship-ucp-workers` specifies the list of CaaS Platform worker
nodes to which the Airship Under Cloud Platform (UCP) services will be
deployed. The UCP services in socok8s include Armada, Shipyard, Deckhand,
Pegleg, keystone, Barbican, and core infrastructure services such as
MariaDB, RabbitMQ, PostgreSQL etc.

The group `airship-openstack-control-workers` specifies the list of CaaS
Platform worker nodes that will make up the Openstack control plane. The
Opestack control plane includes Keystone, Glance, Cinder, Nova, Neutron,
Horizon, Heat, MariaDB, RabbitMQ and so on.

The group `airship-openstack-compute-workers` defines the CaaS Platform worker
nodes will be used as Openstack Compute Nodes. Nova compute, Libvirt, Open
vSwitch are deployed to these nodes.

For most users, UCP and Openstack control planes can share the same worker
nodes. The Openstack compute nodes should be dedicated worker nodes unless
only very light workload is expected.

See also
`Ansible Inventory Hosts and Groups
<https://docs.ansible.com/ansible/2.7/user_guide/intro_inventory.html#hosts-and-groups>`_.

.. tip::

   Do not add `localhost` as a host in your inventory.
   It is a host specially considered by Ansible.
   If you want to create an inventory node for your local
   machine, add your machine's hostname inside your inventory,
   and specify this host variable: **ansible_connection: local**

Configure for SES Integration
-----------------------------

The file `ses_config.yml`, the output from :ref: `ses_integration` should be
present in the worksapce.

The Ceph admin keyring and user keyring, in **base64**, should be present in the file
`env/extravars` in your workspace.

For example:

.. code-block:: yaml

  ceph_admin_keyring_b64key: QVFDMXZ6dGNBQUFBQUJBQVJKakhuYkY4VFpublRPL1RXUEROdHc9PQo=
  ceph_user_keyring_b64key: QVFDMXZ6dGNBQUFBQUJBQVJKakhuYkY4VFpublRPL1RXUEROdHc9PQo=

Configure for Kubernetes
------------------------

socok8s relies on kubectl and helm commands to configure your OpenStack
deployment. You need to provide a `kubeconfig` file on the `deployer` node,
in your workspace. You can fetch this file from the Velum UI on your
SUSE CaaS Platform cluster.

Configure the VIP that will be used for OpenStack service public endpoints
--------------------------------------------------------------------------

Add `socok8s_ext_vip:` with its appropriate value for your
environment in your `env/extravars`. This should be an available IP
on the external network (in development environment, it can be the same as
CaaSP cluster network).

For example:

.. code-block:: yaml

   socok8s_ext_vip: "10.10.10.10"


Configure the VIP that will be used for Airship UCP service endpoints
--------------------------------------------------------------------------

Add `socok8s_dcm_vip:` with its appropriate value for your
environment in your `env/extravars`. This should be an available IP
on the Data Center Management (DCM) network (in development environment, it
can be the same as CaaSP cluster network).

For example:

.. code-block:: yaml

   socok8s_dcm_vip: "192.168.51.35"


Configure Cloud Scale Profile
-----------------------------

The pod scale profile in socok8s allows you to specify the desired number of
pods that each Airship and Openstack service should run.

There are two built-in scale profiles: `minimal` and `ha`. `minimal` will
deploy exactly one pod for each service, making it suitble for demo or tryout
on a resource limited system. `ha`, as you have guessed, ensures at least two
instances of pods for all services, and three or more pods for services that
require quorum and are more heavily used.

To specify the scale profile to use, add `scale_profile:` in the
`env/extravars`.

For example:


.. code-block:: yaml

   scale_profile: ha

The definitions of the pod scale prolfile can be found in this repository:
playbooks/roles/airship-deploy-ucp/files/profiles.

You can customize the built-in profile or create your own profile following
the file name convention.


Advanced configuration
----------------------

socok8s deployment variables respects Ansible general precedence.
All the variables can therefore be adapted.

Keep in mind you can override most user facing variables with host vars and
group vars.

.. note ::

   You can also use extravars, as extravars always win.
   That can be used to override any deployment code.
   Use it at your own risk.

socok8s is very flexible, and allows you to override any upstream helm chart's
value with the appropriate overrides.

.. note ::

   Please read the page :ref:`userscenarios` for inspiration on overrides.
