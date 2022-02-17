#!/usr/bin/env bash

set -euo pipefail

. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../lib/git.bash"
git.paths.get

. "$SUBMODULES/lib/mergefreeze.bash"

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
# Starts the Docker containers and feeds the logs to artifacts/containers.log
#
# Arguments:
#   * zero or more services to start. If none are specified, all services will start.
#######################################
circleci.containers.start() {
    echo "Start containers"
    containers up -d "$@"

    echo "Capture Container Logs"
    containers logs -f > artifacts/containers.log &

    echo "Wait for containers"
    submodules/bin/init/wait_for_services.sh "$@"
}

#######################################
# Configures git for CircleCI use.
#######################################
circleci.git.configure() {
  git.configure "circleci@analytehealth.com" "CircleCI"
}

###############################################################################
# Halts the CircleCI job.
#
# It should be used when you want to conditionally end a job. e.g. if the job
# is performing a task that is not required because no relevant changes were
# made to the project.
#
# The function will halt the job in two possible ways:
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
circleci.job.halt() {
    if ss -atpn | grep -P '\*:\*.*circleci-agent' &> /dev/null; then
      echo "SSH debug session is active. Using exit to halt job"
      exit 1
    else
      echo "SSH debug session is not active. Using circleci-agent to halt job"
      circleci-agent step halt
    fi
}

#######################################
# Waits until the specified job is at the front of the queue
#
# Being at the front of the queue means that no other instances of this same job
# are currently running or waiting to run ahead of this job in other builds.
#
# Environment Variables:
#   CIRCLE_TOKEN            The auth token for the CircleCI API
#   CIRCLE_BUILD_NUM        The number of the current job. Job numbers are unique for each job.
#   CIRCLE_PROJECT_USERNAME The GitHub or Bitbucket username of the current project.
#   CIRCLE_PROJECT_REPONAME The name of the repository of the current project.
#   CIRCLE_REPOSITORY_URL   The URL of your GitHub or Bitbucket repository.
#
# Arguments:
#   1 The maximum queue time in minutes.
#   2 The name of the job that is queueing.
#######################################
circleci.job.queue() {
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
    local max_time="$1"

    if [ -z "${2:-}" ]; then
        echo "Must provide a job name as script argument"
        exit 1
    fi
    local queue_job_name="$2"

    echo "This build for job $queue_job_name will be blocked until all previous builds complete."
    echo "Max Queue Time: $max_time minutes."

    local wait_time=0
    local loop_time=30
    local max_time_seconds=$((max_time * 60))
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
            sleep 60 # wait for API to cancel this build, rather than showing as failure
            exit 1 # but just in case, fail job
        fi

        sleep "$loop_time"
        wait_time=$(( loop_time + wait_time ))
    done
}

#######################################
# Triggers a merge freeze if the current branch is master and has the "no promote" tag.
#######################################
circleci.mergefreeze.freezeIfNoPromoteMaster () {
    if  [ "$(cat is-no-promote)" = true ] && [[ "$CIRCLE_BRANCH" = "master" ]]; then
        mergefreeze.freeze
    fi
}

#######################################
# Removes a merge freeze if the current branch is master
#######################################
circleci.mergefreeze.unfreezeIfMaster () {
    if [[ "$CIRCLE_BRANCH" = "master" ]]; then
      mergefreeze.unfreeze
    fi
}

#######################################
# Grabs the PR Number of the current pull request in circleci
#
# More consistently available than CIRCLE_PR_NUMBER env variable.
#######################################
circleci.pr.number() {
  echo "${CIRCLE_PULL_REQUEST##*/}"
}
