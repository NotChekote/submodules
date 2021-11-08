#!/usr/bin/env bash

set -euo pipefail

# just confirm our required variables are present
: "${CIRCLE_TOKEN:?"Required Env Variable not found!"}"
: "${CIRCLE_BUILD_NUM:?"Required Env Variable not found!"}"
: "${CIRCLE_PROJECT_USERNAME:?"Required Env Variable not found!"}"
: "${CIRCLE_PROJECT_REPONAME:?"Required Env Variable not found!"}"
: "${CIRCLE_REPOSITORY_URL:?"Required Env Variable not found!"}"

if [ -z "${1:-}" ]; then
    echo "Must provide Max Queue Time in *minutes* as script argument"
    exit 1
fi
max_time=$1

if [ -z "${2:-}" ]; then
    echo "Must provide a job name as script argument"
    exit 1
fi
queue_job_name=$2

echo "This build for job $queue_job_name will be blocked until all previous builds complete."
echo "Max Queue Time: $max_time minutes."

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
source "$root/submodules/lib/circle.sh"
wait_time=0
loop_time=30
max_time_seconds=$((max_time * 60))
while true; do

    circleci.build.oldest "$queue_job_name"
    if [ "$CIRCLE_BUILD_NUM" -le "$OLDEST_RUNNING_BUILD_NUM" ]; then
        echo "Front of the line, WooHoo!, Build continuing"
        break
    else
        echo "This build ($CIRCLE_BUILD_NUM) is queued, waiting for build number ($OLDEST_RUNNING_BUILD_NUM) to complete."
        echo "Total Queue time: $wait_time seconds."
    fi

    if [ "$wait_time" -ge "$max_time_seconds" ]; then
        echo "Max wait time exceeded, cancelling this build."
        circleci.build.cancel
        sleep 60 #wait for APi to cancel this job, rather than showing as failure
        exit 1 # but just in case, fail job
    fi

    sleep "$loop_time"
    wait_time=$(( loop_time + wait_time ))
done
