---
name: TRIP-upgrade
description: Upgrade TRIP workflow skills to a newer version while preserving project customizations
disable-model-invocation: true
argument-hint: "[version, e.g. 2.9.0 | path to a local skills folder]"
metadata:
  trip-version: "2.9.0"
---

# TRIP Upgrade Mode

You are now in **upgrade mode** — merging a newer version of the TRIP workflow into this project's existing, customized TRIP skills.

## The Problem

Each project's TRIP skills have two interleaved layers:
1. **Workflow skeleton** — steps, Codex integration, file structure, process flow
2. **Project customizations** — test commands, checklist sections, version file, technical considerations, guidance sections

A naive copy would destroy layer 2. This skill fetches the **generic template the project was installed from**, computes the project's customizations as a diff against it, and replays that diff onto the new template with a git three-way merge — one command per file, exact, and verifiable. The installed version comes from the `metadata.trip-version` stamp every skill carries since 2.8.1; older installs are first brought to 2.8.4 (see **Unstamped Installs**).

## Prerequisites

Nothing to copy. The skill fetches the TRIP-workflow repository itself and upgrades to its **latest release** by default.

`$ARGUMENTS`, optional:
- a **version** (`2.9.0` or `v2.9.0`) pins the target release instead of the latest;
- a **path** to a local `skills/` folder (a fork, an offline copy) is used as the target source instead of fetching. The base template still comes from the clone.

---

## Phase 1: Inventory

### 1.1 Fetch the Latest Release

One clone serves the whole upgrade — it provides the new skills now and the base template in Phase 2:

```bash
TRIP_SRC=$(mktemp -d)
git clone -q --no-checkout https://github.com/PiLastDigit/TRIP-workflow "$TRIP_SRC"
TARGET=$(git -C "$TRIP_SRC" tag --list 'v*' --sort=-v:refname | head -1)   # or v$ARGUMENTS when a version was given
S=$(mktemp -d); git -C "$TRIP_SRC" archive "$TARGET" skills | tar -x -C "$S" --strip-components=1
```

`$S` is the **target** source for the rest of this skill. If a path was passed instead, `S=<that path>` and skip the archive. If the clone fails (offline, no access), tell the user and stop.

### 1.2 Detect Versions

```bash
# Installed (one line per distinct version; more than one line = a mixed install)
grep -h "^  trip-version" .claude/skills/*/SKILL.md | sort | uniq -c

# Target
grep -h "^  trip-version" "$S"/*/SKILL.md | sort -u
```

- **Stamp present**: report `installed X → target Y`. If X equals Y, tell the user the project is already on the latest release and stop; remove `$TRIP_SRC` and `$S`.
- **No stamp** (installed before 2.8.1): go to **Unstamped Installs**, then come back here.
- **Mixed versions**: list the outliers; they are usually skills skipped in a previous upgrade and are merged like any other.

### 1.3 Present Inventory

Compare every skill folder present on either side (`diff -rq -x state .claude/skills/<skill>/ "$S"/<skill>/`), and check which entries of **Structural Changes** apply to this install. Then show the version line and one row per skill:

```
TRIP 2.8.4 → 2.9.0 (installed version read from metadata.trip-version)

Skill                 | Status            | Action
--------------------- | ----------------- | ------
TRIP-1-plan           | Updated           | Merge
TRIP-3-release        | Updated           | Merge
codex-code-review     | Updated           | Merge; receives checklist.md + cr-template.md from TRIP-review/
TRIP-review           | Removed in 2.9.0  | Delete once its files have moved
TRIP-test             | Removed in 2.9.0  | Content moves to docs/4-unit-tests/TESTING.md, then delete
TRIP-compact          | Unchanged         | Skip
my-own-skill          | Project only      | Leave in place
```

`AskUserQuestion`: "Here's the upgrade plan. Proceed?"
Options: "Yes, start upgrade" (recommended) / "Let me review the new files first" / "Abort"

---

## Phase 2: Obtain the Base Template

The merge needs the **generic skills of the installed version** (the "base"). The project only holds its customized copy, so take them from the clone:

```bash
BASE=$(mktemp -d)
git -C "$TRIP_SRC" archive "v$INSTALLED_VERSION" skills | tar -x -C "$BASE" --strip-components=1
```

Report: "Base template v2.8.4 fetched. Upgrading v2.8.4 → v2.9.0."

---

## Phase 3: Three-Way Merge

For **every file in `$S`**, state folders excluded, decide by presence:

| Installed | Base | Action |
|---|---|---|
| yes | yes | `git merge-file -p installed base staged` → merged file |
| yes | no | file is new upstream but the project also has one: merge with an empty base |
| no | — | copy staged |
| (installed only) | — | leave in place, unless **Structural Changes** retires it |

