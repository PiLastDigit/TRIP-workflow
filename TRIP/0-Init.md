---
description: "Initialize TRIP workflow in a new project - creates docs structure and generates ARCHI.md"
---

# TRIP Initialization Mode

You are now in **initialization mode** for setting up the TRIP workflow.

## What is TRIP?

TRIP is a structured development workflow with four phases:

- **P**lan - Design features before implementation
- **I**mplement - Build with proper documentation
- **R**eview - Systematic code review
- **T**est - Comprehensive testing

Why call it TRIP instead of PIRT? Because that's what will be left to us while AI takes care of the rest 🍄

---

## Your Task

Initialize the TRIP workflow for the project: $ARGUMENTS

If no project name provided, ask the user for the project name before proceeding.

---

## Phase 1: Create Documentation Folder Structure

Create the following folder structure if it doesn't exist:

```
docs/
├── 1-plans/              # Feature planning documents
├── 2-changelog/          # Version changelog files
├── 3-code-review/        # Code review documentation
└── 4-unit-tests/         # Unit testing documentation
```

Note: `5-tuto/` and `X-memo/` folders are created conditionally in Phase 6 after the tutorial choice (memo number depends on whether tutorials are enabled).

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

Ask the user:

> **"Please review the generated ARCHI.md. Do you have any comments, corrections, or additional sections you'd like me to add?"**

### Handle Feedback

- **If user requests changes**: Make the requested modifications to ARCHI.md
- **If user validates**: Proceed to Phase 6
- **If user wants to add sections**: Add them and re-present for validation

**Do NOT proceed to Phase 6 until the user explicitly approves the ARCHI.md.**

---

## Phase 6: Update TRIP Commands

After user validation, update the other TRIP command files based on the **actual codebase architecture** documented in ARCHI.md.

> **IMPORTANT**: The examples below are **recommendations and starting points**, not templates to copy blindly. Always tailor the content based on:
>
> - What was actually discovered during codebase exploration (Phase 2)
> - The patterns and conventions documented in the validated ARCHI.md (Phase 5)
> - The specific tools, frameworks, and practices used in **this** project

### Files to Update in `.claude/commands/TRIP/`:

1. **`1-Plan.md`** - Technical considerations, guidance sections
2. **`2-Implement.md`** - Version file, week offset, tutorials
3. **`3-Review.md`** - Review checklist adapted to actual architecture
4. **`4-Test.md`** - Test commands, structure, priorities

---

### 6.1 Universal Updates (ALL commands)

**Project Name**: Replace the `[PROJECT_NAME]` placeholder with the actual project name in all four command files.

---

### 6.2 Update `1-Plan.md`

**A. Technical Considerations Section**

Replace the `[ADAPT_TO_PROJECT: ...]` marker in the Technical Considerations section with concerns **relevant to this specific codebase**. The examples below are starting points - adapt based on what ARCHI.md documents:

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

**C. Custom Plan Sections**

Ask the user:

> **"Are there any project-specific sections you want included in every plan? (e.g., 'Database Migrations', 'API Documentation', 'Hardware Requirements')"**

If yes, add them to the plan template.

---

### 6.3 Update `2-Implement.md`

**A. Version File Location**

Replace the `[VERSION_FILE]` placeholder in Step 2 with the actual version file path:

- `package.json` for Node.js
- `Cargo.toml` for Rust
- `setup.py` / `pyproject.toml` for Python
- `CMakeLists.txt` or `version.h` for C/C++
- Or other location identified in Phase 2

**B. Week Offset**

The current calendar week becomes **Week 1** of the project.

Replace the `[WEEK_OFFSET_FORMULA]` placeholder with the actual formula. For example, if Init is run during calendar week 42:

```
Calculate project week: Calendar week minus 41 = Project week. (Week 42 = Week 1)
```

**C. Tutorial Generation**

Ask the user:

> **"Do you want the Implement command to generate learning tutorials after each implementation? (y/n)"**

**If NO**:

- Remove the `[TUTORIAL_STEP]` comment block entirely from `2-Implement.md`
- Do NOT create the `docs/5-tuto/` folder
- Create `docs/5-memo/` folder (memo takes slot 5)

**If YES**:

- Create the `docs/5-tuto/` folder
- Create `docs/6-memo/` folder (memo takes slot 6)
- Uncomment the `[TUTORIAL_STEP]` block in `2-Implement.md`
- Ask follow-up questions to customize the tutorial generation:

