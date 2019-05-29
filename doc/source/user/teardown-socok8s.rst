====================================================
Deleting SUSE Containerized OpenStack from OpenStack
====================================================

If you have built SUSE Containerized OpenStack (SCO) on top of OpenStack, you can
delete your whole environment by running:

.. code-block:: console

   ./run.sh teardown

This will delete the CaaSP, SES, and deployer nodes from your cloud. It will not
delete your WORKDIR.

If you want to delete your WORKDIR too, run:

.. code-block:: console

   export DELETE_ANYWAY='YES'
   ./run.sh teardown

.. warning::

   You will lose all of your SCO data, your overrides, your certificates,
   your inventory.
