[![CI](https://github.com/sha1n/zsh-scriptest/actions/workflows/ci.yml/badge.svg)](https://github.com/sha1n/zsh-scriptest/actions/workflows/ci.yml)

# Zsh ScripTest

A lightweight, generic test runner framework for zsh scripts. ScripTest provides test discovery, execution isolation, assertion matchers, and formatted output — everything you need to test your shell scripts with minimal setup.

## Quick Start

Create a test file named `my_feature.test.sh`:

```zsh
#!/usr/bin/env zsh

source "$__ZSH_SCRIPTEST_HOME/matchers.sh"
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"

function test_greeting() {
  test_case_title
  local result="hello world"
  assert_contains "$result" "hello"
  assert_not_empty "$result"
}

run_test test_greeting
finish_tests
```

Run it:

```sh
./run_tests.sh .
```

## Installation

Add as a git submodule in your project:

```sh
git submodule add https://github.com/sha1n/zsh-scriptest.git tests/zsh-scriptest
```

Create a thin wrapper script (e.g. `tests/run_tests.sh`):

```zsh
#!/usr/bin/env zsh
export MY_TESTS_HOME="${${(%):-%x}:a:h}"
"$MY_TESTS_HOME/zsh-scriptest/run_tests.sh" "$MY_TESTS_HOME"
```

Add a Makefile target:

```makefile
test:
	./tests/run_tests.sh
```

## Writing Tests

### File Naming

Test files must match the pattern `*.test.sh` and be executable. The runner discovers all matching files in the given directory (one level deep).

### Test Structure

Each test file should:
1. Source `matchers.sh` and `test_util.sh`
2. Define test functions
3. Run them with `run_test` and call `finish_tests` at the end

```zsh
#!/usr/bin/env zsh

source "$__ZSH_SCRIPTEST_HOME/matchers.sh"
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"

function test_something() {
  test_case_title
  # ... test logic and assertions ...
}

function test_another_thing() {
  test_case_title
  # ... test logic and assertions ...
}

run_test test_something
run_test test_another_thing
finish_tests
```

`run_test` executes each test function in a subshell, so a failure in one test does not prevent other tests from running. It emits TAP-compliant `ok`/`not ok` lines, and on failure includes the test output as diagnostic lines.

### Setup and Teardown

Use `test_setup_title` and `test_teardown_title` to mark setup and teardown phases:

```zsh
function setup() {
  test_setup_title
  export TEST_DIR="$(mktemp -d)"
  # ... create test fixtures ...
}

function teardown() {
  test_teardown_title
  rm -rf "$TEST_DIR"
}

function test_my_feature() {
  test_case_title
  assert_dir_exists "$TEST_DIR"
}

setup
run_test test_my_feature
finish_tests
teardown
```

### Test Isolation

The test runner automatically:
- Runs each test **file** in a subshell (failures don't affect other files)
- Sets `$HOME` to a temporary directory (your real home is never touched)
- Restores `$HOME` after all tests complete

For isolation **within** a test file, use subshells or define a `before_each` function:

```zsh
function before_each() {
  test_case_title
  # reset state between tests
}
```

## Matchers Reference

All matchers exit with code `1` on failure and print a diagnostic message.

### Equality

| Matcher | Description | Example |
|---------|-------------|---------|
| `assert_equal` | Values must be identical | `assert_equal "$actual" "expected"` |
| `assert_not_equal` | Values must differ | `assert_not_equal "$actual" "unexpected"` |

```zsh
assert_equal "$result" "42"
assert_not_equal "$status" "error"
```

### String Content

| Matcher | Description | Example |
|---------|-------------|---------|
| `assert_empty` | Value must be empty | `assert_empty "$var"` |
| `assert_not_empty` | Value must not be empty | `assert_not_empty "$var"` |
| `assert_contains` | Haystack must contain needle | `assert_contains "$output" "success"` |
| `assert_not_contains` | Haystack must not contain needle | `assert_not_contains "$output" "error"` |
| `assert_match` | Value must match regex pattern | `assert_match "$val" "^[0-9]+$"` |

```zsh
assert_empty "$error_msg"
assert_not_empty "$PATH"
assert_contains "$output" "Done"
assert_not_contains "$log" "FATAL"
assert_match "$version" "^[0-9]+\.[0-9]+\.[0-9]+$"
```

### File System

| Matcher | Description | Example |
|---------|-------------|---------|
| `assert_file_exists` | File must exist | `assert_file_exists "$config_path"` |
| `assert_file_not_exists` | File must not exist | `assert_file_not_exists "$tmp_file"` |
| `assert_dir_exists` | Directory must exist | `assert_dir_exists "$output_dir"` |
| `assert_dir_not_exists` | Directory must not exist | `assert_dir_not_exists "$old_dir"` |

```zsh
assert_file_exists "$HOME/.config/myapp/config"
assert_file_not_exists "$HOME/.config/myapp/config.bak"
assert_dir_exists "$HOME/.local/bin"
assert_dir_not_exists "/tmp/stale_build"
```

### Exit Code

| Matcher | Description | Example |
|---------|-------------|---------|
| `assert_exit_code` | Command must exit with expected code | `assert_exit_code "0" "my_command --flag"` |

```zsh
assert_exit_code "0" "my_script --validate input.txt"
assert_exit_code "1" "my_script --validate bad_input.txt"
```

### Testing Failure Paths

To test that a matcher correctly fails, run the assertion in a subshell and check the exit code:

```zsh
(assert_equal "a" "b" 2>&1)
[[ "$?" == "1" ]] || exit 1
```

## Utility Functions

| Function | Description | Usage |
|----------|-------------|-------|
| `run_test` | Runs a test function in a subshell and emits TAP output | `run_test test_my_func` |
| `finish_tests` | Exits with code 1 if any `run_test` calls failed | Call at the end of each test file |
| `test_case_title` | Prints the calling function name as a test case header | Call at the top of each test function |
| `test_setup_title` | Prints the calling function name as a setup header | Call at the top of setup functions |
| `test_teardown_title` | Prints the calling function name as a teardown header | Call at the top of teardown functions |

## Running Tests

Run all tests in a directory:

```sh
./run_tests.sh <test_directory>
```

Using Make:

```sh
make test
```

Output follows [TAP (Test Anything Protocol)](https://testanything.org/) format, with one line per test case:

```
1..5
ok 1 - test_greeting
ok 2 - test_farewell
not ok 3 - test_broken
#   NOT EQUAL!
#   Expected: 'goodbye'
#     Actual: 'hello'
ok 4 - test_file_created
ok 5 - test_cleanup
```

Failed test output is included as TAP diagnostic lines (prefixed with `#`). Exit code is `0` if all tests pass, `1` if any test fails.

## CI Integration

Example GitHub Actions workflow:

```yaml
name: CI
on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    steps:
      - uses: actions/checkout@v4

      - name: Install Zsh
        if: runner.os == 'Linux'
        run: |
          sudo apt-get update
          sudo apt-get install zsh

      - name: Run Tests
        run: make test
```
