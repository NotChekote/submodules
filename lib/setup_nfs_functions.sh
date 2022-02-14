#!/usr/bin/env bash

set -euo pipefail

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/git.bash"
git.paths.get

. "$SUBMODULES/lib/dir.bash"
. "$SUBMODULES/lib/file.bash"

#######################################
# Setup NFS server on Mac
#######################################
setupNfsServer() {
  if showmount -e | grep -qF '/System/Volumes/Data'; then
    echo "NFS exports ready"
  else
    local uid
    local gid

    echo "Setting up the NFS server, your password will be required..."

    # Allow connections from any port
    writeToFile 'Allow connections from any port' 'nfs.server.mount.require_resv_port = 0' '/etc/nfs.conf'

    # Config file system exports on macOS Catalina
    uid=${UID:-"$(id -u "$(whoami)")"}
    gid=${GID:-"$(id -g "$(whoami)")"}
    writeToFile 'Export file system' "/System/Volumes/Data -alldirs -mapall=${uid}:${gid} localhost" '/etc/exports'

    echo " - Restarting the NFS server"
    sudo nfsd restart

    echo "NFS exports ready"
  fi
}

#######################################
# Write a line to a file using sudo
#
# Arguments:
#   1 message to output
#   2 the line to write
#   3 the file path
#######################################
writeToFile() {
  local message=$1
  local line=$2
  local file=$3

  if ! grep -qF -- "$line" "$file"; then
    echo " - ${message}"
    echo "$line" | sudo tee -a "$file" > /dev/null
  else
    echo " - ${message} already exists on ${file}, skipping..."
  fi
}

#######################################
# Creates a Docker volume
#
# Arguments:
#   1 the volume name
#   2 the volume path
#   3 the volume type
#   4 the volume opts
#######################################
createDockerVolume() {
  local volume_name=$1
  local volume_path=$2
  local volume_type=$3
  local volume_opts=$4

  echo "Creating Docker Volume ${volume_name} for path ${volume_path}"

  if [ "${VOLUME_TYPES[$volume_name]}" = "$DIRECTORY" ]; then
    dir.ensure.exists "$volume_path"
  else
    file.ensure.exists "$volume_path"
  fi

  if [[ $volume_type = 'nfs' ]]; then
    volume_path=":${volume_path}"
  fi

  docker volume create \
    --driver local \
    --opt type="${volume_type}" \
    --opt o="${volume_opts}" \
    --opt device="${volume_path}" \
    "${volume_name}" > /dev/null
}

#######################################
# Recreate a Docker volume if the existing volume is mounted from incorrect location.
#
# Arguments:
#   1 the volume name
#   2 the volume path
#   3 the volume type
#   4 the volume opts
#######################################
recreateVolumeIfMountFromDifferentFolder() {
  local volume_name=$1
  local volume_path=$2
  local volume_type=$3
  local volume_opts=$4
  if [[ $(docker volume inspect --format '{{.Options.device}}' "${volume_name}" | sed 's/^://') != "${volume_path}" ]]; then
    docker volume rm "${volume_name}"
    createDockerVolume "${volume_name}" "${volume_path}" "${volume_type}" "${volume_opts}"
  fi
}
