===============================
Deleting socok8s from OpenStack
===============================

If you have built socok8s on top of OpenStack, you can delete your whole
environment by running:

.. code-block:: console

   ./run.sh teardown

This will delete the CaaSP, SES, and deployer nodes from your cloud but will
not delete your WORKDIR.

If you want to delete your workdir too, run:

.. warning::

   You will lose all your socok8s data, your overrides, your certificates,
   your inventory.

.. code-block:: console

   export DELETE_ANYWAY='YES'
   ./run.sh teardown
