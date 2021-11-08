#!/usr/bin/env bash

set -euo pipefail

service_key="$GCLOUD_SERVICE_KEY"
service_email="$GCLOUD_SERVICE_EMAIL"
project_id="$GCLOUD_PROJECT"
configuration_name="$GCLOUD_CONFIGURATION_NAME"

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -k|--key) service_key="$2" ;;
            --email) service_email="$2" ;;
            --project) project_id="$2" ;;
            --config-name) configuration_name="$2" ;;
            *) break ;;
        esac
        shift 2
    done
}

parse_args "$@"

echo "Change owner and group for gcloud config dir..."
sudo chown -R circleci:circleci "$HOME/.config/gcloud"

echo "Decode credentials..."
echo "$service_key" | base64 --decode -i > "./cloud-credentials.json"

echo "Authorize service account..."
gcloud auth activate-service-account --key-file "./cloud-credentials.json"

echo "Activate configurations..."
gcloud config configurations create "$configuration_name" --activate

echo "Configure account email..."
gcloud config set account "$service_email"

echo "configure compute zone..."
gcloud config set compute/zone us-central1-b

echo "Configure core/project..."
gcloud config set core/project "$project_id"

echo "Suppress prompts"
gcloud config set disable_prompts True

echo "Docker login..."
docker login -u _json_key --password-stdin https://us.gcr.io < "./cloud-credentials.json"
