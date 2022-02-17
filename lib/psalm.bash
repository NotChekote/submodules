#!/usr/bin/env bash

set -euo pipefail

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../lib/git.bash"
git.paths.get

# Include lib functions
. "$SUBMODULES/lib/git.bash"
. "$SUBMODULES/lib/github.sh"

#######################################
# Update the Psalm baseline and pushes the changes.
#######################################
psalm.baseline.update () {
    echo "Updating the Psalm baseline..."
    psalm --set-baseline=baseline.psalm

    # Add the baseline to the index (stage it)
    git add baseline.psalm

    # Bail if the baseline did not change
    git.index.exit_if_empty "The Psalm baseline did not change. Exiting..."

    echo "Committing the new baseline..."
    git commit -m "Set new Psalm Baseline [skip ci]"

    echo "Stashing any other changes..."
    git stash

    echo "Rebasing to master..."
    git fetch origin master
    git rebase origin master

    echo "Pushing new baseline to master..."
    git push origin master

    echo "Psalm baseline update complete."
}
