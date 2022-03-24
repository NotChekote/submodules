#######################################
# Library of functions for working with Bash strings.
#######################################

#######################################
# Trims leading spaces from a provided string.
#######################################
string.ltrim() {
  sed -e 's/^[[:space:]]*//'
}

#######################################
# Trims trailing spaces from a provided string.
#######################################
string.rtrim() {
  sed -e 's/[[:space:]]*$//'
}

#######################################
# Trims spaces from both sides of a provided string.
#######################################
string.trim() {
  string.ltrim | string.rtrim
}

#######################################
# Escape special chars for grep regex pattern.
#######################################
string.grep.regex.escape() {
  sed -E 's/([@?$|^*(+{\[\\/])/\\\1/g'
}

#######################################
# Escape special chars for sed regex pattern.
#######################################
string.sed.regex.escape() {
  sed -E 's/([&|`?$#@^*\\)\\(+{\[/])/\\\1/g' | sed -E 's/\\{1,}(\$|\()/\\\1/g' | sed -E 's/\\{1,}`/`/g'
}

######################################
# Creates a hash based on the given string value
#
# Arguments:
#   1 the string value
#   2 length of the output hash [Optional] [Default=10, Min=1, Max=64]
#######################################
string.hash() {
  local value
  value=$(echo -n "$1" | sha256sum)
  local length=${2:-10}

  [[ $length -lt 1 ]] && length=1;
  [[ $length -gt 64 ]] && length=64;

  echo -n "${value:0:$length}"
}
