---
name: TRIP-init
description: Initialize TRIP workflow in a new project (creates docs structure and generates ARCHI.md)
disable-model-invocation: true
argument-hint: "name of the project to initialize"
metadata:
  trip-version: "2.9.0"
---

# TRIP Initialization Mode

You are now in **initialization mode** for setting up the TRIP workflow.

## What is TRIP?

TRIP is a structured development workflow with four phases:

- **P**lan - Design features before implementation
- **I**mplement - Build with proper documentation
- **R**eview - Systematic code review
- **T**est - Comprehensive testing

Why call it TRIP instead of PIRT? Because why not

---

## Your Task

Initialize the TRIP workflow for the project: **$ARGUMENTS**

If no project name provided, ask the user for the project name before proceeding.

---

## Phase 1: Create Documentation Folder Structure

Create the following folder structure if it doesn't exist:

```
docs/
├── 1-plans/              # Feature planning documents
├── 2-changelog/          # Version changelog files
├── 3-code-review/        # Code review documentation
├── 4-unit-tests/         # Unit testing documentation
└── 6-memo/               # Miscellaneous notes and memos
```

Files (`ARCHI.md`, `ARCHI-rules.md`, `changelog_table.md`, `TESTING.md`) will be created in later phases after codebase analysis.

---

## Phase 2: Codebase Exploration

Perform a **thorough exploration** of the codebase to gather information:

### 2.1 Project Indicators to Identify

Look for these signals to understand the project:

**Build/Package Files:**

- `package.json` → Node.js/JavaScript/TypeScript
- `Cargo.toml` → Rust
- `CMakeLists.txt`, `Makefile` → C/C++
- `pom.xml`, `build.gradle` → Java
- `pyproject.toml`, `setup.py`, `requirements.txt` → Python
- `go.mod` → Go
- `*.csproj`, `*.sln` → C#/.NET
- `platformio.ini`, `*.ino` → Embedded/Arduino

**Framework Indicators:**

- `next.config.*`, `nuxt.config.*` → Web frontend frameworks
- `electron.*`, `tauri.conf.*` → Desktop apps
- `Dockerfile`, `docker-compose.*` → Containerized services
- `serverless.yml`, `firebase.json` → Cloud functions
- `startup.s`, `linker.ld`, `*.hal` → Embedded/firmware

**Source Structure:**

- `src/components/` → Component-based UI
- `src/routes/`, `src/pages/` → Web routing
- `src/hal/`, `src/drivers/` → Hardware abstraction
- `src/cmd/`, `cmd/` → CLI tools
- `lib/`, `crates/` → Libraries

### 2.2 Information to Gather

- **Current version** - Check `package.json`, `Cargo.toml`, `version.h`, `__version__`, git tags, or any versioning mechanism. Note the format (SemVer, CalVer, custom). If no version exists, start at `0.1.0`.
- **Languages used** and their versions
- **Build system** and toolchain
- **Dependencies** and their purposes
- **Directory structure** and organization patterns
- **Entry points** (main files, boot sequences)
- **Configuration** approach (env vars, config files, compile-time)
- **Testing** framework and conventions

---

## Phase 3: Project Type Classification

Based on Phase 2 findings, classify the project into one of these categories:

### Project Type Profiles

| Type                  | Indicators                                         | Key Concerns                                          |
| --------------------- | -------------------------------------------------- | ----------------------------------------------------- |
| **Web Frontend**      | React/Vue/Angular/Svelte, components, routing, CSS | Components, State, Styling, Routing, API calls        |
| **Web Backend**       | Express/FastAPI/Gin/Spring, routes, middleware     | Endpoints, Database, Auth, Middleware, Error handling |
| **Full-Stack Web**    | Both frontend and backend in monorepo              | All of above, plus API contracts                      |
| **Desktop App**       | Electron/Tauri/Qt/GTK/WinForms                     | Windows, Native APIs, IPC, Cross-platform             |
| **Mobile App**        | React Native/Flutter/Swift/Kotlin                  | Screens, Navigation, Platform APIs, Offline           |
| **CLI Tool**          | Main entry, arg parsing, no GUI                    | Commands, Config, I/O, Exit codes                     |
| **Library/SDK**       | Public API, no main entry, exports                 | API surface, Versioning, Docs, Compatibility          |
| **Embedded/Firmware** | HAL, interrupts, memory-mapped I/O                 | Hardware, Memory, Real-time, Peripherals, Boot        |
| **Game**              | Game loop, rendering, entities                     | Loop, Rendering, Physics, Input, Assets               |
| **Data/ML Pipeline**  | Notebooks, data processing, models                 | Data flow, Training, Inference, Pipelines             |

