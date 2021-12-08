#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "array.join can concentrate array values with a single char, multiple char and an empty string delimiter" {
  # Given I have an array to join values
  ARRAY=("Apple" "Orange" "Pear" "Mango")

  # And I have a set of delimiters
  local delims=("," " %^&  $" "")
  for i in "${!delims[@]}"; do
    # When I run the join the array with delimiter
    run array.join "${delims[$i]}" ARRAY

    # Then the strings should be glued with the given delimiter
    [ "$output" == "Apple${delims[$i]}Orange${delims[$i]}Pear${delims[$i]}Mango" ]
  done
}

@test "array.join should output an empty string if the given array is empty" {
  # Given I have an empty array to join values
  ARRAY=()

  # When I run the array.join
  run array.join "," ARRAY

  # Then I should get an empty string
  [ "$output" == "" ]
}
