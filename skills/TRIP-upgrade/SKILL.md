---
name: TRIP-upgrade
description: Upgrade TRIP workflow skills to a newer version while preserving project customizations
disable-model-invocation: true
argument-hint: "[path to new-TRIP folder]"
---

# TRIP Upgrade Mode

You are now in **upgrade mode** — merging a newer version of the TRIP workflow into this project's existing, customized TRIP skills.

## The Problem

Each project's TRIP skills have two interleaved layers:
1. **Workflow skeleton** — steps, Codex integration, file structure, process flow
2. **Project customizations** — test commands, checklist sections, version file, technical considerations, guidance sections

A naive copy would destroy layer 2. This skill separates both layers, applies the new skeleton, and re-injects the customizations.

## Prerequisites

The user must have copied the new generic TRIP skills into a staging folder before running this skill. Default location: `.claude/skills/new-TRIP/`

If `$ARGUMENTS` is provided, treat it as the path to the staging folder. Otherwise use `.claude/skills/new-TRIP/`.

---

## Phase 1: Inventory

### 1.1 Validate Staging Folder

Confirm the staging folder exists and contains TRIP skills:

```bash
ls -R <staging-path>/
```

If missing or empty, tell the user:
> "No staging folder found at `<path>`. Copy the new TRIP workflow's `skills/` folder there first, then re-run."

### 1.2 Categorize Skills

List all skill folders in both locations:

```bash
# Currently installed
ls -d .claude/skills/*/

# New (staging)
ls -d <staging-path>/*/
```

Categorize each skill into one of:

| Category | Meaning | Action |
|----------|---------|--------|
| **New** | Exists in staging only | Copy directly |
| **Removed** | Exists in installed only | Warn user, leave in place |
| **Unchanged** | Identical in both | Skip |
| **Updated — pure workflow** | Changed, but no project customizations | Replace directly |
| **Updated — customized** | Changed, AND contains project-specific content | Extract → merge → replace |

**Pure workflow skills** (no project customizations): `TRIP-compact`, `TRIP-hotfix`, `TRIP-research`, `TRIP-init`, `codex-implement`, `codex-plan-review`, `codex-code-review`

**Exception — model defaults**: `codex-plan-review/scripts/_common.sh` holds the per-flow Codex model/effort defaults, which the user may have tuned. Before replacing, diff the installed `_common.sh` against staging — if the model/effort values differ from the generic defaults, carry the user's values into the new file.

**Customized skills** (have project-specific content): `TRIP-1-plan`, `TRIP-2-implement`, `TRIP-3-release`, `TRIP-review`, `TRIP-test`

**Renamed in TRIP v2** — when the installed folder uses an old name, treat it as the same skill under its new name (merge into the new name, then delete the old folder):

| Installed (old) | Staging (new) |
|---|---|
| `TRIP-3-review` | `TRIP-review` |
| `TRIP-4-test` | `TRIP-test` |

`TRIP-3-release` is **new in v2** but its project values (version file, week anchor, tutorial config) are **extracted from the old `TRIP-2-implement`'s post-implementation steps** — categorize it as customized even though no folder exists yet.

**Other non-TRIP skills** in staging (e.g. future additions): Treat as new, or as pure workflow if they already exist.

For each skill, diff the installed vs new version to confirm whether it actually changed:

```bash
diff -rq .claude/skills/<skill>/ <staging-path>/<skill>/
```

### 1.3 Present Inventory

Show a summary table to the user:

```
Skill                 | Status              | Action
--------------------- | ------------------- | ------
TRIP-1-plan           | Updated (customized) | Extract + merge
TRIP-2-implement      | Updated (customized) | Extract + merge
TRIP-3-release        | New (customized)     | New template + values from old TRIP-2
TRIP-review           | Renamed + updated    | Extract + merge, delete TRIP-3-review/
TRIP-test             | Renamed + updated    | Extract + merge, delete TRIP-4-test/
TRIP-compact          | Unchanged            | Skip
TRIP-hotfix           | Unchanged            | Skip
TRIP-init             | Updated (pure)       | Replace
TRIP-research         | Unchanged            | Skip
codex-plan-review     | New                  | Copy
codex-code-review     | New                  | Copy
codex-implement       | New                  | Copy
```

