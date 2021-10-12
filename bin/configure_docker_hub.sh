#!/usr/bin/env bash

set -euo pipefail

echo "Docker Hub login..."
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
