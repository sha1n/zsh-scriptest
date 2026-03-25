# !/usr/bin/env zsh

autoload -U colors && colors

function assert_equal() {
  if [[ "$1" != "$2" ]]; then
    print "NOT EQUAL!

Expected: '$2'

  Actual: '$fg[red]$1$reset_color'
"
    exit 1
  fi
}

function assert_not_empty() {
  if [[ -z "$1" ]]; then
    print "EMPTY!

Actual: '$fg[red]$1$reset_color'
"
    exit 1
  fi
}

function assert_empty() {
  if [[ ! -z "$1" ]]; then
    print "NOT EMPTY!

Actual: '$fg[red]$1$reset_color'
"
    exit 1
  fi
}

function assert_file_not_exists() {
  if [[ -f "$1" ]]; then
    print "FILE EXISTS!

Path: '$1'
"
    exit 1
  fi
}

function assert_file_exists() {
  if [[ ! -f "$1" ]]; then
    print "FILE DOESN'T EXIST!

Path: '$1'
"
    exit 1
  fi
}

function assert_dir_not_exists() {
  if [[ -d "$1" ]]; then
    print "DIRECTORY EXISTS!

Path: '$1'
"
    exit 1
  fi
}

function assert_dir_exists() {
  if [[ ! -d "$1" ]]; then
    print "DIRECTORY DOESN'T EXIST!

Path: '$1'
"
    exit 1
  fi
}

function assert_contains() {
  if [[ "$1" != *"$2"* ]]; then
    print "'$1' does not contain '$2'"
    exit 1
  fi
}

function assert_not_equal() {
  if [[ "$1" == "$2" ]]; then
    print "EQUAL!

Expected not: '$1'

      Actual: '$fg[red]$2$reset_color'
"
    exit 1
  fi
}

function assert_not_contains() {
  if [[ "$1" == *"$2"* ]]; then
    print "'$1' contains '$2'"
    exit 1
  fi
}

function assert_match() {
  if [[ ! "$1" =~ $2 ]]; then
    print "NO MATCH!

  Value: '$fg[red]$1$reset_color'

Pattern: '$2'
"
    exit 1
  fi
}

function assert_exit_code() {
  local expected="$1"
  local command="$2"
  local actual
  (eval "$command" >/dev/null 2>&1)
  actual="$?"
  if [[ "$actual" != "$expected" ]]; then
    print "UNEXPECTED EXIT CODE!

Expected: '$expected'

  Actual: '$fg[red]$actual$reset_color'

 Command: '$command'
"
    exit 1
  fi
}
