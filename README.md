![TRIP Workflow Banner](trip-workflow-banner2.png)

## What is TRIP?

A structured development workflow for AI coding agents that brings **memory**, **consistency**, and **reduced hallucination** (only humans should) to AI-assisted development. TRIP helps you enter flow state and eat features like buttered noodles.
It is also the acronym (reversed) of the 4-phases development cycle: <span style="color: #2ea44f;">**P**</span>lan, <span style="color: #d4a017;">**I**</span>mplement, <span style="color: #1f6feb;">**R**</span>eview, <span style="color: #cf222e;">**T**</span>est.  
Made for Claude Code, but works with any agentic coding tool (Codex, Gemini CLI, Open Code, etc.).  

## Why TRIP?

There are tons of AI coding workflows out there - GSD, Superpowers, BMAD, and countless others. They might be powerful, but overwhelming for many of us dumb asses.

Even the "simple" ones come with:

- 47 different commands to memorize
- Sub-agents swarm for God-knows-what
- Certification courses (seriously)

**TRIP is different.** It's deliberately minimal:

| That's it      | Just these            |
| -------------- | --------------------- |
| `/1-Plan`      | Think before you code |
| `/2-Implement` | Write the code        |
| `/3-Review`    | Check the code        |
| `/4-Test`      | Test the code         |

![TRIP Workflow loop](trip-workflow-loop2.png)

Four commands. One architecture file. Zero PhD required.

The onboarding is: copy the folders, run init, start coding. If you can count to 4, you can TRIP.

It was kept stupid simple because **the goal is to ship features, not to master a workflow**. The workflow should disappear into the background, not become a project of its own.

## Getting Started

1. Copy the folders to your repo's `.claude/commands/` or whatever
2. Run `/TRIP:0-Init [YourProjectName]`
3. Follow the interactive prompts
4. Review and approve the generated ARCHI.md

Et voila. Start using the commands like `/TRIP:1-Plan auth for this webapp`, `/TRIP:2-Implement @auth-plan.md`, etc.

## The Heart of TRIP: ARCHI.md

The `ARCHI.md` file is the **central nervous system** of this workflow. It serves as the AI agent's **long-term memory** of your codebase.

### Why ARCHI.md Matters

**1. Persistent Context Across Sessions**

AI agents have no memory between sessions. Every new conversation starts from zero. ARCHI.md solves this by providing a comprehensive, always-up-to-date snapshot of your architecture that the agent reads at the start of each task.

**2. Massive Token Savings**

Without ARCHI.md, your agent must explore your codebase every time:

- Glob for file patterns
- Grep for code structures
- Read multiple files to understand relationships
- Piece together the architecture from scratch

This exploration consumes thousands of tokens and wastes time. With ARCHI.md, the agent gets the full picture in one read.

**3. Drastically Reduced Hallucination**

Hallucination often comes from the agent _guessing_ about your codebase:

- _"There's probably a utils folder..."_
- _"This project likely uses Redux..."_
- _"The API endpoint is probably at..."_

ARCHI.md eliminates guessing. The agent knows exactly what folders exist and their purposes, which patterns your project uses and how components interact.

**4. Balanced Detail vs Token Usage**

ARCHI.md is designed to be:

- **Detailed enough** to provide meaningful context
- **Concise enough** to not waste tokens
- **Structured** for quick navigation
- **Updated** after every architectural change

It's not a dump of your entire codebase - it's a curated architectural guide.

## The Init Process

The `0-Init.md` command is a **script written in human language** that programmatically bootstraps the TRIP workflow in any repository.

### What Init Does

1. **Creates the docs structure** - Folders for plans, changelogs, reviews, tests, memos
2. **Explores your codebase** - Identifies languages, frameworks, patterns, conventions
3. **Classifies your project** - Web frontend? CLI tool? Embedded firmware? Library?
4. **Generates ARCHI.md** - Tailored to your specific project type
5. **Customizes the commands** - Replaces placeholders with your project's specifics

### The Placeholder System

The generic TRIP commands contain placeholders like:

- `[PROJECT_NAME]` - Your project's name
- `[VERSION_FILE]` - Where your version is stored (package.json, Cargo.toml, etc.)
- `[TEST_COMMAND_*]` - Your actual test commands
- `[ADAPT_TO_PROJECT: ...]` - Sections to customize

Init walks you through questions and replaces these placeholders based on your answers, creating a workflow tailored to your project.

## More Commands

### `/TRIP-more:hotfix`

Streamlined workflow for production emergencies. Bypasses full TRIP for genuine crises (or lazy debugging).

### `/TRIP-more:research`

Exploratory investigation with defined compute level. For feasibility studies and technology evaluation. Produces documented findings, not production code.

### `/TRIP-more:compact`

As a rule of thumb, ARCHI.md should not exceed ~20k tokens (~10% of context window for Claude).  
Run this command to compact ARCHI.md size while preserving relevance, accuracy, and coverage through summarization and restructuring.

## Important: Adapt to Your Use Case

**This workflow is a starting point, not a rigid framework.**

You MUST adapt it to your actual needs:

- **Add what's missing** - Special compliance requirements? Add them.
- **Adjust the checklists** - They should reflect **your** quality criteria.
- **Modify the templates** - Make them match **your** conventions.

The provided examples (Web Frontend, Embedded, CLI, etc.) are just templates. Use your brain to customize.

Remember that this is all **experimental**. The intersection of AI-assisted development and structured workflows is new territory.  
**You are highly encouraged to:**

- Tinker with everything
- Break things and fix them
- Add new commands
- Modify existing ones
- Share what works
- Report what doesn't

The best version of this workflow is the one **you** create by adapting it to your reality.

Happy tripping 🍄
