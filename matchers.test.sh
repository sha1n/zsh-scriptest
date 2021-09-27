#!/usr/bin/env zsh

source "$__ZSH_SCRIPTEST_HOME/matchers.sh"
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"


function test_assert_equal() {
  test_case_title
  (eval 'assert_equal "1" "1"')
  [[ "$?" == "0" ]] || exit 1

  (eval 'assert_equal "1" "2"')
  [[ "$?" == "1" ]] || exit 1
}

function test_assert_empty() {
  test_case_title
  (eval 'assert_empty "not empty"')
  [[ "$?" == "1" ]] || exit 1

  (eval 'assert_empty ""')
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_not_empty() {
  test_case_title
  (eval 'assert_not_empty "not empty"')
  [[ "$?" == "0" ]] || exit 1

  (eval 'assert_not_empty ""')
  [[ "$?" == "1" ]] || exit 1
}

function test_assert_dir_exists() {
  test_case_title
  (eval 'assert_dir_exists "$HOME"')
  [[ "$?" == "0" ]] || exit 1

  (eval 'assert_dir_exists $HOME/test_non_existing_dir')
  [[ "$?" == "1" ]] || exit 1
}

function test_assert_dir_not_exists() {
  test_case_title
  (eval 'assert_dir_not_exists "$HOME"')
  [[ "$?" == "1" ]] || exit 1

  (eval 'assert_dir_not_exists $HOME/test_non_existing_dir')
  [[ "$?" == "0" ]] || exit 1
}

function test_assert_file_exists() {
  test_case_title
  
  local existing_file="$(mktemp)"
  (eval 'assert_file_exists "$existing_file"')
  [[ "$?" == "0" ]] || exit 1

  (eval 'assert_file_exists $HOME/test_non_existing_file')
  [[ "$?" == "1" ]] || exit 1
}

function test_assert_file_not_exists() {
  test_case_title

  local existing_file="$(mktemp)"
  (eval 'assert_file_not_exists "$HOME/test_non_existing_file"')
  [[ "$?" == "0" ]] || exit 1

  (eval 'assert_file_not_exists $existing_file')
  [[ "$?" == "1" ]] || exit 1
}

function test_assert_contains() {
  test_case_title

  (eval 'assert_contains "abc" "a"')
  [[ "$?" == "0" ]] || exit 1

  (eval 'assert_contains "abc" "b"')
  [[ "$?" == "0" ]] || exit 1

  (eval 'assert_contains "abc" "c"')
  [[ "$?" == "0" ]] || exit 1

  (eval 'assert_contains "abc" "d"')
  [[ "$?" == "1" ]] || exit 1
}

test_assert_equal
test_assert_empty
test_assert_not_empty
test_assert_dir_exists
test_assert_dir_not_exists
test_assert_file_exists
test_assert_file_not_exists
test_assert_contains
