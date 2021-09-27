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
