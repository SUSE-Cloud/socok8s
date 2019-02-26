Intro
=====

This project automates the deployment of OpenStack-Helm (OSH) on SUSE
Container as a Service Platform (CaaSP) and SUSE Enterprise Storage
(SES) via a series of shell scripts and Ansible playbooks.

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

* A deployment guide
* A reference documentation for more detailed information
* User stories and tips
* Operational information.

Rendering this page
===================

To build this page just run:

.. code-block:: console

   tox -e docs
