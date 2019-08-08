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
- scripts/ci/ contains CI only scripts.
- scripts/cleanup.sh is a k8s cleanup tool.
