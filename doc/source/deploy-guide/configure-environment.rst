Configure the deployment
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
       color = "#EEEEEE"
       label = "Setup hosts"
       ses -> caasp;
       caasp -> deployer [folded];
       deployer -> enroll_caasp;
     }
     enroll_caasp -> configure_deployment [folded];
     localhost -> configure_deployment[folded];

     group {
       color = "red"
       configure_deployment
     }

     configure_deployment -> setup_caasp_workers;

     group {
       color = "#EEEEEE"
       label = "Setup openstack/Setup airship"
       setup_caasp_workers -> deploy, patch_upstream [folded];
       patch_upstream -> build_images;
       build_images -> deploy;
     }
   }

All the files for the deployment are in a workspace, whose default location
is `~/suse-osh-deploy` on `localhost`.

This workspace is structured like an `ansible-runner` directory.

It therefore contains:

* an `inventory` folder
* an `env` folder.

Additionally, this folder will contain extra files necessary for the
deployment.

Configure the inventory
-----------------------

If you are bringing your own cluster, create an inventory based on our
example, located in the `examples` folder.

.. literalinclude:: ../../../examples/workdir/inventory/hosts.yml

As you can see, this inventory only contains the group names.

For each group, a `hosts:` key should be added, with, as value, each
of the hosts you will need. For example:

.. code-block:: yaml

   caasp-admin:
     hosts:
       jevrard-57997-admin-x6sugiws4g34:
         ansible_host: 10.86.1.144

See also
`Ansible Inventory Hosts and Groups
<https://docs.ansible.com/ansible/2.7/user_guide/intro_inventory.html#hosts-and-groups>`_.

.. tip::

   Do not add `localhost` as a host in your inventory.
   It is a host specially considered by Ansible.
   If you want to create an inventory node for your local
   machine, add your machine's hostname inside your inventory,
   and specify this host variable: **ansible_connection: local**

Make the SES pools known by Ansible
-----------------------------------

Currently, we rely on two things to know the SES pools created for the
Airship/OpenStack deployment:

* a `ses_config.yml` file present in the workspace
* the ceph admin keyring, in base64, present in the file `env/extravars` of
  your workspace.

You can find examples of the required files in `examples/workdir`.

Configure the VIP that will be used for OpenStack
-------------------------------------------------

Add `socok8s_ext_vip` with its appropriate value for your
environment in your `env/extravars`. This should be an available IP
on the same network as your CaaSP cluster.

For example:

.. code-block:: yaml

   socok8s_ext_vip: "192.168.50.35/24"

Configure certificates for your own registry
--------------------------------------------

If you want to run developer mode, and want to bring your own registry's SSL
certificates, you can define, in your extra vars:

.. code-block:: yaml

   socok8s_registry_certkey:
   socok8s_registry_cert:

The variables should point to files present in your `localhost`.

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

socok8s is very flexible, and allows you to
override any upstream helm chart's value with the appropriate overrides.

.. note ::

   Please read the :ref:`userscenarios` for inspiration on overrides.
