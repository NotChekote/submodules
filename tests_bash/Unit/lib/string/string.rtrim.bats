#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "string.rtrim trims trailing spaces" {
  bats.pipe string.rtrim "test string to trim  "

  [ "$output" == "test string to trim" ]
}

@test "string.rtrim does not trim leading spaces" {
  bats.pipe string.rtrim "   test string to trim"

  [ "$output" == "   test string to trim" ]
}

@test "string.rtrim trims only trailing spaces when both sides have spaces" {
  bats.pipe string.rtrim "   test string to trim     "

  [ "$output" == "   test string to trim" ]
}

@test "string.rtrim trims all leading whitespace characters (tabs, spaces)" {
  bats.pipe string.rtrim "test string to trim     "

  [ "$output" == "test string to trim" ]
}
