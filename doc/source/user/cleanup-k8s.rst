===================
Clean up Kubernetes
===================

To remove all traces of a Kubernetes deployment in your SUSE Containerized
OpenStack environment, run:

.. code-block:: console

   export DELETE_ANYWAY='YES'
   ./run.sh clean_k8s

.. warning::

   You will lose all your Kubernetes data.
