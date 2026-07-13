![TRIP Workflow Banner](assets/trip-workflow-banner2.png)

![Version](https://img.shields.io/badge/version-2.0.0-blue) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/PiLastDigit/TRIP-workflow/blob/master/LICENSE) ![Works with](https://img.shields.io/badge/Works_with-grey) [![Claude Code](https://img.shields.io/badge/Claude_Code-E5582B)](https://docs.anthropic.com/en/docs/claude-code) [![Codex CLI](https://img.shields.io/badge/Codex_CLI-10A37F)](https://developers.openai.com/codex/cli/) [![OpenCode](https://img.shields.io/badge/OpenCode-1a3a5c)](https://github.com/sst/opencode) [![Mistral Vibe](https://img.shields.io/badge/Mistral_Vibe-F7D046)](https://github.com/mistralai/mistral-vibe)

## What is TRIP?

A structured development workflow for AI coding agents that brings **memory**, **consistency**, and **reduced hallucination** (only humans should) to AI-assisted development. TRIP helps you enter flow state and eat features like buttered noodles.
It is also the acronym (reversed) of the 4-phases development cycle: **P**lan, **I**mplement, **R**eview, **T**est. Since v2.0.0 the numbered flow is **Plan → Implement → Release** — review and test didn't disappear, they moved *inside* Implement as a testing gate and an automatic Codex review loop, so every feature passes through all four phases with fewer commands.

TRIP was initially designed for Claude Code using the [Agent Skills](https://agentskills.io/home) open standard (`SKILL.md`). Also compatible with OpenCode, Codex CLI, Mistral Vibe and more.

## Why TRIP?

There are tons of AI coding workflows out there like [Superpowers](https://github.com/obra/superpowers), [BMAD](https://github.com/bmad-code-org/BMAD-METHOD), [Gastown](https://github.com/steveyegge/gastown) and countless others. They might be powerful, but overwhelming for many of us dumb asses.

Even the "simple" ones come with:

- 47 different commands & skills to memorize
- Sub-agents swarm for God-knows-what
- Mutlti-chapters courses (sometimes paid lol)

**TRIP is different.** It's deliberately minimal:

| That's it           | Just these                                             |
| ------------------- | ------------------------------------------------------ |
| `/TRIP-1-plan`      | Think before you code (Codex reviews the plan)         |
| `/TRIP-2-implement` | Codex writes, you review, tests gate, Codex re-reviews |
| `/TRIP-3-release`   | Version, changelogs, docs, commit, tag, merge, push    |

Support skills on demand: `/TRIP-review` (manual audit), `/TRIP-test` (deep test authoring), plus hotfix/research/compact.

![TRIP Workflow loop](assets/trip-workflow-loop2.png)

Three numbered skills. One architecture file. Zero PhD required.

The onboarding is: copy the folder, run init, start coding. If you can count to 3, you can TRIP.

It was kept stupid simple because **the goal is to ship features, not to master a workflow**. The workflow should disappear into the background, not become a project of its own.

## Getting Started

1. Copy the `skills/` folder contents to your repo's `.claude/skills/` or whatever
2. Run `/TRIP-init [YourProjectName]`
3. Follow the interactive prompts
4. Review and approve the generated ARCHI.md

### Additional For Codex & Mistral users

Also copy `AskUserQuestion/` to your agent `/skills/`, it provides the `AskUserQuestion` tool that TRIP workflow rely on (missing on those two agents BOOOO).  

Et voila ! Start using the skills like `/TRIP-1-plan auth for this webapp`, `/TRIP-2-implement @auth-plan.md`, etc.

https://github.com/user-attachments/assets/d37bbc60-1868-4fa8-9be6-083b60d6a53d

## The Heart of TRIP: ARCHI.md

The `ARCHI.md` file is the **central nervous system** of this workflow. It serves as the AI agent's **long-term memory** of your codebase.

### Why ARCHI.md Matters

**1. Persistent Context Across Sessions**

AI agents have no memory between sessions. Every new conversation starts from zero. ARCHI.md solves this by providing a comprehensive, always-up-to-date snapshot of your architecture that the agent reads at the start of each task. Unlike tool-specific files like `CLAUDE.md` or `AGENTS.md`, ARCHI.md is purely about architecture. It's tool-agnostic, so it works with any agent. You can still reference it from your `CLAUDE.md` to include it in all conversations.

**2. Token Savings & Reduced Hallucination**

Without ARCHI.md, your agent must glob, grep, and read multiple files to piece together the architecture from scratch for every single session. This wastes tokens and leads to guessing: _"There's probably a utils folder..."_, _"This project likely uses Redux..."_. ARCHI.md eliminates both problems. The agent gets the full picture in one read for minimal exploration & hallucination.

**3. Balanced Detail vs Token Usage**

ARCHI.md is designed to be:

- **Detailed enough** to provide meaningful context, **concise enough** to not waste tokens
- **Structured** for quick navigation
- **Updated** after every architectural change

It's not a dump of your entire codebase, rather a curated architectural guide.

## The Init Process

The `TRIP-init` skill is a **script written in human language** that programmatically bootstraps the TRIP workflow in any repository.

### What Init Does

1. **Creates the docs structure** - Folders for plans, changelogs, reviews, tests, memos
2. **Explores your codebase** - Identifies languages, frameworks, patterns, conventions
3. **Classifies your project** - Web frontend? CLI tool? Embedded firmware? Library?
4. **Generates ARCHI.md** - Tailored to your specific project type
5. **Customizes the skills** - Replaces placeholders with your project's specifics

### The Placeholder System

The generic TRIP skills contain placeholders like:

- `[PROJECT_NAME]` - Your project's name
- `[VERSION_FILE]` - Where your version is stored (package.json, Cargo.toml, etc.)
- `[ADAPT_TO_PROJECT: ...]` - Sections to customize

Init walks you through questions and replaces these placeholders based on your answers, creating a workflow tailored to your project.

## More Skills

### `/codex-implement`

Implementation delegated to Codex CLI in a **workspace-write sandbox**: it reads the approved plan, edits the working tree, runs your lint/build, and reports back with a completion tag. Your main agent then self-reviews the diff and fixes issues directly — no ping-pong. Persistent thread per plan, so multi-phase plans resume with full context. Integrated into TRIP-2-implement as the default implementation path.

### `/codex-plan-review` & `/codex-code-review`

Iterative review loops powered by Codex CLI. Plans get a second-opinion review before the user sees them. Code gets reviewed against the plan and a shared checklist after implementation. Both use persistent thread state for multi-round convergence (`start → REQUEST_CHANGES → fix → resume → APPROVED`). Integrated directly into TRIP-1-plan (Step 3) and TRIP-2-implement (after the testing gate).

Per-flow model defaults (implementation vs reviews) live in one file — `codex-plan-review/scripts/_common.sh` — and can be overridden per run via `CODEX_MODEL` / `CODEX_EFFORT` env vars.

### `/TRIP-review` & `/TRIP-test`

The former steps 3 and 4, reborn as on-demand support skills: `/TRIP-review` is the manual fallback/audit review (same checklist as the Codex loop — single source of truth), `/TRIP-test` is the deep test-authoring reference with a seam ladder and a coverage-debt ledger for hard-to-test code.

### `/TRIP-upgrade`

Upgrades an existing project's TRIP skills to a newer version without losing project customizations. Extracts your project-specific content (test commands, checklist sections, technical considerations, version file paths), applies the new workflow skeleton, and re-injects the customizations. Copy the new skills to `new-TRIP/`, run the skill, done.

### `/TRIP-hotfix`

Streamlined workflow for production emergencies. Bypasses full TRIP for genuine crises (or lazy debugging).

### `/TRIP-research`

Exploratory investigation with defined compute level. For feasibility studies and technology evaluation. Produces documented findings, not production code.

### `/TRIP-compact`

Run this skill to compact ARCHI.md size while preserving relevance, accuracy, and coverage through summarization and restructuring. Token calculator script included.
As a rule of thumb, ARCHI.md should not exceed ~10% of context window.

## Multi-Agent: Use Different LLMs at Different Steps

![TRIP Workflow multiLLM](assets/trip-workflow-multiLLM4.png)

Since ARCHI.md is tool-agnostic and skills follow an open standard, nothing stops you from mixing agents across the TRIP phases. In fact, it's a strong recommendation. Just like you wouldn't smell your own fart, an LLM is unlikely to catch bugs in its own implementation. Introducing a different model to catch what the first one missed has become a common practice.

As of v2.0.0, this multi-agent approach is **the default workflow**: Codex reviews the plan (TRIP-1), Codex *implements* it in a sandboxed thread (codex-implement), Claude self-reviews and fixes the diff, runs the testing gate, then a separate Codex thread reviews the code — all in one session. Writer and reviewer are never the same thread, and you can pin different models per flow (e.g. one model for implementation, another for reviews).

You can also mix agents manually across the full cycle. To date, the best combo is Claude Opus 4.6 + Codex 5.3, for example:

1. **Plan** with Claude Code — great at interactive discovery and architecture (Codex reviews the plan automatically)
2. **Implement** with Claude Code — it wrote the plan, it knows the intent (Codex reviews the code automatically)
3. **Test** with either — whoever you trust more with your test framework

The key is that ARCHI.md, the plans and the changelogs all live in `docs/`, they're just text files. Any agent can read them. You're not locked into one tool for the entire cycle.

## MCP Servers: Less Is More

Every MCP server you add is extra context, extra latency, and extra confusion. Keep it minimal. The one use case where MCP genuinely shines is **up-to-date documentation**, so your agent stops hallucinating deprecated APIs. Two servers cover it: [Context7](https://github.com/upstash/context7) for current library & framework docs, and [Exa](https://github.com/exa-labs/exa-mcp-server) for web search when the answer isn't in any doc. No bloat beyond that.

## Important: Adapt to Your Use Case

**This workflow is a starting point, not a rigid framework.**

The initial setup works out of the box, but you will eventually need to fine-tune the workflow. Use your brain to customize.  
The best version of this workflow is the one **you** create by adapting it to your reality.

## Contributing

PRs & forks are welcome (improvements, new useful skills,...), but please keep it stupidly simple for all of us fellow regards.

Happy tripping 🍄
