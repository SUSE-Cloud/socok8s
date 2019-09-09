#!/bin/bash

CI_SCRIPTS_PATH="$(dirname "$(readlink -f "${0}")")"
pushd ${CI_SCRIPTS_PATH}/../../

## Argocd
curl -o argocd-install/upstream-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
