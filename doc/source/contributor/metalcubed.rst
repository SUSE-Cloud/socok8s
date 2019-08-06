Metal³-Bare Metal Provisioning for Kubernetes
=============================================


**What is  Metal³ ?**

The Metal³ project (pronounced: Metal Kubed)  provides components for  bare metal host management for Kubernetes. Metal³ aims to build on  OpenStack Ironic  to provide a Kubernetes native API for managing bare metal hosts via a provisioning stack that is also running on Kubernetes.  The Metal³ project is also building integration with the Kubernetes `cluster-api <https://github.com/kubernetes-sigs/cluster-api>`_
project, allowing Metal³ to be used as an infrastructure backend for Machine objects from the Cluster API.

We plan to use  Metal³  for bare metal host management  , integrating with `Airship 2.0  <https://wiki.openstack.org/wiki/Airship>`_  for Cloud10.


* Interesting Read

  https://thenewstack.io/metal3-uses-openstacks-ironic-for-declarative-bare-metal-kubernetes/

  https://blog.russellbryant.net/2019/04/30/metal%C2%B3-metal-kubed-bare-metal-provisioning-for-kubernetes/


.. |br| raw:: html
* Github Resources

  https://github.com/metal3-io/metal3-docs
  https://github.com/metal3-io/baremetal-operator


.. |br| raw:: html

.. |br| raw:: html

**Architecture**

.. image:: ./metalkubed-architecture.png


**Key Components**

- Machine API Actuator

- Bare Metal Operator

- Bare Metal Management Pods




``Machine API Actuator``

The first component is the `Bare Metal Actuator <https://github.com/metal3-io/cluster-api-provider-baremetal>`_
, which is an implementation of the Machine Actuator interface defined by the cluster-api project. This actuator reacts to changes to Machine objects and acts as a client of the BareMetalHost custom resources managed by the Bare Metal Operator.

``Bare Metal Operator``

The architecture also includes a new `Bare Metal Operator <https://github.com/metal3-io/baremetal-operator>`_
, which includes the following:

A Controller for a new Custom Resource, BareMetalHost. This custom resource represents an inventory of known (configured or automatically discovered) bare metal hosts. When a Machine is created the Bare Metal Actuator will claim one of these hosts to be provisioned as a new Kubernetes node.
In response to BareMetalHost updates, will perform bare metal host provisioning actions as necessary to reach the desired state. It will do so by managing and driving a set of underlying bare metal provisioning components.
The creation of the BareMetalHost inventory can be done in two ways:

Manually via creating BareMetalHost objects.
Optionally, automatically created via a bare metal host discovery process. Ironic is capable of doing this, which will also be integrated into Metal³ as an option.
For more information about Operators, see the `operator-sdk <https://github.com/operator-framework/operator-sdk>`_
.

``Bare Metal Management Pods``

The implementation will focus on using Ironic as its first implementation of the Bare Metal Management Pods, but aims to keep this as an implementation detail under the hood such that alternatives could be added in the future if the need arises.

For more information about the choice to use Ironic, see the `use-ironic design <https://github.com/metal3-io/metal3-docs/blob/master/design/use-ironic.md>`_
document.

Setup Metal³ in  Local Environment
++++++++++++++++++++++++++++++++++

This assumes you have a running CaaSP cluster and kubectl can connect to that.

Requirements
  - python
  - podman



1) Install operator sdk

.. code-block:: console

   export GOPATH=~/go
   mkdir -p $GOPATH/src/github.com/operator-framework
   cd $GOPATH/src/github.com/operator-framework
   git clone https://github.com/operator-framework/operator-sdk
   cd operator-sdk
   make install
   export PATH=$PATH:~/go/bin


2) Create a namespace to host the operator


    kubectl create namespace metal3


3) Install baremetal-operator

.. code-block:: console


   eval $(go env)
   mkdir -p $GOPATH/src/github.com/metal3-io
   cd $GOPATH/src/github.com/metal3-io
   git clone https://github.com/metal3-io/baremetal-operator.git
   cd baremetal-operator
   kubectl apply -f deploy/service_account.yaml -n metal3
   kubectl apply -f deploy/role.yaml -n metal3
   kubectl apply -f deploy/role_binding.yaml
   kubectl apply -f deploy/crds/metal3_v1alpha1_baremetalhost_crd.yaml

4) Launch the operator locally

.. code-block:: console

   export PATH=$PATH:~/go/bin
   cd $GOPATH/src/github.com/metal3-io/baremetal-operator
   export OPERATOR_NAME=baremetal-operator
   export DEPLOY_KERNEL_URL=http://172.22.0.1/images/ironic-python-agent.kernel
   export DEPLOY_RAMDISK_URL=http://172.22.0.1/images/ironic-python-agent.initramfs
   export IRONIC_ENDPOINT=http://localhost:6385/v1/
   export IRONIC_INSPECTOR_ENDPOINT=http://localhost:5050/v1
   operator-sdk up local --namespace=metal3

5) Install the VBMC (This is optional)

.. code-block:: console

   sudo pip install virtualenvwrapper
   source $(which virtualenvwrapper.sh)
   mkvirtualenv vbmc


6) Create some VMs in libvirt to be our bare metal hosts

7) Create VBMC servers for them.  *Note: every "vbmc" instance needs its own port to listen on.*

.. code-block:: console

   vbmc add --username admin --password password --port 15015 <libvirt_domain_name>
   vbmc start <libvirt_domain_name>

8) Write a yaml file to describe the machine and add to cluster. Create a machine. Be sure to update the names and addresses for your paticular machine

   *Note: the ip address of the bmc should be an ip adress that is accessible from any machine ont he kubernetes cluster.*


.. code-block:: console

   cd $GOPATH/src/github.com/metal3-io/baremetal-operator
   export MACHINE_MAC=$(virsh -c qemu:///system domiflist <libvirt_domain_name> | grep network | awk '{print $5}' | head -n 1)
   go run cmd/make-bm-worker/main.go -user admin -password password -address http://192.168.122.1:<vbmc_port>/ -boot-mac $MACHINE_MAC <libvirt_domain_name> | kubectl -n metal3 apply -f

   #Download agent files
   curl https://images.rdoproject.org/master/rdo_trunk/current-tripleo-rdo/ironic-python-agent.tar | tar -xf -


   # Download OS images.

   # SLE:
   curl -LO http://download.suse.de/install/SLE-15-SP1-JeOS-GM/SLES15-SP1-JeOS.x86_64-15.1-OpenStack-Cloud-GM.qcow2
   mv SLES15-SP1-JeOS.x86_64-15.1-OpenStack-Cloud-GM.qcow2 SLES15-SP1.qcow2
   md5sum SLES15-SP1.qcow2 | awk '{print $1}' > SLES15-SP1.qcow2.md5sum

   # openSUSE:
   curl -LO http://download.opensuse.org/distribution/leap/15.1/jeos/openSUSE-Leap-15.1-JeOS.x86_64-15.1.0-OpenStack-Cloud-Current.qcow2
   mv openSUSE-Leap-15.1-JeOS.x86_64-15.1.0-OpenStack-Cloud-Current.qcow2 openSUSE-Leap-15.1.qcow2
   md5sum openSUSE-Leap-15.1.qcow2 | awk '{print $1}' > openSUSE-Leap-15.1.qcow2.md5sum

9) Start Ironic

.. code-block:: console

   cd $GOPATH/src/github.com/metal3-io/baremetal-operator
   tools/run_local_ironic.sh

10) Create Machine

.. code-block:: console

   cd $GOPATH/src/github.com/metal3-io/baremetal-operator
   tools/create_machine.sh <name> <image_name>
