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
- Add explanatory comments but avoid over-commenting obvious code
- Strike the right balance between readability and maintainability
- Follow existing patterns from the codebase

---

## Implementation Phase

Proceed with the implementation following the plan or the task description.

---

## Post-Implementation Checklist

After completing the implementation:

- Cross the corresponding checkboxes in the plan todo list (if any)
- Then **use the `AskUserQuestion` tool** to ask:
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

### Step 3: Commit Message

Propose a one-line commit message.

### Step 4: Changelog File

Create `docs/2-changelog/wa_vx.y.z.md` (a=project week, x.y.z=version):

```markdown
# Changelog - Week a, DD-MM-YYYY, V. x.y.z

**Release Date**: Week a, DD-MM-YYYY at HH:MM
**Version**: x.y.z (previously x0.y0.z0)
**Object**: the commit message

## Changes

[Describe what changed]
```

### Step 5: Changelog Table

Add entry on top of `docs/2-changelog/changelog_table.md`:

```markdown
| `x.y.z` | a | the commit message |
```

Also add a summary entry in the Changelog Summary section.

### Step 6: Architecture Update

1. Read fully @docs/ARCHI-rules.md
2. Update @docs/ARCHI.md following the rules
3. Run `bash .claude/skills/TRIP-compact/count-tokens.sh docs/ARCHI.md` to check token count

<!-- [TUTORIAL_STEP]
### Step 7: Tutorial

Create `docs/5-tuto/tuto_x.y.z.md` explaining the core principle.

**User context for tutorials**:

- Level: [USER_LEVEL]
- Learning focus: [USER_LEARNING_FOCUS]
- Style: [USER_PREFERRED_STYLE]
-->

### Step 7: README Update

Update `README.md` with the new version number.
Also update relevant sections whenever needed.

---

**Warning: If ARCHI.md exceeds ~20,000 tokens**, warn the user:

> "ARCHI.md is at ~X tokens. Consider running `TRIP-compact` to reduce it before committing."

After completing all documentation steps, **use the `AskUserQuestion` tool** to ask:

- **Question**: "All documentation steps are complete. Ready to commit?"
- **Options**: "Yes, commit now" (proceed with git commit and tag), "Not yet" (review changes first)

**ONLY after user selects "Yes"**, proceed:

### Step 8: Commit

```bash
git add -A && git commit -m "<commit message from Step 3>"
```

**Important**: Only use the commit message. Do NOT add Co-Authored-By or any other trailer.

### Step 9: Tag

```bash
git tag vx.y.z
```
