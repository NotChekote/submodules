#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "string.hash should hash the given string to a default length of 10 characters" {
  # When I run the string.hash without a length parameter
  run string.hash 'Some string & | ` ? $ # @ ^ * \)(+{[/🤩🤠'

  # Then the output string length should be 10 by default
  [ ${#output} -eq 10 ]

  # And the string should be like
  [ "$output" == "cdbcbd895b" ]
}

@test "string.hash should hash the given string to the specified length" {
  # Given there is a string needs to be hash
  local text="Some string abc"
  # And I need to hash this string by different lengths
  local lengths=(16 12 1 7 56 43)

  for i in "${!lengths[@]}"; do
    # When I run string.hash for each length
    run string.hash "$text" "${lengths[$i]}"

    # Then the length of the string must be correct
    [ ${#output} -eq ${lengths[$i]} ]
  done
}

@test "string.hash should change lengths outside of 1-64 range to be within range" {
  # Given there is a string needs to be hash
  local text="Some string abc"

  # When I run string.hash and 0 as length
  run string.hash "$text" 0

  # Then the length of the string should be 1
  [ ${#output} -eq 1 ]

  # When I run string.hash with length of more than 64
  run string.hash "$text" 65

  # Then the length of the string should be 64
  [ ${#output} -eq 64 ]
}
