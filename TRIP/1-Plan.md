---
description: "Plan a new feature following project standards"
---

# Planning Mode

You are now in **planning mode** for **[PROJECT_NAME]**.

## Prerequisites - Read First

Before creating any plan, you MUST read ALL THE LINES of:

1. @docs/ARCHI.md - Understand current system architecture

## Your Task

Plan the following feature: $ARGUMENTS

---

## Step 1: Discovery & Clarification (Interactive)

**Do NOT start writing a plan immediately.** First, engage in a discovery conversation to fully understand the user's intent.

### 1.1 Initial Understanding

After reading the feature request, summarize your understanding in 2-3 sentences and ask clarifying questions:

> **"Here's what I understand: [your summary]"**
>
> **"Before I create the plan, I have a few questions:"**
>
> 1. [Question about scope/boundaries]
> 2. [Question about expected behavior]
> 3. [Question about edge cases or constraints]

Focus questions on:

- **Scope**: What's included vs excluded?
- **Behavior**: How should it work from the user's perspective?
- **Constraints**: Any technical limitations, deadlines, or dependencies?
- **Priority**: What's most important if trade-offs are needed?

### 1.2 Iterate Until Clear

After user answers, either:

- **Ask follow-up questions** if new ambiguities emerged
- **Propose an approach** and ask for confirmation

> **"Based on your answers, I'm thinking the approach would be: [brief description]"**
>
> **"Does this align with what you have in mind? Anything to adjust?"**

### 1.3 Confirm Before Planning

Only proceed to Step 2 when the user confirms the understanding is correct.

> **"Great, I have a clear picture now. I'll create the plan document."**

**Minimum: 1 round of questions. Maximum: 3 rounds** (if still unclear after 3 rounds, summarize what you know and proceed with noted assumptions).

---

## Step 2: Plan Document Creation

Once understanding is confirmed, create the plan document.

### File Naming

Depending on the feature (major, minor, patch), propose a new version using SemVer (x.y.z) and create:
`docs/1-plans/[version]_[feature-name].plan.md`

### Required Sections

```markdown
# [Feature Name] Implementation Plan

## Overview

[2-4 sentences describing the feature and its purpose]

## Problem Statement (if applicable)

[Current limitations/issues this feature addresses]

## Solution Architecture

[High-level design approach]

## Implementation Details

### 1. [Component/Module/File Name]

**File**: `path/to/file`

[Detailed description of changes needed]

**Current state** (if modifying existing):
[Describe what currently exists]

**Modifications**:

- Specific change 1 (around line X)
- Specific change 2 (around line Y)

### 2. [Next Component/Module/File]

[Continue with same pattern]

## Technical Considerations

[ADAPT_TO_PROJECT: List the technical concerns relevant to this project type]

- **Pattern Usage**: Which existing patterns to follow (from ARCHI.md)
- **[Concern 1]**: [Description]
- **[Concern 2]**: [Description]
- **Edge Cases**: [Relevant edge cases for this feature]

## Files to Modify/Create

[Comprehensive numbered list with purposes]

1. `path/to/file1` (modify) - Purpose description
2. `path/to/file2` (new) - Purpose description

## Type Definitions (if applicable)

[New types, interfaces, structs, or modifications to existing ones]

## Performance & Cost Impact (if applicable)

[Expected performance implications]

## Backward Compatibility (if applicable)

[Migration strategy if needed]

## To-dos

### Phase 1: [Phase Name] (if multiple phases are needed) or simply skip title if only one phase is needed

- [ ] Task description
- [ ] Another task

### Phase 2: [Phase Name] (if applicable)

- [ ] Task description
- [ ] Another task

**Note**: For simple plans, a single phase is sufficient. Split into multiple phases only for complex features requiring sequential implementation.

**Note**: Testing is OUT OF SCOPE for planning - will be handled separately.
```

## Quality Standards

- **Zero Ambiguity**: Every step must be clear and actionable
- **File-Level Specificity**: List exact files and functions to modify
- **Architecture Alignment**: Must conform to existing patterns in ARCHI.md
- **Risk Assessment**: Highlight potential failure points

---

## Step 3: Plan Review & Validation

After creating the plan document, present a summary to the user:

> **"I've created the plan. Here's a summary:"**
>
> - **Feature**: [name]
> - **Approach**: [1-2 sentences]
> - **Files affected**: [count] files ([list key ones])
> - **Estimated complexity**: [simple/moderate/complex]
>
> **"Please review the plan at `docs/1-plans/x.y.z_feature-name.plan.md`"**
>
> **"Any changes you'd like me to make before we proceed to implementation?"**

Handle feedback:

- **If user requests changes**: Update the plan and re-present
- **If user approves**: The plan is ready for `/2-Implement`

---

## IMPORTANT: No Code Implementation

**DO NOT write code snippets or implement anything during planning.**

This is a high-level planning phase only. Your plan should describe:

- WHAT needs to be done (features, changes, structures)
- WHERE changes will happen (files, modules, functions)
- WHY certain approaches are chosen (trade-offs, rationale)

But NOT:

- Actual code implementations
- Detailed algorithm code

Keep it architectural and descriptive. Code comes in the `/2-Implement` phase.

## [ADAPT_TO_PROJECT: Guidance Sections]

<!--
During Init, replace this section with project-specific guidance.
Examples:

For Web Frontend:
## For New UI Components
## For Service Layer Additions
## For Custom Hooks

For Embedded:
## For New Peripheral Drivers
## For New Communication Protocols

For CLI:
## For New Commands
## For Configuration Changes

For Backend:
## For New API Endpoints
## For Database Changes
-->
