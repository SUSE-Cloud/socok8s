#!/bin/bash

set -e
set -o pipefail

systemctl stop kubelet

systemctl stop docker

mounted_snapshot=$(mount | grep snapshot | gawk  'match($6, /ro.*@\/.snapshots\/(.*)\/snapshot/ , arr1 ) { print arr1[1] }')

if [[ -n "${mounted_snapshot}" ]]; then
  btrfs property set -ts /.snapshots/"${mounted_snapshot}"/snapshot ro false
fi

root_remounted_rw=false

create_subvolume(){
  if [[ ! -d "$1" ]]; then
    if [[ "${root_remounted_rw}" = false ]]; then
      mount -o remount, rw /
      root_remounted_rw=true
    fi
    mksubvolume "$1"
  fi
}

create_subvolume /var/lib/nova
create_subvolume /var/lib/neutron
create_subvolume /var/lib/libvirt

if [[ -n "${mounted_snapshot}" ]]; then
  btrfs property set -ts /.snapshots/"${mounted_snapshot}"/snapshot ro true
fi
