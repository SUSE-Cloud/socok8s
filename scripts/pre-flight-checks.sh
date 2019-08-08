#!/usr/bin/env bash
# Ensures env is ready
# Sets up the SOCOK8S_WORKSPACE FOLDER

if ! type -p podman; then
   echo "Please install podman."
fi

if [ -z ${SOCOK8S_ENVNAME+x} ]; then
    echo "No SOCOK8S_ENVNAME given. export SOCOK8S_ENVNAME=... for setting a env name" && exit 1
fi

invalid_chars=" ."
if [[ ! "${SOCOK8S_ENVNAME}" =~ ^[^$invalid_chars]+$ ]]; then
    echo "SOCOK8S_ENVNAME contains one or more of the following invalid characters: \"$invalid_chars\"" && exit 1
fi

if [ -z ${SOCOK8S_WORKSPACE_BASEDIR+x} ]; then
    echo "No SOCOK8S_WORKSPACE_BASEDIR given. export SOCOK8S_WORKSPACE_BASEDIR=... for setting a directory" && exit 1
else
    echo 'Please export SOCOK8S_WORKSPACE="${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace/"'
    SOCOK8S_WORKSPACE=${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace/
    if [[ ! -d ${SOCOK8S_WORKSPACE} ]]; then
        mkdir -p "${SOCOK8S_WORKSPACE}"
    fi
fi
