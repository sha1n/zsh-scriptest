#!/usr/bin/env zsh

function test_script_title() {
  printf "\n $fg_bold[cyan]> TEST:$reset_color %s...\n" "$1"
}

function test_script_separator() {
  printf "%-80s\n" | tr ' ' '-'
}

function test_setup_title() {
  printf " $fg_bold[cyan]> SETUP:$reset_color %s...\n" "$funcstack[2]"
}

function test_teardown_title() {
  printf " $fg_bold[cyan]> TEARDOWN:$reset_color %s...\n" "$funcstack[2]"
}

function test_case_title() {
  printf " $fg_bold[cyan]> CASE:$reset_color %s...\n" "$funcstack[2]"
}

__SCRIPTEST_FAIL=0

function run_test() {
  local func_name="$1"
  local output
  output="$("$func_name" 2>&1)"
  if [[ "$?" == "0" ]]; then
    print "ok - $func_name"
  else
    (( __SCRIPTEST_FAIL++ ))
    print "not ok - $func_name"
    print "$output" | while IFS= read -r line; do
      [[ -n "$line" ]] && print "#   $line"
    done
  fi
}

function finish_tests() {
  [[ "${__SCRIPTEST_FAIL:-0}" -eq 0 ]] || exit 1
}