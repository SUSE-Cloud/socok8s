Cluster API for Kubernetes
==========================


**What is Cluster API ?**

The Cluster API is a Kubernetes project to bring declarative, Kubernetes-style APIs to cluster creation, configuration, and management. It provides optional, additive functionality on top of core Kubernetes. One of the aims of the `Cluster <https://cluster-api.sigs.k8s.io/GLOSSARY.html#cluster>`_
API project is to leverage the relative uniformity of Kubernetes APIs and associated tooling to make it easier for ordinary users to access computational resources in a portable way. The initial Alpha release came out in March 2019

We plan to use Cluster API  for Cluster Management  with `Airship 2.0 <https://wiki.openstack.org/wiki/Airship>`_
for Cloud10.

**Key Resources**

* Github Page
   https://github.com/kubernetes-sigs/cluster-api


* Cluster API Documentation
   https://cluster-api.sigs.k8s.io/


* Video Tutorial
   https://youtube.com/watch?v=sCD50fO95hI




**Existing Providers**

A great way to become acquainted with the Cluster API is to start using it. There are multiple implementations of the Cluster API for different environments. These implementations are called providers. To find a partial list of the existing providers see the Cluster API `Provider Implementations List <https://github.com/kubernetes-sigs/cluster-api/blob/master/README.md#provider-implementations>`_
.

OpenStack is one of the providers.  To implement  Cluster API on  OpenStack  go to  https://github.com/kubernetes-sigs/cluster-api-provider-openstack


**Architecture**

.. image:: ./architecture.png


**Key Components of Cluster API**

- Cluster Resources

- ClusterSpec

- ClusterStatus

``Cluster Resources``

A Cluster represents the global configuration of a Kubernetes cluster.

``Cluster``

A `Cluster <https://cluster-api.sigs.k8s.io/GLOSSARY.html#cluster>`_
has 4 fields:

``Spec`` contains the desired cluster state specified by the object. While much of the Spec is defined by users, unspecified parts may be filled in with defaults or by Controllers such as autoscalers.

``Status`` contains only observed cluster state and is only written by controllers. Status is not the source of truth for any information, but instead aggregates and publishes observed state.

``TypeMeta`` contains metadata about the API itself - such as Group, Version, Kind.

``ObjectMeta`` contains metadata about the specific object `instance <https://cluster-api.sigs.k8s.io/GLOSSARY.html#instance>`_
, for example, it's name, namespace, labels, and annotations, etc. ``ObjectMeta`` contains data common to most objects.


.. code-block:: go

    type Cluster struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    Spec   ClusterSpec   `json:"spec,omitempty"`
    Status ClusterStatus `json:"status,omitempty"`

   }

``ClusterSpec``

The ``ClusterNetwork`` field includes the information necessary to configure kubelet networking for ``Pods`` and ``Services``.

The ``ProviderSpec`` is recommended to be a serialized API object in a format owned by that `provider <https://cluster-api.sigs.k8s.io/GLOSSARY.html#provider>`_
. This will allow the configuration to be strongly typed, versioned, and have as much nested depth as appropriate. These provider-specific API definitions are meant to live outside of the `Cluster <https://cluster-api.sigs.k8s.io/GLOSSARY.html#cluster>`_  API, which will allow them to evolve independently of it.

.. code-block:: go

    type ClusterSpec struct {
    ClusterNetwork ClusterNetworkingConfig `json:"clusterNetwork"`
    ProviderSpec ProviderSpec `json:"providerSpec,omitempty"`

    }



``ClusterStatus``

Like ``ProviderSpec``, ``ProviderStatus`` is recommended to be a serialized API object in a format owned by that `provider <https://cluster-api.sigs.k8s.io/GLOSSARY.html#provider>`_
.



Cluster API on OpenStack
++++++++++++++++++++++++

Complete information is available  at https://github.com/kubernetes-sigs/cluster-api-provider-openstack

**Create Cluster on Openstack**

``Prerequisites``


1) Install kubectl (you need version 1.14.0+)

2) You can use either VM, container or existing Kubernetes cluster act as bootstrap cluster). Here we will use an existing Kubernetes cluster to bootstrap.

3) Install a configured Go development environment. (https://golang.org/doc/install)

4) Build the clusterctl tool

