---
name: TRIP-2-implement
description: Implement a feature following TRIP plan
argument-hint: "plan file or feature to implement"
---

# Implementation Mode

You are now in **implementation mode** for **[PROJECT_NAME]**.

## Prerequisites - Read First

Before implementing, you MUST read ALL THE LINES of:

1. @docs/ARCHI.md - Understand current system architecture

## Your Task

Implement: $ARGUMENTS

---

## Step 0: Branch Evaluation (Pre-Implementation)

After reading ARCHI.md, evaluate if this implementation warrants a dedicated branch.

### When to Suggest a Branch

Consider a dedicated branch if the task involves:

- Multiple files across different modules
- Changes that could break existing functionality
- Features that might need review before merging
- Work that spans multiple sessions
- Experimental or risky changes

### Ask the User

**Use the `AskUserQuestion` tool** to ask:

- **Question**: "This implementation involves [brief scope assessment]. Would you like me to create a dedicated branch?"
- **Options**:
  1. **"Yes, create branch"** — Suggested name: `feat/[short-description]` or `fix/[short-description]`
  2. **"No, stay on current branch"** — Continue on the current branch

### If YES

```bash
git checkout -b [branch-name]
```

Confirm branch creation before proceeding.

### If NO

Continue on the current branch.

---

## Implementation Rules

- Apply **DRY** and **KISS** principles
- Follow existing patterns from the codebase
- Add comments only for non-obvious logic

---

## Implementation Phase

Proceed with the implementation following the plan or the task description. Cross corresponding checkboxes in the plan to-do list as you go.

---

## Codex Code Review

After implementation, before user sign-off, run the Codex code review loop.

### Pre-step: Run Tests

Codex can't execute tests. Run them and pass the summary:

```bash
# [ADAPT_TO_PROJECT: Replace with actual lint/type-check/test commands during Init]
[LINT_COMMAND] 2>&1 | tee /tmp/_trip2-lint.txt
[TYPECHECK_COMMAND] 2>&1 | tee /tmp/_trip2-typecheck.txt
[TEST_COMMAND] 2>&1 | tee /tmp/_trip2-test.txt
```

Fix failures before starting the loop. Format summary: `lint: clean | typecheck: clean | tests: N passed, 0 failed, M skipped`

### Confirm

`AskUserQuestion`: "Implementation looks done. Run Codex code review against the plan?"
Options: "Yes, run Codex review" (recommended) / "Skip Codex" / "Cap iterations at N"

### Loop

Always export before invoking shared scripts:

```bash
export STATE_DIR=".claude/skills/codex-code-review/state"
```

1. **Start**:
   ```bash
   bash .claude/skills/codex-plan-review/scripts/start.sh \
       --prompt-file .claude/skills/codex-code-review/prompts/start.tpl \
       <plan-path> "$TEST_SUMMARY"
   ```
   For unplanned work (no `F_*.plan.md`), pass a free-form label instead of a plan path.

2. **Parse trailing tag**: `APPROVED` -> synthesize. `NEEDS_REWORK` -> surface to user. `REQUEST_CHANGES` -> continue.

3. **Address findings** — quote each with `file:line`, read the actual code, fix legitimate ones, push back on incorrect ones. Critical/Major block approval; Minor/Suggestion are case-by-case.

4. **Write implementer notes** (1-3 sentences): which findings you fixed, which you pushed back on and why, any user decisions or environment limitations Codex should stop re-flagging.

5. **Resume** (re-run tests first, build fresh summary):
   ```bash
   bash .claude/skills/codex-plan-review/scripts/resume.sh \
       --prompt-file .claude/skills/codex-code-review/prompts/resume.tpl \
       --notes "Fixed X. Pushed back on Y because Z." \
       <plan-path> "$TEST_SUMMARY"
   ```
   Loop to step 2.

6. **Cap at 5 rounds** (or user-specified). Surface remaining findings.

### Synthesize

Skip if loop converged on Turn 1 (state file already holds full review).

Turn-N state files hold only that turn's delta. After multi-round convergence, produce a consolidated review:

```bash
bash .claude/skills/codex-plan-review/scripts/resume.sh \
    --prompt-file .claude/skills/codex-code-review/prompts/synthesize.tpl \
    <plan-path> "Today's date is YYYY-MM-DD"
```

Outputs `PROMOTION_READY` sentinel. `<x.y.z>` Version placeholder left unfilled (resolved in Step 2 below).

Edge cases:
- **Capped without APPROVED**: still synthesize; Codex notes open findings.
- **User skipped Codex**: no synthesis. Write CR manually: "Code review skipped — trivial change."

### Operating Notes

Surface reviews verbatim. Keep edits scoped. If Codex repeats a finding, re-read carefully — you likely addressed an adjacent concern. Reset thread only if context is confused. Tests must pass before APPROVED.

---

## Post-Implementation

After Codex converges (or is skipped):

**Use the `AskUserQuestion` tool** to ask:
- **Question**: "Is the implementation complete?"
- **Options**: "Yes, everything is complete" (proceed to post-implementation steps), "No, there are remaining items" (continue working)

**ONLY after user selects "Yes"**, proceed with these steps:

### Step 1: Get Current Date/Week

Run this command to get date and project week:

```bash
date '+%d-%m-%Y %H:%M' && echo "Project week: $(( ( $(date +%s) - $(date -d '[WEEK_ANCHOR_DATE]' +%s) ) / 604800 + 1 ))"
```

Use the project week in all subsequent steps.

### Step 2: Version Update

- If not already done in the plan phase, propose new SemVer version (x.y.z)
- Update version in `[VERSION_FILE]`
- Do not modify anything else in this file

### Step 3: Promote Code Review

Now that week (`a`) and version (`x.y.z`) are known:

1. Compute state file path:
   ```bash
   STATE_KEY="$(realpath <plan-path> | sed 's|^/||; s|/|__|g')"
   STATE_FILE=".claude/skills/codex-code-review/state/${STATE_KEY}.review.txt"
   ```

2. Content source:
   - **Multi-round loop**: state file has synthesized review + `PROMOTION_READY`. Strip sentinel.
   - **Turn 1 convergence**: state file has full review already.
   - **Skipped Codex**: write CR from `.claude/skills/TRIP-3-review/cr-template.md` with body "Code review skipped — trivial change." Verdict: `APPROVED with observations`.

3. Replace `<x.y.z>` with actual version. Fill any remaining `<...>` placeholders.

4. Save to `docs/3-code-review/CR_wa_vx.y.z.md`.

5. Verify: no `<...>` placeholders, no `PROMOTION_READY`, version matches version file.

### Step 4: Commit Message

Propose a one-line commit message.

### Step 5: Changelog File

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

### Step 6: Changelog Table

Add entry on top of `docs/2-changelog/changelog_table.md`:

```markdown
| `x.y.z` | a | the commit message |
```

Also add a summary entry in the Changelog Summary section.

### Step 7: Architecture Update

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

### Step 8: README Update

Update `README.md` with the new version number.
Also update relevant sections whenever needed.

---

After completing all documentation steps, **use the `AskUserQuestion` tool** to ask:

- **Question**: "All documentation steps are complete. Ready to commit?"
- **Options**: "Yes, commit now" (proceed with git commit and tag), "Not yet" (review changes first)

**ONLY after user selects "Yes"**, proceed:

### Step 9: Commit

```bash
git add -A && git commit -m "<commit message from Step 4>"
```

**Important**: Only use the commit message. Do NOT add Co-Authored-By or any other trailer.

### Step 10: Tag

```bash
git tag vx.y.z
```
