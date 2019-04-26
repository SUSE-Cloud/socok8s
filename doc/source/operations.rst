.. _operationsdocumentation:

===================================
Administration and Operations Guide
===================================

In this section, you will find information on the adminsitration and
operations of SUSE Containerized Openstack.


Scaling in/out
==============

Adding or removing compute nodes
--------------------------------

Adding or removing network nodes
--------------------------------

Change control plane scale profile
----------------------------------


Updates
=======

Update Airship UCP Services
---------------------------

Update OpenStack Services
-------------------------

Update secrets, passwords and certificates
------------------------------------------

Update this repository
----------------------

Troubleshooting
===============


.. _caaspoperations:

CaaS Platform Operations
========================

Disable transactional update for development purposes
-----------------------------------------------------

CaaSP has a documentation for `transactional updates <https://www.suse.com/documentation/suse-caasp-3/book_caasp_admin/data/sec_admin_software_transactional-updates.html>`_.

It is not recommended to disable transactional updates.

Run the following to prevent a cluster from being updated:

.. code-block:: console

   systemctl --now disable transactional-update.timer

Run the following if you only want to override once a week, instead of daily:

.. code-block:: console

   mkdir /etc/systemd/system/transactional-update.timer.d
   cat << EOF > /etc/systemd/system/transactional-update.timer.d/override.conf
   [Timer]
   OnCalendar=
   OnCalendar=weekly
   EOF
   systemctl daemon-reload

Or use the traditional systemctl commands:

.. code-block:: console

   systemctl edit transactional-update.timer
   systemctl restart transactional-update.timer
   systemctl status transactional-update.timer

Check the next run:

.. code-block:: console

   systemctl list-timers


.. _kubernetesoperations:

Kubernetes Operations
=====================

Kubernetes has documentation for `troubleshooting typical problems with applications and clusters <https://kubernetes.io/docs/tasks/debug-application-cluster/troubleshooting//>`_.


.. _tips_and_tricks:

Tips and Tricks
===============


Display all images used by a component
--------------------------------------

Use neutron as n example:

.. code-block:: console

   kubectl get pods -n openstack -l application=neutron -o jsonpath="{.items[*].spec.containers[*].image}"|tr -s '[[:space:]]' '\n' | sort | uniq -c


Remove dangling Docker images
-----------------------------

Useful after building local images:

.. code-block:: console

   docker rmi $(docker images -f "dangling=true" -q)


Setting the default context
---------------------------

So you do not have to pass "-n openstack" all the time

.. code-block:: console

   kubectl config set-context $(kubectl config current-context) --namespace=openstack
