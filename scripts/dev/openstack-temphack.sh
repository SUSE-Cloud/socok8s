#!/bin/bash
# Remove this when port security changes are integrated in skuba

set -o pipefail
set -o errexit
set -o nounset

network=$(jq '.modules[0].resources."openstack_networking_network_v2.network".primary.attributes.id' -r ${SOCOK8S_WORKSPACE}/tf/terraform.tfstate)
echo "Found network ${network}"
serverports=$(openstack port list --network ${network} -c ID -f value)
for port in $serverports; do
    ## Disable port security on those pesky instances
    openstack port set ${port} --no-security-group --disable-port-security
done
