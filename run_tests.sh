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
  local test_exit_code
  local line

  # Each result line is printed as it arrives, so a slow suite shows progress; the
  # plan line comes last because TAP allows a trailing plan and the total is only
  # known then. The while loop is the last pipeline stage, which zsh runs in the
  # current shell, so the counters survive it.
  for test in "${test_files[@]}"; do
    print "# $test"

    "$tests_dir/$test" 2>&1 | while IFS= read -r line; do
      if [[ "$line" == "ok - "* ]]; then
        (( test_num++ ))
        (( passed++ ))
        print "ok $test_num - ${line#ok - }"
      elif [[ "$line" == "not ok - "* ]]; then
        (( test_num++ ))
        (( failed++ ))
        print "not ok $test_num - ${line#not ok - }"
      elif [[ "$line" == "#"* ]]; then
        print "$line"
      fi
    done
    test_exit_code="$pipestatus[1]"

    if [[ "$test_exit_code" != "0" ]]; then
      exit_code=1
    fi
  done

  export HOME="$original_home"

  print "1..$test_num"

  if [[ "$exit_code" != "0" ]]; then
    exit $exit_code
  fi
}

main "$@"
