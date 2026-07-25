#!/usr/bin/env bash
# Turn 2+: resume the existing Codex review session for <target> with a
# follow-up prompt. The thread id is read from the per-target state
# file written by start.sh.
#
# Usage: resume.sh --prompt-file <tpl> [--notes "..."] [--image <file>]…
#            <target> [extra prompt text...]
# Exits 0 on success, 1 on Codex failure, 2 if no prior session exists.
#
# --image attaches a file to the resumed turn (repeatable). Used by
# TRIP-goggins to hand the round's screenshots to the model that has to
# fix them — judging on pixels only works if the worker sees them too.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "$SCRIPT_DIR/_common.sh"

PROMPT_FILE=""
IMPLEMENTER_NOTES=""
IMAGES=()
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
        --image|-i)
            IMAGES+=("$2"); shift 2 ;;
        --image=*)
            IMAGES+=("${1#*=}"); shift ;;
        --) shift; break ;;
        -*)
            echo "error: unknown flag: $1" >&2; exit 64 ;;
        *) break ;;
    esac
done

if [ -z "$PROMPT_FILE" ] || [ $# -lt 1 ]; then
    echo "usage: resume.sh --prompt-file <tpl> [--notes '...'] [--image <file>]… <target> [extra prompt text...]" >&2
    exit 64
fi

# Fail loudly on a missing attachment: a silently dropped screenshot means
# the worker judges its own work blind for a whole round.
# --image=<file> (equals form): `codex exec --image` is variadic, so the
# space-separated form swallows the positional prompt. Same form here.
IMAGE_ARGS=()
for img in ${IMAGES[@]+"${IMAGES[@]}"}; do
    if [ ! -f "$img" ]; then
        echo "error: --image file not found: $img" >&2
        exit 66
    fi
    IMAGE_ARGS+=("--image=$img")
done

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
    ${IMAGE_ARGS[@]+"${IMAGE_ARGS[@]}"} \
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

echo "resumed session for $TARGET"
echo "  thread id:   $THREAD_ID"
echo "  model/effort: $CODEX_MODEL / $CODEX_EFFORT"
if [ "${#IMAGE_ARGS[@]}" -gt 0 ]; then
    echo "  images:      ${IMAGES[*]}"
fi
echo "  review file: $REVIEW_FILE"
echo "---"
cat "$REVIEW_FILE"