A file that moved between skills is looked up under its old path on the installed and base sides — `old_path` below lists the moves (**Structural Changes** explains them).

Build everything in a scratch directory first; nothing under `.claude/skills/` changes until Phase 4 passes.

```bash
MERGED=$(mktemp -d); I=.claude/skills   # $S = target source from Phase 1.1
old_path() { case "$1" in
  codex-code-review/checklist.md|codex-code-review/cr-template.md) echo "TRIP-review/${1#codex-code-review/}" ;;
  *) echo "$1" ;; esac; }
( cd "$S" && find . -type f -not -path '*/state/*' ) | sed 's|^\./||' | while read -r f; do
  mkdir -p "$MERGED/$(dirname "$f")"
  i="$I/$f";    [ -f "$i" ] || i="$I/$(old_path "$f")"
  b="$BASE/$f"; [ -f "$b" ] || b="$BASE/$(old_path "$f")"; [ -f "$b" ] || b=/dev/null
  if [ -f "$i" ]; then
    git merge-file -p -L installed -L base -L staged "$i" "$b" "$S/$f" > "$MERGED/$f" || echo "CONFLICT $f"
  else
    cp "$S/$f" "$MERGED/$f"
  fi
done
grep -rl '^<<<<<<< ' "$MERGED" || echo "no conflicts"
```

**Conflicts** happen only where a workflow change and a customization touch the same lines. Open the marked region, keep the new workflow text and re-apply the project's intent inside it, remove the markers. Never resolve by taking one side wholesale — except where **Structural Changes** says a customization is retired.

---

## Phase 4: Review and Validate

### 4.1 Prove the Merge

Two diffs per merged file, both must be short and readable:

```bash
# what the project customized — must contain ONLY project-specific content
diff "$S/$f" "$MERGED/$f"
# what the upgrade changes — must contain ONLY workflow changes (and the new frontmatter)
diff "$I/$f" "$MERGED/$f"
```

Read both for every customized file (`TRIP-1-plan`, `TRIP-2-implement`, `TRIP-3-release`, `codex-code-review/checklist.md`, `codex-code-review/cr-template.md`) and for any other file whose first diff is not empty — a project sometimes tweaks a "pure" skill by a line, and the merge carries that over. A customization appearing in the second diff as a removal, or workflow text appearing in the first diff, means the merge went wrong for that file — fix it before continuing.

### 4.2 Placeholder Check

```bash
grep -rn --exclude-dir=TRIP-init --exclude-dir=TRIP-upgrade '\[ADAPT_TO_PROJECT\|\[PROJECT_NAME\]\|\[VERSION_FILE\]\|\[TEST_COMMAND\]\|\[LINT_COMMAND\]\|\[TYPECHECK_COMMAND\]\|\[MAIN_BRANCH\]' "$MERGED"/TRIP-*/ "$MERGED"/codex-code-review/*.md
```

`TRIP-init` and `TRIP-upgrade` mention every placeholder by name in their own instructions, so they are excluded. If any are found, fill them from context or ask the user.

### 4.3 Cross-Reference Check

- `codex-code-review/checklist.md` section names must match the checklist section names in `codex-code-review/cr-template.md`.
- No skill points at a retired location any more: `grep -rln --exclude-dir=TRIP-upgrade 'TRIP-review/\|TRIP-test' "$MERGED"` returns nothing.
- `TRIP-1-plan` references `codex-plan-review/scripts/start.sh` and `resume.sh`; `TRIP-2-implement` and `TRIP-research` invoke each skill's own wrapper scripts — confirm `codex-implement`, `codex-code-review`, and `codex-ask` each ship `scripts/{start,resume,reset,show}.sh` (they pin `STATE_DIR` and delegate to `codex-plan-review`), and that `codex-plan-review/scripts/key.sh` exists.

### 4.4 Present Summary

Show what changed:

```
Upgrade ready:
- New skills added: [list]
- Skills updated: [list]
- Skills unchanged: [list]
- Structural changes to apply: [list]
- Project customizations preserved: [list key ones]
```

Run the version-stamp check from **Frontmatter and Version Stamp** on `$MERGED`.

`AskUserQuestion`: "Merge verified. Apply to .claude/skills/?"
Options: "Apply" (recommended) / "Show me the diffs first" / "Abort"

If "Show me the diffs first": present the Phase 4.1 diffs. If "Abort": remove the scratch directories, nothing was changed.

---

## Phase 5: Apply and Clean Up

```bash
# copy merged files over the install; state/ folders are never touched
rsync -a --exclude 'state/' "$MERGED"/ .claude/skills/
```

Then apply the post-merge steps of every **Structural Changes** entry that concerns this install, remove the scratch directories (`$TRIP_SRC`, `$S` unless it is a user-supplied path, `$BASE`, `$MERGED` — use `trash-put` where available, otherwise `rm -r`), and confirm the stamp once more on the live install:

