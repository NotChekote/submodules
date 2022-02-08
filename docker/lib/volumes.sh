#!/usr/bin/env bash

set -euo pipefail

# Associative array mapping Docker Volume names to paths
declare -A VOLUMES
VOLUMES["user_cache"]="$HOME/.cache"
VOLUMES["user_config"]="$HOME/.config"
VOLUMES["user_composer"]="$HOME/.composer"
VOLUMES["user_docker"]="$HOME/.docker"
VOLUMES["user_gitconfig"]="$HOME/.gitconfig"
VOLUMES["user_npm"]="$HOME/.npm"
VOLUMES["user_wrangler"]="$HOME/.wrangler"
VOLUMES["submodules_project"]="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd )"
export VOLUMES

export readonly DIRECTORY=0
export readonly FILE=1

# Associative array mapping Docker Volume targets to types
declare -A VOLUME_TYPES
VOLUME_TYPES["user_cache"]=$DIRECTORY
VOLUME_TYPES["user_config"]=$DIRECTORY
VOLUME_TYPES["user_composer"]=$DIRECTORY
VOLUME_TYPES["user_docker"]=$DIRECTORY
VOLUME_TYPES["user_gitconfig"]=$FILE
VOLUME_TYPES["user_npm"]=$DIRECTORY
VOLUME_TYPES["user_wrangler"]=$DIRECTORY
VOLUME_TYPES["submodules_project"]=$DIRECTORY
export VOLUME_TYPES

export PROJECT_VOLUME="submodules_project"
