#######################################
# Library of functions for working with NFS (Network File System) on Mac OS X.
#######################################

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/git.bash"
git.paths.get

. "$SUBMODULES/lib/dir.bash"
. "$SUBMODULES/lib/docker.bash"
. "$SUBMODULES/lib/file.bash"
. "$SUBMODULES/lib/user.bash"

#######################################
# Compiles the NFS export entry for the specified path
#
# Arguments:
#   1 the export path
#######################################
nfs.export.compile() {
  local path="$1"

  # Config file system exports on Mac OS X
  echo "$path -alldirs -mapall=$(user.id):$(user.group.id) localhost"
}

#######################################
# Ensures that a specified NFS export is configured.
#
# Arguments:
#   1 the export path
#######################################
nfs.export.create() {
  local path="$1"

  echo "Creating NFS export for '$path'..."

  file.sudo.write.line "$(nfs.export.compile "$path")" '/etc/exports'
}

#######################################
# Ensures that a specified NFS export is configured.
#
# Arguments:
#   1 the export path
#######################################
nfs.export.exists() {
  local path="$1"

  echo "Checking if export for '$path' is configured..."

  file.has.line "$(nfs.export.compile "$path")" '/etc/exports'

  return $?
}

#######################################
# Ensures that a specified NFS export is configured.
#
# Arguments:
#   1 the export path
#######################################
nfs.export.ensure.exists() {
  local path="$1"

  echo "Ensuring NFS export for '$path' is set up..."

  if ! nfs.export.exists "$path"; then
    echo "Export for '$path' is not configured."
    nfs.export.create "$path"
  fi
}

#######################################
# Restarts the NFS server
#######################################
nfs.server.restart() {
  echo "Restarting the NFS server"
  sudo nfsd restart
}

#######################################
# Setup NFS server on Mac
#######################################
nfs.server.setup() {
  echo "Setting up the NFS server, your password may be required..."

  # Allow connections from any port
  file.sudo.ensure.has.line 'Allow connections from any port' 'nfs.server.mount.require_resv_port = 0' '/etc/nfs.conf'

  local path
  local restart_nfs="false"
  for path in '/System/Volumes/Data' '/Volumes/Projects'; do
    echo "Ensuring NFS export for '$path' is set up..."

    if nfs.export.exists "$path"; then
      echo "Export for '$path' is already configured."
    else
      echo "Export for '$path' is not configured."
      nfs.export.create "$path"
      restart_nfs="true"
    fi
  done

  if [ "$restart_nfs" = "true" ]; then
    nfs.server.restart
  fi

  echo "NFS exports ready"
}

