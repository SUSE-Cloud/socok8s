
=========================
Multiple network example
=========================

This is a multiple network example configuration for CCP. Caas Platform and
SES network configuration have their own respective documentation.

.. nwdiag::

   nwdiag {

     network storage {
       address = "172.30.2.x/24"
       deployer [address = "172.30.2.10"];
       caasp-admin [address = "172.30.2.11"];
       caasp-master [address = "172.30.2.12"];
       caasp-worker1 [address = "172.30.2.13"];
       caasp-worker2 [address = "172.30.2.14"];
       ses [address = "172.30.2.15"];
     }
     network ext {
       address = "172.30.1.x/24"
       deployer [address = "172.30.1.10"];
       caasp-master [address = "172.30.1.12"];
       caasp-worker1 [address = "172.30.1.13"];
       caasp-worker2 [address = "172.30.1.14"];
     }
   }

The following configuration files reflect the diagram above.

`${WORKDIR}/env/extravars`:

.. code-block:: yaml

    socok8s_deployment_goal: airship
    socok8s_ext_vip: 172.30.1.245
    #either "minimal" or "ha"
    scale_profile: minimal
    redeploy_osh_only: false


`${WORKDIR}/inventory/hosts.yml`:

.. code-block:: yaml

    ---
    caasp-admin:
    hosts:
        caasp-admin:
        ansible_host: 172.30.0.11
    vars:
        ansible_user: root
    caasp-masters:
    hosts:
        caasp-master:
        ansible_host: 172.30.0.12
    vars:
        ansible_user: root
    caasp-workers:
    hosts:
        caasp-worker1:
        ansible_host: 172.30.0.13
        caasp-worker2:
        ansible_host: 172.30.0.14
    vars:
        ansible_user: root

    soc-deployer:
    hosts:
        deployer:
        ansible_host: 172.30.0.10
    vars:
        ansible_user: root
    ses_nodes:
    hosts:
        ses:
        ansible_host: 172.30.0.15
    vars:
        ansible_user: root

    # added for airship

    airship-openstack-control-workers:
    hosts:
        caasp-worker1:
        ansible_host: 172.30.0.13
        primary: yes
        caasp-worker2:
        ansible_host: 172.30.0.14
    vars:
        ansible_user: root

    airship-ucp-workers:
    hosts:
        caasp-worker1:
        ansible_host: 172.30.0.13
        primary: yes
        caasp-worker2:
        ansible_host: 172.30.0.14
    vars:
        ansible_user: root

    airship-kube-system-workers:
    hosts:
        caasp-worker1:
        ansible_host: 172.30.0.13
        primary: yes
        caasp-worker2:
        ansible_host: 172.30.0.14
    vars:
        ansible_user: root

    airship-openstack-compute-workers:
    hosts:
        primary: yes
        caasp-worker2:
        ansible_host: 172.30.0.14
    vars:
        ansible_user: root

`${WORKDIR}/ses_config.yml`:

.. code-block:: yaml

    ---
    # Example ses_config.yml file
    ceph_conf:
    cluster_network: 172.30.2.0/24
    fsid: d40fea38-fcf6-3dd5-8479-dd36e8f53ac5
    mon_host: 172.30.2.15
    mon_initial_members: ses
    public_network: 172.30.2.0/24
    cinder:
    key: AQDkeIZcAAAAABAAdTOl4xyDS0/v9B8m1drZmQ==
    rbd_store_pool: volumes
    rbd_store_user: cinder
    cinder-backup:
    key: AQDkeIZcAAAAABAAdTOl4xyDS0/v9B8m1drZmQ==
    rbd_store_pool: cinder_backup
    rbd_store_user: cinder-backup
    glance:
    key: AQDkeIZcAAAAABAAdTOl4xyDS0/v9B8m1drZmQ==
    rbd_store_pool: images
    rbd_store_user: glance
    libvirt:
    key: AQDkeIZcAAAAABAAdTOl4xyDS0/v9B8m1drZmQ==
    rbd_store_pool: vms
    rbd_store_user: cinder
    nova:
    rbd_store_pool: nova
    radosgw_urls: []
