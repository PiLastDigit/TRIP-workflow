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

## Step 0: Create a Branch (Pre-Implementation)

**Always** create a dedicated branch before implementing — no need to ask. `TRIP-3-release` merges it back into the main branch with fast-forward, keeping a single clean linear history.

```bash
git checkout -b feat/[short-description]   # or fix/[short-description]
```

Derive the short description from the plan/feature name. If already on a dedicated branch for this work (e.g., resuming a session), continue on it.

---

## Implementation Phase — Delegate to Codex

You do NOT write the implementation yourself — delegate it to Codex via the `codex-implement` skill. (Exception: trivial unplanned changes of a few lines may be done directly.)

Delegation is **batched**: Codex implements a few of the plan's checkboxes per turn, you review and fix each batch, then request the next one with your corrections attached. Same persistent thread throughout — context and conventions compound across turns.

### 1. Read the plan and decide the batches

Read the plan fully and split its to-dos into batches. You are the judge of batch size:

- A batch is the **smallest set of checkboxes that leaves the tree green** (compiles, lints). Never split an interface from its implementation and wiring.
- Target a reviewable diff — roughly ≤300 changed lines per batch. A checkbox that alone exceeds this becomes its own batch.
- Size by risk: novel, architectural, or security-critical work → small batches (down to one checkbox). Mechanical, repetitive work → larger batches.
- Never span phase boundaries.
- **One-shot escape hatch**: a low-risk plan (or phase) of ≤3-4 checkboxes is delegated whole — no batching ceremony.
- **Filter out non-Codex items**: checkboxes needing human input, dashboard/console access, credentials, or ops actions are yours — resolve them with the user before or between batches, never delegate them.

### 2. Delegate batch by batch

**Start** the session with the first batch (state dir is handled by the script):

```bash
bash .claude/skills/codex-implement/scripts/start.sh \
    --prompt-file .claude/skills/codex-implement/prompts/implement.tpl \
    <plan-path> "Implement only: <batch-1 checkboxes>"   # or omit instructions to one-shot a small plan
```

**Each next batch resumes the same thread**, carrying your review corrections as `--notes`:

```bash
export STATE_DIR=".claude/skills/codex-implement/state"
bash .claude/skills/codex-plan-review/scripts/resume.sh \
    --prompt-file .claude/skills/codex-implement/prompts/continue.tpl \
    --notes "<what you fixed after the last batch and why; conventions to apply from now on>" \
    <plan-path> "Now implement: <next batch checkboxes>"
```

**Parse the trailing tag** of each report:
- `IMPLEMENTATION_COMPLETE` → review the batch (below).
- `IMPLEMENTATION_PARTIAL` → read the report; resume with instructions for the remainder, or finish small leftovers yourself during the batch review.

### 3. Review each batch (delta review)

After each Codex report, before requesting the next batch:

1. **Review the delta only**: `git status -s && git diff` — worktree vs index shows just this batch, since previous batches are staged (step 4). Check it against the plan, ARCHI.md patterns, and project conventions (DRY, KISS, comment discipline, error-handling and naming conventions from ARCHI.md).
2. **Fix problems directly yourself** — no back-and-forth with Codex over fixes. What you fixed and why becomes the `--notes` of the next resume.
3. **Micro-gate**: run the lint and typecheck/build commands from the Testing Gate (fast checks only — tests wait for the gate itself). Fix failures now.
4. **Checkpoint**: `git add -A` — stage the reviewed batch so the next delta review starts clean. No commits — history stays clean for release.
5. Verify the plan checkboxes Codex ticked match what the diff actually contains; cross any it completed but missed.

**Adapt as you go**: clean batch → grow the next one; heavy corrections → shrink the next one and spell out the fix pattern in the notes. If Codex ignores notes or repeats corrected mistakes late in a long session, reset the thread at the next batch boundary — the plan file plus a summary note rebuilds context.

### 4. Final pass

After the last batch, read the **full feature diff** once (`git diff HEAD`). Batch reviews catch local issues; this pass catches cross-batch drift — duplicated helpers, divergent naming, dead code left by course corrections. Fix directly.

The testing gate and Codex code review run **once**, after the final pass — never per batch. Proceed to the testing gate once you consider the implementation good for review.

---

## Testing Gate

After implementation, before the Codex review loop. Any failure here blocks the loop from starting.

### 1. Lint, type-check & build

```bash
# [ADAPT_TO_PROJECT: Replace with actual lint/type-check/build commands during Init]
[LINT_COMMAND] 2>&1 | tee /tmp/_trip2-lint.txt
[TYPECHECK_COMMAND] 2>&1 | tee /tmp/_trip2-typecheck.txt
```

