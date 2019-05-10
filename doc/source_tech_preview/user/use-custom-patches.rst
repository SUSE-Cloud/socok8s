.. _custompatches:

===================
Use custom patches
===================


If you want to apply upstream patches in your environment, set your patch numbers
under the `dev_patcher_user_patches` key on `${WORKDIR}/env/extravars`:

.. code-block:: yaml

  dev_patcher_user_patches:
    # test patch for kyestone
    - 12345
    # test patch for cinder
    - 12345


This way, the patches will only be carried in your environment.
If you want to change the product instead (for developer mode or not),
please propose a PR to the socok8s repo.

.. note::

    This list of patches provided via extravars will be appended to the default
    patches list available on the dev-patcher role vars.
