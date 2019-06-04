#!/bin/bash

set -xe

export OS_CLOUD=openstack

IMAGE_NAME=$(openstack image show -f value -c name \
  $(openstack image list -f csv | awk -F ',' '{ print $2 "," $1 }' | \
  grep "^\"Cirros" | head -1 | awk -F ',' '{ print $2 }' | tr -d '"'))
openstack image show "${IMAGE_NAME}" -f value -c id
