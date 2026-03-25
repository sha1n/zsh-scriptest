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
  local all_lines=()

  for test in "${test_files[@]}"; do
    output="$($tests_dir/$test 2>&1)"
    test_exit_code="$?"

    if [[ "$test_exit_code" != "0" ]]; then
      exit_code=1
    fi

    # Re-number ok/not ok lines from test file output
    while IFS= read -r line; do
      if [[ "$line" == "ok - "* ]]; then
        (( test_num++ ))
        (( passed++ ))
        all_lines+=("ok $test_num - ${line#ok - }")
      elif [[ "$line" == "not ok - "* ]]; then
        (( test_num++ ))
        (( failed++ ))
        all_lines+=("not ok $test_num - ${line#not ok - }")
      elif [[ "$line" == "#"* ]]; then
        all_lines+=("$line")
      fi
    done <<< "$output"
  done

  export HOME="$original_home"

  # Emit TAP stream: plan line first, then results
  print "1..$test_num"
  for line in "${all_lines[@]}"; do
    print "$line"
  done

  if [[ "$exit_code" != "0" ]]; then
    exit $exit_code
  fi
}

main "$@"
