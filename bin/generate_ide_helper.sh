#!/usr/bin/env bash

set -euo pipefail

if [ "$(./artisan | grep -c 'ide-helper:generate')" != '0' ]; then
  echo "> Generating IDE Helper"
  ./artisan ide-helper:generate
else
  echo "> IDE Helper not found. Skipping"
fi
