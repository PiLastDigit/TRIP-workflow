---
name: TRIP-3-release
description: Release a completed implementation - version, code review promotion, changelogs, docs, commit, tag, ff-merge, push
argument-hint: "plan file or feature label"
---

# Release Mode

You are now in **release mode** for **[PROJECT_NAME]**.

Release: $ARGUMENTS

This skill runs after `TRIP-2-implement` has converged (implementation done, testing gate green, Codex code review `APPROVED` or explicitly skipped). It is normally chained from TRIP-2 in the same session, but can be invoked standalone in a fresh session.

---

## Prerequisites

- Implementation complete and user-confirmed.
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

All must be green. Also verify the Codex state file exists for the given plan path/label (see Step 3 below); if absent, treat as the skipped-Codex fallback (manual CR) and say so explicitly in the CR.

Any failure blocks the release — fix or return to `TRIP-2-implement` first.

---

## Step 1: Get Current Date/Week

Run this command to get date and project week:

```bash
date '+%d-%m-%Y %H:%M' && python3 -c "from datetime import date; print('Project week:', (date.today() - date.fromisoformat('[WEEK_ANCHOR_DATE]')).days // 7 + 1)"
```

(Week anchor: the Monday of the week TRIP Init was run. Python is used instead of `date -d` because macOS BSD `date` doesn't support it.)

Use the project week in all subsequent steps.

## Step 2: Version Update

- If not already done in the plan phase, propose new SemVer version (x.y.z)
- Update version in `[VERSION_FILE]`
- Do not modify anything else in this file

## Step 3: Promote Code Review

Now that week (`a`) and version (`x.y.z`) are known:

1. Compute state file path:
   ```bash
   STATE_KEY="$(realpath <plan-path> | sed 's|^/||; s|/|__|g')"
   STATE_FILE=".claude/skills/codex-code-review/state/${STATE_KEY}.review.txt"
   ```

2. Content source:
   - **Multi-round loop**: state file has synthesized review + `PROMOTION_READY`. Strip sentinel.
   - **Turn 1 convergence**: state file has full review already.
   - **Skipped Codex**: write CR from `.claude/skills/TRIP-review/cr-template.md` with body "Code review skipped — trivial change." Verdict: `APPROVED with observations`.

3. Replace `<x.y.z>` with actual version. Fill any remaining `<...>` placeholders.

4. Save to `docs/3-code-review/CR_wa_vx.y.z.md`.

5. Verify: no `<...>` placeholders, no `PROMOTION_READY`, version matches version file.

## Step 4: Commit Message

Propose a one-line commit message.

## Step 5: Changelog File

Create `docs/2-changelog/wa_vx.y.z.md` (a=project week, x.y.z=version):

```markdown
# Changelog - Week a, DD-MM-YYYY, V. x.y.z

**Release Date**: Week a, DD-MM-YYYY at HH:MM
**Version**: x.y.z (previously x0.y0.z0)
**Object**: the commit message
**Code review**: `docs/3-code-review/CR_wa_vx.y.z.md` (Codex loop, N rounds -> verdict)

## Changes

[Describe what changed]
```

## Step 6: Changelog Table

Add entry on top of `docs/2-changelog/changelog_table.md`:

```markdown
| `x.y.z` | a | the commit message |
```

Also add a summary entry in the Changelog Summary section.

## Step 7: Architecture Update

1. Read fully @docs/ARCHI-rules.md
2. Update @docs/ARCHI.md following the rules
3. Run `bash .claude/skills/TRIP-compact/count-tokens.sh docs/ARCHI.md` to check token count

**Warning: If ARCHI.md exceeds ~20,000 tokens**, warn the user:

> "ARCHI.md is at ~X tokens. Consider running `TRIP-compact` to reduce it before committing."

<!-- [TUTORIAL_STEP]
### Step 8: Tutorial

Create `docs/5-tuto/tuto_x.y.z.md` explaining the core principle.

**User context for tutorials**:

- Level: [USER_LEVEL]
- Learning focus: [USER_LEARNING_FOCUS]
- Style: [USER_PREFERRED_STYLE]
-->

## Step 8: README Update

Update `README.md` with the new version number.
Also update relevant sections whenever needed.

## Step 9: Documentation Sync

Keep the pre-existing (non-TRIP) documentation aligned with the code:

1. Read the plan's **Documentation Impact** section.
2. Contrast it with the **actual diff** of the release (`git diff [MAIN_BRANCH]...HEAD` or equivalent) — the plan may have fallen short; a doc affected by the real changes must be synced even if the plan didn't list it.
3. Update every affected document. **Factual corrections only**: commands, paths, build targets, script/table entries, cadences, config/env vars, structure trees. It is **forbidden** to touch the voice, tone, or strategic/editorial content of these documents.
4. The updated files are included in the release commit (Step 10) — never a separate commit.

If the plan says "None" and the diff confirms it, skip with a one-line note.

---

After completing all documentation steps, **use the `AskUserQuestion` tool** to ask:

- **Question**: "All documentation steps are complete. Ready to commit?"
- **Options**: "Yes, commit now" (proceed with git commit and tag), "Not yet" (review changes first)

**ONLY after user selects "Yes"**, proceed:

## Step 10: Commit

```bash
git add -A && git commit -m "<commit message from Step 4>"
```

**Important**: Only use the commit message. Do NOT add Co-Authored-By or any other trailer.

## Step 11: Tag

```bash
git tag vx.y.z
```

## Step 12: Merge (fast-forward)

Merge the feature branch back into the main branch, keeping a single clean linear history:

```bash
git checkout [MAIN_BRANCH]
git merge --ff-only <feature-branch>
git branch -d <feature-branch>
```

If `--ff-only` fails, the main branch moved during implementation — rebase the feature branch onto it, then retry. **Never create a merge commit.**

## Step 13: Push

**Use the `AskUserQuestion` tool** to ask:

- **Question**: "Release vx.y.z is committed, tagged, and merged. Push to remote?"
- **Options**: "Yes, push now" (push branch and tags), "Not yet" (push manually later)

**If "Yes"**:

```bash
git push && git push --tags
```
