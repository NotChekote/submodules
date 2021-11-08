#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# This script halts the CircleCI job.
#
# It should be used when you want to conditionally end a job. e.g. if the job
# is performing a task that is not required because no relevant changes were
# made to the project.
#
# The script will halt the job in two possible ways:
#
# 1. Failing the job by using 'exit 1'
# 2. Halting the job by using 'circleci-agent step halt'
#
# The second method is preferred, but this will halt the job even if an SSH
# debug session is active. So it makes it impossible to investigate issues when
# halt is triggered. To work around this, we use 'ss' to check if an SSH session
# is active, and if so we use the first method so that the job will fail, but
# keep the VM up so the user can continue to debug the instance.
###############################################################################

if ss -atpn | grep -P '\*:\*.*circleci-agent' &> /dev/null; then
  echo "SSH debug session is active. Using exit to halt job"
  exit 1
else
  echo "SSH debug session is not active. Using circleci-agent to halt job"
  circleci-agent step halt
fi
