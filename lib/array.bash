#######################################
# Glue the given array elements by the given delimiter.
#
# Arguments:
#   1 delimiter
#   2 The name of the array containing the values
#######################################
array.join() {
  local delimiter="$1"
  local -n array="$2"

  # Glue array elements with the given delimiter
  local result
  result=$(printf %s "${array[@]/#/$delimiter}")

  # Remove the first delimiter from start
  local d_length=${#delimiter}
  echo "${result:d_length}"
}
