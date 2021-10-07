#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$BASH_SOURCE[0]")/../.." && pwd)"

echo "Change owner and group for gcloud config dir..."
sudo chown -R circleci:circleci "$HOME/.config/gcloud"

echo "Decode credentials..."
echo "$GCLOUD_SERVICE_KEY" | base64 --decode -i > "./cloud-credentials.json"

echo "Authorize service account..."
gcloud auth activate-service-account --key-file "./cloud-credentials.json"

echo "Activate configurations..."
gcloud config configurations create "$GCLOUD_CONFIGURATION_NAME" --activate

echo "Configure account email..."
gcloud config set account "$GCLOUD_SERVICE_EMAIL"

echo "Configure core/project..."
gcloud config set core/project "$GCLOUD_PROJECT"

echo "configure compute zone..."
gcloud config set compute/zone "$GCLOUD_SERVICE_ZONE"

echo "Suppress prompts"
gcloud config set disable_prompts True

echo "Docker login..."
docker login -u _json_key --password-stdin https://us.gcr.io < "./cloud-credentials.json"
