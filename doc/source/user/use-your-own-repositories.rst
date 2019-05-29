===================
Use a personal fork
===================

SUSE Containerized OpenStack allows you to use your own fork instead of relying
on OpenStack-Helm repositories.

.. note ::

   If you choose to use different Helm charts, you are on your own.

To override the Helm chart sources or fork any other code, override the
content of the file `vars/manifest.yml` inside your extravars by defining
your own `upstream_repos` variable.

.. note ::

   You need to define ALL the repositories defined in `vars/manifest.yml`
