#!/usr/bin/env zsh

source "$__ZSH_SCRIPTEST_HOME/matchers.sh"
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"


# --- assert_equal ---

function test_assert_equal_success() {
  test_case_title
  (assert_equal "hello" "hello" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_equal "" "" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_equal "with spaces" "with spaces" 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_equal_failure() {
  test_case_title
  (assert_equal "hello" "world" 2>&1)
  [[ "$?" == "1" ]] || exit 1

  (assert_equal "" "not empty" 2>&1)
  [[ "$?" == "1" ]] || exit 1

  (assert_equal "a" "A" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- assert_not_equal ---

function test_assert_not_equal_success() {
  test_case_title
  (assert_not_equal "hello" "world" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_not_equal "" "something" 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_not_equal_failure() {
  test_case_title
  (assert_not_equal "same" "same" 2>&1)
  [[ "$?" == "1" ]] || exit 1

  (assert_not_equal "" "" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- assert_empty ---

function test_assert_empty_success() {
  test_case_title
  (assert_empty "" 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_empty_failure() {
  test_case_title
  (assert_empty "not empty" 2>&1)
  [[ "$?" == "1" ]] || exit 1

  (assert_empty " " 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- assert_not_empty ---

function test_assert_not_empty_success() {
  test_case_title
  (assert_not_empty "hello" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_not_empty " " 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_not_empty_failure() {
  test_case_title
  (assert_not_empty "" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- assert_file_exists ---

function test_assert_file_exists_success() {
  test_case_title
  local tmp_file="$(mktemp)"
  (assert_file_exists "$tmp_file" 2>&1)
  [[ "$?" == "0" ]] || exit 1
  rm -f "$tmp_file"
}

function test_assert_file_exists_failure() {
  test_case_title
  (assert_file_exists "$HOME/nonexistent_file_$$" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- assert_file_not_exists ---

function test_assert_file_not_exists_success() {
  test_case_title
  (assert_file_not_exists "$HOME/nonexistent_file_$$" 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_file_not_exists_failure() {
  test_case_title
  local tmp_file="$(mktemp)"
  (assert_file_not_exists "$tmp_file" 2>&1)
  [[ "$?" == "1" ]] || exit 1
  rm -f "$tmp_file"
}

# --- assert_dir_exists ---

function test_assert_dir_exists_success() {
  test_case_title
  local tmp_dir="$(mktemp -d)"
  (assert_dir_exists "$tmp_dir" 2>&1)
  [[ "$?" == "0" ]] || exit 1
  rmdir "$tmp_dir"
}

function test_assert_dir_exists_failure() {
  test_case_title
  (assert_dir_exists "$HOME/nonexistent_dir_$$" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- assert_dir_not_exists ---

function test_assert_dir_not_exists_success() {
  test_case_title
  (assert_dir_not_exists "$HOME/nonexistent_dir_$$" 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_dir_not_exists_failure() {
  test_case_title
  local tmp_dir="$(mktemp -d)"
  (assert_dir_not_exists "$tmp_dir" 2>&1)
  [[ "$?" == "1" ]] || exit 1
  rmdir "$tmp_dir"
}

# --- assert_contains ---

function test_assert_contains_success() {
  test_case_title
  (assert_contains "hello world" "hello" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_contains "hello world" "world" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_contains "hello world" "lo wo" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_contains "hello world" "hello world" 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_contains_failure() {
  test_case_title
  (assert_contains "hello world" "xyz" 2>&1)
  [[ "$?" == "1" ]] || exit 1

  (assert_contains "" "something" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- assert_not_contains ---

function test_assert_not_contains_success() {
  test_case_title
  (assert_not_contains "hello world" "xyz" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_not_contains "" "something" 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_not_contains_failure() {
  test_case_title
  (assert_not_contains "hello world" "hello" 2>&1)
  [[ "$?" == "1" ]] || exit 1

  (assert_not_contains "hello world" "lo wo" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- assert_match ---

function test_assert_match_success() {
  test_case_title
  (assert_match "hello123" "^hello[0-9]+$" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_match "test@example.com" ".*@.*\.com" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_match "abc" "." 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_match_failure() {
  test_case_title
  (assert_match "hello" "^[0-9]+$" 2>&1)
  [[ "$?" == "1" ]] || exit 1

  (assert_match "" "^.+$" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- assert_exit_code ---

function test_assert_exit_code_success() {
  test_case_title
  (assert_exit_code "0" "true" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_exit_code "1" "false" 2>&1)
  [[ "$?" == "0" ]] || exit 1

  (assert_exit_code "2" "exit 2" 2>&1)
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_exit_code_failure() {
  test_case_title
  (assert_exit_code "0" "false" 2>&1)
  [[ "$?" == "1" ]] || exit 1

  (assert_exit_code "1" "true" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}


# Run all tests
run_test test_assert_equal_success
run_test test_assert_equal_failure
run_test test_assert_not_equal_success
run_test test_assert_not_equal_failure
run_test test_assert_empty_success
run_test test_assert_empty_failure
run_test test_assert_not_empty_success
run_test test_assert_not_empty_failure
run_test test_assert_file_exists_success
run_test test_assert_file_exists_failure
run_test test_assert_file_not_exists_success
run_test test_assert_file_not_exists_failure
run_test test_assert_dir_exists_success
run_test test_assert_dir_exists_failure
run_test test_assert_dir_not_exists_success
run_test test_assert_dir_not_exists_failure
run_test test_assert_contains_success
run_test test_assert_contains_failure
run_test test_assert_not_contains_success
run_test test_assert_not_contains_failure
run_test test_assert_match_success
run_test test_assert_match_failure
run_test test_assert_exit_code_success
run_test test_assert_exit_code_failure
finish_tests
