Deploy Airship and OpenStack
============================

.. blockdiag::

   blockdiag {
     default_fontsize = 11;
     deployer [label="Setup deployer"]
     ses_integration [label="SES Integration"]
     configure_soc [label="Configure\nCloud"]
     setup_caasp_workers [label="Setup CaaS Platform\nworker nodes"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build Docker images\n(for developers)"]
     deploy_airship [label="Deploy Airship"]
     deploy_openstack [label="Deploy OpenStack"]

     deployer -> ses_integration;
     ses_integration -> configure_soc;
     configure_soc -> setup_caasp_workers;

     group {
       color = "red"
       label = "Cloud Deployment"
       setup_caasp_workers -> patch_upstream;
       patch_upstream -> build_images;
       build_images -> deploy_airship [folded];
       setup_caasp_workers -> deploy_airship;
       deploy_airship -> deploy_openstack;
     }
   }


To deploy SUSE OpenStack cloud using Airship, run:

.. code-block:: console

   ./run.sh deploy_airship

Those steps may take a while to finish.

Track Deployment Progress
-------------------------

Using kubectl
+++++++++++++

To check the deployment progress of the Airship UCP services:

.. code-block:: console

  kubectl get po -n ucp

To check the deployment progress of the Openstack services:

.. code-block:: console

  kubectl get po -n openstack

Using K8s dashboard
+++++++++++++++++++

To deploy the Kubernetes Dashboard UI, follow the page https://github.com/kubernetes/dashboard.

Using Shipyard CLI
++++++++++++++++++

Airship Shipyard CLI allows you to retrieve the progress an status of
deployment actions.

To use the CLI, you first need to set up two environment varibles:

.. code-block:: console

  export OS_CLOUD=airship
  export OS_PASSWORD=PEdLb_RgyDXJUJ7VgeRy

The `OS_PASSWORD` is the Shipyard service pssword in the UCP keystone. It can
be found in the `secrets/ucp_shipyard_keystone_password` file in your
workspace on the deployer node.

To check the workflow status of the deployment action, run:

.. code-block:: console

  /opt/airship-shipyard/tools/shipyard.sh describe action/01D821AZ27H6NCSPV01RXQPDST

The last argument is the action key in Shipyard. Its value is stored in the
`soc-keys.yaml` file in your workspace, for example,

.. code-block:: yaml

  Site:
  name: soc
  action_key: action/01D963GH0B621TBQHZAH8MW9JE

Here is a sample output of the Shipyard `describe` command:

.. code-block:: console

  Name:                  update_software
  Action:                action/01D963GH0B621TBQHZAH8MW9JE
  Lifecycle:             Complete
  Parameters:            {}
  Datetime:              2019-04-23 22:01:57.003504+00:00
  Dag Status:            success
  Context Marker:        b2157815-e993-4333-b881-4937084441dd
  User:                  shipyard

  Steps                                                                Index        State          Footnotes
  step/01D963GH0B621TBQHZAH8MW9JE/action_xcom                          1            success
  step/01D963GH0B621TBQHZAH8MW9JE/dag_concurrency_check                2            success
  step/01D963GH0B621TBQHZAH8MW9JE/deployment_configuration             3            success
  step/01D963GH0B621TBQHZAH8MW9JE/validate_site_design                 4            success
  step/01D963GH0B621TBQHZAH8MW9JE/armada_build                         5            success
  step/01D963GH0B621TBQHZAH8MW9JE/decide_airflow_upgrade               6            success
  step/01D963GH0B621TBQHZAH8MW9JE/armada_get_status                    7            success
  step/01D963GH0B621TBQHZAH8MW9JE/armada_post_apply                    8            success
  step/01D963GH0B621TBQHZAH8MW9JE/upgrade_airflow                      9            skipped
  step/01D963GH0B621TBQHZAH8MW9JE/skip_upgrade_airflow                 10           success
  step/01D963GH0B621TBQHZAH8MW9JE/deckhand_validate_site_design        11           success
  step/01D963GH0B621TBQHZAH8MW9JE/armada_validate_site_design          12           success
  step/01D963GH0B621TBQHZAH8MW9JE/armada_get_releases                  13           success
  step/01D963GH0B621TBQHZAH8MW9JE/create_action_tag                    14           success

  Commands        User            Datetime
  invoke          shipyard        2019-04-23 22:01:57.752593+00:00

  Validations: None

  Action Notes:
  > action metadata:01D963GH0B621TBQHZAH8MW9JE(2019-04-23 22:01:57.736165+00:00): Configdoc revision 1

Logs
++++

To check Airship logs, you can run Shipyard logs CLI command, for example,

.. code-block:: console

  /opt/airship-shipyard/tools/shipyard.sh logs step/01D963GH0B621TBQHZAH8MW9JE/armada_build

To check logs from a running container, you can use the kubectl logs command.
For exmample, to retrieve the test output form the Keystone Rally test, run:

.. code-block:: console

  kubectl logs airship-keystone-test -n openstack

Run Developer Mode
------------------

If you want to patch upstream Helm charts and/or build your own container
images, you need to set the following environment variables before deployment:

.. code-block:: console

   export SOCOK8S_DEVELOPER_MODE='True'
   export AIRSHIP_BUILD_LOCAL_IMAGES='true'
   ./run.sh deploy_airship

Alternatively, you can add the following two lines to the `env/extrvars` file:

.. code-block:: console

   SOCOK8S_DEVELOPER_MODE: true
   AIRSHIP_BUILD_LOCAL_IMAGES: true