> **"To tailor the tutorials to your needs, please tell me:"**
>
> 1. **What is your current programming level?**
>    - Beginner (learning fundamentals)
>    - Intermediate (comfortable with basics, learning advanced concepts)
>    - Advanced (experienced, interested in deep dives and edge cases)
> 2. **What do you want to learn from these tutorials?**
>    - Language fundamentals (syntax, idioms, patterns)
>    - Framework/library specifics (React, Rust, etc.)
>    - Architecture & design patterns
>    - Performance & optimization
>    - Other: [let user specify]
> 3. **What style do you prefer?**
>    - Concise (key points, minimal explanation)
>    - Balanced (explanations with examples)
>    - Verbose (detailed explanations, multiple examples, diagrams)

Then replace the placeholders in the tutorial step with the user's answers:

- `[USER_LEVEL]` → user's programming level
- `[USER_LEARNING_FOCUS]` → what they want to learn
- `[USER_PREFERRED_STYLE]` → concise/balanced/verbose

---

### 6.4 Update `3-Review.md`

**A. Adapt Review Checklist**

Replace the `[ADAPT_TO_PROJECT: ...]` comment block with checklist sections based on **what matters for this specific codebase** as documented in ARCHI.md. The examples below are starting points - include only what's relevant and add project-specific checks:

**For Web Frontend** (example - adapt to actual patterns)

**For Web Backend:**

```markdown
### 3. Architectural Compliance

- [ ] Routes follow RESTful conventions
- [ ] Proper separation (controllers, services, repositories)
- [ ] Middleware used appropriately
- [ ] Database queries optimized
- [ ] Proper use of transactions

### 4. API Best Practices

- [ ] Input validation on all endpoints
- [ ] Consistent error response format
- [ ] Proper HTTP status codes
- [ ] API versioning respected
- [ ] Rate limiting considered

### 5. Security

- [ ] Authentication checked on protected routes
- [ ] Authorization logic correct
- [ ] No SQL injection vulnerabilities
- [ ] Sensitive data not logged
- [ ] CORS configured properly
```

**For Embedded/Firmware:**

```markdown
### 3. Architectural Compliance

- [ ] HAL abstractions used correctly
- [ ] Memory allocation follows project patterns
- [ ] Interrupt handlers are minimal
- [ ] Critical sections properly protected
- [ ] Follows coding standard

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
- [ ] Fail-safe behavior defined
```

**For CLI Tool:**

```markdown
### 3. Architectural Compliance

- [ ] Command structure follows patterns
- [ ] Configuration precedence respected
- [ ] Error handling consistent
- [ ] Logging follows conventions

### 4. User Experience

- [ ] Help text is clear and complete
- [ ] Error messages are actionable
- [ ] Exit codes are correct
- [ ] Progress feedback for long operations
- [ ] Quiet/verbose modes work correctly

### 5. Compatibility

- [ ] Works on target platforms
- [ ] Handles edge cases (missing files, permissions)
- [ ] Scriptable (proper stdout/stderr separation)
- [ ] No hardcoded paths
```

_These are examples. Build the checklist from ARCHI.md - what patterns does this project use? What quality criteria matter here? What are the common pitfalls to check for?_

---

### 6.5 Update `4-Test.md`

**A. Test Commands**

Replace the test command placeholders with the **actual test commands** used in this project:

- `[TEST_COMMAND_ALL]` → command to run all tests (e.g., `npm test`, `cargo test`, `pytest`)
- `[TEST_COMMAND_SPECIFIC]` → command to run a specific test file
- `[TEST_COMMAND_COVERAGE]` → command to run tests with coverage

**B. Test Structure**

Replace the `[ADAPT_TO_PROJECT: ...]` marker in the Test Structure section with actual test organization:

- Where tests are located
- Naming conventions
- Test file patterns

**C. Testing Priorities**

Replace the `[ADAPT_TO_PROJECT: ...]` comment block in Testing Priorities with what's **actually tested in this project**. Examples:

**For Embedded:**

```markdown
### Testing Priorities

**Unit Tests**:

- HAL mock testing
- Protocol parsers
- State machines
- Utility functions

**Hardware-in-Loop Tests**:

- Peripheral initialization
- Communication protocols
- Interrupt handling

**What to Test**:

- Normal operation paths
- Error conditions
- Boundary values
- Timing constraints
```

