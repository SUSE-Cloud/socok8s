.. _operationsdocumentation:

===================================
Administration and Operations Guide
===================================

This section has information on the administration and operation of SUSE
Containerized Openstack.

Using run.sh
============

The primary means for running deployment, update, and cleanup actions in SUSE
Containerized OpenStack is run.sh, a bash script that acts as a convenient
wrapper around Ansible playbook execution. All of the commands below should be
run from the root of the socok8s directory.

Deployment Actions
------------------

The ``run.sh deploy`` command:

- Performs all necessary setup actions
- Deploys all Airship UCP components and OpenStack services
- Configures the inventory, extravars file, and appropriate
  environment variables as described in the :ref:`deploymentguide`

.. code-block:: console

   ./run.sh deploy

It may be desirable to redeploy only OpenStack services while leaving all Airship
components in the UCP untouched. In these use cases, run:

.. code-block:: console

   ./run.sh update_openstack

Cleanup Actions
---------------

In addition to deployment, run.sh can be used to perform environment cleanup actions.
To ensure all resources are removed, the following environment variable should be set
before running the cleanup command:

.. code-block:: console

   export DELETE_ANYWAY='YES'

To clean up the deployment and remove SUSE Containerized OpenStack entirely,
run the following command in the root of the socok8s directory:

.. code-block:: console

   ./run.sh remove_deployment

This will delete all Helm releases, all Kubernetes resources in the ``ucp`` and
``openstack`` namespaces, and all persistent volumes that were provisioned for
use in the deployment. After this operation is complete, only the original
Kubernetes services deployed by the SUSE CaaS Platform will remain.

Testing
-------

The run.sh script also has an option to deploy and run OpenStack Tempest tests. To begin
testing, run the following command:

.. code-block:: console

   ./run.sh test

.. note::

   Please read the :ref:`deploymentguide` for further information about configuring and
   running OpenStack Tempest tests in SUSE Containerized OpenStack.

Scaling in/out
==============

Adding or removing compute nodes
--------------------------------

To add a compute node, the node must be running SUSE CaaS Platform v3.0, has
been accepted into the cluster and bootstrapped using the Velum dashboard.
After the node is bootstrapped, add its host details to the "airship-openstack-compute-workers"
group in your inventory in ${WORKSPACE}/inventory/hosts.yaml. Run the following
command from the root of the socok8s directory:

.. code-block:: console

   ./run.sh add_openstack_compute

.. note::

   Multiple new compute nodes can be added to the inventory at the same time.

   It can take a few minutes for the new host to initialize and show in the
   OpenStack hypervisor list.

To remove a compute node, run the following command from the root of the socok8s
directory:

.. code-block:: console

   ./run.sh remove_openstack_compute ${NODE_HOSTNAME}

.. note::

   NODE_HOSTNAME must be same as host name in ansible inventory.

   Compute nodes must be removed individually. When the node has been successfully
   removed, the host details must be manually removed from
   "airship-openstack-compute-workers" group in the inventory.

Control plane horizontal scaling
--------------------------------

SUSE Containerized OpenStack provides two built-in scale profiles:

- **minimal**, the default profile, deploys a single Pod for each service
- **ha** deploys a minimum of two Pods for each service. Three or more Pods are
  suggested for services that will be heavily utilized or require a quorum.

Change scale profiles by adding a "scale_profile" key to ${WORKSPACE}/env/extravars
and specifying a profile value:

.. code-block:: yaml

   scale_profile: ha

The built-in profiles are defined in playbooks/roles/airship-deploy-ucp/files/profiles
and can be modified to suit custom use cases. Additional profiles can be created
and added to this directory following the file naming convention in that directory.

We recommend using at least three controller nodes for a highly available
control plane for both Airship and OpenStack services. To add new controller
nodes, the nodes must:

- be running SUSE CaaS Platform v3.0
- have been accepted into the cluster
- be bootstrapped using the Velum dashboard.

After the nodes are bootstrapped, add the host entries to the 'airship-ucp-workers',
'airship-openstack-control-workers', `airship-openstack-l3-agent-workers`, and
'airship-kube-system-workers' groups in your Ansible inventory in 
${WORKSPACE}/inventory/hosts.yaml.

