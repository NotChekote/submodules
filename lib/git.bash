#######################################
# Library of functions for working with the Git version control system.
#
# https://git-scm.com/
#######################################

#######################################
# Configures git with our default setup
#
# This will set the user email, name and ensure Git uses SSH over HTTPS
#
# Arguments:
#   1 The email of the git user
#   2 The name of the git user
#######################################
git.configure () {
  local email="$1"
  local name="$2"

  echo "Configure Git user"
  git config --global user.email "$email"
  git config --global user.name "$name"

  echo "Configure Git to use SSH instead of HTTP"
  git config --global url.git@github.com:.insteadOf git://github.com/
}

#######################################
# Determines ROOT and submodules paths
#
# This method will take into account if the current project is a git submodule, or a git root project.
# $ROOT will always resolve to the root project, whereas $SUBMODULES will either point to the submodules
# dir of the root project, or the submodules project itself if it is root.
#
# Invoked from Submodules as the root project
# Invoked from Submodules as a Git submodule
# Invoked from host project with Submodules as a Git submodule
#
# Exports:
#   ROOT       the path to the root project
#   SUBMODULES the path to the submodules project or git submodule
#######################################
git.paths.get () {
    local local_root
    local_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

    if git.repo.isRootSubmodules; then
      ROOT="$local_root"; SUBMODULES="$local_root"
    elif git.repo.isSubmodule; then
      ROOT="$(git.repo.super)"; SUBMODULES="$local_root"
    elif git.submodule.contains "submodules"; then
      ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd )"; SUBMODULES="$ROOT/submodules"
    fi

    export ROOT
    export SUBMODULES
}

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

#######################################
# Determines if the Git repo of the current working directory is a root installation of Medology/Submodules
#
# The method makes an assumption, in that if this the current working dir is not a submodule, and also does
# not have Medology/Submodules installed as a Git submodule, then it itself is Medology/Submodules.
#
# I could not determine a way to reliably determine if this is the Submodules project, as things like remotes
# can change from install to install, and inspecting the project itself could easily break if the expected
# result changes for some unrelated reason.
#######################################
git.repo.isRootSubmodules () {
  # We are not root if we are a submodule
  if git.repo.isSubmodule; then
    return 1
  fi

  # Submodules isn't nested, so we are not Submodules if we have Submodules as a Git submodule
  if git.submodule.contains "submodules"; then
    return 1
  fi

  # We assume we are Submodules if we are a root project and do not have Submodules as a Git submodule
  return 0
}

#######################################
# Determines if the Git repo of the current working directory is a Git submodule.
#######################################
git.repo.isSubmodule() {
  # We are a submodule if we have a super project
  if [ "$(git.repo.super)" == "" ]; then
    return 1
  fi

  return 0
}

#######################################
# Returns the super-project of the Git repo of the current working directory (if any)
#######################################
git.repo.super() {
  git rev-parse --show-superproject-working-tree
}

#######################################
# Determines if the Git repo of the current working directory has the specified submodule
#
# Arguments:
#   1 the name of the submodule to check for
# ######################################
git.submodule.contains() {
  git submodule | awk '{print $2}' | grep "$1" &> /dev/null
  return $?
}

#######################################
# Gets a list of line numbers updated
# in the given file
#
# Arguments:
#   1 the file to search within
#######################################
git.worktree.lines.changed() {
  file=$1
  git diff origin/master...HEAD --unified=0 "$file" | grep '@@ -' | sed 's/.*+\([0-9]*\).*/\1/'
}
