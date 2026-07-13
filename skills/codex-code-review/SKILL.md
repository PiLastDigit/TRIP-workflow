---
name: codex-code-review
description: Iterative Codex CLI code review against an implementation plan
argument-hint: "<plan-path> [extra context] | reset <plan-path> | show <plan-path>"
---

# Codex Code Review

Iterative code review via Codex CLI on uncommitted changes. Codex reads the plan and runs `git status -s` / `git diff HEAD` to inspect the change set.

Review output stays in `state/<key>.review.txt` — not `docs/3-code-review/`. Promotion to `docs/3-code-review/CR_wa_vx.y.z.md` happens after convergence, not per-turn.

State persisted under `.claude/skills/codex-code-review/state/<sanitized-target>.{thread,review.txt,events.ndjson}`. Shared scripts live under `.claude/skills/codex-plan-review/scripts/`; always export before invoking:

```bash
export STATE_DIR=".claude/skills/codex-code-review/state"
```

## Arguments

- `<target>` — auto: start if no thread, resume if exists. Usually a plan path (`docs/1-plans/F_*.plan.md`) or a free-form label for unplanned work.
- `reset <target>` — drop state, next call starts fresh.
- `show <target>` — display latest review without calling Codex.

## Execution

1. **Parse `$ARGUMENTS`**: extract action (`reset`/`show`/auto) and target.

2. **Auto** — try `start.sh` first (exit code 2 = thread exists -> use `resume.sh`):
   - **Start**: `bash .claude/skills/codex-plan-review/scripts/start.sh --prompt-file .claude/skills/codex-code-review/prompts/start.tpl <target> [extra]`
   - **Resume**: `bash .claude/skills/codex-plan-review/scripts/resume.sh --prompt-file .claude/skills/codex-code-review/prompts/resume.tpl <target> [extra]`

3. **Reset**: `bash .claude/skills/codex-plan-review/scripts/reset.sh <target>`

4. **Show**: `bash .claude/skills/codex-plan-review/scripts/show.sh <target>`

5. **Parse trailing tag**:
   - `APPROVED` — propose post-convergence steps.
   - `REQUEST_CHANGES` — surface review verbatim, engage critically (read actual code at `file:line`, fix legitimate ones, push back on incorrect ones), then resume.
   - `NEEDS_REWORK` — surface to user before mass-editing.

6. **Resume** after addressing findings for incremental re-review.

## Diff Visibility

Codex uses `git status -s` / `git diff HEAD` in read-only sandbox. If those fail, pass diff inline: `DIFF="$(git diff --stat HEAD; echo '---'; git diff HEAD)"` as extra context.

## After Convergence

1. Promote `state/<key>.review.txt` to `docs/3-code-review/CR_wa_vx.y.z.md` using `.claude/skills/TRIP-review/cr-template.md`.
2. Continue with `TRIP-3-release`.

## Notes

- Model/effort defaults live in `codex-plan-review/scripts/_common.sh` (implementation → gpt-5.6-luna, plan/code review → gpt-5.6-sol, effort xhigh; derived from `STATE_DIR`). Adjust that one file to your preferred models, or override per run via `CODEX_MODEL` / `CODEX_EFFORT` env vars; the scripts echo the effective values.
- `--sandbox read-only`. Safe to invoke autonomously.
- Thread IDs persisted per-target (no `--last`). Concurrent reviews don't collide.
- Separate `STATE_DIR` from `codex-plan-review` — same key is fine.
- Extra context -> `{{EXTRA_PROMPT}}`. Keep short.

## Loop Shape

```
turn 1: start.sh -> REQUEST_CHANGES (Critical: A, Major: B C)
         address A B C
turn 2: resume.sh -> REQUEST_CHANGES (A B addressed, Minor: C partial, Suggestion: D)
         address C, optionally D
turn 3: resume.sh -> APPROVED -> promote, continue with TRIP-3-release
```
