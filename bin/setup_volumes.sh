#!/usr/bin/env bash

set -eu

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd )"
. "$ROOT"/submodules/lib/setup_nfs_functions.sh
. "$ROOT"/docker/lib/volumes.sh

if [[ "$(uname)" == 'Darwin' ]]; then
  # On mac, setup NFS server and create NFS volumes
  TYPE='nfs'
  OPTS='addr=host.docker.internal,rw,nolock,hard,nointr,nfsvers=3'
  setupNfsServer
else
  # On linux, create local bind volumes
  TYPE='none'
  OPTS='bind'
fi

# Loop over each of the volumes
for VOLUME in "${!VOLUMES[@]}"; do
  # And check if it exists
  if ! docker volume ls | grep -qF "${VOLUME}"; then
    # If not, then create it
    createDockerVolume "${VOLUME}" "${VOLUMES[$VOLUME]}" "${TYPE}" "${OPTS}"
  else
    recreateVolumeIfMountFromDifferentFolder "${VOLUME}" "${VOLUMES[$VOLUME]}" "${TYPE}" "${OPTS}"
  fi
done
