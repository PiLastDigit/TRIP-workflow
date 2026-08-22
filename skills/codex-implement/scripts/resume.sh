#!/usr/bin/env bash
# Wrapper: pin THIS skill's STATE_DIR, then delegate to the shared
# codex-plan-review resume.sh. Exists so the caller never has to remember
# to `export STATE_DIR` first — a forgotten export would otherwise make
# this operate on the plan-review thread for the same target (wrong
# model, wrong sandbox, wrong prompt).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export STATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/state"
exec bash "$SCRIPT_DIR/../../codex-plan-review/scripts/resume.sh" "$@"