`AskUserQuestion`: "Here's the upgrade plan. Proceed?"
Options: "Yes, start upgrade" (recommended) / "Let me review the new files first" / "Abort"

---

## Phase 2: Extract Project Context

Before touching any installed files, read every customized skill and extract all project-specific values into a context block. This is your safety net — everything here gets re-injected later.

### 2.1 Read All Installed Skills

Read every file in the installed skills directory that will be affected.

### 2.2 Extract Customizations

Build a context block by extracting these values from the installed skills:

**From TRIP-1-plan/SKILL.md:**
- `PROJECT_NAME` — the text that replaced `[PROJECT_NAME]` (appears in the `# Planning Mode` header and `**planning mode** for` line)
- `TECHNICAL_CONSIDERATIONS` — the full content of the `## Technical Considerations` section in the plan template (everything between `## Technical Considerations` and the next `##` heading)
- `GUIDANCE_SECTIONS` — everything after the plan template's closing section that replaced `[ADAPT_TO_PROJECT: Guidance Sections]` (project-specific per-component guidance at the bottom of the file)

**From TRIP-2-implement/SKILL.md** (in v1 installs, the release values below live in its Post-Implementation steps; in v2 installs they live in `TRIP-3-release/SKILL.md`):
- `PROJECT_NAME` — (confirm matches TRIP-1-plan)
- `VERSION_FILE` — the text that replaced `[VERSION_FILE]` in Step 2
- `WEEK_ANCHOR_DATE` — the date that replaced `[WEEK_ANCHOR_DATE]` in Step 1
- `TUTORIAL_CONFIG` — if tutorials are enabled: the full Tutorial step block with user context. If disabled: note "tutorials disabled"
- `LINT_COMMAND` — if present (may not exist in older versions)
- `TYPECHECK_COMMAND` — if present
- `TEST_COMMAND` — if present

**From TRIP-review/SKILL.md — or `TRIP-3-review/` in v1 installs (checklist.md if already split):**
- `REVIEW_CHECKLIST` — the full checklist content. In older versions this is inline in SKILL.md. In newer versions it's in `checklist.md`. Extract it wherever it lives.
- `CR_TEMPLATE` — if `cr-template.md` exists, extract it. Otherwise note "no template file — using inline template"

**From TRIP-test/SKILL.md — or `TRIP-4-test/` in v1 installs:**
- `TEST_COMMANDS` — the full Commands section
- `TEST_STRUCTURE` — the test structure description
- `TESTING_PRIORITIES` — the full testing priorities section

### 2.3 Present Extracted Context

Show the user a summary of what was extracted:

```
Extracted project context:
- Project name: [name]
- Version file: [path]
- Week anchor: [date]
- Tutorials: [enabled/disabled]
- Test commands: [lint] / [typecheck] / [test]
- Checklist sections: [count] sections ([list names])
- Guidance sections: [count] sections ([list names])
- Technical considerations: [count] items
```

`AskUserQuestion`: "Extracted project context looks correct?"
Options: "Yes, continue" / "No, let me correct something"

If "No": let the user specify corrections, update the context block.

---

## Phase 3: Handle Structural Migrations

Before merging, handle any structural changes between the old and new workflow versions. Read both old and new files to detect what changed structurally.

### 3.1 Checklist Extraction (TRIP-review)

**Old structure** (early v1): Checklist inline in `TRIP-3-review/SKILL.md`
**New structure** (v2): Checklist in separate `TRIP-review/checklist.md`, template in `TRIP-review/cr-template.md` (late-v1 installs have these same files under `TRIP-3-review/`)

If the installed version has the checklist inline in SKILL.md (no separate `checklist.md`):
1. The extracted `REVIEW_CHECKLIST` from Phase 2 is the project-customized checklist
2. It will be injected into the new `checklist.md` in Phase 4

If the installed version already has `checklist.md`:
1. The extracted content is already in the right format
2. Merge normally in Phase 4

### 3.2 Codex Integration (TRIP-1-plan, TRIP-2-implement)

**Old structure**: No Codex review steps
**New structure**: TRIP-1-plan has Step 3 (Codex plan review), TRIP-2-implement has Codex Code Review section

These are pure workflow additions — no project-specific content to migrate. They will be applied from the new template. The only project-specific part is the test commands in TRIP-2-implement's Codex pre-step, which come from the extracted context.

