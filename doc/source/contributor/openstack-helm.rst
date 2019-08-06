OpenStack Helm
==============

OpenStack-helm is a collection of packages to deploy OpenStack in kubernetes.

These packages are written using the helm packaging structure called Chart that
describe how to automatize the deployment the images.

The OpenStack images are built using LOCI_ (official OpenStack images). The
rest of images are fetched from other upstream projects created using docker
build. See `role SUSE-build-images`_

.. _LOCI: https://github.com/openstack/loci
.. _role SUSE-build-images: https://github.com/SUSE-Cloud/socok8s/tree/master/playbooks/roles/suse-build-images

List of interesting links:
--------------------------

* Helm

  * webpage
      https://helm.sh

  * Documentation
      https://helm.sh/docs/helm (v2)

      https://v3.helm.sh/docs/ (v3)

  * Quick start
      https://github.com/helm/helm/blob/master/docs/quickstart.md

* OpenStack helm infra git repository
    https://opendev.org/openstack/openstack-helm-infra

* OpenStack helm

  * Webpage
      https://wiki.openstack.org/wiki/Openstack-helm

  * Documentation
      https://docs.openstack.org/openstack-helm/latest/

  * Git repository
      https://opendev.org/openstack/openstack-helm

  * Git images repository
      https://opendev.org/openstack/openstack-helm-images

  * Git addons repository
      https://opendev.org/openstack/openstack-helm-addons

  * Git docs repository
      https://opendev.org/openstack/openstack-helm-docs


* Loci git Repository
    https://github.com/openstack/loci


Keys to learn
-------------

* `Helm commands`_
* Chart_

.. _Helm commands: https://helm.sh/docs/helm/#helm
.. _Chart: https://helm.sh/docs/developing_charts/#charts
