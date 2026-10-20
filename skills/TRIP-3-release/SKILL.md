---
name: TRIP-3-release
description: Release a completed implementation - version, code review promotion, changelogs, docs, commit, tag, ff-merge, push
argument-hint: "plan file or feature label"
metadata:
  trip-version: "2.9.0"
---

# Release Mode

You are now in **release mode** for **[PROJECT_NAME]**.

Release: $ARGUMENTS

This skill runs after `TRIP-2-implement` has converged (implementation done, testing gate green, Codex code review `APPROVED` or explicitly skipped). It is normally chained from TRIP-2 in the same session, but can be invoked standalone in a fresh session.

---

## Prerequisites

- Implementation complete: every plan to-do checked or explicitly deferred.
- Testing gate green: affected unit tests pass.
- Codex code review converged (`APPROVED`), or explicitly skipped by the user.
- Lint and type-check/build green.

### Standalone verification (fresh session, not chained from TRIP-2)

If this skill was NOT chained from a TRIP-2 session in the current conversation, verify before any release step:

```bash
# [ADAPT_TO_PROJECT: Replace with actual lint/type-check/test commands during Init]
[LINT_COMMAND]
[TYPECHECK_COMMAND]
[TEST_COMMAND] <pattern-from-the-plan's-Test-Impact-section>
```

All must be green. Also verify the Codex state file exists for the given plan path/label (see Step 2 below); if absent, treat as the skipped-Codex fallback (manual CR) and say so explicitly in the CR.

Any failure blocks the release — fix or return to `TRIP-2-implement` first.

---

## Step 1: Date, Version, Commit Message

```bash
date '+%d-%m-%Y %H:%M'
```

- If not already done in the plan phase, propose the new SemVer version (x.y.z) and update it in `[VERSION_FILE]`. Do not modify anything else in that file.
- Write the one-line commit message. It is reused as the changelog's Object, the changelog table row, and the commit itself.

## Step 2: Promote Code Review

Now that the version (`x.y.z`) is known:

1. Compute state file path (derive the key via `key.sh` so it matches what the review scripts actually wrote — never re-derive it inline):
   ```bash
   STATE_KEY="$(bash .claude/skills/codex-plan-review/scripts/key.sh <plan-path>)"
   STATE_FILE=".claude/skills/codex-code-review/state/${STATE_KEY}.review.txt"
   ```

2. Content source:
   - **Multi-round loop**: state file has synthesized review + `PROMOTION_READY`. Strip sentinel.
   - **Turn 1 convergence**: state file has full review already.
   - **Skipped Codex**: write CR from `.claude/skills/codex-code-review/cr-template.md` with body "Code review skipped — trivial change." Verdict: `APPROVED with observations`.

3. Replace `<x.y.z>` with actual version. Fill any remaining `<...>` placeholders.

4. Save to `docs/3-code-review/CR_vx.y.z.md`.

5. Verify: no `<...>` placeholders, no `PROMOTION_READY`, version matches version file.

## Step 3: Changelog

1. Create `docs/2-changelog/vx.y.z.md`:

   ```markdown
   # Changelog vx.y.z (DD-MM-YYYY)

   **Release Date**: DD-MM-YYYY at HH:MM
   **Version**: x.y.z (previously x0.y0.z0)
   **Object**: the commit message
   **Code review**: `docs/3-code-review/CR_vx.y.z.md` (Codex loop, N rounds -> verdict)

   ## Changes

   [Describe what changed]
   ```

2. Add a row at the top of the table in `docs/2-changelog/changelog_table.md`:

   ```markdown
   | `x.y.z` | the commit message |
   ```

## Step 4: Architecture Update

1. Read fully @docs/ARCHI-rules.md
2. Update @docs/ARCHI.md following the rules
3. Run `bash .claude/skills/TRIP-compact/count-tokens.sh docs/ARCHI.md` to check token count

**Warning: If ARCHI.md exceeds ~20,000 tokens**, warn the user:

> "ARCHI.md is at ~X tokens. Consider running `TRIP-compact` to reduce it before committing."

## Step 5: Documentation Sync

Keep the pre-existing (non-TRIP) documentation aligned with the code:

1. If `README.md` shows the project version, bump it to x.y.z.
2. Read the plan's **Documentation Impact** section.
3. Contrast it with the **actual diff** of the release (`git diff [MAIN_BRANCH]...HEAD` or equivalent) — the plan may have fallen short; a doc affected by the real changes must be synced even if the plan didn't list it.
4. Update every affected document. **Factual corrections only**: commands, paths, build targets, script/table entries, cadences, config/env vars, structure trees. It is **forbidden** to touch the voice, tone, or strategic/editorial content of these documents.
5. The updated files are included in the release commit (Step 6) — never a separate commit.

If the plan says "None" and the diff confirms it, skip with a one-line note.

Then continue straight to the commit — no confirmation. Everything up to the merge stays local and reversible; the push (Step 9) is the release's only question.

## Step 6: Commit

```bash
git add -A && git commit -m "<commit message from Step 1>"
```

**Important**: Only use the commit message. Do NOT add Co-Authored-By or any other trailer.

## Step 7: Tag

```bash
git tag vx.y.z
```

## Step 8: Merge (fast-forward)

Merge the feature branch back into the main branch, keeping a single clean linear history:

```bash
git checkout [MAIN_BRANCH]
git merge --ff-only <feature-branch>
git branch -d <feature-branch>
```

If `--ff-only` fails, the main branch moved during implementation — rebase the feature branch onto it, then retry. **Never create a merge commit.**

## Step 9: Push

**Use the `AskUserQuestion` tool** to ask:

- **Question**: "Release vx.y.z is committed, tagged, and merged. Push to remote?"
- **Options**: "Yes, push now" (push branch and tags), "Not yet" (push manually later)

**If "Yes"**:

```bash
git push && git push --tags
```