### 3.3 Codex Skills (codex-plan-review, codex-code-review, codex-implement)

If not installed yet, these are entirely new — copy from staging directly. The review skills reference `TRIP-review/checklist.md` and `TRIP-review/cr-template.md`, which will be populated with project content. If already installed (late-v1), replace as pure workflow (see the `_common.sh` exception in Phase 1.2) — v1 prompt templates point at the old `TRIP-3-review/` paths and must be replaced with the v2 versions.

---

## Phase 4: Merge & Apply

For each skill, apply the appropriate action from the Phase 1 inventory.

### 4.1 New Skills — Copy Directly

```bash
cp -r <staging-path>/<skill>/ .claude/skills/<skill>/
```

For skills with `state/` directories, ensure `.gitignore` is in place.

### 4.2 Pure Workflow Skills — Replace Directly

```bash
rm -rf .claude/skills/<skill>/
cp -r <staging-path>/<skill>/ .claude/skills/<skill>/
```

### 4.3 Customized Skills — Extract + Merge

For each customized skill, take the **new template** from staging and inject the **extracted project context** from Phase 2. This is the core of the upgrade.

**General approach**: Read the new template file. Find each placeholder or generic section. Replace with the corresponding extracted value. Write the result.

#### TRIP-1-plan/SKILL.md

1. Start from the new template (staging)
2. Replace `[PROJECT_NAME]` with extracted `PROJECT_NAME`
3. Replace the generic `## Technical Considerations` block in the plan template with extracted `TECHNICAL_CONSIDERATIONS`
4. Replace the `[ADAPT_TO_PROJECT: Guidance Sections]` comment block with extracted `GUIDANCE_SECTIONS`

#### TRIP-2-implement/SKILL.md

1. Start from the new template (staging)
2. Replace `[PROJECT_NAME]` with extracted `PROJECT_NAME`
3. Replace `[LINT_COMMAND]`, `[TYPECHECK_COMMAND]`, `[TEST_COMMAND]` in the Testing Gate with extracted commands
   - If the old version didn't have Codex review (no test commands extracted), check the old TRIP-4-test for test commands, or ask the user
4. Adapt the Integration impact check comment block to the project's integration/E2E tooling (from the old TRIP-4-test content if present)

#### TRIP-3-release/SKILL.md (new in v2 — values come from the old TRIP-2)

1. Start from the new template (staging)
2. Replace `[PROJECT_NAME]` with extracted `PROJECT_NAME`
3. Replace `[VERSION_FILE]` with extracted `VERSION_FILE`
4. Replace `[WEEK_ANCHOR_DATE]` with extracted `WEEK_ANCHOR_DATE`
5. Replace `[MAIN_BRANCH]` with the repo's default branch name
6. Replace the standalone-verification commands with the same extracted lint/typecheck/test commands
7. Handle tutorial config:
   - If tutorials were disabled: remove the `[TUTORIAL_STEP]` block
   - If tutorials were enabled: replace the `[TUTORIAL_STEP]` block with extracted `TUTORIAL_CONFIG` and renumber subsequent steps

#### TRIP-review/SKILL.md + checklist.md + cr-template.md (was `TRIP-3-review` in v1)

1. `SKILL.md`: Start from the new template. Replace `[PROJECT_NAME]`.
2. `checklist.md`: Start from the new template. Replace the `[ADAPT_TO_PROJECT]` comment block with the project-specific checklist sections from the extracted `REVIEW_CHECKLIST`.
   - The new template has generic sections 1-3 (Functional, Code Quality, Architectural) and 4-6 (Error Handling, Security, Performance). The project customization goes between section 3 and 4 (where the comment marker is), and may also modify sections 3-6.
   - If the old checklist had custom sections (numbered 4+), insert them at the `[ADAPT_TO_PROJECT]` marker and renumber if needed.
   - Preserve the Severity Classification and Approval Gate from the **new** template unless the project had custom overrides.
3. `cr-template.md`: Start from the new template. Update the Checklist section names to match the actual sections in the merged `checklist.md`.

#### TRIP-test/SKILL.md (was `TRIP-4-test` in v1)

