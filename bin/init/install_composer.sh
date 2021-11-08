#!/usr/bin/env bash

set -euo pipefail

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" && pwd )"

expected_version=2.1.9

#############################################
# Download the sha256-sum file from composer page for the expected version
#
# Globals:
#   $expected_version the expected composer version to install/validate
#   $root             root project directory
#
#############################################
downloadComposerSHA() {
  # Download the original sha256 sum for the expected version
  curl -L https://getcomposer.org/download/${expected_version}/composer.phar.sha256sum > "$root/bin/composer.sha256sum"
}

#############################################
# Delete the downloaded sha256-sum file
#
# Globals:
#   $root root project directory
#############################################
clearComposerSHA() {
  rm "$root/bin/composer.sha256sum" &> /dev/null || TRUE
}

#############################################
# Validate the sha256sum against the existing composer file
#
# Globals:
#   $root root project directory
#
# Returns:
#   1 when the validation pass
#   0 when the sha validation fail
#
#############################################
isValidComposerSHA() {
  local parsed_sha256_sum
  local sha256_sum
  local validation_result

  sha256_sum=$(cat "$root/bin/composer.sha256sum")
  # The file includes sha256 string and file name with phar extension
  # The next method replaces the .phar from the string
  parsed_sha256_sum="${sha256_sum/ composer.phar/}"
  validation_result=$(echo "$parsed_sha256_sum $root/bin/composer" | shasum -c -a 256) || TRUE
  if [ "$validation_result" == "$root/bin/composer: OK" ]; then
    return
  fi

  false
}

#############################################
# Check if the project already have a composer installed and
# if exists validates the file sha256sum match the expected version
#
# Globals:
#   $expected_version the expected composer version to install/validate
#   $root             root project directory
#
#############################################
checkExistingInstallation() {
  if [ -e "$root/bin/composer" ]; then
    local found_version

    echo "Checking Composer version..."
    found_version=$( \
        cd "$root" && \
        "$root/bin/composer" --version | \
        tail -1 | \
        awk '{print $3}' \
    )

    if isValidComposerSHA; then
        # Version is as expected. We're done.
        echo "Composer ${expected_version} already installed."
        clearComposerSHA
        exit 0
    else
        # Version does not match. Remove it.
        echo "Removing Composer version ${found_version}..."
        rm "$root/bin/composer"
    fi
  fi
}

#############################################
# Download the desired composer binary
#
# Globals:
#   $expected_version the expected composer version to install/validate
#   $root             root project directory
#
#############################################
downloadComposerBinary() {
  # Install composer
  echo "Installing Composer ${expected_version}..."
  curl -L https://getcomposer.org/download/${expected_version}/composer.phar > "$root/bin/composer"
}

#############################################
# Validate the sha256sum of the downloaded file
#
# Globals:
#   $root root project directory
#
#############################################
validateDownloadedComposer() {
  echo -n "Checking the SHA for the downloaded file..."
  if isValidComposerSHA; then
      clearComposerSHA
      echo "passed"
  else
      echo "ERROR: composer's sha256sum doesn't match. Download it again."
      rm "$root/bin/composer"
      clearComposerSHA
      exit 1
  fi
}

#############################################
# Fix execution permissions
#
# Globals:
#   $root root project directory
#
#############################################
fixComposerPermissions() {
  echo "Setting composer permissions..."
  chmod 755 "$root/bin/composer"
}

#############################################
# Ensure ~/.composer exists for the Docker container to mount
#############################################
initializeComposerDir() {
  echo "Initializing ~/.composer directory..."
  if [ ! -d ~/.composer ]; then
      mkdir ~/.composer
  fi
}

# Download sha256sum for the expected version
downloadComposerSHA
# Check for existing installation
checkExistingInstallation
# Download composer
downloadComposerBinary
# Validate downloaded file sha256sum match with the expected version sha256sum
validateDownloadedComposer
# Fix permissions
fixComposerPermissions
# Initialize .composer directory
initializeComposerDir

echo "Composer v${expected_version} installation complete."
