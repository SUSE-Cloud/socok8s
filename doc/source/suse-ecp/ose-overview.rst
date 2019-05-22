.. _ose-overview:

Deploy in SUSE ECP Overview
============================

SUSE Engineering Cloud Platform is an OpenStack environment. An experimental
tool is provided for you to bootstrap the `deployer` VM, `CaaS Platform` nodes
and SES on the OpenStack infrastructure before deploying Airship and
Containerized Openstack.

In this scenario, we introduce a new type of host called `localhost`.
`localhost` runs shell scripts and Ansible playbooks. This can be your CI node,
or your development laptop. It can be the same as the `deployer`, but that is
not a requirement.

The following diagram shows the general workflow of a SUSE Containerized
Openstack deployment on an Openstack environment.

.. blockdiag::

   blockdiag {
     default_fontsize = 11;
     localhost [label="Prepare localhost"]
     ses [label="Deploy SES"]
     caasp [label="Deploy CaaS Platform"]
     deployer [label="Deploy deployer\n(optional)"]
     enroll_caasp [label="Enroll CaaS Platform Nodes"]

     configure [label="Configure\n Cloud"]
     setup_caasp_workers [label="Setup CaaS Platform\nworker nodes"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build Docker images\n(for developers)"]
     deploy_airship [label="Deploy Airship"]
     deploy_openstack [label="Deploy OpenStack"]

     localhost -> ses;

     group {
       color = "#EEEEEE"
       label = "Setup hosts"
       ses -> caasp;
       caasp -> deployer [folded];
       deployer -> enroll_caasp;
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
