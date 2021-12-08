#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "string.trim function trims spaces from both sides" {
  bats.pipe string.trim "  test string to trim   "

  [ "$output" == "test string to trim" ]
}

@test "string.trim function trims all white spaces like tabs, spaces" {
  bats.pipe string.trim "  test string to trim          "

  [ "$output" == "test string to trim" ]
}

@test "string.trim function has no effect on string without white spaces on sides" {
  bats.pipe string.trim "test string to trim"

  [ "$output" == "test string to trim" ]
}
