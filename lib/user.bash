#######################################
# Library of functions for working with users.
#######################################

#######################################
# Outputs the id of the current user
#
# Output:
#   The id of the user
#######################################
user.id() {
  echo "${UID:-"$(id -u "$(whoami)")"}"
}

#######################################
# Outputs the id of the current user's primary group
#
# Output:
#   The id of the current user's primary group
#######################################
user.group.id() {
  echo "${GID:-"$(id -g "$(whoami)")"}"
}

