#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "get_scenarios_from_file returns proper list of scenarios" {
  run get_scenarios_from_file "$BATS_TEST_DIRNAME/fixture.feature"

  [ "$output" == "Parallel worker should work with multiple scenarios on feature file (lineFilters() should run last)" ]
}
