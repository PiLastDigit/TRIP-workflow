#!/usr/bin/env bash
# Turn 2+: resume the existing Codex review session for <target> with a
# follow-up prompt. The thread id is read from the per-target state
# file written by start.sh.
#
# Usage: resume.sh --prompt-file <tpl> [--notes "..."] <target> [extra prompt text...]
# Exits 0 on success, 1 on Codex failure, 2 if no prior session exists.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "$SCRIPT_DIR/_common.sh"

PROMPT_FILE=""
IMPLEMENTER_NOTES=""
while [ $# -gt 0 ]; do
    case "$1" in
        --prompt-file)
            PROMPT_FILE="$2"; shift 2 ;;
        --prompt-file=*)
            PROMPT_FILE="${1#*=}"; shift ;;
        --notes)
            IMPLEMENTER_NOTES="$2"; shift 2 ;;
        --notes=*)
            IMPLEMENTER_NOTES="${1#*=}"; shift ;;
        --) shift; break ;;
        -*)
            echo "error: unknown flag: $1" >&2; exit 64 ;;
        *) break ;;
    esac
done

if [ -z "$PROMPT_FILE" ] || [ $# -lt 1 ]; then
    echo "usage: resume.sh --prompt-file <tpl> [--notes '...'] <target> [extra prompt text...]" >&2
    exit 64
fi

TARGET="$1"; shift
EXTRA_PROMPT="${*:-}"
export TARGET EXTRA_PROMPT IMPLEMENTER_NOTES

THREAD_FILE="$(thread_file "$TARGET")"
REVIEW_FILE="$(review_file "$TARGET")"
EVENTS_FILE="$(events_file "$TARGET")"

if [ ! -f "$THREAD_FILE" ]; then
    echo "error: no review session for $TARGET" >&2
    echo "       run start.sh first." >&2
    exit 2
fi
THREAD_ID="$(cat "$THREAD_FILE")"

PROMPT="$(load_prompt "$PROMPT_FILE")"

# resume inherits sandbox from the original session; --sandbox and --color
# are not accepted by `codex exec resume`.
codex exec resume "$THREAD_ID" \
    --skip-git-repo-check \
    --json \
    -c model="$CODEX_MODEL" \
    -c model_reasoning_effort="$CODEX_EFFORT" \
    -o "$REVIEW_FILE" \
    "$PROMPT" \
    </dev/null \
    >"$EVENTS_FILE" \
    2> "$EVENTS_FILE.stderr" || {
        rc=$?
        echo "error: codex exec resume failed (rc=$rc)" >&2
        echo "stderr tail:" >&2
        tail -20 "$EVENTS_FILE.stderr" >&2
        exit 1
    }

echo "resumed review session for $TARGET"
echo "  thread id:   $THREAD_ID"
echo "  model/effort: $CODEX_MODEL / $CODEX_EFFORT"
echo "  review file: $REVIEW_FILE"
echo "---"
cat "$REVIEW_FILE"
