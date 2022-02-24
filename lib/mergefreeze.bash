#!/usr/bin/env bash

set -euo pipefail

#######################################
# Gets the Target URL for the Mergefreeze API of this branch
#
# Arguments:
#   1 The username of the account that hosts the github project
#   2 The name of the repository to be frozen
#
# Globals:
#   MERGEFREEZE_ACCESS_TOKEN The API TOKEN to access mergefreeze and freeze / unfreeze the branch
#######################################
mergefreeze.url() {
  local username="$1"
  local reponame="$2"

  #Format: https://www.mergefreeze.com/api/branches/[Github account name]/[Github repository name]/[protected branch name]/?access_token=[Access token]
  local baseUrl="https://www.mergefreeze.com/api/branches/"
  local finalUrl="$baseUrl$username/$reponame/master/?access_token=$MERGEFREEZE_ACCESS_TOKEN"
  echo "$finalUrl"
}

#######################################
# Freezes the current branch
#
# Arguments:
#   1 The username of the account that hosts the github project
#   2 The name of the repository to be frozen
#######################################
mergefreeze.freeze(){
  local username="$1"
  local reponame="$2"

  local url
  url="$(mergefreeze.url "$username" "$reponame")"
  echo "Merge Freeze in action"
  curl --data "frozen=true&user_name=$username" "$url"
}

#######################################
# Unfreezes the current branch
#
# Arguments:
#   1 The username of the account that hosts the github project
#   2 The name of the repository to be frozen
#######################################
mergefreeze.unfreeze(){
  local username="$1"
  local reponame="$2"

  local url
  url="$(mergefreeze.url "$username" "$reponame")"
  echo "Merge Unfreeze in action"
  curl --data "frozen=false&user_name=$username" "$url"
}
