#!/usr/bin/env zsh

function test_script_title() {
  printf "\n $fg_bold[cyan]> TEST:$reset_color %s...\n" "$1"
}

function test_script_separator() {
  printf "%-80s\n" | tr ' ' '-'
}

function test_setup_title() {
  printf " $fg_bold[cyan]> SETUP:$reset_color %s...\n" "$funcstack[-1]"
}

function test_teardown_title() {
  printf " $fg_bold[cyan]> TEARDOWN:$reset_color %s...\n" "$funcstack[-1]"
}

function test_case_title() {
  printf " $fg_bold[cyan]> CASE:$reset_color %s...\n" "$funcstack[-1]"
}