#!/bin/bash

CI_SCRIPTS_PATH="$(dirname "$(readlink -f "${0}")")"
pushd ${CI_SCRIPTS_PATH}/../../

## Argocd
curl -o argocd-install/upstream-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

## SES6 manifests. See also: https://jira.suse.com/browse/SES-799
ses_container=$(podman run -d registry.suse.de/home/jevrard/ses-container-images/containers/rook-manifests-extractor /bin/bash | tail -n 1)
echo "Container running id ${ses_container}"
podman cp "${ses_container}:/usr/share/k8s-yaml/rook/ceph/*" ses6/upstream/
podman rm ${ses_container}
