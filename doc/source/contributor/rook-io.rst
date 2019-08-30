Rook for Kubernetes
===================


**What is Rook?**

Rook is a storage orchestrator for Kubernetes. Rook turns distributed storage
systems into self-managing, self-scaling, self-healing storage services. It
automates the tasks of a storage administrator: deployment, bootstrapping,
configuration, provisioning, scaling, upgrading, migration, disaster recovery,
monitoring, and resource management.

Rook uses aspects of the Kubernetes platform to deliver its services:
cloud-native container management, scheduling, and orchestration.

**Key Resources**

* Github Page
   https://github.com/rook/rook


* Rook Getting Started Guide
   https://rook.github.io/docs/rook/master/


* Video Introduction to Rook
   https://www.youtube.com/watch?v=pwVsFHy2EdE

* In-depth Reads
   https://akomljen.com/rook-cloud-native-on-premises-persistent-storage-for-kubernetes-on-kubernetes/

   https://superuser.openstack.org/articles/rook-ceph-kubernetes-quickstart/


* Rook Website `Rook <https://rook.io/>`_


* Rook Slack Channel `Join  <https://slack.rook.io/>`_




**Storage Providers for Rook**


Rook supports a growing number of storage providers to Kubernetes clusters,
each with its own operator to deploy and manage clusters. The supported
storage providers are Ceph, EdgeFS, Cassandra, CockroachDB, Minio, and NFS.

The following is an example of Rook integration with Ceph.


Rook Integration with Ceph
++++++++++++++++++++++++++

Ceph is a highly scalable distributed storage solution for block storage,
object storage, and shared file systems. Rook enables Ceph storage systems to
run on Kubernetes using Kubernetes primitives. The following image illustrates
how Ceph Rook integrates with Kubernetes.


.. image:: ./rook-ceph.png


With Rook running in the Kubernetes cluster, Kubernetes applications can mount
block devices and filesystems managed by Rook, or they can use the S3/Swift API
for object storage. The Rook operator automates configuration of storage
components and monitors the cluster to ensure the storage remains available and
healthy.

The Rook operator is a simple container that has everything needed to bootstrap
and monitor the storage cluster. The operator starts and monitors
`ceph monitor pods <https://github.com/rook/rook/blob/master/design/mon-health.md>`_
and a daemonset for the object storage daemons (OSDs), which provides basic
RADOS storage. The operator manages custom resource definitions (CRDs) for
pools, object stores (S3/Swift), and file systems by initializing the Pods and
other artifacts necessary to run the services.

The operator monitors the storage daemons to ensure the cluster is healthy. Ceph
monitors (MONs) are started or failed over when necessary. Other adjustments
are made as the cluster grows or shrinks. The operator also watches for desired
state changes requested by the API service and applies the changes.

The Rook operator also creates Rook agents. These agents are Pods deployed on
every Kubernetes node. Each agent configures a `Flexvolume <https://github.com/kubernetes/community/blob/master/contributors/devel/sig-storage/flexvolume.md/>`_
plugin that integrates with the Kubernetes volume controller framework. Agents
handle all storage operations such as attaching network storage devices,
mounting volumes on the host, and formatting the filesystem.

**Architecture**

.. image:: ./rook-architecture.png

The Rook container includes all necessary Ceph daemons and tools to manage and
store all data. There are no changes to the data path. Many of the Ceph
concepts, such as  placement groups and crush maps, are hidden, so they do not
have to be managed directly. Rook provides a UX for admins that simplifies
interactions with physical resources, pools, volumes, filesystems, and buckets.
Advanced configuration can be applied when needed with the Ceph tools.


**Rook Quick Start Guide**

The Quick Start Guide covers Rook prerequisites, the basic setup of a Ceph
cluster, and how to consume block, object, and file storage from other Pods
running in the cluster.

See the `Quick Start instructions for Ceph <https://rook.io/docs/rook/v0.9/ceph-quickstart.html>`_.


**Contribute to the Rook Project**

See `How to Contribute <https://github.com/rook/rook/blob/master/CONTRIBUTING.md#how-to-contribute>`_.