.. code-block:: console

  git clone https://github.com/kubernetes-sigs/cluster-api-provider-openstack $GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack
  cd $GOPATH/src/sigs.k8s.io/cluster-api-provider-openstack/
  make clusterctl


**Cluster Creation (Using an existing Kubernetes cluster to bootstrap)**

1) Create the cluster.yaml, machines.yaml, provider-components.yaml, and addons.yaml files needed

.. code-block:: console

   cd examples/openstack
   ./generate-yaml.sh [options] <path/to/clouds.yaml> <openstack cloud> <provider os: [centos,ubuntu,coreos]> [output folder]
   cd ../..

2) Execute the cluster create command

.. code-block:: console

   ./clusterctl create cluster --bootstrap-cluster-kubeconfig ~/.kube/config \
   --provider openstack -c examples/openstack/out/cluster.yaml \
   -m examples/openstack/out/machines.yaml \
   -p examples/openstack/out/provider-components.yaml

**Steps to create Custom Provider**

``Prerequisites``


1) Install go language 

2) Install dep

.. code-block:: console

   curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
   sudo mv $HOME/bin/dep /usr/bin

3) Install kustomize

.. code-block:: console

   wget https://github.com/kubernetes-sigs/kustomize/releases/download/v1.0.11/kustomize_1.0.11_linux_amd64
   mv kustomize_1.0.11_linux_amd64 kustomize
   chmod +x kustomize
   sudo mv kustomize /usr/bin/

4) Install kubebuilder (contains a copy of kubectl, etcd and kubeapi-server)

.. code-block:: console
 
   wget https://github.com/kubernetes-sigs/kubebuilder/releases/download/v1.0.8/kubebuilder_1.0.8_linux_amd64.tar.gz
   tar xvf kubebuilder_1.0.8_linux_amd64.tar.gz
   mv kubebuilder_1.0.8_linux_amd64 kubebuilder
   sudo mv kubebuilder /usr/local
 

``Generation Steps for CRDs``

.. code-block:: console

   kubebuilder init --domain <provider>.org --license apache2 --owner "The Kubernetes Authors"
   git add .
   git commit -m "Generate scaffolding."
   git push
   kubebuilder create api --group <provider> --version v1alpha1 --kind <Provider>ClusterProviderSpec

   kubebuilder create api --group <provider> --version v1alpha1 --kind <Provider>ClusterProviderStatus
   kubebuilder create api --group <provider> --version v1alpha1 --kind <Provider>MachineProviderStatus
   kubebuilder create api --group <provider> --version v1alpha1 --kind <Provider>MachineProviderSpec

The user cluster config code will be written in  ``~/go/src/cluster-api-provider-<provider>/pkg/apis/<provider>/v1alpha1/<provider>clusterproviderspec_types.go``

The user machine config will be written in ``~/go/src/cluster-api-provider-<provider>/pkg/apis/<provider>/v1alpha1/<provider>machineproviderspec_types.go``

``Register Schemes``

The manager process generated by kubebuilder only knows about the resources we defined. It does not know about the resources defined by the common Cluster API code. 

.. code-block:: console

   vi cmd/manager/main.go

``Creating Actuators``

Actuator needs different provider implementations.So, to develop custom infrastructure provider, develop Actuator code for it.

.. code-block:: console

   mkdir -p pkg/cloud/<provider>/actuators/cluster/
   mkdir -p pkg/cloud/<provider>/actuators/machine/
   vi pkg/cloud/<provider>/actuators/cluster/actuator.go - This is where the code for creating the cluster and reconciliation go for Yomi integration
   vi pkg/cloud/<provider>/actuators/machine/actuator.go   This is where the code for creating the machine and reconciliation go for Yomi integration

``Register Controllers``

.. code-block:: console

   vi pkg/controller/add_cluster_controller.go 
   vi pkg/controller/add_machine_controller.go

``Building``

.. code-block:: console

   vi Makefile

``Build and push images``

.. code-block:: console

   export IMG=<repo-owner>/cluster-api-provider-<provider>
   dep ensure
   make
   make docker-build IMG=${IMG}
   git add .
   git commit -m "Add CRDs and build image"
   git push

For detailed description of creating a custom provider, Please refer to https://cluster-api.sigs.k8s.io/
