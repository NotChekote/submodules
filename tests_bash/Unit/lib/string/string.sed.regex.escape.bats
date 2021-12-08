#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "string.sed.regex.escape should escape special chars" {
  bats.pipe string.sed.regex.escape "@ $ ^ * \ ( { [ / + & ) | ? #"

  [ "$output" == '\@ \$ \^ \* \\ \( \{ \[ \/ \+ \& \) \| \? \#' ]
}

@test "string.sed.regex.escape should not escape good chars" {
  bats.pipe string.sed.regex.escape '` _ - ! ~ % = : ; " < > , .'

  [ "$output" == '` _ - ! ~ % = : ; " < > , .' ]
}

@test "string.sed.regex.escape should not escape alphanumeric chars" {
  bats.pipe string.sed.regex.escape 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTVUWXYZ0123456789'

  [ "$output" == 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTVUWXYZ0123456789' ]
}
