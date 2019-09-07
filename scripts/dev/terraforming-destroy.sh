#!/bin/bash
env | grep OS_
terraform destroy -auto-approve ./
rm -rf ./caasp4-cluster/ || true
rm /workdir/kubeconfig || true
