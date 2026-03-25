#!/usr/bin/env zsh

source "$__ZSH_SCRIPTEST_HOME/matchers.sh"
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"


# --- Paths with spaces ---

function test_file_exists_with_spaces_in_path() {
  test_case_title
  local tmp_dir="$(mktemp -d)"
  local spaced_file="$tmp_dir/my test file.txt"
  touch "$spaced_file"

  assert_file_exists "$spaced_file"
  rm -f "$spaced_file"
  rmdir "$tmp_dir"
}

function test_file_not_exists_with_spaces_in_path() {
  test_case_title
  assert_file_not_exists "/tmp/no such file $$.txt"
}

function test_dir_exists_with_spaces_in_path() {
  test_case_title
  local tmp_dir="$(mktemp -d)"
  local spaced_dir="$tmp_dir/my test dir"
  mkdir "$spaced_dir"

  assert_dir_exists "$spaced_dir"
  rmdir "$spaced_dir"
  rmdir "$tmp_dir"
}

function test_dir_not_exists_with_spaces_in_path() {
  test_case_title
  assert_dir_not_exists "/tmp/no such dir $$"
}

# --- Special characters in strings ---

function test_equal_with_special_chars() {
  test_case_title
  assert_equal 'hello "world"' 'hello "world"'
  assert_equal "it's" "it's"
  assert_equal 'back\slash' 'back\slash'
}

function test_contains_with_special_chars() {
  test_case_title
  assert_contains 'path/to/file' 'to/file'
  assert_contains 'key=value' '=value'
  assert_contains 'hello "quoted" world' '"quoted"'
}

function test_not_contains_with_special_chars() {
  test_case_title
  assert_not_contains 'hello world' 'xyz'
  assert_not_contains 'path/to/file' 'missing'
}

# --- Empty string edge cases ---

function test_empty_string_matchers() {
  test_case_title
  assert_empty ""
  assert_not_empty " "

  assert_contains "" ""
  assert_contains "abc" ""

  (assert_not_empty "" 2>&1)
  [[ "$?" == "1" ]] || exit 1

  (assert_empty " " 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

# --- Multiword and whitespace strings ---

function test_equal_with_whitespace() {
  test_case_title
  assert_equal "  leading" "  leading"
  assert_equal "trailing  " "trailing  "

  (assert_equal "  a" "a" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

function test_contains_overlapping() {
  test_case_title
  assert_contains "aaabaaab" "aab"
  assert_contains "abcabcabc" "cabca"
}

# --- Match edge cases ---

function test_match_anchored_patterns() {
  test_case_title
  assert_match "12345" "^[0-9]+$"

  (assert_match "12345a" "^[0-9]+$" 2>&1)
  [[ "$?" == "1" ]] || exit 1
}

function test_match_partial() {
  test_case_title
  assert_match "hello world 123" "[0-9]+"
  assert_match "/usr/local/bin" "^/usr"
}

# --- Exit code edge cases ---

function test_exit_code_with_output() {
  test_case_title
  assert_exit_code "0" "echo hello"
  assert_exit_code "0" "printf test"
}

function test_exit_code_nonstandard() {
  test_case_title
  assert_exit_code "42" "exit 42"
  assert_exit_code "127" "command_that_does_not_exist_$$"
}


# Run all tests
run_test test_file_exists_with_spaces_in_path
run_test test_file_not_exists_with_spaces_in_path
run_test test_dir_exists_with_spaces_in_path
run_test test_dir_not_exists_with_spaces_in_path
run_test test_equal_with_special_chars
run_test test_contains_with_special_chars
run_test test_not_contains_with_special_chars
run_test test_empty_string_matchers
run_test test_equal_with_whitespace
run_test test_contains_overlapping
run_test test_match_anchored_patterns
run_test test_match_partial
run_test test_exit_code_with_output
run_test test_exit_code_nonstandard
finish_tests
