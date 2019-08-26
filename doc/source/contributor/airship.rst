Airship
=======

Airship is a collection of interoperable tools for automating cloud
provisioning and management. It uses a declarative framework described by YAML
documents to define and manage the life cycle of container-based
`open infrastructure <https://opensource.com/article/18/5/open-infrastructure>`_
software tools and underlying hardware.

.. image:: https://airship-treasuremap.readthedocs.io/en/stable/_images/architecture.png

* Airship architecture
    https://airship-treasuremap.readthedocs.io/en/stable/

* Git repository for Airship and Airship subprojects
    https://opendev.org/airship

* Video introduction
    https://www.youtube.com/watch?v=0eEisMm9ykg


Airship Architecture Elements
-----------------------------

Shipyard
++++++++

Shipyard is the cluster lifecycle orchestrator that provides a framework for a
fully functional container-based Cloud.

* Documentation
    https://airship-shipyard.readthedocs.io/

* Git repository
    https://opendev.org/airship/shipyard


Treasuremap
+++++++++++

This documentation project outlines a reference architecture for automated
cloud provisioning and management, leveraging a collection of interoperable
open-source tools.

* Documentation
    https://airship-treasuremap.readthedocs.io/en/latest/

* Git repository - reference manifests, reference architecture
    https://opendev.org/airship/treasuremap

Armada
++++++

Armada is used to deploy and manage multiple Helm charts. It
communicates with Helm to create a single YAML to centralize configurations
of the desired infrastructure. The configuration can be managed with Deckhand.

* Documentation
    https://airship-armada.readthedocs.io/

* Git repository
    https://opendev.org/airship/armada

* Guide
    https://airship-armada.readthedocs.io/en/latest/operations/guide-use-armada.html

* Video
    https://www.youtube.com/watch?v=ae-g9irTsXY


Deckhand
++++++++

Deckhand is a document-based configuration management service back-end for
Airship. It validates and stores YAML documents, including sensitive data using
Barbican secure storage service.

* Documentation
    https://airship-deckhand.readthedocs.io/en/latest/

* Git repository
    https://opendev.org/airship/deckhand


Pegleg
++++++

Pegleg is a document aggregator that combines all required documents in a
repository into a single YAML file. It is a configuration organization tool that
provides the automation and tooling needed to aggregate, lint, and render the
documents for deployment.

* Documentation
    https://airship-pegleg.readthedocs.io/

* Git repository
    https://opendev.org/airship/pegleg
