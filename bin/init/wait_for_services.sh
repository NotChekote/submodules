#!/usr/bin/env bash

##
# Waits for specific services (Docker containers) on the project's network to be ready.
#
# Usage: wait_for_services.sh [services]
#
# services can be any number of keys from the SERVICE_HOST_MAP/SERVICE_PORT_MAP arrays below. If no services are
#          specified, then the script will wait for all services.
##

set -euo pipefail

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" && pwd )"

. "$root/docker/lib/services.sh"

count=0
timeout=30

# Associative array mapping service names to statuses
declare -A service_status

. "$root/bin/lib/env.sh"
. get_colors
. get_tty

# List of services passed in by the user, or default to all services
declare -a services
# We actually want word splitting to occur here.
# shellcheck disable=SC2206
services=( ${@:-${!SERVICE_PORT_MAP[@]}} )

# Initializes the service_status array based on the services array
initServicesStatus() {
  for service in "${services[@]}"; do
    service_status[$service]=1
  done
}

# Checks the status of the app, db and web services
checkServices() {
  # Disabled exit-on-error because we're using nc's failure to detect if services are up yet
  set +e

  for service in "${services[@]}"; do
    nc -z "${SERVICE_HOST_MAP[$service]}" "${SERVICE_PORT_MAP[$service]}" &> /dev/null
    service_status[$service]=$?
  done

  set -e
}

# Prints the status of service named $1 based on the status code of $2
printServiceStatus() {
  local name="$1"
  local status="$2"

  if [ "$status" = 0 ]; then
    echo -ne "$GREEN$name$NC "
  else
    echo -ne "$RED$name$NC "
  fi
}

# Prints the status of the app, db and web services
printServicesStatus() {
    echo -ne "\r"

    for service in "${services[@]}"; do
      printServiceStatus "$service" ${service_status[$service]}
    done

    # If we're not in the first loop, print the next dot for the progress indicator
    if [ "$count" -ne "0" ]; then
        for ((i=1; i<=count; i++)); do
          echo -n '.'
        done
    fi
}

# Exits the script with a success code if all services are up
exitIfAllServicesAreUp() {
    for service in "${services[@]}"; do
      # return if any services is not yet started
      if [ ${service_status[$service]} != 0 ]; then
        return;
      fi
    done

    echo -e "\n${GREEN}Services are now available.$NC"
    exit 0
}

initServicesStatus

echo "Waiting for Services:"
printServicesStatus

checkServices
printServicesStatus

while true; do
  exitIfAllServicesAreUp

  sleep 1
  count=$((count + 1))

  checkServices
  printServicesStatus

  if [ "$count" -gt "$timeout" ]; then
    echo -e "\n${RED}Timeout expired while waiting for services to start.$NC"
    exit 1
  fi
done
