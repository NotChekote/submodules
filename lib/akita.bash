#!/usr/bin/env bash

set -euo pipefail

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/git.bash"
git.paths.get

. "$ROOT/docker/lib/images.sh"

#######################################
# Sets the specified Akita spec as the new baseline
#
# Args:
#   1 The ID of the Akita spec to set as the new baseline
#######################################
akita.baseline.update () {
    local spec_id="$1"
    akita setversion stable "$spec_id"
}

#######################################
# Issues the command to start the Akita session, and waits for it to succeed
#
# Args:
#   1 The name of the Akita service to associate the session with
#######################################
akita.run () {
    local service="$1"
    akita learn --har --har_output_dir=/tmp/artifacts/ --service "$service" --port 80 --session "$(akita.session.id)" &
    wait
}

#######################################
# Reads the Akita session id from the artifacts/akita file
#######################################
akita.session.id () {
    file=artifacts/akita

    if [[ -r "$file" ]]; then
        cat "$file"
    fi
}

#######################################
# Creates a checkpoint for the specified service using the session id provided by akita.session.id
#
# Args:
#   1 The name of the Akita service to create the checkpoint for
#
# Exports:
#   AKITA_SPEC the identifier for the spec that was created.
#######################################
akita.session.checkpoint() {
    local service="$1"
    AKITA_SPEC="$(akita learn-sessions checkpoint --service "$service" "$(akita.session.id)")"
    export AKITA_SPEC
}

#######################################
# Creates a session for the specified service
#
# Args:
#   1 The name of the Akita service to create the session for
#######################################
akita.session.create () {
    local service="$1"
    akita learn-sessions create --service "$service" > artifacts/akita
}

#######################################
# Stops the Docker container that the Akita process is running in
#
# Environment Variables:
#   AKITA_IMAGE The Docker tag for the image that the container is using
#######################################
akita.stop () {
    if [ ! -v AKITA_IMAGE ]; then
      echo "The AKITA_IMAGE env var must be set"
      return 1
    fi

    docker container ls --format "{{.Image}} {{.Names}}" | grep "$AKITA_IMAGE" | awk '{print $2}' | xargs docker kill --signal=SIGINT

    ###
    # Temporarily disabled this, as it causes an error in CI and we are working with Akita to fix it
    #
    # .circleci/bin/akita/stop_akita.sh: line 11: wait: pid 16066 is not a child of this shell
    # ##
    # wait "$SUPER_LEARN_PID"
}
