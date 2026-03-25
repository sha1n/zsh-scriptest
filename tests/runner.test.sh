#!/usr/bin/env zsh

source "$__ZSH_SCRIPTEST_HOME/matchers.sh"
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"

local runner="$__ZSH_SCRIPTEST_HOME/run_tests.sh"


function test_runner_passing_suite() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/pass.test.sh" <<'TESTEOF'
#!/usr/bin/env zsh
exit 0
TESTEOF
  chmod +x "$tmp_dir/pass.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "0"
  assert_contains "$output" "PASSED"

  rm -rf "$tmp_dir"
}

function test_runner_failing_suite() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/fail.test.sh" <<'TESTEOF'
#!/usr/bin/env zsh
exit 1
TESTEOF
  chmod +x "$tmp_dir/fail.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "1"
  assert_contains "$output" "FAILED"

  rm -rf "$tmp_dir"
}

function test_runner_mixed_suite() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/pass.test.sh" <<'TESTEOF'
#!/usr/bin/env zsh
exit 0
TESTEOF
  chmod +x "$tmp_dir/pass.test.sh"

  cat > "$tmp_dir/fail.test.sh" <<'TESTEOF'
#!/usr/bin/env zsh
exit 1
TESTEOF
  chmod +x "$tmp_dir/fail.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "1"
  assert_contains "$output" "PASSED"
  assert_contains "$output" "FAILED"

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
  cat > "$tmp_dir/real.test.sh" <<'TESTEOF'
#!/usr/bin/env zsh
exit 0
TESTEOF
  chmod +x "$tmp_dir/real.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "0"
  assert_contains "$output" "real.test.sh"
  assert_not_contains "$output" "not_a_test.sh"

  rm -rf "$tmp_dir"
}

function test_runner_home_isolation() {
  test_case_title
  local original_home="$HOME"
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/home_check.test.sh" <<TESTEOF
#!/usr/bin/env zsh
# HOME should NOT be the original home inside the runner
if [[ "\$HOME" == "$original_home" ]]; then
  exit 1
fi
exit 0
TESTEOF
  chmod +x "$tmp_dir/home_check.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"
  local rc="$?"

  assert_equal "$rc" "0"

  rm -rf "$tmp_dir"
}

function test_runner_summary_output() {
  test_case_title
  local tmp_dir="$(mktemp -d)"

  cat > "$tmp_dir/one.test.sh" <<'TESTEOF'
#!/usr/bin/env zsh
exit 0
TESTEOF
  chmod +x "$tmp_dir/one.test.sh"

  cat > "$tmp_dir/two.test.sh" <<'TESTEOF'
#!/usr/bin/env zsh
exit 0
TESTEOF
  chmod +x "$tmp_dir/two.test.sh"

  local output
  output="$($runner "$tmp_dir" 2>&1)"

  assert_contains "$output" "Tests: 2"
  assert_contains "$output" "Passed:"
  assert_contains "$output" "Failed:"

  rm -rf "$tmp_dir"
}


# Run all tests
test_runner_passing_suite
test_runner_failing_suite
test_runner_mixed_suite
test_runner_ignores_non_test_files
test_runner_home_isolation
test_runner_summary_output
