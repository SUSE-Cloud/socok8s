#!/bin/bash

set -e
env | grep -e OS_ -e SSH_

if [[ ! -d .terraform ]]; then
    cp -r /usr/share/caasp/terraform/openstack/* ./
    terraform init -input=false
fi

terraform apply ./
terraform output -json > ./terraform-output.json
echo "Cloud instances successfully deployed"

# Skuba init
CLUSTER_NAME="caasp4-cluster"
if [[ ! -d ./${CLUSTER_NAME} ]]; then
    skuba cluster init ${CLUSTER_NAME} --control-plane $(python -c 'import json; fd=open("terraform-output.json"); tf=json.load(fd); fd.close(); print(tf["ip_load_balancer"]["value"]);')
fi

cd ${CLUSTER_NAME}

if [[ -f admin.conf ]]; then
    echo "Checking cluster status"
    cluster_status=$(skuba cluster status)
    echo $cluster_status
fi

# Skuba master deploy
if [ "$cluster_status" == "" ] || [ ! `echo $cluster_status | grep master-0` ]; then
    master_ip=$(python -c 'import json; fd=open("../terraform-output.json"); tf=json.load(fd); fd.close(); print(tf["ip_masters"]["value"][0]);')
    echo "Bootstrapping master through ${master_ip}"
    skuba node bootstrap master-0 -s -t ${master_ip} -u sles -v 2
fi

# Skuba workers deploy
let i=1
for worker in $(python -c 'import json,pprint; fd=open("../terraform-output.json"); tf=json.load(fd); fd.close(); print("\n".join(tf["ip_workers"]["value"]));'); do
    echo "Bootstrapping worker ${i} through ip ${worker}"
    skuba node join worker-${i} -r worker -s -t ${worker} -u sles -v 2
    let i++
done

cp /workdir/tf/${CLUSTER_NAME}/admin.conf /workdir/kubeconfig
