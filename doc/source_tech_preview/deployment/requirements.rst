.. _requirements:


System Requirements
===================

Before you begin the installation, your system must meet the following
requirements.

Infrastructure
--------------

* The `Deployer` must run openSUSE Leap 15 or SUSE Linux Enterprise 15. See the page
  :ref:`setupdeployer` for required deployment tools and packages.

  .. note::
     To install openSUSE Leap 15, follow the instructions at
     https://software.opensuse.org/distributions/leap.

* The :term:`CaaS Platform` cluster must run the latest :term:`CaaS Platform`
  version 3.

  .. note::
     The CaaS Platform Installation Quick Start guide is available at:
     https://www.suse.com/documentation/suse-caasp-3/singlehtml/book_caasp_installquick/book_caasp_installquick.html

* The :term:`SES` cluster must run :term:`SES` version 5.5.

  .. note::
     The SES deployment guide is available at:
     https://www.suse.com/documentation/suse-enterprise-storage-5/singlehtml/book_storage_deployment/book_storage_deployment.html

If you don't bring your own deployer, CaaS Platform cluster and SES, this
tooling can create one for you if you have an OpenStack environment. However,
this is experimental. More details can be found at
:ref:`provisioninfra`.

Minimum Node Specification
--------------------------

:term:`Deployer` node
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
and one or more worker nodes as Openstack compute nodes.

To ensure high availability, we recommend three worker nodes designated for
the Airship and Openstack control plane, and additional number of worker nodes
allocated for compute.

Network Requirements
--------------------

* CaaS Platform networking and spec
    Create necessary CaaS Platform networks before deploying Containerized
    Openstack. Separating traffic by function is recommended but not required.

* Storage Network and spec
    A separate storage network can be created to isolate storage traffic. This
    separate network should be present on the Caas Platform and ses_config.yml
    mon_host: section.

* VIP for Airship and Openstack
    Virtual IP address will be assigned to pods allowing ingress to Airship
    and Openstack services. The ingress IP assignments for these services must
    be on a subnet present on the Caas Platform nodes and an IP that is
    not currently in use. VIPs are configured in env/extravars

* DNS
    Installing Containerized Openstack updates /etc/hosts on all Caas Platform
    nodes and Deployer. If expanding testing beyond these devices, it is
    reccomended to use DNS for sharing this data. It is possible to configure
    the Deployer with dnsmasq to supply DNS functionality, but this is beyond
    the scope of this preview.

  .. note::
     Network configuration examples can be found in :ref:`userscenarios`
