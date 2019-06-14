====================================
Select OpenStack services to install
====================================

SUSE Containerized OpenStack currently deploys OpenStack Cinder, Glance, Nova,
Neutron, Heat, Horizon, and Keystone.

You can change which services to deploy by modifying the chart group list in
the site manifest file site/soc/software/manifests/full-site.yaml.

.. code-block:: yaml

   chart_groups:
     - openstack-ingress-controller-soc
     - openstack-mariadb-soc
     - openstack-memcached-soc
     - openstack-keystone-soc
     - openstack-ceph-config-soc
     - openstack-glance-soc
     - openstack-cinder-soc
     - openstack-compute-kit-soc
     - openstack-heat-soc
     - openstack-horizon-soc

For more details, please refer to the Airship site authoring guide:
https://airship-treasuremap.readthedocs.io/en/latest/authoring_and_deployment.html
