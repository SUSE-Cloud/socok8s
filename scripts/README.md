Expectations
============

- Your locahost should have podman.
- You are exporting the following variables:
  - SOCOK8S_WORKSPACE (the folder must exist, and not contain spaces or dots)
  - SOCOK8S_ENVNAME (this must not contain spaces or dots)

You can check this by running the scripts in ```scripts/checks/```

Folder structure
================

- scripts/checks/ contains pre-flight checks
- scripts/ci/ contains **for CI only** scripts.
- scripts/dev/ contains tools to use/setup caasp for development environment.
- scripts/tools/ contains generic tools for users or developers.

Example tools
=============

- a way to gather logs without relying on central logging.
- a way to clean up the k8s cluster to an empty state.
