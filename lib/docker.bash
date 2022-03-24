#######################################
# Library of functions for working with Docker.
#
# https://www.docker.com/
#######################################

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/git.bash"
git.paths.get

. "$SUBMODULES/lib/dir.bash"
. "$SUBMODULES/lib/file.bash"

#######################################
# Determines the UID of the user running the Docker containers.
#
# Output
#   The UID of the user running the Docker containers.
#######################################
docker.host.user.id() {
  if [ "$(uname)" == 'Linux' ]; then
    # We're on Linux. There's no virtualization, so we use our own UID.
    id -u
  else
    # We're not on Linux. The User ID doesn't really matter on non-linux hosts as modern Docker allows any user within
    # the container to have full read/write access to mounted volumes. But to make it easier for users of this script
    # to work with the env var, we'll set this to something innocuous so it can still be passed to commands and used in
    # docker compose config files.
    echo 1000
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
docker.volume.create() {
  local volume_name="$1"
  local volume_path="$2"
  local volume_type="$3"
  local volume_opts="$4"

  echo "Creating Docker Volume $volume_name for path $volume_path"

  if [ "${VOLUME_TYPES[$volume_name]}" = "$DIRECTORY" ]; then
    dir.ensure.exists "$volume_path"
  else
    file.ensure.exists "$volume_path"
  fi

  if [[ $volume_type = 'nfs' ]]; then
    volume_path=":$volume_path"
  fi

  docker volume create \
    --driver local \
    --opt type="$volume_type" \
    --opt o="$volume_opts" \
    --opt device="$volume_path" \
    "$volume_name" > /dev/null
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
docker.volume.ensure.has.path() {
  local volume_name="$1"
  local volume_path="$2"
  local volume_type="$3"
  local volume_opts="$4"

  if [[ $(docker volume inspect --format '{{.Options.device}}' "$volume_name" | sed 's/^://') != "$volume_path" ]]; then
    docker volume rm "$volume_name"
    docker.volume.create "$volume_name" "$volume_path" "$volume_type" "$volume_opts"
  fi
}

