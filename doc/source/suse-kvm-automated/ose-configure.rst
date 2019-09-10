.. _ose-configure:

Configure the Deployment
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
       color = "#EEEEEE"
       label = "Set up KVM hosts"
       caasp -> deployer;
       deployer -> ses [folded];
       ses -> enroll_caasp;
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
       label = "OpenStack deployment"
       setup_caasp_workers -> deploy, patch_upstream [folded];
       patch_upstream -> build_images;
       build_images -> deploy;
     }
   }

All the files for the deployment are in a :term:`workspace`, whose default location
is |socok8s_workspace_default| on `localhost`.
The default name can be changed via the environment variable `SOCOK8S_ENVNAME`

This workspace is structured like an `ansible-runner` directory. It contains:

* an `inventory` folder
* an `env` folder.

This folder must also contain extra files necessary for the deployment, such as
the `ses_config.yml` and the `kubeconfig` files.


Configure the VIP that will be used for OpenStack service public endpoints
--------------------------------------------------------------------------

Add `socok8s_ext_vip:` with its appropriate value for your environment in your
`env/extravars`. This should be an available IP on the external network
(in a development environment, it can be the same as a CaaSP cluster network).

For example:

.. code-block:: yaml

   socok8s_ext_vip: "10.10.10.10"

For other localhost configuration refer to :ref:`configurekvmdeploymentmechanism`

Advanced configuration
----------------------

socok8s deployment variables respect Ansible general precedence. All the
variables can be adapted.

You can override most user facing variables with host vars and group vars.

.. note ::

   You can also use extravars, as they always win. extravars can be used to
   override any deployment code.
   Use it at your own risk.

socok8s is flexible and allows you to override the value of any upstream Helm
chart value with appropriate overrides.

.. note ::

   Please read the page :ref:`userscenarios` for inspiration on overrides.
