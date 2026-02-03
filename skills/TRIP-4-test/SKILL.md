---
name: TRIP-4-test
description: Write/run tests following project standards
disable-model-invocation: true
argument-hint: "component or feature to test"
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
# [ADAPT_TO_PROJECT: Replace with actual test commands during Init]

# Run all tests
[TEST_COMMAND_ALL]

# Run specific test
[TEST_COMMAND_SPECIFIC]

# With coverage
[TEST_COMMAND_COVERAGE]
```

### Test Structure

[ADAPT_TO_PROJECT: Describe where tests are located and naming conventions during Init]

### Testing Priorities

<!-- [ADAPT_TO_PROJECT: Replace with project-specific testing priorities during Init] -->

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
