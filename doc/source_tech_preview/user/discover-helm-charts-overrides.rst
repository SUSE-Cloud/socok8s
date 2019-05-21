==============================
Discover Helm charts overrides
==============================

The upstream Helm charts have values that can be used to alter the deployment
of a chart to match your needs.

Generate a list of the available overrides:

1. Build all the Helm charts (`make all` in each of the
   /opt/openstack/openstack-helm folders) in your environment
2. Run the following on your `deployer` node:


.. code-block:: console

   for fname in /opt/openstack/openstack-helm{,-infra}/*.tgz; do
       chartname=$(basename $fname | rev | cut -f "2-" -d "-" | rev);
       foldername=$(dirname $fname);
       pushd $foldername;
           echo -e "\nNow analysing: $chartname\n\n" >> /opt/charts-details;
           helm inspect values $chartname >> /opt/charts-details;
       popd;
   done
   less /opt/charts-details