To apply the changes, run the following command from the root of the socok8s directory:

.. code-block:: console

   ./run.sh deploy

Updates
=======

SUSE Containerized OpenStack is delivered as an RPM package. Generally it can be
updated by updating the RPM package to the latest version and redeploying with
the necessary steps in the :ref:`deploymentguide`. This is the typical update
path and will incorporate all recent changes. It will also automatically update
component chart and image versions.

It is also possible to update services and components directly using
the procedures below.

Updating OpenStack Version
--------------------------

To make a global change to the OpenStack version used by all component images,
create a key in ${WORKSPACE}/env/extravars called "suse_openstack_image_version"
and set it to the desired value. For example, to use the "stein" version, add
the following line to the extravars file:

.. code-block:: yaml

   suse_openstack_image_version: "stein"

It is also possible to update an individual image or subset of images to a
different version rather than making a global change. To do this, it is necessary
to manually edit the versions.yaml file located in socok8s/site/soc/software/config/.
Locate the images to be changed in the "images" section of the file and modify
the line to include the desired version. For example, to use the "stein" version
for the heat_api image, change the following line in versions.yaml from

.. code-block:: yaml

   heat_api: "{{ suse_osh_registry_location }}/openstackhelm/heat:{{ suse_openstack_image_version }}"

to

.. code-block:: yaml

   heat_api: "{{ suse_osh_registry_location }}/openstackhelm/heat:stein"

Updating Individual Images and Helm Charts
------------------------------------------

The versions.yaml file can also be used for more advanced update configurations
such as using a specific image or Helm chart source version.

.. note::

   Changing the image registry location from its default value or using a custom
   or non-default image will void any product support by SUSE.

To specify the use of an updated or customized image, locate the appropriate image
name in socok8s/site/soc/software/config/versions.yaml and modify the line to
include the desired image location and tag. For example, to use a new heat_api
image, modify its entry with the new image location:

.. code-block:: yaml

   heat_api: "registry_location/image_directory/image_name:tag"

Similarly, the versions.yaml file can be used to retrieve a specific version of
any Helm chart being deployed. To do so, it is necessary to provide a repository
location, type, and a reference. The reference can be a branch, commit ID, or a
reference in the repository, and will default to "master" if not specified.
As an example, to use a specific version of the Helm chart for Heat, add the
following information to the "osh" section under "charts":

.. code-block:: yaml

     heat:
       location: https://git.openstack.org/openstack/openstack-helm
       reference: ${REFERENCE}
       subpath: heat
       type: git

.. note::

   When specifying a particular version of a Helm chart, it may be necessary to
   first create the appropriate subsection under "charts". Airship components
   such as Deckhand and Shipyard belong under "ucp", OpenStack services belong
   under "osh", and infrastructure components belong under "osh_infra".

Reboot Compute Host
===================

Before reboot compute host, shutdown all Nova VM(s) from that compute host.

After reboot the compute host, it is possible that the pods when started come up out of order.
If this happens, you might see symptoms of the Nova VM(s) not getting an ip address.
To address this problem, run the following commands:

.. code-block:: console

   kubectl get pods -o wide | grep ovs-agent | grep <compute name>
   kubectl delete pod -n openstack <ovs-agent pod name>

This should restart the Neutron OVS agent pod and reconfigure the vxlan tunnel network configuration.


Troubleshooting
===============

Viewing Shipyard Logs
---------------------

The deployment of OpenStack components in SUSE Containerized OpenStack is
directed by Shipyard, the Airship platform's directed acyclic graph (DAG)
controller, so Shipyard is one of the best places to begin troubleshooting
deployment problems. The Shipyard CLI client authenticates with Keystone, so
the following environment variables must be set before running any commands:

.. code-block:: console

   export OS_USERNAME=shipyard
   export OS_PASSWORD=$(kubectl get secret -n ucp shipyard-keystone-user \
   -o json | jq -r '.data.OS_PASSWORD' | base64 -d)

.. note::

   The Shipyard user's password can be obtained from the contents of
   ${WORKSPACE}/secrets/ucp_shipyard_keystone_password

The following commands are run from the /opt/airship/shipyard/tools directory.
If no Shipyard image is found when the first command is executed, it is
downloaded automatically.