**For CLI:**

```markdown
### Testing Priorities

**Unit Tests**:

- Argument parsing
- Configuration loading
- Core logic functions

**Integration Tests**:

- Command execution end-to-end
- File I/O operations
- Error scenarios

**What to Test**:

- Valid inputs
- Invalid inputs (edge cases)
- Missing files/permissions
- Exit codes
```

---

## Phase 7: Create Supporting Files

Now that ARCHI.md is validated, create the supporting documentation files adapted to the project.

### 1. `docs/2-changelog/changelog_table.md` - Version Tracking

**Version for first entry**: Take the current version identified in Phase 2 and increment the patch number. For example:

- Current `1.2.3` → First entry `1.2.4`
- Current `0.5.0` → First entry `0.5.1`
- No version found → First entry `0.1.0`

This file has two sections:

**Section 1: Quick Reference Table**

```markdown
# Changelog Table

| Version   | Week | Commit Message                  |
| --------- | ---- | ------------------------------- |
| `X.Y.Z+1` | 1    | chore: initialize TRIP workflow |
```

- **Version**: SemVer format in backticks (e.g., `1.0.0`, `0.2.1`)
- **Week**: Project week number. Week 1 = the week when TRIP Init was run.
- **Commit Message**: One-line description of the change

**Section 2: Detailed Changelog Summary**

```markdown
# Changelog Summary

- **vX.Y.Z+1 (TRIP Initialization - Week 1, DD-MM-YYYY)**:
  - **Setup**: Initialized TRIP workflow with docs structure
  - **Documentation**: Generated ARCHI.md with [project type] architecture
  - **Files Added**: docs/ARCHI.md, docs/ARCHI-rules.md, docs/2-changelog/changelog_table.md, docs/4-unit-tests/TESTING.md
```

The summary provides context that the table cannot capture: rationale, impact, technical decisions, and file-level details. New entries are added at the **top** of each section.

---

### 2. `docs/4-unit-tests/TESTING.md` - Testing Guidelines

**Adapt based on the validated ARCHI.md** - use the actual test framework, commands, and conventions discovered during codebase exploration:

```markdown
# Testing Guidelines

## Test Framework

[From ARCHI: actual framework name and version]

## Running Tests

\`\`\`bash
[From ARCHI: actual test commands]
\`\`\`

## Test Organization

[From ARCHI: actual test file locations and patterns]

## Writing Tests

[Project-specific conventions observed in the codebase]

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

- [ ] Core `docs/` folders created (Phase 1): 1-plans, 2-changelog, 3-code-review, 4-unit-tests
- [ ] Codebase thoroughly explored (Phase 2)
- [ ] Current version identified (Phase 2)
- [ ] Project type correctly classified (Phase 3)
- [ ] ARCHI.md generated with appropriate sections (Phase 4)
- [ ] Custom sections added where relevant (Phase 4)
- [ ] **User reviewed and approved ARCHI.md** (Phase 5)
- [ ] **TRIP commands updated** (Phase 6):
  - [ ] `[PROJECT_NAME]` placeholder replaced in all commands
  - [ ] `1-Plan.md`: `[ADAPT_TO_PROJECT]` markers replaced with actual technical considerations
  - [ ] `1-Plan.md`: Guidance sections replaced with project-specific patterns
  - [ ] `1-Plan.md`: Custom plan sections added (if user requested)
  - [ ] `2-Implement.md`: `[VERSION_FILE]` placeholder replaced
  - [ ] `2-Implement.md`: `[WEEK_OFFSET_FORMULA]` placeholder replaced
  - [ ] `2-Implement.md`: Tutorial configured (if enabled: 5-tuto/ + 6-memo/ created, `[TUTORIAL_STEP]` uncommented + `[USER_*]` replaced; if disabled: 5-memo/ created, block removed)
  - [ ] `3-Review.md`: `[ADAPT_TO_PROJECT]` comment block replaced with project-specific checklist
  - [ ] `4-Test.md`: `[TEST_COMMAND_*]` placeholders replaced with actual commands
  - [ ] `4-Test.md`: `[ADAPT_TO_PROJECT]` markers replaced with actual test structure/priorities
- [ ] changelog_table.md initialized with version+1 (Phase 7)
- [ ] TESTING.md created, adapted to actual test setup (Phase 7)
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
