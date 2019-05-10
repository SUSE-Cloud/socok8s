Intro
=====

This project automates the SUSE Openstack Cloud provisioning and lifecycle
management on Airship, SUSE Container as a Service Platform and SUSE
Enterprise Storage (SES) via a series of shell scripts and Ansible playbooks.

Cloning this repository
=======================

To get started, you need to clone this repository. This repository uses
submodules, so you need to get all the code to make sure the playbooks
work.

::

   git clone --recursive https://github.com/SUSE-Cloud/socok8s.git

Alternatively, one can fetch/update the tree of the submodules by
running:

::

   git submodule update --init --recursive

Please see the rest of the documentation in docs/ for:

* socok8s Deployment guide
* socok8s Administration guide
* Guide for Openstack Helm Developers
* Guide for Airship developers

Rendering this page
===================

To build this page just run:

.. code-block:: console

   tox -e docs

To build technical preview docs run:

.. code-block:: console

   tox -e docs_tech_preview
