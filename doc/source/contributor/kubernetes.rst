Kubernetes
==========

Kubernetes Resources:
---------------------

* Kubernetes official webpage:
    https://kubernetes.io
* Kubernetes documentation:
    https://kubernetes.io/docs/home/
* Kubernetes basic tutorial:
    https://kubernetes.io/docs/tutorials/kubernetes-basics/
* Minikube git page:
    https://github.com/kubernetes/minikube
* Minikube tutorial:
    https://kubernetes.io/docs/setup/learning-environment/minikube/
* Kubectl cheatsheet:
    https://kubernetes.io/docs/reference/kubectl/cheatsheet/

An easy way to understand Kubernetes is with the
`Kubernetes Basics tutorial <https://kubernetes.io/docs/tutorials/kubernetes-basics/>`_,
which provides an interactive console for learning commands. It is useful to
install a `minikube` on your local machine or in a virtual machine for a more
realistic, hands-on experience of Kubernetes.

Keys to learn
-------------
* Deployment_
* Pod_
* Service_
* Labels_
* `Scale an app`_
* `Rolling updates`_

.. _Deployment: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
.. _Pod: https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/
.. _Service: https://kubernetes.io/docs/concepts/services-networking/service/
.. _Labels: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
.. _Scale an app: https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/scale-intro/
.. _Rolling updates: https://kubernetes.io/docs/concepts/containers/images/


Deployment
++++++++++

A Deployment controller provides declarative updates for Pods and ReplicaSets.
`Learn more about Kubernetes Deployments <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>`_.

Create a deployment.

.. code-block:: console

  kubectl run <myDeployment> --image=<myImage>:<version> --port=8080

Check current deployments.

.. code-block:: console

  kubectl get deployments

Create a proxy. The ports will be accessible from outside the pod.

.. code-block:: console

  kubectl proxy


Access to the pod proxy.

.. code-block:: console

  curl http://localhost:8001/api/v1/namespaces/default/pods/<pod name>/proxy/


Pods
++++

A Pod is the basic execution unit of a Kubernetes application.
`Learn more about pods <https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/>`_.

Get information about Pods.

.. code-block:: console

  kubectl get pods
  kubectl describe pods
  kubectl get pods -o wide

Get a Pod log.

.. code-block:: console

  kubectl logs <pod name>

Execute a command inside a Pod.

.. code-block:: console

  kubectl exec <pod name> <command>

.. note ::

   The name of the Pod (or container) can be omitted if there is only one Pod
   (or container).

Open a bash session.

.. code-block:: console

  kubectl exec -ti <pod name> bash

Services
++++++++

A `Service` is an abstract way to expose an application running on a set of
Pods as a network service. There are different kinds of services.
`Learn more about services <https://kubernetes.io/docs/concepts/services-networking/service/>`_.

Get services.

.. code-block:: console

  kubectl get services
  kubectl describe services

Create a new service (expose it as `NodePort` accessible from outside the
cluster).

.. code-block:: console

  kubectl expose deployment/<myDeployment> --type="NodePort" --port 8080

Get details about a resource.

.. code-block:: console

  kubectl describe service/<myDeployment>

Connect to a port (via cluster ip).

.. code-block:: console

  curl $(minikube ip):<node port>

Delete a service.
$ kubectl delete service -l run=<my deployment>

Labels
++++++

Labels are key/value pairs that are attached to objects, such as Pods. Labels
are used to group different objects (for example, Pods, services, deployments)
when a command is applied.
`Learn more about Labels <https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/>`_.

Using labels

.. code-block:: console

  kubectl get pods -l run=<my deployment>
  kubectl get services -l run=<my deployment>

Add labels

.. code-block:: console

  kubectl label pod <pod name> app=v1


Scaling the application
+++++++++++++++++++++++

Scaling is used to add more replicas of a Pod, such as when traffic increases.
`Learn more about scaling <https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/scale-intro/>`_.

Scale (or downscale) an application.

.. code-block:: console

  kubectl scale deployments/<my deployment> --replicas=4

See the status.

.. code-block:: console

  kubectl get deployments
  kubectl describe deployments/<my deployment>

See the loadbalancer in the default service.

.. code-block:: console

  kubectl describe services/<my deployment>


Updating the image
++++++++++++++++++

Kubernetes allows for updating a Pod image without interrupting the service, and
rollbacking an operation if necessary.
`Learn more about updating images <https://kubernetes.io/docs/concepts/containers/images/>`_.

Change an image.

.. code-block:: console

  kubectl set image deployments/<myDeployment> <myContainer>=<myImage>:<version>

Check current status.

.. code-block:: console

  kubectl rollout status deployments/<myDeployment>

See the current version of each Pod and to see errors if any.

.. code-block:: console

  kubectl describe pods

Undo an update.

.. code-block:: console

  kubectl rollout undo deployments/<myDeployment>


Minikube playground
-------------------

Minikube is a tool for running Kubernetes locally. It is available at
https://github.com/kubernetes/minikube.

Launching Minikube is simple.

.. code-block:: console

  minikube start


Minikube requires VirtualBox (by default) or KVM (recommended for Linux).
To use Minikube with KVM, launch it with the flag ``--vm-driver`.

.. code-block:: console

  minikube start --vm-driver kvm2
