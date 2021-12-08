#######################################
# Simple mock builder for functions
#  Mocked function prints out the function name and the passed arguments, input or the custom given value
#
# Arguments:
#   1 function name that needs to be mocked
#   2 If set the mocked function will always echo the given value [Optional]
#######################################
bats.mock() {
  local func=${1:-}

  bats.assert.isFunction "$func"

  if [ $# -gt 1 ] ; then
    local custom_output=${2:-}
    eval "${func}() { echo \"$custom_output\"; }"
  else
    eval "${func}() { bats.mock.arguments \"\$@\"; bats.mock.stdout; }"
  fi
}

######################################
# Bats framework run() function not supporting pipe commands. This is a workaround to support that
#
# Arguments:
#   1 the name of the function being tested
#   2 the string to pipe into the function via echo
#   @:3 parameter 3 onwards will be passed to the function as parameter 1 onwards
#######################################
bats.pipe() {
  function __piped() {
    echo "$2" | $1 "${@:3}"
  }
  run __piped "$@"
}

#######################################
# Based on the folder structure of the bats file path, detects the source file of the method that being tested.
# And loads the source file.
#######################################
bats.source.autoload() {
  local filename="$(echo "$BATS_TEST_DIRNAME" | sed 's#/tests_bash/Unit##' | sed 's#/tests_bash/Integration##').bash"

  if [[ ! -f "$filename" ]]; then
    echo "bats: $filename does not exist. Make sure directory structure is correct." >&2
    exit 1
  fi

  source "$filename"
}

#######################################
# Asserts the given string is a valid function name
#
# Arguments:
#   1 a string needs to be validated as function name
#######################################
bats.assert.isFunction() {
  local func=$1

  if [ "$func" == "" ] || [ "$(echo "$func" | sed -e 's/[^[:alnum:]_\.]//g')" != "$func" ]; then
    echo "'$func' is not a valid function name" >&2
    exit 1
  fi
}

#######################################
# Internal function used to output the result for Mocking.
#  1) Format: function_name(<arguments list>).
#  2) Custom output value
#
# Globals
#  ARGS - Global arguments list. Defined by custom
#  FUNCNAME - Global variable for the list of the called function names
#
# Arguments:
#   1 mock function returns this value if specified [Optional]
#######################################
bats.mock.stdout() {
  # Return value defined or not
  if [ $# -eq 0 ]; then
    # Mocked function (function name that calls this function)
    local func="${FUNCNAME[1]}"
    # Output contains of func_name and space separated arguments list
    local arguments_as_string="'$(array.join "', '" ARGS)'"
    local output="$func($arguments_as_string)"
  else
    local output="$1"
  fi

  # Check if the function executed inside subshell and if so redirect the output to STDERR, so we can track the down
  # the functions call order inside bats tests
  if [ $BASH_SUBSHELL -gt 1 ]; then # Since this function used in eval, the starting value is 1
    echo "$output" >&2
  fi
  # Output to the STDOUT
  echo "$output"
}

#######################################
# Fetch all the arguments list passed by the STDIN and as parameters and assign to global var.
#
# Globals
#  ARGS - Global arguments list. Defined in this function
#######################################
bats.mock.arguments() {
  unset ARGS;
  # If the function arguments passed by directly or by pipe
  if [ -t 0 ]; then
    [ $# -eq 0 ] && ARGS=() || ARGS=("$@")
  else
    read arg;
    # If the are additional parameters to the pipe function add them to argument list
    [ $# -eq 0 ] && ARGS="${arg:-}" || ARGS=("${arg:-}" "$@")
  fi
}
