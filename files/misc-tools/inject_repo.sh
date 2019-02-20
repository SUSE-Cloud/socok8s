#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"

# Options
REPO=${1:-http://download.suse.de/ibs/Devel:/CASP:/Head:/ControllerNode/standard}
ALIAS=${2:-Extra}
ENVIRONMENT=${ENVIRONMENT:-$DIR/../caasp-kvm/environment.json}

FQDNS=$(jq -r "[.minions[] | .fqdn ] | join(\" \" )" $ENVIRONMENT)
for fqdn in $FQDNS; do
  ssh -F $DIR/environment.ssh_config $fqdn -- bash -c "\"echo -e \\\"[main]\nvendors = suse,opensuse,obs://build.suse.de,obs://build.opensuse.org\\\" > /etc/zypp/vendors.d/vendors.conf && zypper ar --no-gpgcheck $REPO $ALIAS\""
done
