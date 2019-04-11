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


Building and using the socok8s.sh shell script
==============================================

The run.sh script is the main bootstrapping script to setup and build the
environment.  socok8s.sh is a wrapper for run.sh that includes the argument
parser, as well as help output.  Arguments that are supported by socok8s.sh
are defined in the argbash template socok8s.m4.  Running make can generate
the socok8s.sh script from the socok8s.m4 file.

To build socok8s.sh, simply run

::

  make

This will pull down and install argbash in build/argbash/install.  Next,
argbash is run on the socok8s.m4 to construct the sosok8s.sh script.
The Makefile also builds a bash-completion script, which can be sourced into
your environment.  A manpage is also built for socok8s.sh

To view the help after it's built

::

  ./socok8s.sh -h
  This script is used to bootstrap the socok8s dev env. To build the documentation, run tox -edocs
  Usage: ./socok8s.sh [-q|--(no-)quiet] [-p|--(no-)pre] [-v|--version] [-h|--help] [<command>]
      <command>: The command you want to run. (default: 'setup_everything')
      -q, --quiet, --no-quiet: suppress noisy output (off by default)
      -p, --pre, --no-pre: Run preflight only (off by default)
      -v, --version: Prints version
      -h, --help: Prints help

  Environment variables that are supported:
      DEPLOYMENT_MECHANISM: The deployment type you want. (default: 'openstack')
      SOCOK8S_DEVELOPER_MODE: Enable SOCOK8S script developer mode. (default: 'False')
      USE_ARA: Use ARA?. (default: 'False')

The argbash m4 files are macros to define which arguments are available, their
help strings, and valid commands.   You can modify socok8s.m4 to add new
arguments, and then simply rebuild socok8s.sh with make again.  You can view argbash
here:  http://argbash.io or http://github.com/matejak/argbash
