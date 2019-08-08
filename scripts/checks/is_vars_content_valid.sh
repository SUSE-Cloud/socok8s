#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

invalid_chars=" ."

if [[ ! "${SOCOK8S_ENVNAME}" =~ ^[^$invalid_chars]+$ ]] || [[ ! "${SOCOK8S_WORKSPACE}" =~ ^[^$invalid_chars]+$ ]]; then
    echo "SOCOK8S_ENVNAME or SOCOK8S_WORKSPACE contains one or more of the following invalid characters: '$invalid_chars'"
    exit 1
fi
