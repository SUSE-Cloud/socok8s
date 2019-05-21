Installation Overview
=====================

This guide refers to the following types of hosts:

* A `deployer` with dual roles. It is the starting point for invoking the
  deployment socok8s scripts and Ansible playbooks. And it is the access point
  to your Kubernetes cluster. A deployer can be a continuous integration (CI) node,
  a laptop, or a dedicated VM.
* A series of :term:`CaaS Platform` nodes: `administration node`, `master`, `workers`.
* A series of :term:`SES` nodes.

The following diagram shows the general workflow of a SUSE Containerized
Openstack deployment on an installed SUSE CaaS Platform cluster and
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

Users who do not have SUSE CaaS Platform and SES can still try out the technical
preview. An experimental tool is included to install a minimal SUSE CaaS Platform
cluster and an SES all-in-one (AIO) for bootstrapping the SUSE Containerized
Openstack deployment. The instructions can be found on the page :ref:`provisioninfra`.
