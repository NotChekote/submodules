#!/usr/bin/env bash

set -euo pipefail

#######################################
# Checks out a remote branch and tracks it
#
# Arguments:
#   1 the url of the remote repo
#   2 the branch to check out
#######################################
git.branch.checkout-and-track () {
    local remote_url="$1"
    local branch="$2"

    git remote add temp "$remote_url"
    git fetch temp
    git checkout --track "temp/$branch"
}

#######################################
# Exits if branch is on master
#
# Arguments:
#   1 the message prefix to print if we are going to exit
#######################################
git.branch.exit-if-master () {
    local message="$1"

    local branch
    branch="$(git symbolic-ref --short HEAD)"

    if [[ "$branch" == "master" ]]; then
        echo "$message since the branch is master"
        exit 0
    fi
}

#######################################
# Exits if the git index is empty (nothing is staged for commit)
#
# Arguments:
#   1 the message to print if nothing is staged
#######################################
git.index.exit_if_empty () {
    local message="$1"

    if [[ $(git status | grep -Ec 'Changes to be committed') -eq 0 ]]; then
      echo "$message"
      exit 0
    fi
}

#######################################
# Lists staged files based on filters passed
#
# Flags:
#   -g=|--git-filters= string of git short formats to filter by defaults to "MARC"
#   https://git-scm.com/docs/git-status#_short_format
#
#   -e=|--extension-filters= string of extensions to filter by E.g. "*.php" or "*.php|*.js"
#
#   -* all other flags will be passed into git status
#######################################
git.index.staged () {
  local gitFilters='MARC'
  local extensionFilters=''
  local gitFlags=''

  for i in "$@"; do
    case $i in
      -g=*|--git-filters=*)
        gitFilters="${i#*=}"
        shift
        ;;
      -e=*|--extension-filters=*)
        extensionFilters="-- ${i#*=}"
        shift
        ;;
      -*)
        if [ -z "$gitFlags" ]; then
          gitFlags="$i"
        else
          gitFlags="$gitFlags $i"
        fi
        shift
        ;;
      *)
        # unknown option
        ;;
    esac
  done

  # We actually want splitting here
  # shellcheck disable=SC2086
  git status --short ${gitFlags:-} ${extensionFilters:-} | { grep "^[$gitFilters]" || true; } | cut -c 4-
}
