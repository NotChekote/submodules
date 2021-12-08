#!/usr/bin/env bash

set -euo pipefail

load lib/bats.bash
bats.source.autoload

@test "string.grep.regex.escape should escape special chars" {
  bats.pipe string.grep.regex.escape '@ $ ^ * \ ( { [ / + ? |'

  [ "$output" == '\@ \$ \^ \* \\ \( \{ \[ \/ \+ \? \|' ]
}

@test "string.grep.regex.escape should not escape good chars" {
  bats.pipe string.grep.regex.escape '& ) ` # _ - ! ~ % & = : ; " < > , .'

  [ "$output" == '& ) ` # _ - ! ~ % & = : ; " < > , .' ]
}

@test "string.grep.regex.escape should not escape alphanumeric chars" {
  bats.pipe string.grep.regex.escape 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTVUWXYZ0123456789'

  [ "$output" == 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTVUWXYZ0123456789' ]
}
