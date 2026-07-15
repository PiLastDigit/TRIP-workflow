#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local label="$3"
    if [ "$actual" != "$expected" ]; then
        printf 'FAIL: %s\nexpected: %s\nactual:   %s\n' "$label" "$expected" "$actual" >&2
        exit 1
    fi
}

test_prompt_substitution_preserves_literal_text() {
    local template="$TMP_DIR/prompt.tpl"
    printf 'Target={{TARGET}}\nExtra={{EXTRA_PROMPT}}\nNotes={{IMPLEMENTER_NOTES}}\n' > "$template"

    export STATE_DIR="$TMP_DIR/state"
    export TARGET='docs/C:\work\plan & notes.md'
    export EXTRA_PROMPT='Keep A & B; preserve C:\temp\file.'
    export IMPLEMENTER_NOTES='Fixed X & Y; left D:\repo\case unchanged.'

    # shellcheck source=../skills/codex-plan-review/scripts/_common.sh
    source "$ROOT/skills/codex-plan-review/scripts/_common.sh"
    local actual
    actual="$(load_prompt "$template")"
    local expected
    expected=$'Target=docs/C:\\work\\plan & notes.md\nExtra=Keep A & B; preserve C:\\temp\\file.\nNotes=Fixed X & Y; left D:\\repo\\case unchanged.'
    assert_eq "$expected" "$actual" "prompt substitution must preserve ampersands and backslashes"
}

test_prompt_substitution_terminates_when_value_quotes_placeholder() {
    local template="$TMP_DIR/self-ref.tpl"
    local runner="$TMP_DIR/self-ref-runner.sh"
    printf 'Notes={{IMPLEMENTER_NOTES}}\n' > "$template"

    # Run in a subprocess under timeout: a regression here is an infinite
    # loop, which must fail the test rather than hang the suite.
    cat > "$runner" <<EOF
export STATE_DIR="$TMP_DIR/state"
export TARGET='x' EXTRA_PROMPT=''
export IMPLEMENTER_NOTES='fixed the {{IMPLEMENTER_NOTES}} handling'
source "$ROOT/skills/codex-plan-review/scripts/_common.sh"
load_prompt "$template"
EOF

    local actual
    actual="$(timeout 10 bash "$runner")" \
        || fail "substitution hung or errored when the value quotes its own placeholder"
    assert_eq 'Notes=fixed the {{IMPLEMENTER_NOTES}} handling' "$actual" \
        "quoted placeholder in a value must pass through literally, not recurse"
}

test_key_helper_matches_shared_target_key() {
    local actual
    actual="$(bash "$ROOT/skills/codex-plan-review/scripts/key.sh" 'unplanned review & fix')"
    assert_eq 'unplanned_review___fix' "$actual" "free-form labels must use the shared key derivation"
}

test_consumer_show_wrappers_use_their_own_state() {
    # Run against a copy of the skills tree so fixtures never land in the
    # real state directories, even when an assertion fails mid-loop.
    local sandbox="$TMP_DIR/wrapper-sandbox"
    mkdir -p "$sandbox"
    cp -r "$ROOT/skills" "$sandbox/"

    local skill label state output
    for skill in codex-implement codex-code-review codex-ask; do
        label="wrapper-test-$skill"
        state="$sandbox/skills/$skill/state"
        mkdir -p "$state"
        printf 'thread-%s\n' "$skill" > "$state/$label.thread"
        printf 'report-%s\n' "$skill" > "$state/$label.review.txt"
        output="$(bash "$sandbox/skills/$skill/scripts/show.sh" "$label")"
        grep -q "report-$skill" <<< "$output" || fail "$skill show wrapper read the wrong state directory"
    done
}

test_runtime_state_is_ignored() {
    local skill
    for skill in codex-implement codex-ask; do
        [ -f "$ROOT/skills/$skill/state/.gitignore" ] || fail "$skill state directory needs a .gitignore"
        grep -qx '\*' "$ROOT/skills/$skill/state/.gitignore" || fail "$skill state .gitignore must ignore runtime files"
        grep -qx '!\.gitignore' "$ROOT/skills/$skill/state/.gitignore" || fail "$skill state .gitignore must keep itself"
    done
}

test_prompt_substitution_preserves_literal_text
test_prompt_substitution_terminates_when_value_quotes_placeholder
test_key_helper_matches_shared_target_key
test_consumer_show_wrappers_use_their_own_state
test_runtime_state_is_ignored

echo "workflow regression tests passed"
