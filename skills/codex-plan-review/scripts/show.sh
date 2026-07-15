#!/usr/bin/env bash
# Show the most recent review for <plan-path> without re-running Codex.
# Useful when the conversation has scrolled past the review output.
#
# Usage: show.sh <plan-path>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "$SCRIPT_DIR/_common.sh"

if [ $# -ne 1 ]; then
    echo "usage: show.sh <plan-path>" >&2
    exit 64
fi

REVIEW_FILE="$(review_file "$1")"
THREAD_FILE="$(thread_file "$1")"

if [ ! -f "$REVIEW_FILE" ]; then
    echo "error: no review on file for $1" >&2
    exit 1
fi

if [ -f "$THREAD_FILE" ]; then
    echo "thread id: $(cat "$THREAD_FILE")"
fi
echo "review file: $REVIEW_FILE"
echo "---"
cat "$REVIEW_FILE"