1. Start from the new template (staging)
2. Replace `[PROJECT_NAME]` with extracted `PROJECT_NAME`
3. Replace `[TEST_COMMAND_*]` placeholders with extracted `TEST_COMMANDS`
4. Replace test structure placeholder with extracted `TEST_STRUCTURE`
5. Replace testing priorities placeholder with extracted `TESTING_PRIORITIES`

### 4.4 Write All Files

After building all merged content in memory, write every file. Do NOT write partial results — complete the full merge first, then write all at once.

---

## Phase 5: Validate

After writing all files, run a validation pass.

### 5.1 Placeholder Check

Scan all upgraded skill files for leftover placeholders:

```bash
grep -rn '\[ADAPT_TO_PROJECT\|\[PROJECT_NAME\]\|\[VERSION_FILE\]\|\[WEEK_ANCHOR_DATE\]\|\[TEST_COMMAND\]\|\[LINT_COMMAND\]\|\[TYPECHECK_COMMAND\]\|\[TUTORIAL_STEP\]\|\[MAIN_BRANCH\]' .claude/skills/TRIP-*/
```

If any are found, fill them from context or ask the user.

### 5.2 Cross-Reference Check

- `checklist.md` section names must match `cr-template.md` checklist section names
- `codex-code-review/prompts/start.tpl` and `resume.tpl` reference `.claude/skills/TRIP-review/checklist.md` — confirm it exists, and that no template still points at the old `TRIP-3-review/` path
- `codex-code-review/prompts/synthesize.tpl` and `codex-code-review/SKILL.md` reference `.claude/skills/TRIP-review/cr-template.md` — confirm it exists
- `TRIP-1-plan` and `TRIP-2-implement` reference `codex-plan-review/scripts/start.sh` and `resume.sh`; `TRIP-2-implement` also references `codex-implement/scripts/start.sh` — confirm they exist

### 5.3 Present Summary

Show what changed:

```
Upgrade complete:
- New skills added: [list]
- Skills updated: [list]
- Skills unchanged: [list]
- Project customizations preserved: [list key ones]
```

`AskUserQuestion`: "Upgrade applied. Review the changes?"
Options: "Looks good" / "Show me the diffs" / "Revert everything"

If "Show me the diffs": run `git diff .claude/skills/` and present.
If "Revert everything": `git checkout -- .claude/skills/`

---

## Phase 6: Clean Up

After user confirms:

1. Remove the staging folder:
   ```bash
   rm -rf <staging-path>
   ```

2. Report completion:
   > "TRIP workflow upgraded. The staging folder has been removed. You can `git diff .claude/skills/` to review all changes before committing."

---

## Edge Cases

### Old version has no Codex skills at all
This is the most common upgrade path. The Codex skills are "New" — copy directly. The Codex integration in TRIP-1-plan and TRIP-2-implement comes from the new template and needs no project-specific content except test commands.

### Old version has inline checklist but no separate files
The structural migration in Phase 3.1 handles this. Extract the custom checklist content from the old SKILL.md, inject into the new `checklist.md`.

### Old version already has the new structure
Everything categorizes as "Unchanged" or minor updates. The merge is trivial.

### Project has extra custom skills not in the new workflow
These are "Removed" in the inventory — warn the user but leave them in place. Never delete skills that exist only in the installed version.

### Test commands not available anywhere
If the old version predates the Codex review pre-step and TRIP-4-test doesn't have extractable commands, ask the user:

`AskUserQuestion`: "The new workflow needs lint/typecheck/test commands for Codex code review. What are the commands for this project?"
Options: "Let me provide them" (user types commands) / "Skip for now" (leave placeholders)

---

## Notes for the Agent

- **Read before writing.** Read every file you plan to modify. Never write from memory alone.
- **Preserve semantics, not bytes.** If the old checklist had 10 custom sections, they all need to survive, even if their numbering changes.
- **New workflow features get project context.** When Codex code review is new, the test commands still need to be filled from the project's existing test setup.
- **When in doubt, ask.** If you can't confidently extract a customization, show the user the relevant section and ask what to keep.
- **Atomic application.** Build all merged content before writing any files. If something goes wrong mid-merge, the installed skills should still be intact.
- **Never delete user-created files.** If the project has extra files in a skill directory (like project-specific fixtures or notes), leave them alone.
