.. _ses_integration:

SUSE Enterprise Storage Integration
===================================

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

     group {
       ses_integration
       color="red"
     }

     deployer -> ses_integration;
     ses_integration -> configure_soc;
     configure_soc -> setup_caasp_workers;

     group {
       color = "#EEEEEE"
       label = "OpenStack deployment"
       setup_caasp_workers -> patch_upstream;
       patch_upstream -> build_images;
       build_images -> deploy_airship [folded];
       setup_caasp_workers -> deploy_airship;
       deploy_airship -> deploy_openstack;
     }
   }


For SES deployments that have version 5.5 and higher, there is a Salt runner
that can create all the users and pools Openstack services require. It also
generates a yaml configuration that is needed to integrate with SUSE
Containerized OpenStack Cloud. The integration runner creates separate users
for Cinder, Cinder backup, and Glance. Both the Cinder and Nova services
will have the same user, as Cinder needs access to create objects that Nova
uses.

Log in as root to run the SES 5.5 Salt runner on the salt admin host.
root #

.. code-block:: bash

  salt-run --out=yaml openstack.integrate prefix=mycloud

The prefix parameter allows pools to be created with the specified prefix.
In this way, multiple cloud deployments can use different users and pools on
the same SES deployment.

The sample yaml output:

.. code-block:: yaml

  ceph_conf:
    cluster_network: 10.84.56.0/21
    fsid: d5d7c7cb-5858-3218-a36f-d028df7b0673
    mon_host: 10.84.56.8, 10.84.56.9, 10.84.56.7
    mon_initial_members: ses-osd1, ses-osd2, ses-osd3
    public_network: 10.84.56.0/21
  cinder:
    key: AQCdfIRaxefEMxAAW4zp2My/5HjoST2Y8mJg8A==
    rbd_store_pool: mycloud-cinder
    rbd_store_user: cinder
  cinder-backup:
    key: AQBb8hdbrY2bNRAAqJC2ZzR5Q4yrionh7V5PkQ==
    rbd_store_pool: mycloud-backups
    rbd_store_user: cinder-backup
  glance:
    key: AQD9eYRachg1NxAAiT6Hw/xYDA1vwSWLItLpgA==
    rbd_store_pool: mycloud-glance
    rbd_store_user: glance
  nova:
    rbd_store_pool: mycloud-nova
  radosgw_urls:
    - http://10.84.56.7:80/swift/v1
    - http://10.84.56.8:80/swift/v1

After you have run the openstack.integrate runner, copy the yaml into the
ses_config.yml file in the root of the workspace on the Deployer node.
