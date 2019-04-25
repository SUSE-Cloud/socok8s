.. _provisioninfra:


Provision CaaS Platform cluster and SES (experimental)
======================================================


* `localhost` can run any OS. Please check its software requirements on the
  page :ref:`preparelocalhost`.

* `deployer` must run openSUSE Leap 15 or SLE 15. Those must have all the
  deployment tools available. See more details on the page
  :ref:`targethosts`.

  .. note::
     If you are not coming with your own node for `deployer`, this tooling
     can create one for you in an OpenStack environment. However, this should
     be treated as experimental.

* The :term:`CaaS Platform` cluster must run :term:`CaaS Platform` version 3.
  :term:`CaaS Platform` must be updated to its latest 3 version.

  .. note::
     If you are not coming with your own :term:`CaaS Platform` cluster,
     this tooling can create one for you in an OpenStack environment.
     However, this should be treated as experimental.

* The :term:`SES` cluster must run :term:`SES` version 5.5.

  .. note::
     If you are not coming with your own :term:`SES` cluster, this tooling can
     create an "All-in-one" node for :term:`SES` for you in an OpenStack
     environment. However, this should be treated `as experimental.