### Classification Output

After classification, note:

1. **Primary type** (the main category)
2. **Secondary aspects** (e.g., a CLI tool that's also a library)
3. **Domain-specific concerns** (e.g., real-time constraints, security requirements)

---

## Phase 4: Generate ARCHI.md

Based on the project type, generate `docs/ARCHI.md` using the appropriate sections.

### Universal Sections (ALL projects)

```markdown
# [Project Name] Architecture Documentation

## 1. How to Read This Document

[Document structure and intended audience]

## 2. Overview

[Project purpose, main functionality, high-level architecture]

## 3. Technology Stack

[Languages, frameworks, tools with versions]

## 4. Project Structure

[Directory tree with explanations]

## 5. Core Architecture Principles

[Design principles guiding the codebase]

## 6. Build System & Toolchain

[How to build, compile flags, build targets]

## 7. Configuration

[Environment variables, config files, compile-time options]
```

### Type-Specific Sections

Select sections based on project type classification.

**Important**: The sections below are starting points, not exhaustive lists. If during codebase exploration you identify architectural aspects that deserve their own section but aren't listed here, **add them**. Examples of custom sections you might add:

- **Caching Layer** - for projects with complex caching strategies
- **Plugin/Extension System** - for extensible architectures
- **Multi-tenancy** - for SaaS applications
- **Offline Support** - for apps with offline-first patterns
- **WebSocket/Real-time** - for real-time communication
- **File Processing Pipeline** - for media/document processing
- **Logging & Observability** - for complex monitoring setups
- **Feature Flags** - for projects with feature flag systems
- **Migration System** - for projects with data migration patterns
- _...or any other architectural aspect significant to the project_

---

#### For Web Frontend

```markdown
## Components & UI Architecture

[Component organization, patterns (atomic, feature-based), reusability]

## State Management

[Local state, global state, server state caching]

## Routing

[Route structure, navigation patterns, guards]

## Styling Architecture

[CSS approach, theming, responsive design]

## API Integration

[Service layer, data fetching, error handling]

## Internationalization (i18n)

[If applicable - translation system, locale handling]
```

---

#### For Web Backend / API

```markdown
## API Design

[Endpoints, REST/GraphQL conventions, versioning]

## Request Lifecycle

[Middleware chain, validation, response formatting]

## Database Layer

[ORM/query patterns, migrations, connections]

## Authentication & Authorization

[Auth flow, session/token management, RBAC]

## Error Handling

[Error types, logging, client responses]

## Background Jobs

[If applicable - queues, scheduled tasks, workers]
```

---

#### For Desktop Application

```markdown
## Window Management

[Main window, dialogs, multi-window architecture]

## Native Platform Integration

[System APIs, file system, notifications, tray]

## IPC Architecture

[If applicable - main/renderer communication, message protocols]

## Cross-Platform Considerations

[Platform-specific code, abstractions, conditional compilation]

## Packaging & Distribution

[Installers, updates, code signing]
```

---

#### For CLI Tool

```markdown
## Command Structure

[Commands, subcommands, argument parsing]

## Input/Output Handling

[stdin/stdout/stderr, interactive mode, piping]

## Configuration Management

[Config files, environment variables, precedence]

## Error Handling & Exit Codes

[Error types, user-friendly messages, exit code conventions]
```

---

#### For Library/SDK

```markdown
## Public API Surface

[Exported modules, main entry points, API stability]

## Internal Architecture

[Private modules, helper utilities]

## Versioning Strategy

[SemVer policy, breaking changes, deprecation]

## Integration Patterns

[How consumers use the library, common patterns]

## Documentation

[API docs generation, examples, guides]
```

---

#### For Embedded/Firmware

```markdown
## Hardware Abstraction Layer (HAL)

[Peripheral abstractions, board support packages]

## Memory Architecture

[Memory map, stack/heap, static allocation, DMA]

## Interrupt Handling

[ISR design, priorities, critical sections]

## Peripheral Drivers

[UART, SPI, I2C, GPIO, ADC, timers, etc.]

## Boot Process

[Startup sequence, initialization order, watchdog]

## Power Management

[Sleep modes, wake sources, power budgeting]

## Real-Time Constraints

[Timing requirements, latency budgets, determinism]

## Communication Protocols

[Protocol stacks, message formats, error recovery]
```

---

#### For Game Development

```markdown
## Game Loop Architecture

[Update/render cycle, fixed timestep, frame timing]

## Entity/Component System

[Entity management, component patterns, systems]

## Rendering Pipeline

[Graphics API, shaders, scene graph, culling]

## Input Handling

[Input abstraction, rebinding, multiple devices]

## Asset Pipeline

[Asset loading, formats, streaming, caching]

## Audio System

[Sound engine, music, spatial audio]

## Physics & Collision

[Physics engine, collision detection, response]
```

---

### Closing Universal Sections (ALL projects)

```markdown
## Data Flow Diagrams

[Mermaid diagrams showing key interactions]

## Error Handling Strategy

[How errors are handled, logged, and reported]

## Testing Strategy

[Test types, frameworks, coverage expectations]

## Performance Considerations

[Optimization strategies, profiling, benchmarks]

## Security Considerations

[If applicable - threat model, mitigations]

## Deployment

[How the project is deployed/distributed/flashed]

## Conclusion

[Summary and key architectural decisions]
```

---

## Phase 5: User Review & Validation

After generating ARCHI.md, **stop and request user review**.

### Present to User

Summarize what was generated:

1. **Project classification** - What type was detected and why
2. **Sections included** - List the sections added to ARCHI.md
3. **Custom sections** - Highlight any sections added beyond the standard templates
4. **Key architectural decisions** documented

### Ask for Feedback

**Use the `AskUserQuestion` tool** to present the user with a structured choice:

- **Question**: "Please review the generated ARCHI.md. How would you like to proceed?"
- **Options**:
  1. **"Approved"** — ARCHI.md looks good, proceed to Phase 6
  2. **"Request changes"** — I have corrections or modifications
  3. **"Add sections"** — I'd like additional sections added

### Handle Feedback

- **If "Approved"**: Proceed to Phase 6
- **If "Request changes"**: Make the requested modifications, then re-present for validation using `AskUserQuestion` again
- **If "Add sections"**: Add them, then re-present for validation using `AskUserQuestion` again
- **If "Other" (custom input)**: Handle accordingly

**Do NOT proceed to Phase 6 until the user explicitly approves the ARCHI.md.**

---

## Phase 6: Update TRIP Skills

After user validation, update the other TRIP skill files based on the **actual codebase architecture** documented in ARCHI.md.

> **IMPORTANT**: The examples below are **recommendations and starting points**, not templates to copy blindly. Always tailor the content based on:
>
> - What was actually discovered during codebase exploration (Phase 2)
> - The patterns and conventions documented in the validated ARCHI.md (Phase 5)
> - The specific tools, frameworks, and practices used in **this** project

### Skills to Update:

1. **`TRIP-1-plan`** - Technical considerations, guidance sections, documentation impact candidates
2. **`TRIP-2-implement`** - Testing gate commands
3. **`TRIP-3-release`** - Version file, main branch
4. **`codex-code-review`** - `checklist.md` and `cr-template.md` adapted to actual architecture

---

### 6.1 Universal Updates (ALL skills)

**Project Name**: Replace the `[PROJECT_NAME]` placeholder with the actual project name in all skill files.

---

### 6.2 Update `TRIP-1-plan`

**A. Technical Considerations Section**

Replace the `[ADAPT_TO_PROJECT]` markers in the Technical Considerations section with concerns **relevant to this specific codebase**. The examples below are starting points - adapt based on what ARCHI.md documents:

- If the project uses specific patterns (e.g., a custom state management approach), include them
- If certain concerns don't apply (e.g., no i18n in this project), omit them
- If the project has unique concerns (e.g., regulatory compliance, specific hardware constraints), add them

**For Web Frontend:**

```markdown
## Technical Considerations

- **Pattern Usage**: Which existing patterns to follow (from ARCHI.md)
- **Performance**: useMemo, useCallback, lazy loading, code splitting
- **Accessibility**: Keyboard navigation, ARIA labels, focus management
- **Responsive Design**: Mobile/tablet/desktop breakpoints
- **Edge Cases**: Empty states, loading states, error states
- **Theming**: Light/dark mode support
```

**For Web Backend:**

```markdown
## Technical Considerations

- **Pattern Usage**: Which existing patterns to follow (from ARCHI.md)
- **Database Impact**: Schema changes, migrations, query performance
- **API Design**: REST conventions, versioning, backwards compatibility
- **Security**: Input validation, authentication, authorization
- **Error Handling**: Error codes, logging, client responses
- **Edge Cases**: Rate limiting, timeouts, partial failures
```

**For CLI Tool:**

```markdown
## Technical Considerations

- **Pattern Usage**: Which existing patterns to follow (from ARCHI.md)
- **User Experience**: Help text, progress indicators, error messages
- **Configuration**: Precedence (flags > env > config file > defaults)
- **Exit Codes**: Success/failure codes, scripting compatibility
- **Edge Cases**: Invalid input, missing files, permission errors
- **Cross-Platform**: Path handling, line endings, shell compatibility
```

**For Embedded/Firmware:**

```markdown
## Technical Considerations

- **Pattern Usage**: Which existing patterns to follow (from ARCHI.md)
- **Memory Impact**: Stack usage, heap allocation, static vs dynamic
- **Timing**: Interrupt latency, real-time constraints, blocking calls
- **Power**: Sleep mode impact, wake sources, power budget
- **Hardware Dependencies**: Pin assignments, peripheral conflicts
- **Edge Cases**: Startup race conditions, watchdog, error recovery
```

**For Library/SDK:**

```markdown
## Technical Considerations

- **Pattern Usage**: Which existing patterns to follow (from ARCHI.md)
- **API Design**: Public surface, naming conventions, consistency
- **Backwards Compatibility**: Breaking changes, deprecation strategy
- **Documentation**: API docs, examples, migration guides
- **Edge Cases**: Null handling, error propagation, thread safety
```

_Adapt based on actual project architecture. Only include considerations that are relevant to this codebase._

**B. Guidance Sections**

Replace the `[ADAPT_TO_PROJECT: Guidance Sections]` comment block with guidance that matches **the actual architectural patterns in ARCHI.md**.

Look at the major component types documented and create guidance for each. Examples:

**For Web Frontend** (keep existing React sections)

**For Embedded/Firmware:**

```markdown
## For New Peripheral Drivers

Required analysis:

- Hardware interface (registers, pins, timing)
- Interrupt requirements (priority, latency)
- DMA usage if applicable
- Power management impact
- Error handling strategy

## For New Communication Protocols

Required analysis:

- Message format and framing
- Error detection/correction
- Timeout and retry strategy
- Buffer management
- Thread/interrupt safety
```

**For CLI Tool:**

```markdown
## For New Commands

Required analysis:

- Command name and aliases
- Required and optional arguments
- Input sources (args, stdin, files)
- Output format (human, JSON, etc.)
- Error messages and exit codes

## For Configuration Changes

Required analysis:

- Config key naming
- Default value
- Validation rules
- Documentation updates
```

_These are examples. Create guidance sections based on what's actually in ARCHI.md - the major patterns, layers, and component types specific to this project._

**C. Documentation Impact Candidates**

Replace the `[ADAPT_TO_PROJECT]` marker inside the plan template's **Documentation Impact** section with the project's actual living documentation — every non-TRIP document that code changes can leave stale, one bullet per doc with when it's affected. Draw from what Phase 2 discovered:

- `README.md` — quick start, repo structure tree, command reference
- Module/subdirectory READMEs
- Operations or user manuals
- Reference `.md` specs living next to the code
- Contributor guides (`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`)

This list is what makes the TRIP-3 Documentation Sync step effective — a doc missing here tends to drift silently.

Also resolve the `[ADAPT_TO_PROJECT]` marker in the **Prerequisites** list at the top of `TRIP-1-plan`: if the project has living docs a plan must respect beyond ARCHI.md (e.g. an operations manual), list them with the condition under which they must be read; otherwise delete that line.

**D. Custom Plan Sections**

**Use the `AskUserQuestion` tool** to ask:

- **Question**: "Are there any project-specific sections you want included in every plan?"
- **Options**:
  1. **"No custom sections"** — Standard plan sections are sufficient
  2. **"Yes, add custom sections"** — I want to specify additional sections (provide details via "Other")

If the user selects "Yes" or provides custom input, add the specified sections to the plan template.

---

### 6.3 Update `TRIP-2-implement` and `TRIP-3-release`

The testing gate in `TRIP-2-implement` and the standalone-verification block in `TRIP-3-release` share the same command placeholders. The release ceremony customizations (version file, main branch) live in `TRIP-3-release`:

**A. Version File Location**

Update Step 2 to reference the actual version file:

- `package.json` for Node.js
- `Cargo.toml` for Rust
- `setup.py` / `pyproject.toml` for Python
- `CMakeLists.txt` or `version.h` for C/C++
- Or other location identified in Phase 2

**B. Main Branch**

Replace the `[MAIN_BRANCH]` placeholder in `TRIP-3-release` (the Documentation Sync diff command and the fast-forward merge step) with the repo's default branch name. Detect it with:

```bash
basename "$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || git branch --show-current)"
```

(The fallback covers repos without a remote — there, the branch Init runs on is the main branch.)

**C. Codex Review Test Commands**

Replace the `[LINT_COMMAND]`, `[TYPECHECK_COMMAND]`, and `[TEST_COMMAND]` placeholders in the TRIP-2 Testing Gate AND the TRIP-3-release standalone-verification block with the **actual commands** for this project (from ARCHI.md or discovered during exploration). For example:

- Python: `uv run ruff check .`, `uv run mypy`, `uv run pytest -q`
- Node.js: `npm run lint`, `npx tsc --noEmit`, `npm test`
- Rust: `cargo clippy`, (no separate typecheck), `cargo test`
- Go: `golangci-lint run`, (no separate typecheck), `go test ./...`

If the project doesn't have a lint or typecheck step, remove the corresponding line entirely rather than leaving a placeholder.

---

### 6.4 Adapt the Code Review Checklist (`codex-code-review`)

The Codex code review reads two project-adapted files in `.claude/skills/codex-code-review/`: `checklist.md` (criteria — single source of truth) and `cr-template.md` (output skeleton). During Init, update both — leave the skill's `SKILL.md`, prompts and scripts as-is.

**A. Adapt `checklist.md`**

`checklist.md` ships with generic sections (Functional Requirements, Code Quality, Architectural Compliance, Error Handling, Security, Performance). Replace the `[ADAPT_TO_PROJECT]` comment block with **project-specific checklist sections** based on what matters for this codebase as documented in ARCHI.md.

The examples below are starting points — include only what's relevant and add project-specific checks:

**For Web Backend:**

```markdown
### 4. API Best Practices

- [ ] Input validation on all endpoints
- [ ] Consistent error response format
- [ ] Proper HTTP status codes
- [ ] API versioning respected
- [ ] Rate limiting considered
```

**For Embedded/Firmware:**

```markdown
### 4. Resource Management

- [ ] Stack usage analyzed
- [ ] No memory leaks
- [ ] DMA buffers aligned
- [ ] Peripheral resources released
- [ ] Power modes handled correctly

### 5. Timing & Safety

- [ ] Real-time constraints met
- [ ] Watchdog considerations addressed
- [ ] Race conditions prevented
- [ ] Error recovery implemented
```

**For CLI Tool:**

```markdown
### 4. User Experience

- [ ] Help text is clear and complete
- [ ] Error messages are actionable
- [ ] Exit codes are correct
- [ ] Progress feedback for long operations
```

_Build from ARCHI.md — what patterns does this project use? What quality criteria matter? What are common pitfalls?_

Also update the existing generic sections (3. Architectural Compliance, etc.) with project-specific items if the generic ones are too vague. Remove sections that don't apply.

**B. Update `cr-template.md`**

Update the Checklist section in `cr-template.md` to list the **actual section names** from the adapted `checklist.md`. The template ships with generic section names (1-6); after adapting the checklist, the template's section list must match.

**C. Update Approval Gate**

If the project has specific build/test commands, update the "Review Completion Criteria" section at the bottom of `checklist.md` with the actual commands (e.g., `uv run pytest` instead of generic "All existing tests pass").

---

## Phase 7: Create Supporting Files

Now that ARCHI.md is validated, create the supporting documentation files adapted to the project.

### 1. `docs/2-changelog/changelog_table.md` - Version Tracking

**Version for first entry**: Take the current version identified in Phase 2 and increment the patch number. For example:

- Current `1.2.3` → First entry `1.2.4`
- Current `0.5.0` → First entry `0.5.1`
- No version found → First entry `0.1.0`

It is a one-line-per-release index; each release's detail lives in its own `docs/2-changelog/vx.y.z.md` file.

```markdown
# Changelog Table

| Version   | Commit Message                  |
| --------- | ------------------------------- |
| `X.Y.Z+1` | chore: initialize TRIP workflow |
```

- **Version**: SemVer format in backticks (e.g., `1.0.0`, `0.2.1`)
- **Commit Message**: One-line description of the change

New rows are added at the **top** of the table.

---

### 2. `docs/4-unit-tests/TESTING.md` - Testing Guidelines

**Adapt based on the validated ARCHI.md** - use the actual test framework, commands, and conventions discovered during codebase exploration. This file is the project's testing guide: `TRIP-2-implement` sends the agent here when it writes tests.

```markdown
# Testing Guidelines

## Test Framework

[From ARCHI: actual framework name and version]

## Running Tests

\`\`\`bash
# All tests
[actual command]

# One file or one test
[actual command]

# With coverage
[actual command]
\`\`\`

## Test Organization

[From ARCHI: where tests live, naming conventions, file patterns]

## Testing Priorities

[What is worth testing in this project — e.g. parsers and state machines for firmware, endpoints and data access for a backend, argument parsing and exit codes for a CLI. Unit targets first, then the integration paths that matter.]

## Writing Tests

[Project-specific conventions observed in the codebase]

## Hard-to-Test Code

Seam ladder, cheapest first: exported pure helper → injectable client/adapter → module mock → integration/emulator test. Take the first rung that works; refactor for a seam only if the refactor is smaller than the feature being shipped. Before refactoring legacy code, pin it with characterization tests.

Uncovered risky paths: one line each in `docs/4-unit-tests/COVERAGE-DEBT.md` (`path | why hard | escape plan`). Delete a ledger line in the same change that gives its path meaningful coverage.

## Coverage Requirements

[From ARCHI: actual coverage thresholds if defined, or "Not defined" if none]
```

---

### 3. `docs/ARCHI-rules.md` - Architecture Maintenance Rules

**Adapt based on the validated ARCHI.md** - reference the actual sections and terminology used:

```markdown
# Architecture Documentation Rules

[ARCHI.md](ARCHI.md) documents the [Project Name] architecture. After each
task (new feature, refactor, bug fix), determine if ARCHI.md needs updating.

## When to Update

Update after ANY change that alters:

- Project structure (new directories, moved files)
- Technology stack (new dependencies, version changes)
- [List actual section names from ARCHI.md that might need updates]
- Data flow or component interactions
- Build or deployment processes

## How to Update by Change Type

### Major Feature / Refactor

Review: [List actual relevant section names from ARCHI.md]

### Minor Feature / Enhancement

Update: [List actual relevant section names from ARCHI.md]

### Bug Fix

Usually no update needed, unless it reveals/fixes an architectural flaw

### Dependency Changes

Update: Technology Stack, and any affected architectural sections

## Guidelines

- Be precise and factual - reflect the actual codebase
- Be concise - enough detail to understand, not implementation specifics
- Update diagrams when data flow changes
- Reference actual file paths
```

---

## Post-Initialization Checklist

- [ ] Core `docs/` folders created (Phase 1): 1-plans, 2-changelog, 3-code-review, 4-unit-tests, 6-memo
- [ ] Codebase thoroughly explored (Phase 2)
- [ ] Current version identified (Phase 2)
- [ ] Project type correctly classified (Phase 3)
- [ ] ARCHI.md generated with appropriate sections (Phase 4)
- [ ] Custom sections added where relevant (Phase 4)
- [ ] **User reviewed and approved ARCHI.md** (Phase 5)
- [ ] **TRIP skills updated** (Phase 6):
  - [ ] `[PROJECT_NAME]` placeholder replaced in all skills
  - [ ] `TRIP-1-plan`: `[ADAPT_TO_PROJECT]` markers replaced with actual technical considerations
  - [ ] `TRIP-1-plan`: Guidance sections replaced with project-specific patterns
  - [ ] `TRIP-1-plan`: Documentation Impact candidates replaced with the project's actual living docs
  - [ ] `TRIP-1-plan`: Prerequisites `[ADAPT_TO_PROJECT]` line resolved (project docs listed, or line deleted)
  - [ ] `TRIP-1-plan`: Custom plan sections added (if user requested)
  - [ ] `TRIP-2-implement`: Testing gate commands (`[LINT_COMMAND]`, `[TYPECHECK_COMMAND]`, `[TEST_COMMAND]`) replaced with actual commands
  - [ ] `TRIP-3-release`: `[VERSION_FILE]` placeholder replaced
  - [ ] `TRIP-3-release`: `[MAIN_BRANCH]` placeholder replaced
  - [ ] `TRIP-3-release`: Standalone-verification commands replaced with actual commands
  - [ ] `codex-code-review/checklist.md`: `[ADAPT_TO_PROJECT]` markers replaced with project-specific checklist sections
  - [ ] `codex-code-review/cr-template.md`: Checklist section names updated to match adapted `checklist.md`
- [ ] changelog_table.md initialized with version+1 (Phase 7)
- [ ] TESTING.md created with the project's test commands, organization and priorities (Phase 7)
- [ ] ARCHI-rules.md created, referencing actual ARCHI sections (Phase 7)

---

## Notes for the Agent

- **Explore thoroughly**: Read key files to understand the project before classifying
- **Be adaptive**: The section list is a guide, not a rigid template. Add custom sections when the codebase has architectural patterns not covered by the templates
- **Use correct terminology**: Embedded projects have "peripherals", not "components". CLI tools have "commands", not "routes"
- **Ask if uncertain**: If the project type is ambiguous, ask the user
- **Focus on what exists**: Document the actual architecture, not an idealized version
- **Diagrams matter**: Mermaid diagrams help visualize complex flows regardless of project type
- **User review is mandatory**: Never skip Phase 5. The user must validate the ARCHI.md before proceeding
- **Iterate if needed**: If the user requests changes, make them and re-present for approval
