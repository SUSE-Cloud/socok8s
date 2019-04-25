Installation Overview
=====================

This guide refers to the following types of hosts:

* A `deployer`, which has dual roles, the starting point to invoke the
  socok8s scripts and Ansible playbooks, and point of the access to your
  Kubernetes cluster. This can be your CI node, a laptop or a dedicted VM.
* A series of :term:`CaaS Platform` nodes: `workers`, `administration node`,
  `master`.
* A series of :term:`SES` nodes.

The following diagram shows the general workflow of a SUSE Containerized
Openstack deployment on an already installed  SUSE CaaS Platform cluster and
SUSE Enterprise Storage.

.. blockdiag::

   blockdiag {
     default_fontsize = 11;
     deployer [label="Setup deployer"]
     ses_integration [label="SES Integration"]
     configure [label="Configure\n Cloud"]
     setup_caasp_workers [label="Setup CaaS Platform\nworker nodes"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build Docker images\n(for developers)"]
     deploy_airship [label="Deploy Airship"]
     deploy_openstack [label="Deploy OpenStack"]
     
     deployer -> ses_integration;
     ses_integration -> configure_soc;
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

For users who don't have SUSE CaaS Platform and SES but are interested to try
out the technical preview, an experiemental tool is included to install a
minimal SUSE CaaS Platform cluster and a SES AIO when bootstraping for the
Containerized Openstack deployment. The instructions can be found on the page
:ref:`provisioninfra`.
