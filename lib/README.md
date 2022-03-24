# Library scripts

This directory contains a collection of libraries for various tools, services etc.

## What is a library?

A library is a non-executable shell script that contains one or more functions.

The script should be sourced by an active session, which will then allow the functions to be invoked.

## Dos and Don'ts:

Do NOT make library scripts executable. They should be sourced, NOT executed.
Do NOT put shebangs in library scripts. Shebangs are only necessary for executable files.
Do NOT set options in library scripts (e.g. set -euo pipefail). These should be set once per session by the host script.

DO use the correct file extension for the script. e.g. *.bash for Bash scripts.
DO use one library per tool, service, etc.
DO use dot-syntax for function names.