To view the status of all Shipyard actions, run:

.. code-block:: console

   ./shipyard.sh get actions

Example output:

.. code-block:: console

   Name                   Action                                   Lifecycle        Execution Time             Step Succ/Fail/Oth        Footnotes
   update_software        action/01D9ZSVG70XS9ZMF4Z6QFF32A6        Complete         2019-05-03T21:33:27        13/0/1                    (1)
   update_software        action/01DAB3ETP69MGN7XHVVRHNPVCR        Failed           2019-05-08T06:52:58        7/0/7                     (2)

To view the status of the individual steps of a particular action, copy its
action ID and run the following command:

.. code-block:: console

  ./shipyard.sh describe action/01DAB3ETP69MGN7XHVVRHNPVCR

Example output:

.. code-block:: console

   Name:                  update_software
   Action:                action/01DAB3ETP69MGN7XHVVRHNPVCR
   Lifecycle:             Failed
   Parameters:            {}
   Datetime:              2019-05-08 06:52:55.366919+00:00
   Dag Status:            failed
   Context Marker:        18993f2c-1cfa-4d42-9320-3fbd70e75c21
   User:                  shipyard

   Steps                                                                Index        State            Footnotes
   step/01DAB3ETP69MGN7XHVVRHNPVCR/action_xcom                          1            success
   step/01DAB3ETP69MGN7XHVVRHNPVCR/dag_concurrency_check                2            success
   step/01DAB3ETP69MGN7XHVVRHNPVCR/deployment_configuration             3            success
   step/01DAB3ETP69MGN7XHVVRHNPVCR/validate_site_design                 4            success
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_build                         5            failed
   step/01DAB3ETP69MGN7XHVVRHNPVCR/decide_airflow_upgrade               6            None
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_get_status                    7            success
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_post_apply                    8            upstream_failed
   step/01DAB3ETP69MGN7XHVVRHNPVCR/skip_upgrade_airflow                 9            upstream_failed
   step/01DAB3ETP69MGN7XHVVRHNPVCR/upgrade_airflow                      10           None
   step/01DAB3ETP69MGN7XHVVRHNPVCR/deckhand_validate_site_design        11           success
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_validate_site_design          12           upstream_failed
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_get_releases                  13           failed
   step/01DAB3ETP69MGN7XHVVRHNPVCR/create_action_tag                    14           None

To view the logs from a particular step such as armada_build, which has failed
in the above example, run:

.. code-block:: console

   ./shipyard.sh logs step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_build

Viewing Logs From Kubernetes Pods
---------------------------------

To view the logs from any Pod in the Running or Completed state, run

.. code-block:: console

   kubectl logs -n ${NAMESPACE} ${POD_NAME}

To view logs from a specific container within a Pod in the Running or Completed
state, run:

.. code-block:: console

   kubectl logs -n ${NAMESPACE} ${POD_NAME} -c ${CONTAINER_NAME}

If logs cannot be retrieved due to the Pod entering the Error or CrashLoopBackoff
state, it may be necessary to use the -p option to retrieve logs from the previous
instance:

.. code-block:: console

   kubectl logs -n ${NAMESPACE} ${POD_NAME} -p

Recover Controller Host Node
----------------------------

If deployment failed with error of controller host not reachable ( has entered maintenance mode )

Go to maintenance mode on controller host and run following commands:

.. code-block:: console

   mounted_snapshot=$(mount | grep snapshot | gawk  'match($6, /ro.*@\/.snapshots\/(.*)\/snapshot/ , arr1 ) { print arr1[1] }')

   btrfs property set -ts /.snapshots/$mounted_snapshot/snapshot ro false

   mount -o remount, rw /

   mkdir /var/lib/neutron

   btrfs property set -ts /.snapshots/$mounted_snapshot/snapshot ro true

   reboot

Recover Compute Host Node
-------------------------

If deployment failed with error of compute host not reachable ( has entered maintenance mode )

Go to maintenance mode on compute host and run following commands:

