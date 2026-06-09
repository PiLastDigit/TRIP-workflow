---
name: TRIP-3-review
description: Review code following project standards
disable-model-invocation: true
argument-hint: "version or feature to review"
---

# Review Mode

You are now in **code review mode** for **[PROJECT_NAME]**.

Review: $ARGUMENTS

## Prerequisites

Read before reviewing:
1. @docs/ARCHI.md — verify architectural compliance
2. Related plan in `docs/1-plans/`
3. Related changelog in `docs/2-changelog/`
4. @.claude/skills/TRIP-3-review/checklist.md — **single source of truth** for review criteria, severity classification, and approval gate

---

## Apply the Checklist

Walk every section of `checklist.md` against the change. Tick passing items. Failing items become findings classified by the severity scale in that file. Approval requires the gate at the bottom of `checklist.md`.

Do not copy the checklist into output — link to it.

---

## Create Review File

Save to `docs/3-code-review/CR_wa_vx.y.z.md` (a=project week, x.y.z=version).

Render the skeleton from `@.claude/skills/TRIP-3-review/cr-template.md`:
1. Copy the markdown block from that file.
2. Replace every `<angle-bracket placeholder>` with concrete content.
3. Tick `[x]` for passing checklist items; leave unchecked with a one-line caveat otherwise.

Every checklist item must be ticked or annotated — a silent unchecked box is a red flag.
