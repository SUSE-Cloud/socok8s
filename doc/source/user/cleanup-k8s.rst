================================
Cleanup k8s of socok8s artifacts
================================

If you want to simply cleanup your kubernetes environment of all the
traces of a socok8s deployment, run:

.. warning::

   You will lose all your k8s data.

.. code-block:: console

   export DELETE_ANYWAY='YES'
   ./run.sh clean_k8s
