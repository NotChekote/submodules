#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "exit_if_file_does_not_exist exits if the file does not exist" {
  run exit_if_file_does_not_exist "$BATS_TEST_DIRNAME/missing-file.feature"

  [ "$status" -eq 1 ]
}

@test "exit_if_file_does_not_exist does not exit if the file does exist" {
  run exit_if_file_does_not_exist "$BATS_TEST_DIRNAME/fixture.feature"

  [ "$status" -eq 0 ]
  [ "$output" == "" ]
}
