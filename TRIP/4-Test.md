---
description: "Write/run tests following project standards"
---

# Testing Mode

You are now in **testing mode** for **[PROJECT_NAME]**.

## Prerequisites - Read First

Before testing, you MUST read:
1. @docs/ARCHI.md - Understand system architecture
2. @docs/4-unit-tests/TESTING.md - Testing guidelines

## Your Task

Test: $ARGUMENTS

---

## Testing Guidelines

### Scope
- Only run tests for relevant files that changed (not the whole project)
- Focus on the new feature/fix/refactor

### Commands

```bash
# [ADAPT_TO_PROJECT: Replace with actual test commands]

# Run all tests
[TEST_COMMAND_ALL]

# Run specific test
[TEST_COMMAND_SPECIFIC]

# With coverage
[TEST_COMMAND_COVERAGE]
```

### Test Structure

[ADAPT_TO_PROJECT: Describe where tests are located and naming conventions]

### Testing Priorities

<!-- [ADAPT_TO_PROJECT: Replace with project-specific testing priorities]

Examples:

**Unit Tests**:
- [Component type 1]
- [Component type 2]
- Utility functions
- Core logic

**Integration Tests**:
- [Integration point 1]
- [Integration point 2]

**What to Test**:
- Happy path scenarios
- Error states and error handling
- Edge cases
- Boundary conditions
-->

**Unit Tests**:
- Core logic functions
- Utility functions
- Individual modules/components

**Integration Tests**:
- Module interactions
- External service integration
- End-to-end flows

**What to Test**:
- Happy path scenarios
- Error states and error handling
- Edge cases (null, empty, boundary values)
- Invalid inputs

---

## Post-Testing Summary

After completing tests, create a summary file:

**File**: `docs/4-unit-tests/wa_vx.y.z_test.md`
(a = project week, x.y.z = version)

**Content**:
```markdown
# Test Summary - Week a, V. x.y.z

## What Was Tested
[List of tested components/functions]

## Test Results
- Total tests: X
- Passed: X
- Failed: X
- Coverage: X%

## Key Findings
[Any issues discovered, edge cases found, etc.]

## Notes
[Additional context or recommendations]
```
