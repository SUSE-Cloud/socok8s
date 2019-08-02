Kubernetes
==========

List of interesting links:
--------------------------

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

An easy way to understand kubernetes is following the tutorial "kubernetes-basics"
https://kubernetes.io/docs/tutorials/kubernetes-basics/ that provides an interactive console to
tests the commands of the tutorial. However it is also interesting to have installed a minikube in
your local machine or in a virtual machine to increase the experience

Keys to learn
-------------
* Deployment_
* Pod_
* Service_
* Labels_
* `Scale your app`_
* `Rolling updates`_

.. _Deployment: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
.. _Pod: https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)
.. _Service: https://kubernetes.io/docs/concepts/services-networking/service/)
.. _Labels: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
.. _Scale your app: https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/scale-intro/)
.. _Rolling updates: https://kubernetes.io/docs/concepts/containers/images/)


Deployment
++++++++++

A Deployment controller provides declarative updates for Pods and ReplicaSets.
`Learn more about deployments`_

.. _Learn more about deployments: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

Create a deployment

.. code-block:: console

  kubectl run <myDeployment> --image=<myImage>:<version> --port=8080

Check current deployments

.. code-block:: console

  kubectl get deployments

Create a proxy. The ports will be accessibles from outside the pod

.. code-block:: console

  kubectl proxy


Access to the pod proxy

.. code-block:: console

  curl http://localhost:8001/api/v1/namespaces/default/pods/<pod name>/proxy/


Pods
++++

A Pod is the basic execution unit of a Kubernetes application. `Learn more about pods`_

.. _Learn more about pods: https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/

Get pods information

.. code-block:: console

  kubectl get pods
  kubectl describe pods
  kubectl get pods -o wide

Get pod log

.. code-block:: console

  kubectl logs <pod name>

Execute command inside the pod

.. code-block:: console

  kubectl exec <pod name> <command>

NOTE: The name of the container can be omitted if there is only one container.

Open a bash session

.. code-block:: console

  kubectl exec -ti <pod name> bash

Services
++++++++

An abstract way to expose an application running on a set of Pods as a network service. There are
different kinds of services. `Learn more about services`_

.. _Learn more about services: https://kubernetes.io/docs/concepts/services-networking/service/

Get services

.. code-block:: console

  kubectl get services
  kubectl describe services

Create a new service (expose it as nodeport)

.. code-block:: console

  kubectl expose deployment/<myDeployment> --type="NodePort" --port 8080

Get info from a service

.. code-block:: console

  kubectl describe service/<myDeployment>

Connect to the port (via cluster ip)

.. code-block:: console

  curl $(minikube ip):<node port>

Delete a service
$ kubectl delete service -l run=<my deployment>

Labels
++++++

Labels are key/value pairs that are attached to objects, such as pods. The labels group the
different objects (pods, services, deployments, ...) helping to select one or a set of them when a
command is applied. `Learn more about Labels`_


.. _Learn more about Labels: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/

Using labels

.. code-block:: console

  kubectl get pods -l run=<my deployment>
  kubectl get services -l run=<my deployment>

Add labels

.. code-block:: console

  kubectl label pod <pod name> app=v1


Scaling the application
+++++++++++++++++++++++

Scaling helps to add more replicas of a pod, for instance in case when traffic increases. `Learn more about scaling`_

.. _Learn more about scaling: https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/scale-intro/

Scale (or downscale)

.. code-block:: console

  kubectl scale deployments/<my deployment> --replicas=4

See the status

.. code-block:: console

  kubectl get deployments
  kubectl describe deployments/<my deployment>

See the loadbalancer in the default service

.. code-block:: console

  kubectl describe services/<my deployment>


Updating the image
++++++++++++++++++

Kubernetes allows to update an Pod image without interrupting the service.
And rollback the operation if something is wrong. `Learn more about updating images`_

.. _Learn more about updating images: https://kubernetes.io/docs/concepts/containers/images/

To change the image

.. code-block:: console

  kubectl set image deployments/<myDeployment> <myContainer>=<myImage>:<version>

To check the current status. this message will be appears when finish and all is right
"deployment <my Deployment> successfully rolled out"

.. code-block:: console

  kubectl rollout status deployments/<myDeployment>

To see the current version in each pod && to see errors

.. code-block:: console

  kubectl describe pods

Undo an update

.. code-block:: console

  kubectl rollout undo deployments/<myDeployment>


Minikube playground
-------------------

Minikube allows to run kubernetes in a local environment. https://github.com/kubernetes/minikube

To run minikube is simple

.. code-block:: console

  minikube start


Minikube requires VirtualBox (by default) or KVM (the recommended in Linux) installed.
To use minikube with KVM can be used instead with the flag --vm-driver

.. code-block:: console

  minikube start --vm-driver kvm2
