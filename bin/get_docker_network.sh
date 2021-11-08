#!/usr/bin/env bash

set -euo pipefail

readonly DOCKER_NETWORK=global

if [[ "$(docker network ls | grep -c "$DOCKER_NETWORK" | awk '{ print $1 }')" = 0 ]]; then
  docker network create "$DOCKER_NETWORK" > /dev/null
fi

export DOCKER_NETWORK
