==============================
Discover helm charts overrides
==============================

The upstream helm charts have a large series of values which can be used
to alter the deployment of a chart to match your needs.

You can generate a list of the available overrides, after building all the
helm charts (`make all` in each of the /opt/openstack-helm folders)
in your environment, by running the following on your `deployer` node:

.. code-block:: console

   for fname in /opt/openstack-helm{,-infra}/*.tgz; do
       chartname=$(basename $fname | rev | cut -f "2-" -d "-" | rev);
       foldername=$(dirname $fname);
       pushd $foldername;
           echo -e "\nNow analysing: $chartname\n\n" >> /opt/charts-details;
           helm inspect values $chartname >> /opt/charts-details;
       popd;
   done
   less /opt/charts-details
