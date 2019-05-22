.. _buildownimages:

=================================
Build and consume your own images
=================================

Build non-openstack images
==========================

If you want to build your own image (for example, libvirt), set
the following in your `${WORKDIR}/env/extravars`:

.. code-block:: yaml

   ---
   myregistry: "myuser-osh.openstack.local:5000/"
   developer_mode: "True"
   # Builds the libvirt image from OSH-images repository.
   docker_images:
     - context: libvirt
       repository: "{{ myregistry }}openstackhelm/libvirt"
       # dockerfile: # Insert here the alternative Dockerfile's name.
       # build_args: # Insert here your extra build arguments to pass to docker.
       tags:
         - latest-opensuse_15

.. _buildlociimages:

Build LOCI images
=================

The LOCI command to build the OpenStack images is stored by default in
`loci_build_command` (see also our `suse-build-images role default variables`_).

.. _suse-build-images role default variables: https://github.com/SUSE-Cloud/socok8s/blob/master/playbooks/roles/suse-build-images/defaults/main.yml

For example, set `loci_build_command` to `"./openstack/loci/build-ocata.sh"` to
build LOCI with the Ocata release.

.. note::

   By default, the list of projects to build in LOCI is empty, and the LOCI
   builds are skipped.
   Define `loci_build_projects` as a list, each item being an upstream project
   to build in the image build process.

.. _useownimages:

Consume built images
====================

Now that your images are built, you can point to them in the deployment.

For Airship
-----------

For OSH (developer mode)
------------------------

Set the following variable (for example for libvirt image override) in your
`env/extravars`:

.. code-block:: yaml

   ---
   # Points to that image in the libvirt chart.
   suse_osh_deploy_libvirt_yaml_overrides:
     images:
       tags:
         libvirt: "{{ myregistry }}openstackhelm/libvirt:latest-opensuse_15"

