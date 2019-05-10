===================
Use a personal fork
===================

socok8s allows you to use your own fork, instead of relying solely on
OpenStack-Helm repositories.

.. note ::

   You will be on your own if you are using different helm charts.

To override the helm charts sources, or fork any other code, override the
content of the file `vars/manifest.yml` inside your extravars by defining
your own `upstream_repos` variable.

.. note ::

   You need to define ALL the repositories defined in `vars/manifest.yml`
