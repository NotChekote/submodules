#!/usr/bin/env bash

set -euo pipefail

#######################################
# Exits if the current working directory is not a git repo
#######################################
assert_git_repo () {
  if [[ ! -d .git ]]; then
    echo "This script must be ran from the root of a git repository";
    exit 1;
  fi;
}

#######################################
# Create the hooks symlink
#######################################
create_symlink () {
  echo "Creating symbolic link..."
  ln -s ../hooks .git/hooks
}

#######################################
# Exits if the user does not provide authorization to remove the hooks folder
#######################################
exit_if_not_willing_to_remove_dir () {
  local response

  while true; do
    read -r -p "Symbolic link is NOT configured correctly. We need to remove the git hooks directory. Is that okay? (y/n)" response
    case "$response" in
      [Yy]* ) break;;
      [Nn]* )  echo "Git hook initialization canceled by user"; exit 1;;
      * ) echo "Please answer yes or no (y/n).";;
    esac
  done
}

#######################################
# Removes and creates the hooks symlink
#######################################
recreate_symlink () {
  remove_git_hooks
  create_symlink
}

#######################################
# Removes the git hooks
#
# Globals:
#   CI true if the current env is CI, false if not.
#######################################
remove_git_hooks() {
  if [[ "${CI:-}" != true ]] ; then
      exit_if_not_willing_to_remove_dir
  fi

  echo "Removing..."
  rm -rf .git/hooks
}

#######################################
# Verifies that the current hooks symlink is configured correct, and fixes it if not
#######################################
verify_symlink() {
  if [[ "$(readlink .git/hooks)" == ../hooks ]]; then
    echo "Symbolic link is configured correctly."
  else
    recreate_symlink
  fi
}

assert_git_repo

echo "Checking Git hooks..."

if [[ -L .git/hooks ]]; then
  echo "Git hooks symbolic link is already configured correctly."
  verify_symlink
else
  echo "Git hooks symbolic link is not configured correctly."
  if [[ -e .git/hooks ]]; then
    remove_git_hooks
  fi

  create_symlink
fi

echo "Git hooks symbolic link setup is complete."
