=================================
Build and consume your own images
=================================

If you want to build and consume your own image, for example, for libvirt, set
the following in your `${WORKDIR}/env/extravars`:


.. code-block:: yaml

   ---
   myregistry: "jevrard-osh.openstack.local:5000/"
   developer_mode: "True"
   # Builds the libvirt image from OSH-images repository.
   docker_images:
     - context: libvirt
       repository: "{{ myregistry }}openstackhelm/libvirt"
       # dockerfile: # Insert here the alternative Dockerfile's name.
       # build_args: # Insert here your extra build arguments to pass to docker.
       tags:
         - latest-opensuse_15
   # Points to that image in the libvirt chart.
   suse_osh_deploy_libvirt_yaml_overrides:
     images:
       tags:
         libvirt: "{{ myregistry }}openstackhelm/libvirt:latest-opensuse_15"
