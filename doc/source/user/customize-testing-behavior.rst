=================================
Customizing Helm testing behavior
=================================

By default, all tests that have been defined for each Helm chart will be run
as part of that chart's deployment. However, in
some scenarios you may want to prevent these tests from running. To disable Helm
tests, define the `run_tests` key in `${WORKDIR}/env/extravars` and set it to `false`:

.. code-block:: yaml

   run_tests: false

.. note::

   This will disable all Helm tests in all charts during a full site deployment.
   Tests for individual Helm charts can still be run by using the Helm CLI and the
   service name, such as:

.. code-block:: console

   helm test airship-glance

The default timeout value of 300s for test completion can be customized by
adding the `test_timeout` key in `${WORKDIR}/env/extravars` and
providing a value, in seconds:

.. code-block:: yaml

   test_timeout: 1200
