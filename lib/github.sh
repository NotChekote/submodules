#!/usr/bin/env bash

set -euo pipefail

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/git.bash"
git.paths.get

. "$SUBMODULES/lib/circleci.sh"

#######################################
# Retrieve the details of the pull request from the github api
#
# @see https://docs.github.com/en/rest/reference/pulls#get-a-pull-request
#
# Globals:
#   GITHUB_TOKEN
#   CIRCLE_PROJECT_USERNAME
#   CIRCLE_PROJECT_REPONAME
#
# Return:
#   The PR details
#######################################
github.pull.get () {
    curl -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.shadow-cat-preview+json" \
        -S "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/$(circleci.pr.number)"
}

#######################################
# Extracts the URL from a pull request details response
#
# Arguments:
#   1 the pull request details response to extract the URL from
#######################################
github.pull.url.get () {
  echo "$1" | jq '.head.repo.git_url' | sed -e 's/^"//' -e 's/"$//'
}

#######################################
# Extracts the ref from a pull request details response
#
# Arguments:
#   1 the pull request details response to extract the ref from
#######################################
github.pull.ref.get () {
  echo "$1" | jq '.head.ref' | sed -e 's/^"//' -e 's/"$//'
}
