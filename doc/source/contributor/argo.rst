Argo  for Kubernetes
====================


**What is the Argo Project?**


`Argo` is an open source Container-Native workflow engine for Kubernetes. The use
of containers and Kubernetes is driving a major shift in how applications and
services are developed, distributed, and deployed. In a distributed system, an
integrated workflow engine such as Argo is essential for orchestrating jobs as
well as distributing and deploying complex microservices-based applications.
With Argo, each step in the workflow is implemented as a container.


**Key Resources**

* Applatix Project Page
   https://argoproj.github.io/

* Github Page
   https://github.com/argoproj/argo

* Argo Getting Started Guide
   https://github.com/argoproj/argo/blob/master/demo.md

* Video Presentation
   https://www.youtube.com/watch?v=OdzH82VpMwI

* In-depth Read
   https://itnext.io/argo-workflow-engine-for-kubernetes-7ae81eda1cc5

* Argo Slack Channel `Join  <https://join.slack.com/t/argoproj/shared_invite/enQtMzExODU3MzIyNjYzLTA5MTFjNjI0Nzg3NzNiMDZiNmRiODM4Y2M1NWQxOGYzMzZkNTc1YWVkYTZkNzdlNmYyZjMxNWI3NjY2MDc1MzI>`_



**Architecture**

.. image:: ./argo-architecture.png


**Key Components of Argo**

- `Argo Workflows <https://argoproj.github.io/argo/>`_ Container-native Workflow Engine
- `Argo CD <https://argoproj.github.io/argo-cd/>`_ Declarative GitOps Continuous Delivery
- `Argo Events <https://argoproj.github.io/argo-events/>`_ Event-based Dependency Manager
- `Argo Rollouts <https://argoproj.github.io/argo-rollouts/>`_ Deployment custom resource with support for Canary and Blue Green deployment strategies

**Argo Workflows**

`Argo Workflows` is an open source container-native workflow engine for
orchestrating parallel jobs on Kubernetes. Argo Workflows is implemented as a
Kubernetes CRD (Custom Resource Definition).

- Define workflows where each step in the workflow is a container.
- Model multi-step workflows as a sequence of tasks or capture the dependencies
  between tasks using a directed acyclic graph (DAG).
- Easy operation of compute intensive jobs for machine learning or data
  processing. Saves time over alternative methods.
- Run CI/CD pipelines natively on Kubernetes without configuring complex
  software development products.


**Why Argo Workflows?**

- Designed specifically for containers without the overhead and limitations of
  legacy VM and server-based environments.
- Cloud agnostic. Runs run on any Kubernetes cluster.
- Easily orchestrate highly parallel jobs on Kubernetes.
- Argo Workflows is like having a cloud-scale supercomputer.

**Argo CD**

`Argo CD` is a declarative, GitOps continuous delivery tool for Kubernetes.
Argo CD follows the GitOps pattern of using Git repositories as the source of
truth for defining a desired application state. Argo CD automates the deployment
of the desired application states in the specified target environments.
Application deployments can track updates to branches or tags, and can be
pinned to a specific version of manifests at a Git commit.


**Argo Events**

`Argo Events` is an event-based dependency manager for Kubernetes which helps
define multiple dependencies from a variety of event sources such as webhook,
AWS S3, schedules, and streams. It can trigger Kubernetes objects after
successful event dependencies resolution.

**Argo Rollouts**

`Argo Rollouts` provides a custom resource to provide additional deployment
strategies for Kubernetes such as Blue-Green and Canary. The Rollout custom
resource provides feature parity with the Kubernetes deployment resource and
offers additional deployment strategies.


Argo Getting Started
++++++++++++++++++++

You can run examples of simple workflows, as well as workflows that use Argo
artifacts with an artifact repository for storing the artifacts that are passed
in the workflows. Visit https://argoproj.github.io/docs/argo/demo.html for demo
instructions.

**Contribute to Argo Project**

If you want to contribute to the  Argo Community, please contact
saradhi_sreegiriraju@intuit.com for more information.
