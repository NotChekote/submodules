#!/bin/bash

set -euo pipefail

#######################################
# Makes curl http request and returns the response
#
# Arguments:
#   1 The HTTP request method. i.e., GET or POST
#   2 The URL
#   3 The data to be sent as part of request (optional)
#######################################
http.request() {
  local method="$1"
  local url="$2"
  local data="${3:-""}"

  curl --silent --write-out "HTTPSTATUS:%{http_code}" --location -d "$data" --request "$method" "$url"
}

#######################################
# Retrieves and returns http status code from http response
#
# Arguments:
#   1 http response
#######################################
http.request.status() {
  local http_response="$1"
  echo "${http_response/*HTTPSTATUS:/}"
}

#######################################
# Retrieves and returns http body from http response
#
# Arguments:
#   1 http response
#######################################
http.request.body() {
  local http_response="$1"
  echo "${http_response/HTTPSTATUS:*/}"
}
