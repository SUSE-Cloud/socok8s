Overview
========

This guide refers to the following type of hosts:

* A `localhost`, which runs shell scripts and ansible playbooks. This can
  be your CI node, or your development laptop.
* A `deployer`, which is your point of access to your kubernetes
  cluster. The `deployer` can be the same as the `localhost`, but it
  is not a requirement.
* A series of :term:`CaaSP` nodes: `workers`, `admin`, `master`.
* A series of :term:`SES` nodes.

The following diagram shows the general workflow of a deployment from scratch:

.. blockdiag::

   blockdiag {
     default_fontsize = 11;
     localhost [label="Prepare localhost"]
     ses [label="Deploy SES\n(optional)"]
     caasp [label="Deploy CaaSP\n(optional)"]
     deployer [label="Deploy deployer\n(optional)"]
     enroll_caasp [label="Enroll CaaSP\n(optional)"]
     setup_caasp_workers [label="Setup CaaSP\nfor OpenStack"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build docker images\n(for developers)"]
     deploy [label="Deploy OpenStack"]
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

     configure_deployment -> setup_caasp_workers;

     group {
       color = "#EEEEEE"
       label = "OpenStack deployment"
       setup_caasp_workers -> deploy, patch_upstream [folded];
       patch_upstream -> build_images;
       build_images -> deploy;
     }
   }

Installation requirements
-------------------------

Your environment should be setup with the following:

* `localhost` can run any OS. Please check its software requirements on the
  page :ref:`preparelocalhost`.

* `deployer` must run openSUSE Leap 15 or SLE15. Those must have all the
  deployment tools available. See more details on the page
  :ref:`targethosts`.

  .. note::
     If you are not coming with your own node for
     `deployer`, this tooling can create one for you in an OpenStack
     environment. However, this should be treated as experimental.

* The :term:`CaaSP` cluster must run :term:`CaaSP` version 3.
  :term:`CaaSP` must be updated to its latest 3 version.

  .. note::
     If you are not coming with your own :term:`CaaSP` cluster,
     this tooling can create one for you in an OpenStack environment.
     However, this should be treated as experimental.

* The :term:`SES` cluster must run :term:`SES` 5.5.

  .. note::
     If you are not coming with your own :term:`SES` cluster,
     this tooling can create an "All-in-one" node for :term:`SES`
     for you in an OpenStack environment. However, this should be treated
     as experimental.
