#!/usr/bin/env bash
# Per-round worktree snapshots for GOGGINS MODE.
#
# The loop runs on a dirty tree: son is forbidden to commit, and every round
# overwrites the last. Without snapshots a bold round that lands worse than
# the round before it destroys the better version — "best round wins" needs
# something to win with.
#
# A snapshot is a real commit object built from the worktree (tracked +
# untracked, .gitignore respected) via a temp index. HEAD, the index, and
# the worktree are never touched. Each snapshot is kept alive by a ref under
# refs/goggins/ — invisible to `git branch`/`git tag`, never pushed.
#
# Usage:
#   snapshot.sh save <mission-label> <round> [note]
#   snapshot.sh restore <mission-label> <round>
#   snapshot.sh list <mission-label>
#   snapshot.sh diff <mission-label> <round-a> <round-b>
#
# restore auto-saves the current state as round `pre-restore` first, so a
# rollback is itself reversible. Files created after the target round are
# reported, never deleted — the human decides.
#
# Exits 0 on success, 1 on error, 2 if the requested snapshot is missing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${STATE_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)/state}"

TOPLEVEL="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "error: not inside a git repository" >&2
    exit 1
}
cd "$TOPLEVEL"

# Sanitize a mission label into a ref-safe / path-safe slug.
slug() {
    printf '%s' "$1" | sed 's|[^A-Za-z0-9._-]|_|g'
}

ref_name() {  # <label-slug> <round>
    printf 'refs/goggins/%s/round-%s' "$1" "$2"
}

round_dir() {  # <round>
    printf '%s/rounds/round-%s' "$STATE_DIR" "$1"
}

# A fresh, NON-EXISTENT index path: git refuses a zero-byte index file, so
# `mktemp` (which creates the file) cannot be used directly.
new_index_path() {
    local d
    d="$(mktemp -d)"
    printf '%s/index' "$d"
}

# Build a commit object from the current worktree. Prints the sha.
snapshot_commit() {  # <message>
    local msg="$1" tmp_index tree parent sha
    tmp_index="$(new_index_path)"
    trap 'rm -rf "$(dirname "$tmp_index")"' RETURN
    # Empty base index + `git add -A` => the tree IS the worktree
    # (ignored files excluded, untracked files included).
    GIT_INDEX_FILE="$tmp_index" git add -A
    tree="$(GIT_INDEX_FILE="$tmp_index" git write-tree)"
    if parent="$(git rev-parse --verify --quiet HEAD)"; then
        sha="$(git commit-tree "$tree" -p "$parent" -m "$msg")"
    else
        sha="$(git commit-tree "$tree" -m "$msg")"
    fi
    if [ -z "$sha" ]; then
        echo "error: failed to build snapshot commit" >&2
        return 1
    fi
    printf '%s' "$sha"
}

cmd_save() {
    local label="$1" round="$2" note="${3:-}"
    local sl ref sha dir
    sl="$(slug "$label")"
    ref="$(ref_name "$sl" "$round")"
    sha="$(snapshot_commit "goggins round $round: $label${note:+ — $note}")"
    git update-ref "$ref" "$sha"
    dir="$(round_dir "$round")"
    mkdir -p "$dir"
    printf '%s\n' "$sha" > "$dir/tree.sha"
    echo "snapshot saved: round $round"
    echo "  sha:  $sha"
    echo "  ref:  $ref"
    echo "  file: $dir/tree.sha"
    echo "  size: $(git ls-tree -r --name-only "$sha" | wc -l) files in tree"
}

resolve_sha() {  # <label-slug> <round> -> sha on stdout, exit 2 if missing
    local sl="$1" round="$2" sha
    if sha="$(git rev-parse --verify --quiet "$(ref_name "$sl" "$round")")"; then
        printf '%s' "$sha"
        return 0
    fi
    local f
    f="$(round_dir "$round")/tree.sha"
    if [ -f "$f" ] && sha="$(git rev-parse --verify --quiet "$(cat "$f")^{commit}")"; then
        printf '%s' "$sha"
        return 0
    fi
    return 2
}

