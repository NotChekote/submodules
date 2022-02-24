#!/usr/bin/env bash

set -euo pipefail

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../lib/git.bash"
git.paths.get

. "$SUBMODULES/lib/circleci.sh"

circleci.job.queue "$@"
