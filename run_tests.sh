#!/usr/bin/env zsh
autoload -U colors && colors

export __ZSH_SCRIPTEST_HOME="${${(%):-%x}:a:h}"

source "$__ZSH_SCRIPTEST_HOME/test_util.sh"


function main() {
  local original_home="$HOME"
  local exit_code=0
  local tests_dir="$1"
  local test_num=0
  local passed=0
  local failed=0

  # Make sure we don't interact witn the local user original_home
  export HOME="$(mktemp -d)"

  local test_files=($(find $tests_dir -maxdepth 1 -type f -iname '*.test.sh' | awk -F/ '{print $NF}'))
  local output
  local test_exit_code

  print "TAP version 13"
  print "1..${#test_files[@]}"

  for test in "${test_files[@]}"; do
    test_num=$((test_num + 1))

    output="$($tests_dir/$test 2>&1)"
    test_exit_code="$?"

    if [ "$test_exit_code" != "0" ]; then
      exit_code=1
      failed=$((failed + 1))
      print "not ok $test_num - $test"
      # Print test output as TAP diagnostic lines
      print "$output" | while IFS= read -r line; do
        print "# $line"
      done
    else
      passed=$((passed + 1))
      print "ok $test_num - $test"
    fi
  done

  export HOME="$original_home"

  print "# Tests: $test_num | Passed: $passed | Failed: $failed"

  if [ "$exit_code" != "0" ]; then
    exit $exit_code
  fi
}

main "$@"
