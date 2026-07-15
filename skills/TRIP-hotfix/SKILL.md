---
name: TRIP-hotfix
description: Urgent fix bypassing full TRIP workflow
disable-model-invocation: true
argument-hint: "what is broken in production?"
---

# Hotfix Mode

You are now in **hotfix mode** - a streamlined workflow for urgent production fixes.

> **Warning**: Only use this for genuine emergencies. For regular bugs, use the full TRIP workflow (`TRIP-1-plan` → `TRIP-2-implement`).

## Your Task

Hotfix: $ARGUMENTS

---

## Step 1: Assess Urgency

Before proceeding, confirm this is a genuine hotfix:

**Use the `AskUserQuestion` tool** to confirm urgency:

- **Question**: "Is this a production-critical issue that cannot wait for the normal TRIP workflow?"
- **Options**: "Yes — critical issue" (security vulnerability, data corruption, service outage, or critical user-facing bug), "No — regular bug" (redirect to `TRIP-1-plan` for proper workflow)

**If "No"**: Redirect to `TRIP-1-plan` for proper workflow.

**If "Yes"**: Proceed with hotfix.

---

## Step 2: Create Hotfix Branch

Branch from the **currently active branch** — the workflow is base-branch agnostic, and Step 8 merges back into whatever branch you started from. Run as ONE command so the steps share a shell:

```bash
BASE_BRANCH="$(git branch --show-current)" \
    && git pull --ff-only \
    && git checkout -b hotfix/[short-description] \
    && git config branch."hotfix/[short-description]".trip-base "$BASE_BRANCH"
```

If the active branch has no upstream, drop the `git pull --ff-only` step instead of ignoring its failure.

---

## Step 3: Minimal Investigation

First, you MUST read ALL THE LINES of @docs/ARCHI.md then explore the codebase and read the files relevant to the issue.

Quickly identify:

1. **Root cause** (1-2 sentences)
2. **Affected files** (list)
3. **Fix approach** (brief)

No formal plan document needed.

---

## Step 4: Implement Fix

- Focus only on the fix - no refactoring, no "while I'm here" improvements
- Minimal changes to resolve the issue
- Follow existing patterns from the codebase

---

## Step 5: Quick Verification

- Manually test the fix
- Run relevant tests only: `[test command] [affected files]`
- Confirm the issue is resolved

---

## Step 6: Version & Changelog

### Version Bump

Increment **patch** version only (x.y.Z+1) in version file.

### Minimal Changelog Entry

Add to top of `docs/2-changelog/changelog_table.md`:

```markdown
| `x.y.z` | W | hotfix: [brief description] |
```

Add to Changelog Summary:

```markdown
- **vX.Y.Z (Hotfix - Week W, DD-MM-YYYY)**:
  - **Issue**: [What was broken]
  - **Fix**: [What was done]
  - **Root Cause**: [Brief explanation]
```

---

## Step 7: Commit

```bash
git add -A && git commit -m "hotfix: [brief description]"
```

---

## Step 8: Merge & Tag

Merge back into the base branch recorded in Step 2. Run as ONE command so the lookup and the merge share a shell:

```bash
BASE_BRANCH="$(git config branch.hotfix/[short-description].trip-base)" \
    && git checkout "$BASE_BRANCH" \
    && git merge --ff-only hotfix/[short-description] \
    && git tag vx.y.z \
    && git branch -d hotfix/[short-description]
```

If the `trip-base` lookup fails (branch created outside this skill), ask the user which branch to merge into. If `--ff-only` fails, the base branch moved during the fix — rebase the hotfix branch onto it, then retry. **Never create a merge commit.**

## Step 8b: Push

**If the user already specified which branch to push**, push that branch directly and skip the question.

Otherwise, list the available branches:

```bash
git branch --format='%(refname:short)'
```

Then **use the `AskUserQuestion` tool** to ask:

- **Question**: "Hotfix vx.y.z is merged and tagged. Which branch should I push?"
- **Options**: One option per branch from the list above — the base branch first, marked "(recommended)" — plus "Not yet" (push manually later). If there are too many branches to list, include the most relevant ones; the user can name another via "Other".

**If a branch is selected**:

```bash
git push origin <selected-branch> && git push --tags
```

---

## Step 9: Post-Hotfix

After the immediate crisis is resolved:

1. **Document**: Create a brief incident report in `docs/6-memo/` if significant
2. **Follow-up**: If deeper fixes are needed, create a proper TRIP plan
3. **Retrospective**: Consider what could prevent similar issues

---

## What This Workflow Skips

Compared to full TRIP:

- No interactive discovery questions
- No formal plan document
- No full code review checklist
- No tutorial generation
- No ARCHI.md update (unless architecture changed)
- No README update (unless relevant)

These are acceptable trade-offs for genuine emergencies only.
