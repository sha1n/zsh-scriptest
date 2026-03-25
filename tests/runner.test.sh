#!/usr/bin/env zsh

source "$__ZSH_SCRIPTEST_HOME/matchers.sh"
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"

local runner="$__ZSH_SCRIPTEST_HOME/run_tests.sh"


function test_runner_plan_line() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/pass.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_ok() { true; }
run_test test_ok
finish_tests
TESTEOF
  chmod +x "$tmp_dir/pass.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"

  assert_contains "$output" "1..1"

  rm -rf "$tmp_dir"
}

function test_runner_passing_suite() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/pass.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_ok() { true; }
run_test test_ok
finish_tests
TESTEOF
  chmod +x "$tmp_dir/pass.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "0"
  assert_contains "$output" "ok 1 - test_ok"

  rm -rf "$tmp_dir"
}

function test_runner_failing_suite() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/fail.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_bad() { exit 1; }
run_test test_bad
finish_tests
TESTEOF
  chmod +x "$tmp_dir/fail.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "1"
  assert_contains "$output" "not ok 1 - test_bad"

  rm -rf "$tmp_dir"
}

function test_runner_mixed_suite() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/suite.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_good() { true; }
function test_bad() { exit 1; }
run_test test_good
run_test test_bad
finish_tests
TESTEOF
  chmod +x "$tmp_dir/suite.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "1"
  assert_contains "$output" "ok 1 - test_good"
  assert_contains "$output" "not ok 2 - test_bad"

  rm -rf "$tmp_dir"
}

function test_runner_ignores_non_test_files() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  # This file should NOT be discovered (wrong extension)
  cat > "$tmp_dir/not_a_test.sh" <<'TESTEOF'
#!/usr/bin/env zsh
exit 1
TESTEOF
  chmod +x "$tmp_dir/not_a_test.sh"

  # This file SHOULD be discovered
  cat > "$tmp_dir/real.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_ok() { true; }
run_test test_ok
finish_tests
TESTEOF
  chmod +x "$tmp_dir/real.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "0"
  assert_contains "$output" "test_ok"
  assert_not_contains "$output" "not_a_test.sh"

  rm -rf "$tmp_dir"
}

function test_runner_home_isolation() {
  test_case_title
  local original_home="$HOME"
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/home_check.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_home() {
  if [[ "\$HOME" == "$original_home" ]]; then
    exit 1
  fi
}
run_test test_home
finish_tests
TESTEOF
  chmod +x "$tmp_dir/home_check.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "0"

  rm -rf "$tmp_dir"
}

function test_runner_per_case_counting() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/multi.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_a() { true; }
function test_b() { true; }
function test_c() { true; }
run_test test_a
run_test test_b
run_test test_c
finish_tests
TESTEOF
  chmod +x "$tmp_dir/multi.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"

  assert_contains "$output" "1..3"
  assert_contains "$output" "ok 1 - test_a"
  assert_contains "$output" "ok 2 - test_b"
  assert_contains "$output" "ok 3 - test_c"

  rm -rf "$tmp_dir"
}

function test_runner_cross_file_numbering() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/a.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_one() { true; }
function test_two() { true; }
run_test test_one
run_test test_two
finish_tests
TESTEOF
  chmod +x "$tmp_dir/a.test.sh"

  cat > "$tmp_dir/b.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_three() { true; }
run_test test_three
finish_tests
TESTEOF
  chmod +x "$tmp_dir/b.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"

  # Plan should cover all cases across files
  assert_contains "$output" "1..3"

  rm -rf "$tmp_dir"
}

function test_runner_failure_diagnostics() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/fail.test.sh" <<TESTEOF
#!/usr/bin/env zsh
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"
function test_failing() {
  echo "something went wrong"
  exit 1
}
run_test test_failing
finish_tests
TESTEOF
  chmod +x "$tmp_dir/fail.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"

  # Failure output should be included as TAP diagnostic (# prefixed)
  assert_contains "$output" "#   something went wrong"

  rm -rf "$tmp_dir"
}


# Run all tests
run_test test_runner_plan_line
run_test test_runner_passing_suite
run_test test_runner_failing_suite
run_test test_runner_mixed_suite
run_test test_runner_ignores_non_test_files
run_test test_runner_home_isolation
run_test test_runner_per_case_counting
run_test test_runner_cross_file_numbering
run_test test_runner_failure_diagnostics
finish_tests
