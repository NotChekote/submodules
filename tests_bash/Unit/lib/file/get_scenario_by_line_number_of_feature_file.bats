#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "get_scenario_by_line_number_of_feature_file wont stop at empty lines" {
  run get_scenario_by_line_number_of_feature_file 47  "$BATS_TEST_DIRNAME/fixture.feature"

  [ "$output" == "Parallel worker should work with multiple scenarios on feature file (lineFilters() should run last)" ]
}

@test "get_scenario_by_line_number_of_feature_file wont stop at PyNode scenarios" {
  run get_scenario_by_line_number_of_feature_file 47  "$BATS_TEST_DIRNAME/fixture.feature"

  [ "$output" == "Parallel worker should work with multiple scenarios on feature file (lineFilters() should run last)" ]
}

@test "get_scenario_by_line_number_of_feature_file returns file if background is provided" {
  run get_scenario_by_line_number_of_feature_file 8  "$BATS_TEST_DIRNAME/fixture.feature"

  [ "$output" == "$BATS_TEST_DIRNAME/fixture.feature" ]
}

@test "get_scenario_by_line_number_of_feature_file returns nothing if it reaches the first line" {
  run get_scenario_by_line_number_of_feature_file 0 "$BATS_TEST_DIRNAME/fixture.feature"

  [ "$output" == "" ]
}
