=======================================================
Use your own certificates for your local image registry
=======================================================


If you want to run developer mode and bring your own registry's SSL
certificates, define the following in `${WORKDIR}/env/extravars`:

.. code-block:: yaml

   socok8s_registry_certkey:
   socok8s_registry_cert:

The variables should point to files present in your `localhost`.
If they are not defined, self-signed certificates will be generated on your
`localhost`, and transferred to all the nodes.
