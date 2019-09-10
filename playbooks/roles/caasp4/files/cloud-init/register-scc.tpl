  - [ SUSEConnect, -r, ${sles_registry_code} ]
# Change from skuba repo version: Start
  - [ SUSEConnect, -r, ${caasp_registry_code} ]
# Change from skuba repo version: End
  - [ SUSEConnect, -p, sle-module-containers/15.1/x86_64 ]
  - [ SUSEConnect, -p, caasp/4.0/x86_64, -r, ${caasp_registry_code} ]
