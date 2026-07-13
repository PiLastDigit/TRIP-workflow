# Code Review Output Template

This file is the **single source of truth** for the markdown skeleton of a code review record. Both review surfaces produce output that conforms to this skeleton:

- The human-driven `/TRIP-review` flow renders this skeleton into `docs/3-code-review/CR_wa_vx.y.z.md` as the final committed review.
- The Codex iteration loop's `synthesize.tpl` step renders the same skeleton, which the requester then promotes to the same path.

Anything review-surface-specific (file naming, save location, iteration-loop sentinels, "where do findings come from") lives in the consuming SKILL.md / prompt, **not here**.

Angle-bracket placeholders (`<like this>`) are filling-in instructions for the reviewer and must be replaced with concrete content before the file is committed.

---

```markdown
# Code Review: <feature or change name>

**Review Date**: <YYYY-MM-DD>
**Version**: <x.y.z>
**Files Reviewed**: <bullet list of paths from the change set>
**Plan**: <plan path under `docs/1-plans/`, or "no plan — unplanned change">

---

## Executive Summary

<1-3 sentences: what was changed and why. End with the verdict line: APPROVED / APPROVED with observations / NEEDS REVISION>

---

## Changes Overview

<2-4 sentences: scope of the change, key files, key behavior introduced>

---

## Findings

### Critical Issues

<For each Critical finding: short title, file:line, description, and disposition (addressed / accepted with override / open). If none, write "None.">

### Major Issues

<Same format as Critical. If none, write "None.">

### Minor Issues

<Same format. If none, write "None.">

### Suggestions

<Same format. Items not addressed are fine here — they're suggestions. If none, write "None.">

---

## Checklist

State each section's outcome (passed / passed with caveats / not applicable). One line per section, no expanded prose unless a caveat needs explanation. The section names match the criteria headings in `.claude/skills/TRIP-review/checklist.md` so a reader can cross-reference what was checked.

- [ ] 1. Functional Requirements — <outcome>
- [ ] 2. Code Quality — <outcome>
- [ ] 3. Architectural Compliance — <outcome>
- [ ] 4. Error Handling — <outcome>
- [ ] 5. Security — <outcome>
- [ ] 6. Performance — <outcome>

Tick the box (`[x]`) for sections that passed cleanly. Leave unchecked with a one-line caveat for sections with open observations.

---

## Verdict

**<APPROVED / APPROVED with observations / NEEDS REVISION>**

<Final paragraph: anything a future reader should know — overrides applied, open findings the requester accepted, follow-up work deferred, etc.>
```
