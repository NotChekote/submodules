#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

# Unset the overridden functions
teardown() {
  unset git
}

@test "git.worktree.lines.changed parses git output properly" {
  # Given I have a file that has 21 line changes
  diff_fixture="diff --git a/bin/lib/utilities/file_utilities.bash b/bin/lib/utilities/file_utilities.bash
new file mode 100755
index 000000000..33a4257a6
--- /dev/null
+++ b/bin/lib/utilities/file_utilities.bash
@@ -0,0 +21,38 @@
+#!/bin/bash"
  bats.mock git "$diff_fixture"
  export -f git

  # When I run git.worktree.lines.changed
  run git.worktree.lines.changed  "$PWD/submodules/lib/git.bash"

  # Then I should get following result
  [ "$output" == "21" ]
}
