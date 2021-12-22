#!/usr/bin/env bash

set -euo pipefail

vcs_type="github"

#######################################
# Determines the oldest running build number
#
# Environment Variables:
#   OLDEST_RUNNING_BUILD_NUM the oldest running build number for the specified job
#
# Arguments:
#   1 the name of the job to queue for. e.g. "deploy"
#######################################
circleci.build.oldest() {
    local queue_job_name="$1"
    local jobs_api_url_template="https://circleci.com/api/v1.1/project/$vcs_type/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME?circle-token=$CIRCLE_TOKEN&filter=running&limit=100"
    local oldest

    #negative index grabs last (oldest) job in returned results.
    if [ -z "$queue_job_name" ];then
        echo "No Job variable, blocking on any running jobs for this project."
        oldest=$(curl -s "$jobs_api_url_template" | jq '.[-1].build_num')
    else
        echo "Only blocking for running jobs matching: $queue_job_name"
        oldest=$(curl -s "$jobs_api_url_template" | jq ". | map(select(.workflows.job_name==\"$queue_job_name\")) | .[-1].build_num")
    fi
    if [ -z "$oldest" ];then
        echo "API Call for existing jobs failed, failing this build.  Please check API token"
        exit 1
    elif [ "null" == "$oldest" ];then
        echo "No running builds found, this is likely a bug in queue script"
        exit 1
    fi

    export OLDEST_RUNNING_BUILD_NUM="$oldest"
}

circleci.build.cancel() {
    echo "Canceling build $CIRCLE_BUILD_NUM"
    local cancel_api_url_template="https://circleci.com/api/v1.1/project/$vcs_type/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/$CIRCLE_BUILD_NUM/cancel?circle-token=$CIRCLECI_API_KEY"
    curl -s -X POST "$cancel_api_url_template" > /dev/null
}

#######################################
# Grabs the PR Number of the current pull request in circleci
#
# More consistently available than CIRCLE_PR_NUMBER env variable.
#######################################
circleci.pr.number() {
  echo "${CIRCLE_PULL_REQUEST##*/}"
}