cmd_restore() {
    local label="$1" round="$2"
    local sl sha extras
    sl="$(slug "$label")"
    if ! sha="$(resolve_sha "$sl" "$round")"; then
        echo "error: no snapshot for round $round of '$label'" >&2
        echo "       run: snapshot.sh list '$label'" >&2
        exit 2
    fi

    # A rollback must itself be reversible.
    local safety
    safety="$(snapshot_commit "goggins pre-restore ($label, before round $round restore)")"
    git update-ref "$(ref_name "$sl" "pre-restore")" "$safety"
    mkdir -p "$(round_dir "pre-restore")"
    printf '%s\n' "$safety" > "$(round_dir "pre-restore")/tree.sha"

    # Files present now but absent from the target snapshot: restore cannot
    # remove them, so list them for the human.
    local tmp_index
    tmp_index="$(new_index_path)"
    GIT_INDEX_FILE="$tmp_index" git read-tree "$sha"
    GIT_INDEX_FILE="$tmp_index" git add -A
    extras="$(GIT_INDEX_FILE="$tmp_index" git diff --cached --diff-filter=A --name-only "$sha")"
    rm -rf "$(dirname "$tmp_index")"

    git restore --source="$sha" --worktree -- .

    echo "restored worktree to round $round of '$label'"
    echo "  snapshot:      $sha"
    echo "  pre-restore:   $safety  (snapshot.sh restore '$label' pre-restore to undo)"
    if [ -n "$extras" ]; then
        echo "  leftover files created after round $round (NOT deleted — review, then trash-put):"
        while IFS= read -r f; do
            [ -n "$f" ] && echo "    $f"
        done <<< "$extras"
    fi
}

cmd_list() {
    local label="$1" sl found=0
    sl="$(slug "$label")"
    echo "snapshots for '$label':"
    while read -r sha ref; do
        [ -n "$sha" ] || continue
        found=1
        printf '  %-14s %s  %s\n' "${ref##*/}" "${sha:0:12}" \
            "$(git log -1 --format='%ad' --date=format:'%Y-%m-%d %H:%M' "$sha")"
    done < <(git for-each-ref --format='%(objectname) %(refname)' "refs/goggins/$sl" 2>/dev/null)
    if [ "$found" = 0 ]; then
        echo "  (none)"
    fi
}

cmd_diff() {
    local label="$1" a="$2" b="$3" sl sha_a sha_b
    sl="$(slug "$label")"
    sha_a="$(resolve_sha "$sl" "$a")" || { echo "error: no snapshot for round $a" >&2; exit 2; }
    sha_b="$(resolve_sha "$sl" "$b")" || { echo "error: no snapshot for round $b" >&2; exit 2; }
    git diff --stat "$sha_a" "$sha_b"
}

ACTION="${1:-}"
case "$ACTION" in
    save)
        [ $# -ge 3 ] || { echo "usage: snapshot.sh save <mission-label> <round> [note]" >&2; exit 64; }
        cmd_save "$2" "$3" "${4:-}" ;;
    restore)
        [ $# -eq 3 ] || { echo "usage: snapshot.sh restore <mission-label> <round>" >&2; exit 64; }
        cmd_restore "$2" "$3" ;;
    list)
        [ $# -eq 2 ] || { echo "usage: snapshot.sh list <mission-label>" >&2; exit 64; }
        cmd_list "$2" ;;
    diff)
        [ $# -eq 4 ] || { echo "usage: snapshot.sh diff <mission-label> <round-a> <round-b>" >&2; exit 64; }
        cmd_diff "$2" "$3" "$4" ;;
    *)
        echo "usage: snapshot.sh {save|restore|list|diff} <mission-label> …" >&2
        exit 64 ;;
esac
