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
To add a compute node, the node must be running SUSE CaaS Platform v3.0 and have been accepted into the cluster and bootstrapped using the Velum dashboard. Once the node is bootstrapped, add its host details to the "airship-openstack-compute-workers" group in your inventory in ${WORKSPACE}/inventory/hosts.yaml, then run the following command from the root of the socok8s directory:

.. code-block:: console

   ./run.sh add_compute

.. note::

   Multiple new compute nodes can be added to the inventory at the same time.

To remove a compute node, run the following command from the root of the socok8s directory:

.. code-block:: console

   ./run.sh remove_compute ${NODE_HOSTNAME}

.. note::

   Although multiple compute nodes can be added at the same time, they must be removed individually. Once the node has been successfully removed, the host details must be removed from "airship-openstack-compute-workers" group in the inventory.

Adding or removing network nodes
--------------------------------

Change control plane scale profile
----------------------------------
SUSE Containerized OpenStack provides two built-in scale profiles: "minimal," which deploys a single pod for each service, and "ha," which is the default profile and deploys a minimum of 2 pods for each service, or 3 or more pods for services that will be heavily utilized or require a quorum. Changing scale profiles can be accomplished by adding a "scale_profile" key to ${WORKSPACE}/env/extravars and specifying a profile value:

.. code-block:: yaml

   scale_profile: minimal

The built-in profiles are defined in playbooks/roles/airship-deploy-ucp/files/profiles and can be modified to suit custom use cases. Additional profiles can also be created and added to this directory following the same file naming convention.


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

The SUSE Containerized OpenStack repository can be updated by performing a pull operation from the socok8s directory:

.. code-block:: console

   git pull origin master

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