#!/usr/bin/env bash

set -euo pipefail

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../lib/git.bash"
git.paths.get

. "$SUBMODULES/lib/docker.bash"
. "$SUBMODULES/lib/nfs.bash"
. "$ROOT/docker/lib/volumes.sh"

if [[ "$(uname)" == 'Darwin' ]]; then
  # On mac, setup NFS server and create NFS volumes
  type='nfs'
  opts='addr=host.docker.internal,rw,nolock,hard,nointr,nfsvers=3'
  nfs.server.setup
else
  # On linux, create local bind volumes
  type='none'
  opts='bind'
fi

# Loop over each of the volumes
for volume in "${!VOLUMES[@]}"; do
  # And check if it exists
  if ! docker volume inspect "$volume" &> /dev/null; then
    # If not, then create it
    docker.volume.create "$volume" "${VOLUMES[$volume]}" "$type" "${opts}"
  else
    docker.volume.ensure.has.path "$volume" "${VOLUMES[$volume]}" "$type" "$opts"
  fi
done
