.. _developerdocumentation:

=======================
Developer Documentation
=======================

In this section, you will find documentation relevant to developing
SUSE Containerized OpenStack.

.. _learning:

Learning Materials
==================

You can find some learning materials for the technologies used by this project
in the following sections.

.. toctree::
   :maxdepth: 1

   kubernetes.rst
   openstack-helm.rst
   airship.rst
   cluster-api.rst
   metalcubed.rst






.. _contributing:

Contributor Guidelines
======================

Submodules
----------

This repository uses submodules. The following guidelines apply only to the
socok8s project and repository. If your contribution affects other projects,
please check those practices before contributing to them.

Before submitting code
----------------------

This is a fast moving project. Please contact us before starting to work on it.

If you're willing to submit code, please remember the following rules:

* All code should match our
  :ref:`codeguidelines`.
* All code is required to go through our :ref:`reviews`.
* Documentation should be provided with the code directly. See also
  :ref:`documentation`.

.. _bug_reporting:

Bug reporting process
---------------------

File bugs as Github issues.

When submitting a bug or working on a bug, please observe the following
criteria:

* The description clearly states or describes the original problem or root
  cause of the problem.
* The description clearly states the expected outcome of the user action.
* Include historical information about how the problem was identified.
* Include any relevant logs or user configuration information, either directly
  or through a pastebin.
* If the issue is a bug that needs fixing in a branch other than master,
  please note the associated branch within the issue.
* The provided information should be totally self-contained. External access
  to web services/sites should not be needed.
* Steps to reproduce the problem if possible.

.. _reviews:

Review process
--------------

Any new code will be reviewed before merging into our repositories.

Two approving reviews are required before merging a pull request.

Any patch can be refused by the community if it does not match the :ref:`codeguidelines`.

Upstream communication channels
-------------------------------

Most of this project is a thin wrapper around the Airship, OpenStack Helm,
OpenStack LOCI upstream projects.

A developer should monitor the **OpenStack-discuss** `openstack mailing lists`_,
and the **Airship-discuss** `airship mailing lists`_

.. _openstack mailing lists: http://lists.openstack.org/cgi-bin/mailman/listinfo
.. _airship mailing lists: http://lists.airshipit.org/cgi-bin/mailman/listinfo

Please contact us on freenode IRC, in the #openstack-helm or #airshipit
channels.

.. _code_rules:

Code rules
==========

.. _codeguidelines:

General Guidelines for Submitting Code
--------------------------------------

* Write good commit messages. We follow the OpenStack
  "`Git Commit Good Practice`_" guide. If you have any questions regarding how
  to write good commit messages, please review the upstream OpenStack
  documentation.
* All patch sets should adhere to the :ref:`ansiblestyleguide` listed here and
  follow the `Ansible best practices`_ when possible.
* Refactoring work should never include additional "rider" features. Features
  that may pertain to something that was refactored should be raised as an
  issue and submitted in prior or subsequent patches.
* All patches including code, documentation and release notes should be built
  and tested locally first.

.. _Git Commit Good Practice: https://wiki.openstack.org/wiki/GitCommitMessages
.. _Ansible best practices: http://docs.ansible.com/playbooks_best_practices.html

.. _documentation:

Documentation with code
-----------------------

Documentation is a critical part of ensuring that the deployers of
this project are appropriately informed about:

* How to use the project's tooling effectively to deploy OpenStack.
* How to implement the right configuration to meet the needs of their specific
  use case.
* Changes in the project over time which may affect an existing deployment.

To meet these needs developers must submit
:ref:`codecomments` and documentation with any code submissions.

All forms of documentation should comply with the guidelines provided
in the `OpenStack Documentation Contributor Guide`_, with particular attention
to the following sections:

* Writing style
* RST formatting conventions

.. _OpenStack Documentation Contributor Guide: https://docs.openstack.org/contributor-guide/

.. _codecomments:

Code Comments
-------------

Code comments for variables should be used to explain the purpose of the
variable.

Code comments for Bash/Python3 scripts should give guidance to the purpose of
the code. This is important to provide context for reviewers before the patch
has merged, and for later modifications to remind the contributors what the
purpose was and why it was done that way.


.. _ansiblestyleguide:

Ansible Style Guide
-------------------

When creating tasks and other roles for use in Ansible, create them using the
YAML dictionary format.

Example YAML dictionary format:

.. code-block:: yaml

   - name: The name of the tasks
      module_name:
        thing1: "some-stuff"
        thing2: "some-other-stuff"
      tags:
        - some-tag
        - some-other-tag


Example what **NOT** to do:

.. code-block:: yaml

    - name: The name of the tasks
      module_name: thing1="some-stuff" thing2="some-other-stuff"
      tags: some-tag

.. code-block:: yaml

    - name: The name of the tasks
      module_name: >
        thing1="some-stuff"
        thing2="some-other-stuff"
      tags: some-tag


Usage of the ">" and "|" operators should be limited to Ansible conditionals
and command modules such as the Ansible ``shell`` or ``command``.

Testing
=======

Code is tested using Travis and SUSE CI.

Bash Linting
------------

Bash coding conventions are tested using shellcheck.

Ansible Linting
---------------

Ansible convention are tested using ansible-lint, with the exception of:

* Allow warning 204, which means lines longer than 120 characters are enabled.

Helm chart values linting
-------------------------

No test is implemented yet, and patches are welcomed.

Periodic work
=============

This repository actively freezes the upstream code into `vars/manifest.yml`.
It is necessary to regularly refresh the versions inside this file.

Similarly, we are using submodules, which also need a regular version update.

Updating the manifest and the submodules are manual operations.
There is no code available to bump those versions yet.

Airship Developer Guide
=======================

Testing upstream patches
------------------------

Carrying your own patches has been described as a user story on the page
:ref:`custompatches`.

Build your own images
---------------------

Carrying your own images has been described as a user story on the page
:ref:`buildownimages`.

Point to your own images in airship
-----------------------------------

This has been described in a user story on the page :ref:`useownimages`.
