#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export STATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/state"
exec bash "$SCRIPT_DIR/../../codex-plan-review/scripts/reset.sh" "$@"
