#!/usr/bin/env zsh
autoload -U colors && colors

export __ZSH_SCRIPTEST_HOME="${${(%):-%x}:a:h}"

source "$__ZSH_SCRIPTEST_HOME/test_util.sh"


function main() {
  local original_home="$HOME"
  local exit_code=0
  local tests_dir="$1"
  local total=0
  local passed=0
  local failed=0

  # Make sure we don't interact witn the local user original_home
  export HOME="$(mktemp -d)"

  for test in $(find $tests_dir -maxdepth 1 -type f -iname '*.test.sh' | awk -F/ '{print $NF}'); do
    total=$((total + 1))
    test_script_title $test

    (eval $tests_dir/$test 2>&1)
    local test_exit_code="$?"

    if [ "$test_exit_code" != "0" ]; then
      exit_code=1
      failed=$((failed + 1))
      print "\n > $fg[red]FAILED!$reset_color\n"
    else
      passed=$((passed + 1))
      print "\n > $fg[green]PASSED!$reset_color\n"
    fi

    test_script_separator
  done

  export HOME="$original_home"

  print "\nTests: $total | Passed: $fg[green]$passed$reset_color | Failed: $fg[red]$failed$reset_color"

  if [ "$exit_code" != "0" ]; then
    print "\n$fg[red]FAILURE!$reset_color"
    exit $exit_code
  fi
}

main "$@"
