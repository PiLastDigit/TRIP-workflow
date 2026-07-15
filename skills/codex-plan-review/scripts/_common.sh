#!/usr/bin/env bash
# Shared paths, key derivation, and prompt-loading helpers for the
# codex-plan-review and codex-code-review skills. Source-only.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# STATE_DIR can be overridden by the caller (e.g., codex-code-review
# exports its own state path before invoking the shared scripts).
# Default falls back to the script's own skill directory.
: "${STATE_DIR:=$SKILL_DIR/state}"
export STATE_DIR
mkdir -p "$STATE_DIR"

# Model/effort/tier per flow (single source of truth for all codex skills):
# implementation runs Luna at high effort on the fast service tier (benchmarked
# ~40-150% higher throughput, no observed quality cost); reviews (plan + code)
# run Sol at xhigh on standard routing. Adjust these defaults to your
# preferred models. CODEX_MODEL / CODEX_EFFORT / CODEX_TIER act as per-run
# overrides (e.g. CODEX_EFFORT=xhigh to escalate a hard batch).
# Models that don't support a tier silently ignore it ("default" = standard).
# Match the trailing path components exactly — a repo path that merely
# contains "codex-implement" must not flip reviews to the implement model.
case "${STATE_DIR%/}" in
    */codex-implement/state | codex-implement/state)
        CODEX_MODEL="${CODEX_MODEL:-gpt-5.6-luna}"
        CODEX_EFFORT="${CODEX_EFFORT:-high}"
        CODEX_TIER="${CODEX_TIER:-fast}"
        ;;
    *)
        CODEX_MODEL="${CODEX_MODEL:-gpt-5.6-sol}"
        CODEX_EFFORT="${CODEX_EFFORT:-xhigh}"
        CODEX_TIER="${CODEX_TIER:-default}"
        ;;
esac
export CODEX_MODEL CODEX_EFFORT CODEX_TIER

# Optional wall-clock bound for each codex call, in whole seconds.
# 0 (the default) = no timeout — identical to historical behavior.
CODEX_TIMEOUT="${CODEX_TIMEOUT:-0}"
case "$CODEX_TIMEOUT" in
    ''|*[!0-9]*)
        echo "error: CODEX_TIMEOUT must be a whole number of seconds (got '$CODEX_TIMEOUT')" >&2
        exit 64 ;;
esac
export CODEX_TIMEOUT

# codex_exec <codex args...> — run codex, bounded by CODEX_TIMEOUT when set.
# TERM first, KILL 10s later. GNU timeout exits 124 on expiry, which flows
# through the call sites' existing `|| { ... }` failure handling; the
# "timed out" message below lands in the redirected stderr file, so the
# handlers' stderr tail surfaces it. macOS has no stock `timeout` — fall
# back to gtimeout (brew coreutils), and warn rather than silently running
# unbounded when neither exists.
codex_exec() {
    if [ "$CODEX_TIMEOUT" -eq 0 ]; then
        codex "$@"
        return
    fi
    local timeout_bin=""
    if command -v timeout >/dev/null 2>&1; then
        timeout_bin=timeout
    elif command -v gtimeout >/dev/null 2>&1; then
        timeout_bin=gtimeout
    fi
    if [ -z "$timeout_bin" ]; then
        echo "warning: CODEX_TIMEOUT=$CODEX_TIMEOUT is set but neither 'timeout' nor 'gtimeout' is available; running unbounded (macOS: brew install coreutils)" >&2
        codex "$@"
        return
    fi
    local rc=0
    "$timeout_bin" --signal=TERM --kill-after=10 "$CODEX_TIMEOUT" codex "$@" || rc=$?
    if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
        echo "error: codex timed out after ${CODEX_TIMEOUT}s (CODEX_TIMEOUT)" >&2
    fi
    return "$rc"
}

# Fail fast when a required external tool is missing. Without this,
# `set -e` + suppressed stderr would kill the caller with no message.
require_tools() {
    local tool
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "error: required tool not found on PATH: $tool" >&2
            return 1
        fi
    done
}

# Derive a per-target key from a path-like string. For real paths we
# resolve to absolute; for non-path targets (branch names, commit
# ranges) we use the string as-is. The key is a sanitized, readable
# form plus a checksum of the resolved target, so distinct targets
# that sanitize identically (e.g. "foo/bar" vs "foo__bar") never
# share state files.
target_key() {
    local target="$1" resolved sanitized sum
    if [ -e "$target" ]; then
        resolved="$(realpath -- "$target" 2>/dev/null || readlink -f -- "$target")"
        if [ -z "$resolved" ]; then
            echo "error: cannot resolve target path: $target" >&2
            return 1
        fi
    else
        resolved="$target"
    fi
    sanitized="$(printf '%s' "$resolved" | sed 's|^/||; s|/|__|g; s|[^A-Za-z0-9._-]|_|g')"
    sum="$(printf '%s' "$resolved" | cksum | cut -d' ' -f1)"
    printf '%s.%s' "$sanitized" "$sum"
}

# Backwards-compatible alias used by older script call sites.
plan_key() { target_key "$@"; }

thread_file() {
    printf '%s/%s.thread' "$STATE_DIR" "$(target_key "$1")"
}

review_file() {
    printf '%s/%s.review.txt' "$STATE_DIR" "$(target_key "$1")"
}

events_file() {
    printf '%s/%s.events.ndjson' "$STATE_DIR" "$(target_key "$1")"
}

# Load a prompt template from $1 and substitute {{TARGET}},
# {{EXTRA_PROMPT}} and {{IMPLEMENTER_NOTES}} placeholders with the
# values of the corresponding environment variables. The replacement
# expansions are double-quoted, which forces bash to treat them as
# literal strings — without the quotes, bash >= 5.2 (patsub_replacement)
# expands '&' to the matched text, exactly the mangling awk's gsub did.
load_prompt() {
    local tpl="$1" content
    if [ ! -f "$tpl" ]; then
        echo "error: prompt template not found: $tpl" >&2
        return 1
    fi
    content="$(cat "$tpl")"
    content="${content//'{{TARGET}}'/"${TARGET-}"}"
    content="${content//'{{EXTRA_PROMPT}}'/"${EXTRA_PROMPT-}"}"
    content="${content//'{{IMPLEMENTER_NOTES}}'/"${IMPLEMENTER_NOTES-}"}"
    printf '%s\n' "$content"
}
