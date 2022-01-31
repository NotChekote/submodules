#!/usr/bin/env bash

set -euo pipefail

######################################################
# Delete old versions of service on Google App Engine.
#
# Arguments:
#   1 the name of the service on GAE
#   2 the maximum number of versions to keep on GAE
######################################################
delete_old_versions() {
  local service=$1
  local max_service_versions=$2
  local ids=()
  local limit=0

  echo ""
  echo "Checking number of versions for $service service"
  readarray -t ids < <(gcloud app versions list \
    --service="$service" \
    --filter="version.servingStatus=stopped" \
    --format="table[no-heading](version.id)")

  if [ "${#ids[@]}" -le "$max_service_versions" ]; then
    echo "No old versions to delete"
    return 0;
  fi

  limit=$((${#ids[@]} - max_service_versions))

  echo "Deleting $limit old versions"
  for version in "${ids[@]::limit}"
  do
    gcloud app versions delete --service="$service" "$(echo "$version" | tr -d '\r')"
  done
}

######################################################
# Stop previous versions of service on Google App Engine.
#
# Arguments:
#   1 the name of the service on GAE
######################################################
stop_previous_versions() {
    local ids

    echo -e "\nStopping all previous serving versions of $1"
    # Fetch all previous serving versions sorted by creation time in desc. order.
    # Remove headings and start from second line.
    ids=$(gcloud app versions list --service "$1" \
        --filter="version.servingStatus=serving" \
        --sort-by="~version.createTime" \
        --format="table[no-heading](version.id)" | tail -n +2)
    for version in $ids
    do
        echo -e "\nStopping version"
        version="$(echo "$version" | tr -d '\r')"
        gcloud -q --verbosity=debug app versions stop --service "$1" "${version}"
    done
}

######################################################
# Promotes the current version of service on Google App Engine.
#
# Arguments:
#   1 the name of the service on GAE
#   2 the version of the service to promote
######################################################
promote_version(){
    echo ""
    echo "Split Routing 100% of traffic to version $2 of service $1"
    gcloud app services set-traffic "$1" --splits "$2"=100
    stop_previous_versions "$1"
}

######################################################
# Deploys a new version of a service into Google App Engine
#
# Arguments:
#   1 the name of the service on GAE
#   2 the name of the service file
#   3 the url of the image file
#   4 the version of the service to promote
######################################################
deploy_appengine_service(){
    echo ""
    echo "Deploying application $1 to Google App Engine"
    gcloud app deploy --verbosity=debug "$2" --image-url="$3" --version="$4"
}
