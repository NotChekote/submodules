#!/usr/bin/env bash

set -euo pipefail

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd )"
. "$root/submodules/lib/setup_nfs_functions.sh"
. "$root/docker/lib/volumes.sh"

if [[ "$(uname)" == 'Darwin' ]]; then
  # On mac, setup NFS server and create NFS volumes
  type='nfs'
  opts='addr=host.docker.internal,rw,nolock,hard,nointr,nfsvers=3'
  setupNfsServer
else
  # On linux, create local bind volumes
  type='none'
  opts='bind'
fi

# Loop over each of the volumes
for volume in "${!VOLUMES[@]}"; do
  # And check if it exists
  if ! docker volume ls | grep -qF "$volume"; then
    # If not, then create it
    createDockerVolume "$volume" "${VOLUMES[$volume]}" "$type" "${opts}"
  else
    recreateVolumeIfMountFromDifferentFolder "$volume" "${VOLUMES[$volume]}" "$type" "$opts"
  fi
done
