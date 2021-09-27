#!/usr/bin/env zsh
autoload -U colors && colors

export __ZSH_SCRIPTEST_HOME="${${(%):-%x}:a:h}"

source "$__ZSH_SCRIPTEST_HOME/test_util.sh"


function main() {
  local original_home="$HOME"
  local exit_code=0
  local tests_dir="$1"

  # Make sure we don't interact witn the local user original_home
  export HOME="$(mktemp -d)"

  for test in $(find $tests_dir -maxdepth 1 -type f -iname '*.test.sh' | awk -F/ '{print $NF}'); do
    test_script_title $test

    (eval $tests_dir/$test 2>&1)
    local test_exit_code="$?"

    if [ "$test_exit_code" != "0" ]; then
      exit_code=1
      print "\n > $fg[red]FAILED!$reset_color\n"
    else
      print "\n > $fg[green]PASSED!$reset_color\n"
    fi

    test_script_separator
  done

  export HOME="$original_home"
  
  if [ "$exit_code" != "0" ]; then
    print "$fg[red]FAILURE!$reset_color"
    exit $exit_code
  fi
}

main "$@"