```bash
grep -h "^  trip-version" .claude/skills/*/SKILL.md | sort | uniq -c
```

Report:
> "TRIP workflow upgraded vX → vY. N files merged, M copied, 0 conflicts. `git diff .claude/skills/ docs/` shows the change before you commit."

---

## Structural Changes

Changes a file merge cannot express on its own. Apply every entry newer than the installed version.

### 2.9.0 — `TRIP-review` and `TRIP-test` removed

- `checklist.md` and `cr-template.md` moved from `TRIP-review/` to `codex-code-review/`; Phase 3 merges them from their old path. After applying, delete `TRIP-review/` — its `SKILL.md` was the on-demand manual review, which no longer exists.
- `TRIP-test/SKILL.md` holds the project's test commands, test structure and testing priorities. Before deleting the folder, move whatever `docs/4-unit-tests/TESTING.md` does not already say into it, under "Running Tests", "Test Organization" and "Testing Priorities" (create the file if missing). Then delete `TRIP-test/`.
- Project text can still point at the retired skills, e.g. a checklist line saying "see `TRIP-test`". Repoint it at `docs/4-unit-tests/TESTING.md` (or the code review checklist for `TRIP-review`); the Phase 4.3 cross-reference check lists every occurrence.

### 2.9.0 — week numbers and changelog summary removed

- `TRIP-3-release` Step 1 no longer computes a project week; the project's week anchor date conflicts with that change. Take the new Step 1.
- In `docs/2-changelog/changelog_table.md`, drop the Week column (header, separator, and the second cell of every row) so the new two-column rows fit. Leave any `# Changelog Summary` section below the table as it is — older hotfix entries only exist there — new releases no longer add to it.
- Existing `wN_vx.y.z.md` changelogs and `CR_wN_vx.y.z.md` reviews keep their names. New ones are `vx.y.z.md` and `CR_vx.y.z.md`.

### 2.9.0 — tutorial step removed

Projects that had tutorials enabled get a conflict on that step of `TRIP-3-release`. Drop the Tutorial step and keep the new template's step numbering. Leave any existing `docs/5-tuto/` folder in place — it is project content.

---

## Unstamped Installs (before 2.8.1)

Merging needs the base template, and an install without a stamp cannot name it. Bring it to 2.8.4 first — the last release that rebuilds customized skills by hand — then merge from there:

1. Read v2.8.4's upgrade skill from the clone: `git -C "$TRIP_SRC" show v2.8.4:skills/TRIP-upgrade/SKILL.md`.
2. Follow it with target `v2.8.4` (it accepts a version argument), reusing the same clone. It rebuilds the customized skills and stamps every skill `2.8.4`.
3. Come back to Phase 1.2 here. The install now reports 2.8.4, and this skill merges it to the latest release.

---

## Frontmatter and Version Stamp

The YAML frontmatter of every merged `SKILL.md` (`name`, `description`, `argument-hint`, `disable-model-invocation`, `metadata.trip-version`) is **pure workflow**: take it verbatim from the target file, never from the installed copy. After the merge, verify every skill reports the target version:

```bash
grep -h "^  trip-version" .claude/skills/*/SKILL.md | sort | uniq -c
```

Exactly one line must come back, matching the target version. Any other line means a skill was skipped, merged from the old frontmatter, or is a retired skill that was not deleted — fix it before reporting completion.

---

## Edge Cases

### Installed TRIP-upgrade predates 2.8.4 (or does not exist — v1 installs)
The user copied this skill's folder over `.claude/skills/TRIP-upgrade/` by hand to bootstrap. That is expected: run normally. The old skill (if any) used a `new-TRIP/` staging folder — if one is present, remove it in Phase 5.

### Project has extra custom skills not in the new workflow
These are "Project only" in the inventory — leave them in place. Never delete skills that exist only in the installed version, except those **Structural Changes** retires.

---

## Notes for the Agent

- **Read before writing.** Read every file you plan to modify. Never write from memory alone.
- **Preserve semantics, not bytes.** If the old checklist had 10 custom sections, they all need to survive, even if their numbering changes.
- **When in doubt, ask.** If a conflict or a moved customization has no obvious home, show the user the relevant section and ask what to keep.
- **Atomic application.** Build all merged content in `$MERGED` before touching `.claude/skills/`. If something goes wrong mid-merge, the installed skills are still intact.
- **Never remove-and-copy a skill folder.** Codex `state/` directories live inside the skill folders and hold every past review thread. Copy over; the only folders this skill deletes are those **Structural Changes** retires.
- **Never delete user-created files.** If the project has extra files in a skill directory (like project-specific fixtures or notes), leave them alone.
