#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "get_file_line_count returns the proper line count" {
  run get_file_line_count "$BATS_TEST_DIRNAME/fixture.feature"

  [ "$output" == 52 ]
}
