---
name: codex-plan-review
description: Iterative Codex CLI review of a planning document
argument-hint: "<plan-path> [extra context] | reset <plan-path> | show <plan-path>"
---

# Codex Plan Review

Iterative review of a planning document via Codex CLI. State (thread ID, review text, event log) persisted under `.claude/skills/codex-plan-review/state/<sanitized-path>.{thread,review.txt,events.ndjson}`.

The companion `codex-code-review` skill shares the same scripts with its own prompt templates and `STATE_DIR`.

## Arguments

- `<plan-path>` — auto: start if no thread, resume if exists. Trailing free-text is extra context.
- `reset <plan-path>` — drop state, next call starts fresh.
- `show <plan-path>` — display latest review without calling Codex.

## Execution

1. **Parse `$ARGUMENTS`**: extract action (`reset`/`show`/auto) and plan path.

2. **Auto** — try `start.sh` first (exit code 2 = thread exists -> use `resume.sh`):
   - **Start**: `bash .claude/skills/codex-plan-review/scripts/start.sh --prompt-file .claude/skills/codex-plan-review/prompts/start.tpl <plan-path> [extra]`
   - **Resume**: `bash .claude/skills/codex-plan-review/scripts/resume.sh --prompt-file .claude/skills/codex-plan-review/prompts/resume.tpl <plan-path> [extra]`

3. **Reset**: `bash .claude/skills/codex-plan-review/scripts/reset.sh <plan-path>`

4. **Show**: `bash .claude/skills/codex-plan-review/scripts/show.sh <plan-path>`

5. **Parse trailing tag**:
   - `APPROVED` — tell user, done.
   - `REQUEST_CHANGES` — engage critically: fix legitimate findings by editing the plan, push back on incorrect ones. Surface review verbatim, propose fixes, let user confirm.
   - `NEEDS_REWORK` — surface to user before mass-editing.

## Notes

- Model/effort defaults live in `codex-plan-review/scripts/_common.sh` (implementation → gpt-5.6-luna, plan/code review → gpt-5.6-sol, effort xhigh; derived from `STATE_DIR`). Adjust that one file to your preferred models, or override per run via `CODEX_MODEL` / `CODEX_EFFORT` env vars; the scripts echo the effective values.
- `--sandbox read-only`. Safe to invoke autonomously.
- On network failure, check `*.events.ndjson.stderr`. Run `reset.sh` and retry.
- Thread IDs persisted per-plan (no `--last`). Concurrent reviews don't collide.
- Extra context -> `{{EXTRA_PROMPT}}`. Keep short.

## Loop Shape

```
turn 1: start.sh -> REQUEST_CHANGES (A B C)
         address A B C
turn 2: resume.sh -> REQUEST_CHANGES (A B addressed, C stale, new D)
         address C D
turn 3: resume.sh -> APPROVED
```
