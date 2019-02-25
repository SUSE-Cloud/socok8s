#!/bin/bash

set -euo pipefail

OPENRC=$1
CHANNEL=$2

IMAGE_FILENAME=$(readlink ../downloads/openstack-${CHANNEL})
IMAGE_BUILD=$(echo $IMAGE_FILENAME | sed -n 's/.*\(Build.*\).qcow2/\1/p')
IMAGE_VERSION=$(echo $IMAGE_FILENAME | sed -n 's/.*CaaS-Platform-\(.*\)-for-OpenStack-Cloud.*/\1/p')
IMAGE_NAME="CaaSP-${CHANNEL}-${IMAGE_VERSION}-${IMAGE_BUILD}"

source $OPENRC
echo "[+] Checking if we already have this image: $IMAGE_NAME"

if ! openstack image list --public | grep " $IMAGE_NAME "; then
    echo "[+] Uploading SUSE CaaSP qcow2 VM image: $IMAGE_NAME"
    openstack image create $IMAGE_NAME --public --disk-format qcow2 --container-format bare --min-disk 40 --file $IMAGE_FILENAME \
        --property caasp-version="$IMAGE_VERSION" \
        --property caasp-build="$IMAGE_BUILD" \
        --property caasp-channel="$CHANNEL"
else
   echo "[+] Skipping upload, we already have this image"
fi
