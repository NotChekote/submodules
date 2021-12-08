#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "string.ltrim trims leading spaces" {
  bats.pipe string.ltrim "  test string to trim"

  [ "$output" == "test string to trim" ]
}

@test "string.ltrim does not trim trailing spaces" {
  bats.pipe string.ltrim "test string to trim   "

  [ "$output" == "test string to trim   " ]
}

@test "string.ltrim trims only from left side when both sides have spaces" {
  bats.pipe string.ltrim "     test string to trim  "

  [ "$output" == "test string to trim  " ]
}

@test "string.ltrim trims all leading whitespace characters (tabs, spaces)" {
  bats.pipe string.ltrim "      test string to trim"

  [ "$output" == "test string to trim" ]
}