.. code-block:: console

   mounted_snapshot=$(mount | grep snapshot | gawk  'match($6, /ro.*@\/.snapshots\/(.*)\/snapshot/ , arr1 ) { print arr1[1] }')

   btrfs property set -ts /.snapshots/$mounted_snapshot/snapshot ro false

   mount -o remount, rw /

   mkdir /var/lib/libvirt
   mkdir /var/lib/nova
   mkdir /var/lib/openstack-helm
   mkdir /var/lib/neutron

   btrfs property set -ts /.snapshots/$mounted_snapshot/snapshot ro true

   reboot

.. _caaspoperations:

CaaS Platform Operations
========================

Disable transactional update for development purposes
-----------------------------------------------------

CaaSP has documentation for `transactional updates <https://www.suse.com/documentation/suse-caasp-3/book_caasp_admin/data/sec_admin_software_transactional-updates.html>`_.

Disabling transactional updates is discouraged.

Run the following to prevent a cluster from being updated:

.. code-block:: console

   systemctl --now disable transactional-update.timer

If you want to override once a week, instead of daily, run the following:

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

Recovering from Node Failure
============================

Kubernetes clusters are generally able to recover from node failures by performing
a number of self-healing actions, but it may be necessary to manually intervene
occasionally. Recovery actions vary depending on the type of failure. Some
common scenarios and their solutions are outlined below.

Pod Status of NodeLost or Unknown
---------------------------------

If a large number of Pods show a status of NodeLost or Unknown, first determine
which nodes may be causing the problem by running:

.. code-block:: console

   kubectl get nodes

If any of the nodes show a status of NotReady but they still respond to ping and
can be accessed via SSH, it may be that either the kubelet or docker service has
stopped running. This can be confirmed by checking the "Conditions" section for
the message "Kubelet has stopped posting node status" after running:

.. code-block:: console

   kubectl describe node ${NODE_NAME}

 Log into the affected nodes and check the status of these services by running:

.. code-block:: console

   systemctl status kubelet
   systemctl status docker

If either service has stopped, start it by running:

.. code-block:: console

   systemctl start ${SERVICE_NAME}

.. note::

   The kubelet service requires Docker to be running. So if both services are stopped,
   Docker should be restarted first.

These services should start automatically each time a node boots up and should
be running at all times. If either service has stopped, examine the system logs
to determine the root cause of the failure. This can be done by using the
journalctl command:

.. code-block:: console

   journalctl -u kubelet

Frequent Pod Evictions
----------------------

If Pods are frequently being evicted from a particular node, it may be a sign
that the node is unhealthy and requires maintenance. Check that node's conditions
and events by running:

.. code-block:: console

   kubectl describe node ${NODE_NAME}

If the cause of the Pod evictions is determined to be resource exhaustion, such
as NodeHasDiskPressure or NodeHasMemoryPressure, it may be necessary to remove
the node from the cluster temporarily to perform maintenance. To gracefully
remove all Pods from the affected node and mark it as `not schedulable`, run:

.. code-block:: console

   kubectl drain ${NODE_NAME}

After maintenance work is complete, the node can be brought back into the cluster
by running:

.. code-block:: console

   kubectl uncordon ${NODE_NAME}

which will allow normal Pod scheduling operations to resume. If the node was
decommissioned permanently while offline and a new node was brought into the
CaaSP cluster as a replacement, it is not necessary to run the uncordon
command. A new schedulable resource will be created automatically.

.. _kubernetesoperations:

Kubernetes Operations
=====================

Kubernetes has documentation for `troubleshooting typical problems with applications and clusters <https://kubernetes.io/docs/tasks/debug-application-cluster/troubleshooting//>`_.


.. _tips_and_tricks:

Tips and Tricks
===============


Display all images used by a component
--------------------------------------

Using Neutron as an example:

.. code-block:: console

   kubectl get pods -n openstack -l application=neutron -o \
   jsonpath="{.items[*].spec.containers[*].image}"|tr -s '[[:space:]]' '\n' \
   | sort | uniq -c


Remove dangling Docker images
-----------------------------

Useful after building local images:

.. code-block:: console

   docker rmi $(docker images -f "dangling=true" -q)


Setting the default context
---------------------------

To avoid having to pass "-n openstack" all the time:

.. code-block:: console

   kubectl config set-context $(kubectl config current-context) --namespace=openstack
