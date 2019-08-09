Rook for Kubernetes
===================


**What is Rook ?**

Rook is a storage orchestrator for Kubernetes. Rook turns distributed storage systems into self-managing, self-scaling, self-healing storage services. It automates the tasks of a storage administrator: deployment, bootstrapping, configuration, provisioning, scaling, upgrading, migration, disaster recovery, monitoring, and resource management.

Rook uses the power of the Kubernetes platform to deliver its services: cloud-native container management, scheduling, and orchestration.

**Key Resources**

* Github Page
   https://github.com/rook/rook


* Rook Getting Started Guide
   https://rook.github.io/docs/rook/master/


* Video Tutorial
   https://www.youtube.com/watch?v=pwVsFHy2EdE

* Interesting Read
   https://akomljen.com/rook-cloud-native-on-premises-persistent-storage-for-kubernetes-on-kubernetes/

   https://superuser.openstack.org/articles/rook-ceph-kubernetes-quickstart/


* Rook Website `Rook <https://rook.io/>`_


* Rook Slack Channel `Join  <https://slack.rook.io/>`_




**Storage Providers for Rook**


Rook provides a growing number of storage providers to  Kubernetes cluster, each with its own operator to deploy and manage the cluster. The supported storage providers are Ceph, EdgeFS, Cassandra,CockroachDB,Minio and NFS.

Here we will discuss Rook integration with Ceph.


Rook Integration with Ceph
++++++++++++++++++++++++++

Ceph is a highly scalable distributed storage solution for block storage, object storage, and shared file systems with years of production deployments. Rook enables Ceph storage systems to run on Kubernetes using Kubernetes primitives. The following image illustrates how Ceph Rook integrates with Kubernetes.


|
|


.. image:: ./rook-ceph.png

|
|



With Rook running in the Kubernetes cluster, Kubernetes applications can mount block devices and filesystems managed by Rook, or can use the S3/Swift API for object storage. The Rook operator automates configuration of storage components and monitors the cluster to ensure the storage remains available and healthy.

The Rook operator is a simple container that has all that is needed to bootstrap and monitor the storage cluster. The operator will start and monitor `ceph monitor pods <https://github.com/rook/rook/blob/master/design/mon-health.md>`_ and a daemonset for the OSDs, which provides basic RADOS storage. The operator manages CRDs for pools, object stores (S3/Swift), and file systems by initializing the pods and other artifacts necessary to run the services.

The operator will monitor the storage daemons to ensure the cluster is healthy. Ceph mons will be started or failed over when necessary, and other adjustments are made as the cluster grows or shrinks. The operator will also watch for desired state changes requested by the api service and apply the changes.

The Rook operator also creates the Rook agents. These agents are pods deployed on every Kubernetes node. Each agent configures a Flexvolume plugin that integrates with Kubernetes’ volume controller framework. All storage operations required on the node are handled such as attaching network storage devices, mounting volumes, and formating the filesystem.

**Architecture**

|
|


.. image:: ./rook-architecture.png

|
|

The rook container includes all necessary Ceph daemons and tools to manage and store all data – there are no changes to the data path. Rook does not attempt to maintain full fidelity with Ceph. Many of the Ceph concepts like placement groups and crush maps are hidden so you don’t have to worry about them. Instead Rook creates a much simplified UX for admins that is in terms of physical resources, pools, volumes, filesystems, and buckets. At the same time, advanced configuration can be applied when needed with the Ceph tools.

Rook is implemented in golang. Ceph is implemented in C++ where the data path is highly optimized. We believe this combination offers the best of both worlds.


**Rook Quick Start Guide**

This guide will walk you through the basic setup of a Ceph cluster and enable you to consume block, object, and file storage from other pods running in your cluster.

Here are the requirements and further `instructions  <https://rook.io/docs/rook/v0.9/ceph-quickstart.html>`_. Please make sure you start with the latest stable version.



**Contribute to Rook Project**

Rook project is under Apache license. To contribute access `here. <https://github.com/rook/rook/blob/master/CONTRIBUTING.md#how-to-contribute>`_
