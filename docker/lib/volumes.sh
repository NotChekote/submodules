#!/usr/bin/env bash

set -euo pipefail

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../lib/git.bash"
git.paths.get

. "$SUBMODULES/docker/lib/base_volumes.sh"

# Associative array mapping Docker Volume names to paths. Extends array defined in Submodules Docker volumes script.
VOLUMES["submodules_project"]="$SUBMODULES"
export VOLUMES

# Associative array mapping Docker Volume targets to types. Extends array defined in Submodules Docker volumes script.
VOLUME_TYPES["submodules_project"]=$DIRECTORY
export VOLUME_TYPES

export PROJECT_VOLUME="submodules_project"
