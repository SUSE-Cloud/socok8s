#!/usr/bin/env bash

if ! type -p podman; then
   echo "Podman not present. Please install podman."
   exit 1
fi
