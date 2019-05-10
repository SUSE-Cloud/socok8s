=================================
Customizing Helm Testing Behavior
=================================

By default, all tests that have been defined for each helm chart will be run
as part of that chart's deployment operations. However, it may be desirable in
some scenarios to prevent these tests from running. To disable helm tests, define
the following key in `${WORKDIR}/env/extravars` and set it to `false`:

.. code-block:: yaml

   run_tests: false

.. note::

   This will disable all helm tests in all charts during a full site deployment.
   Tests for individual helm charts can still be run by using the helm CLI and the
   release name, such as:

.. code-block:: console

   helm test airship-glance

Additionally, the default timeout value of 300s for test completion can be 
customized by adding the following key in `${WORKDIR}/env/extravars` and 
providing a value, in seconds:

.. code-block:: yaml

   test_timeout: 1200