### 2. Run affected unit tests

```bash
[TEST_COMMAND] <pattern-for-affected-files>
```

Only the files/areas the change touched — never the full suite by default.

### 3. Integration impact check

<!-- [ADAPT_TO_PROJECT: During Init, replace with the project's integration/E2E impact rules — e.g. "if selectors changed, run the E2E suite" or "if an API contract changed, exercise it against the local server/emulator". Docs-only changes skip this.] -->

If the change modifies an externally observable contract (API shape, UI selectors, auth behavior), exercise it with the project's integration/E2E tooling. Docs-only changes skip this.

### 4. Author missing tests

If the change adds new logic, write its tests **now**, guided by the plan's **Test Impact** section and the project's testing guide (see `TRIP-test`). If no new logic was added, skip this step.

**Hard-to-cover code policy:**

- Test **observable behavior** (inputs → outputs/persisted effects), never internal wiring.
- **Mock-pain tripwire**: if the mock setup grows longer than the test's assertions, stop fighting it — check the project's testing guide for a seam recipe; if none applies, skip the *deep unit* test and add one line to `docs/4-unit-tests/COVERAGE-DEBT.md` (`path | why hard | escape plan`).
- **Critical-path floor**: behavior touching auth, deletion, persistence, cost, or external request shape must keep at least one behavioral test or manual integration check — coverage debt may defer internal-path depth, never safety-critical behavior.
- Never hide untested code (no coverage-ignore comments, no config exclusions, no lowering coverage gates). Legacy modules outside the change scope are not a feature blocker — but record newly encountered risky gaps in the ledger.

### 5. Build the summary

Format: `lint: clean | typecheck: clean | tests: N passed (M new)`

Fix failures before starting the loop.

---

## Codex Code Review

Always run the Codex code review after the testing gate passes — no confirmation needed.

### Loop

Always export before invoking shared scripts:

```bash
export STATE_DIR=".claude/skills/codex-code-review/state"
```

1. **Start**:
   ```bash
   bash .claude/skills/codex-plan-review/scripts/start.sh \
       --prompt-file .claude/skills/codex-code-review/prompts/start.tpl \
       <plan-path> "$GATE_SUMMARY"
   ```
   `$GATE_SUMMARY` is the testing-gate summary (`lint | typecheck | tests`). For unplanned work (no `F_*.plan.md`), pass a free-form label instead of a plan path.

2. **Parse trailing tag**: `APPROVED` -> synthesize. `NEEDS_REWORK` -> surface to user. `REQUEST_CHANGES` -> continue.

3. **Address findings** — quote each with `file:line`, read the actual code, fix legitimate ones, push back on incorrect ones. Critical/Major block approval; Minor/Suggestion are case-by-case.

4. **Write implementer notes** (1-3 sentences): which findings you fixed, which you pushed back on and why, any user decisions or environment limitations Codex should stop re-flagging.

5. **Resume** (re-run the testing gate first — lint, typecheck, affected tests — and build a fresh summary):
   ```bash
   bash .claude/skills/codex-plan-review/scripts/resume.sh \
       --prompt-file .claude/skills/codex-code-review/prompts/resume.tpl \
       --notes "Fixed X. Pushed back on Y because Z." \
       <plan-path> "$GATE_SUMMARY"
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

Outputs `PROMOTION_READY` sentinel. `<x.y.z>` Version placeholder left unfilled (resolved during `TRIP-3-release`).

Edge cases:
- **Capped without APPROVED**: still synthesize; Codex notes open findings.
- **User skipped Codex**: no synthesis. The CR is written manually during `TRIP-3-release`: "Code review skipped — trivial change."

### Operating Notes

Surface reviews verbatim. Keep edits scoped. If Codex repeats a finding, re-read carefully — you likely addressed an adjacent concern. Reset thread only if context is confused. The testing gate (lint, typecheck, affected tests) must pass before APPROVED.

---

## Handoff to Release

After Codex converges (or is skipped):

- Cross the corresponding checkboxes in the plan todo list (if any)
- Then **use the `AskUserQuestion` tool** to ask:
  - **Question**: "Is the implementation complete?"
  - **Options**: "Yes, everything is complete" (proceed to release), "No, there are remaining items" (continue working)

**If "Yes"**: proceed directly into the release — read `.claude/skills/TRIP-3-release/SKILL.md` and follow it in this session, passing the same plan path (or feature label). The release skill owns everything from version bump to the fast-forward merge and push.

**If "No"**: continue working, then repeat the sequence: testing gate → Codex review → this question.
