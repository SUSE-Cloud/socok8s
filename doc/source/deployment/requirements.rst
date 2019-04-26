.. _requirements:


System Requirements
===================

Before you begin the installation, please make sure your system meets all the
requirements listed below.

Infrastructure
--------------

* The `deployer` must run openSUSE Leap 15 or SLE 15. See more details on the
  page :ref:`setupdeployer` for required deployment tools and packages.

  .. note::
     To install openSUSE Leap 15, you can follow the instructions from the page
     https://software.opensuse.org/distributions/leap.

* The :term:`CaaS Platform` cluster must run :term:`CaaS Platform` version 3.
  :term:`CaaS Platform` must be updated to its latest 3 version.

  .. note::
     CaaS Platform Installation Quick Start guide can be found here:
     https://www.suse.com/documentation/suse-caasp-3/singlehtml/book_caasp_installquick/book_caasp_installquick.html

* The :term:`SES` cluster must run :term:`SES` version 5.5.

  .. note::
     SES deployment guide can be found here:
     https://www.suse.com/documentation/suse-enterprise-storage-5/singlehtml/book_storage_deployment/book_storage_deployment.html

If you don't bring your own deployer, CaaS Platform cluster and SES, this
tooling can create one for you if you have an OpenStack environment. However,
this should be treated as experimental. More details can be found at
:ref:'provisioninfra'.

Minimum Node Specification
--------------------------

:term:`deployer` node
+++++++++++++++++++++

* (v)CPU: 4
* Memory: 4GB
* Storage: 40GB

:term:`CaaS Platform` worker node
+++++++++++++++++++++++++++++++++

* (v)CPU: 6
* Memory: 16GB
* Storage: 80GB

  If the work node is used as Compute node, sizing shall be determined by
  the target workloads on the compute node.

:term:`SES` AIO node (Experimental only)
++++++++++++++++++++++++++++++++++++++++

* (v)CPU: 6
*  Memory: 16GB
*  Storage: 80GB

Cluster size
------------

A minimal :term:`CaaS Platform` cluster requires one administration node, one
master node and two worker nodes.

SUSE Containerized Openstack enrolls :term:`CaaS Platform` work nodes for two
different purposes: control plane where the Airship and Openstack services
run and compute nodes where customer workloads are hosted.

For a minimal cloud, you should plan one worker node for the control plane,
and one or more worker nodes as Openstck compute nodes.

To ensure high availability, we recommend three worker nodes designated for
the Airship and Openstack contol plane, and additonal number of worker nodes
allocated for compute.

Network Requirements
--------------------

* CaaS Platform networking and spec
    Create CaaS Platform networks needed before deploying Containerized
    Openstack. Seperating traffic by function is recomended but not required.

* Storage Network and spec
    A seperate storage network can be created to isolate storage traffic. This
    seperate network should be present on the Caas Platform and ses_config.yml
    mon_host: section.

* VIP for Airship and Openstack
    Virtual IP address will be assigned to pods allowing ingress to Airship
    and Openstack services. The ingress IP assingments for these services must
    be on a subnet that is present on the Caas Platform nodes and an IP that is
    not currently in use. VIP's are configured in env/extravars

* DNS
    Installing Containerized Openstack updates /etc/hosts on all Caas Platform
    nodes and Deployer. If expanding testing beyond these devices, it is
    recomended to use DNS for sharing this data. It is possible to configure
    deployer with dnsmasq to supply DNS functionality but beyond the scope of
    this preview.

  .. note::
     Network configuration examples can be found in :ref:`userscenarios`
