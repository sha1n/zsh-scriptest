#!/usr/bin/env zsh

source "$__ZSH_SCRIPTEST_HOME/matchers.sh"
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"


function test_test_script_title() {
  test_case_title
  local output="$(test_script_title "my_test.sh")"
  assert_contains "$output" "TEST:"
  assert_contains "$output" "my_test.sh"
}

function test_test_script_separator() {
  test_case_title
  local output="$(test_script_separator)"
  local length="${#output}"
  assert_equal "$length" "80"
  # Verify it's all dashes
  local dashes="$(printf '%.0s-' {1..80})"
  assert_equal "$output" "$dashes"
}

function test_test_case_title_output() {
  # test_case_title uses funcstack[-1] which returns the outermost calling function
  local output="$(test_case_title)"
  assert_contains "$output" "CASE:"
  assert_contains "$output" "test_test_case_title_output"
}

function test_test_setup_title_output() {
  test_case_title
  # test_setup_title uses funcstack[-1] for the outermost caller
  local output="$(test_setup_title)"
  assert_contains "$output" "SETUP:"
  assert_contains "$output" "test_test_setup_title_output"
}

function test_test_teardown_title_output() {
  test_case_title
  # test_teardown_title uses funcstack[-1] for the outermost caller
  local output="$(test_teardown_title)"
  assert_contains "$output" "TEARDOWN:"
  assert_contains "$output" "test_test_teardown_title_output"
}


# Run all tests
test_test_script_title
test_test_script_separator
test_test_case_title_output
test_test_setup_title_output
test_test_teardown_title_output
