# Changelog

## 2.1.1 — 2026-07-15

Robustness release: script hardening, dynamic branching, and a regression test suite.

### Fixed

- **State-directory footgun**: `codex-implement`, `codex-code-review`, and `codex-ask` now ship their own `start`/`resume`/`reset`/`show` wrapper scripts that pin `STATE_DIR` themselves. The old `export STATE_DIR` choreography silently broke when the export and the script call ran in separate shells — worst case, a resume continued the *plan-review* thread with the reviewer model instead of the implementation thread.
- **State-key lookup for free-form labels**: `TRIP-3-release` now derives the code-review state key via the new shared `key.sh` instead of an inline `realpath` pipeline, which mis-keyed unplanned work (free-form labels) and silently downgraded a converged Codex review to the "skipped" fallback.
- **Prompt substitution**: `load_prompt` no longer corrupts prompts containing `&` or backslashes, and no longer loops forever when a substituted value quotes its own placeholder (e.g. implementer notes discussing the templates).
- **Committed session artifacts**: added the missing `state/.gitignore` for `codex-implement` and `codex-ask`, so `git add -A` during release no longer commits thread IDs, reports, and event logs.
- **Stale v1 references**: week-anchor formula location, synthesize template's version-step pointer, tutorial step numbering and its renumber list.

### Changed

- **Dynamic base branch**: `TRIP-2-implement`, `TRIP-3-release`, and `TRIP-hotfix` now work from whatever branch is active. The base branch is recorded at branch creation (`branch.<name>.trip-base` git config) and the release/hotfix merge returns to it — the `[MAIN_BRANCH]` placeholder is gone.
- **Push is now explicit**: `TRIP-3-release` and `TRIP-hotfix` list the available branches and ask which one to push (base branch recommended), unless the user already specified one. Hotfix previously pushed automatically as part of the merge chain.
- **Hotfix merge policy**: `TRIP-hotfix` now enforces `--ff-only` like the release skill — never a merge commit.
- **Docs**: unified ARCHI.md token thresholds (10–15k target, ~20k ceiling) across README, `TRIP-compact`, and `TRIP-3-release`; added the Bash/Codex CLI/`jq`/GNU-coreutils requirements note; typo fixes.

### Added

- `tests/workflow-regression.sh` — regression suite covering prompt substitution (literal `&`/backslash handling, self-referencing placeholder termination), shared key derivation for free-form labels, wrapper state-directory isolation, and state `.gitignore` presence.

## 2.1.0 — 2026-07-13

### Added

- **`codex-ask` skill**: grounded second opinion from Codex on any matter — architecture calls, debugging hypotheses, research conclusions. Read-only sandbox, threaded per topic, advisory only (no verdict tags, nothing gated).
- **TRIP-research cross-check step**: decision-grade findings are red-teamed via `codex-ask` before being presented; real disagreements are recorded in the memo's Open Questions section.

## 2.0.0 — 2026-07-13

Flow simplified to **Plan → Implement → Release**: review and test moved inside Implement as a testing gate and an automatic Codex review loop.

### Added

- **`codex-implement` skill**: implementation delegated to Codex CLI in a workspace-write sandbox, with persistent per-plan threads for phased delegation.
- **`TRIP-3-release` skill**: owns the release ceremony (version, CR promotion, changelogs, docs, commit, tag, ff-merge, push).
- **Testing gate** in `TRIP-2-implement`, with the hard-to-cover policy and coverage-debt ledger.
- **Per-flow Codex model defaults** in `codex-plan-review/scripts/_common.sh` (implementation vs review models), overridable via `CODEX_MODEL` / `CODEX_EFFORT`.

### Changed

- `TRIP-review` and `TRIP-test` reborn as on-demand support skills (manual fallback/audit review, deep test-authoring reference).
- `TRIP-upgrade` handles the v1 → v2 rename/migration (`TRIP-3-review` → `TRIP-review`, `TRIP-4-test` → `TRIP-test`).

## Earlier (1.x)

- 2026-06-09 — Codex review integration, `TRIP-upgrade` skill, review file separation.
- 2026-02-10 — minor tool call update.
- 2026-02-05 — Mistral Vibe compatibility, contributing section, `AskUserQuestion` emulation skill.
- 2026-02-03 — migration to Skills.
- 2026-01-29 — initial commit.
