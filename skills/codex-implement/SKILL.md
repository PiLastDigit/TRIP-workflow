---
name: codex-implement
description: Delegate implementation of a TRIP plan (or a scoped part of it) to Codex CLI
argument-hint: "<plan-path> [instructions] | reset <plan-path> | show <plan-path>"
---

# Codex Implement

Non-interactive implementation via Codex CLI in a **workspace-write** sandbox: Codex reads the plan, edits the working tree directly, runs the project's lint/build on its own work, and reports back. One persistent thread per target, so a plan can be delegated in successive batches (or phase by phase) with full context retained.

State persisted under `.claude/skills/codex-implement/state/<sanitized-target>.{thread,review.txt,events.ndjson}` (the `.review.txt` file holds Codex's implementation **report** — the naming comes from the shared helpers). `resume`/`reset`/`show` reuse the shared scripts from `codex-plan-review`; always export before invoking them:

```bash
export STATE_DIR=".claude/skills/codex-implement/state"
```

## Arguments

- `<target>` — auto: start if no thread, resume if one exists. Usually a plan path (`docs/1-plans/F_*.plan.md`); a free-form label for unplanned work.
- Optional trailing instructions — scope control appended to the prompt, e.g. `"Implement only: <batch checkboxes>"` or `"Now implement: <next batch>"`.
- `reset <target>` — drop state, next call starts fresh.
- `show <target>` — display the latest report without calling Codex.

## Execution

1. **Parse `$ARGUMENTS`**: extract action (`reset`/`show`/auto) and target.

2. **Auto** — try `start.sh` first (exit code 2 = thread exists → use `resume.sh`):
   - **Start**: `bash .claude/skills/codex-implement/scripts/start.sh --prompt-file .claude/skills/codex-implement/prompts/implement.tpl <target> [instructions]`
   - **Resume** (next batch / additional scope): `bash .claude/skills/codex-plan-review/scripts/resume.sh --prompt-file .claude/skills/codex-implement/prompts/continue.tpl [--notes "review corrections"] <target> [instructions]`

3. **Reset**: `bash .claude/skills/codex-plan-review/scripts/reset.sh <target>`

4. **Show**: `bash .claude/skills/codex-plan-review/scripts/show.sh <target>`

5. **Parse trailing tag** of the report:
   - `IMPLEMENTATION_COMPLETE` — hand control back to the requester's batch review (TRIP-2).
   - `IMPLEMENTATION_PARTIAL` — read the report; resume with instructions for the remainder, or let the requester finish small leftovers directly.

## Notes

- `--sandbox workspace-write` on start; `codex exec resume` inherits it. Codex edits files and runs repo commands (lint/build); no network, no commits.
- **Fixes are the requester's job.** After Codex reports, the requester (TRIP-2 batch review) fixes problems directly in the tree — do NOT ping-pong fixes back to Codex. Resume only for genuinely new scope (next batch, large remainder), passing what was fixed and why via `--notes`.
- Separate `STATE_DIR` from the review skills — the same plan path can hold an implementation thread and a review thread without collision.
- Codex is instructed not to write tests (testing gate owns that) and not to touch release ceremony.
- Network is blocked in the sandbox: if the plan requires installing a new dependency, Codex will report it as a leftover — install it yourself during the batch review.
- Model/effort defaults live in `codex-plan-review/scripts/_common.sh` (implementation → gpt-5.6-luna, reviews → gpt-5.6-sol, effort xhigh; derived from `STATE_DIR`). Adjust that one file to your preferred models, or override per run via `CODEX_MODEL` / `CODEX_EFFORT` env vars; the scripts echo the effective values.
