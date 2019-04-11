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

Building and using the run script
=================================

The run.sh script is the main bootstrapping script to setup and build the
environment.  First you must build run.sh as it argbash to construct
an argument parser and help for the tool itself.

To build run.sh, simply run

::

  make

This will pull down and install argbash in $HOME/.local, and then run argbash
to construct the run.sh script, which is a wrapper for _run.sh, that includes
an argparser that explains how to run the script and which environment
vars are used.

To view the help after it's built

::

  ./run.sh -h
  This script is used to bootstrap the socok8s dev env. To build the documentation, run tox -edocs
  Usage: ./run.sh [-h|--help] <command>
      <command>: The command you want to run.
      -h, --help: Prints help

  Environment variables that are supported:
      DEPLOYMENT_MECHANISM: The deployment type you want. (default: 'openstack')
      USE_ARA: Use ARA?. (default: 'True')


The argbash m4 files are macros to define which arguments are available, their
help strings, and valid commands.   You can modify _parsing.m4 to add new
arguments, and then simply rebuild run.sh with make again.  You can view argbash
here:  http://argbash.io or http://github.com/matejak/argbash
