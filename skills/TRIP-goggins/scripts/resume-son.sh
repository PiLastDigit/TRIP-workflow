#!/usr/bin/env bash
# Resume son with a round report — screenshots MANDATORY.
#
# Why this wrapper exists: in the first real mission the judge scored every
# round on rendered pixels and never attached one to son. Son designed an
# entire visual identity from prose descriptions of its own output, and the
# only two dimensions that never moved were the two it could not inspect.
# Codex cannot be relied on to render the app itself — its sandbox often has
# no browser and no access to the dev server. So the judge's eyes are the only
# eyes, and handing them over is not optional.
#
# It also enforces the report-file convention: the report is read from
# state/rounds/round-<N>/report.md and passed via "$(cat …)", so backticks and
# $ in `file:line` receipts are never command-substituted by the shell.
#
# Usage:
#   resume-son.sh <mission-label> <round> --image <file> [--image <file>]…
#                 [--notes "…"]
#
# Exits 0 on success, 64 on usage error, 65 on a missing round report,
# 66 on a missing/absent image, plus whatever resume.sh returns.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_DIR="${STATE_DIR:-$SKILL_DIR/state}"
export STATE_DIR

IMAGES=()
NOTES=""
POSITIONAL=()
while [ $# -gt 0 ]; do
    case "$1" in
        --image|-i)   IMAGES+=("$2"); shift 2 ;;
        --image=*)    IMAGES+=("${1#*=}"); shift ;;
        --notes)      NOTES="$2"; shift 2 ;;
        --notes=*)    NOTES="${1#*=}"; shift ;;
        --)           shift; break ;;
        -*)           echo "error: unknown flag: $1" >&2; exit 64 ;;
        *)            POSITIONAL+=("$1"); shift ;;
    esac
done

if [ "${#POSITIONAL[@]}" -lt 2 ]; then
    echo "usage: resume-son.sh <mission-label> <round> --image <file> [--image <file>]… [--notes '…']" >&2
    exit 64
fi
LABEL="${POSITIONAL[0]}"
ROUND="${POSITIONAL[1]}"

ROUND_DIR="$STATE_DIR/rounds/round-$ROUND"
REPORT="$ROUND_DIR/report.md"

if [ ! -f "$REPORT" ]; then
    echo "error: no round report at $REPORT" >&2
    echo "       write the scorecard + roast + numbered demands there first;" >&2
    echo "       never inline the report into the command line." >&2
    exit 65
fi

# The whole point of the wrapper.
if [ "${#IMAGES[@]}" -eq 0 ]; then
    echo "error: no --image given. Son does not get to design blind." >&2
    echo "       Attach the hero view plus the weakest dimension's evidence" >&2
    echo "       (and a refs/ image when the signature dimension is failing)." >&2
    if [ -d "$ROUND_DIR" ]; then
        echo "       Candidates in round-$ROUND:" >&2
        find "$ROUND_DIR" -maxdepth 1 -name '*.png' -printf '         %f\n' 2>/dev/null | sort >&2
    fi
    if [ -d "$STATE_DIR/refs" ]; then
        find "$STATE_DIR/refs" -name '*.png' -printf '         refs/%P\n' 2>/dev/null | sort >&2
    fi
    exit 66
fi

if [ "${#IMAGES[@]}" -gt 6 ]; then
    echo "warning: ${#IMAGES[@]} images on one turn — cap around 4, tokens are not free." >&2
fi

RESUME_ARGS=(--prompt-file "$SKILL_DIR/prompts/son-resume.tpl")
for img in "${IMAGES[@]}"; do
    RESUME_ARGS+=(--image "$img")   # resume.sh validates existence and exits 66
done
if [ -n "$NOTES" ]; then
    RESUME_ARGS+=(--notes "$NOTES")
fi

echo "resuming son: $LABEL round $ROUND"
echo "  report: $REPORT ($(wc -l < "$REPORT") lines)"
echo "  images: ${IMAGES[*]}"

exec bash "$SKILL_DIR/../codex-plan-review/scripts/resume.sh" \
    "${RESUME_ARGS[@]}" \
    "$LABEL" "$(cat "$REPORT")"
