#!/usr/bin/env bash

MAIN_FOLDER="$(readlink -f $(dirname ${0})/..)"
CURRENT_FOLDER="$(readlink -f $(dirname ${0}))"

set -o errexit

# Ensure the necessary variables are set
source ${MAIN_FOLDER}/script_library/pre-flight-checks.sh check_ansible_requirements

pushd ${CURRENT_FOLDER} > /dev/null
    # TODO(evrardjp) Remove the submodule init and update when the git clone has received a -b branch argument
    git submodule init; git submodule update
    # Generates the expected inventory for ses-ansible
    # TODO(evrardjp) Disable ses_openstack_config when ensured properly configured in step 7
    # with both existing pools and uncreated pools. Likewise, remove the next playbook (get-ses-data)
    # when we are sure about the data structure we need for upgrades.
    ansible-playbook ses-install.yml -i ${MAIN_FOLDER}/inventory-ses.ini -e ses_openstack_config=True
    ansible-playbook get-ses-data.yml -i ${MAIN_FOLDER}/inventory-ses.ini
    ansible-playbook set-user-variables.yml -i ${MAIN_FOLDER}/inventory-ses.ini
popd
