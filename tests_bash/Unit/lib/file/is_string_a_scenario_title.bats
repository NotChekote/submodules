#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "is_string_a_scenario_title true if the string is a scenario proper title" {
  run is_string_a_scenario_title "  Scenario: Parallel worker should work with multiple scenarios on feature file (lineFilters() should run last)"

  [ "$output" == "true" ]
}

@test "is_string_a_scenario_title false if the string is not a proper scenario title" {
  run is_string_a_scenario_title "            Scenario: This is a decoy scenario"

  [ "$output" == "false" ]
}
