OpenStack-Helm
==============

`OpenStack-Helm` (OSH) is a collection of packages to deploy, maintain and
upgrade OpenStack and related services on Kubernetes. OSH uses a package
management format called `Chart` that has all the resource definitions necessary
to run an application, tool or service in a Kubernetes cluster. Charts are used
to simplify the deployment of those resource packages.

OSH images are built with LOCI_ (lightweight OpenStack containers). Additional
capabilities can be fetched from other upstream projects to create
pre-configured packages of resources, ready to be deployed as charts. Charts
can also be created using Docker containers, for example, see
`role SUSE-build-images`_

.. _LOCI: https://github.com/openstack/loci
.. _role SUSE-build-images: https://github.com/SUSE-Cloud/socok8s/tree/master/playbooks/roles/suse-build-images

OpenStack-Helm Resources:
-------------------------

* Helm

  * Project webpage
      https://helm.sh

  * Documentation and more
      https://helm.sh/docs/

  * Quick start
      https://github.com/helm/helm/blob/master/docs/quickstart.md

* Repository for OpenStack-Helm infrastructure-related code
    https://opendev.org/openstack/openstack-helm-infra

* OpenStack-Helm

  * Project webpage
      https://wiki.openstack.org/wiki/Openstack-helm

  * Documentation
      https://docs.openstack.org/openstack-helm/latest/

  * Repository - Helm charts
      https://opendev.org/openstack/openstack-helm

  * Repository - Images for use with OpenStack-Helm
      https://opendev.org/openstack/openstack-helm-images

  * Repository - Add-ons for OpenStack-Helm
      https://opendev.org/openstack/openstack-helm-addons

  * Repository - OpenStack-Helm Documentation
      https://opendev.org/openstack/openstack-helm-docs


* Repository - Lightweight OCI compatible images for OpenStack projects
    https://github.com/openstack/loci


Keys to learn
-------------

* `Helm commands`_
* Chart_

.. _Helm commands: https://helm.sh/docs/helm/#helm
.. _Chart: https://helm.sh/docs/developing_charts/#charts
