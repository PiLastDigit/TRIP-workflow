---
name: TRIP-3-review
description: Review code following project standards
disable-model-invocation: true
argument-hint: "version or feature to review"
---

# Review Mode

You are now in **code review mode** for **[PROJECT_NAME]**.

Review: $ARGUMENTS

## Prerequisites - Read First

Before reviewing, you MUST read:

1. @docs/ARCHI.md - Verify architectural compliance
2. Related plan file in `docs/1-plans/` - Confirm implementation matches design
3. Related changelog entry in `docs/2-changelog/`

---

## Systematic Review Checklist

### 1. Functional Requirements

- [ ] Implementation logic matches requirements correctly
- [ ] Interface/API matches documented specifications
- [ ] Error scenarios handled with proper feedback
- [ ] Edge cases and boundary conditions validated

### 2. Code Quality

- [ ] Proper typing (no unjustified dynamic types)
- [ ] DRY principle - no code duplication
- [ ] KISS principle - not unnecessarily complex
- [ ] Consistent, descriptive naming conventions
- [ ] Complex logic has explanatory comments
- [ ] Files/modules not excessively large
- [ ] Imports/includes organized, unused ones removed

### 3. Architectural Compliance

- [ ] Code follows established patterns from ARCHI.md
- [ ] Proper separation of concerns
- [ ] Appropriate abstractions used
- [ ] Consistent with existing codebase style

<!-- [ADAPT_TO_PROJECT: Add project-specific checklist sections during Init]

Examples:

### 4. [Framework] Best Practices
- [ ] [Specific check 1]
- [ ] [Specific check 2]

### 5. [Domain-Specific Concerns]
- [ ] [Specific check 1]
- [ ] [Specific check 2]

-->

### 4. Error Handling

- [ ] Errors are properly caught and handled
- [ ] Error messages are clear and actionable
- [ ] Failure modes are graceful
- [ ] Logging is appropriate (not too verbose, not silent)

### 5. Security (if applicable)

- [ ] Input validation implemented
- [ ] No sensitive data exposed
- [ ] Authentication/authorization respected
- [ ] No obvious vulnerabilities

### 6. Performance

- [ ] No obvious performance issues
- [ ] Resource cleanup implemented (no leaks)
- [ ] Appropriate data structures used
- [ ] No unnecessary operations in hot paths

---

## Issue Severity Classification

**Critical (Block Deployment)**:

- Security vulnerabilities
- Data corruption risks
- Breaking API/interface changes
- Authentication bypasses

**Major (Require Immediate Fix)**:

- Incorrect business logic
- Significant performance degradation
- Missing error handling
- Compilation/build errors

**Minor (Should Fix)**:

- Code style inconsistencies
- Missing documentation
- Code duplication
- Missing edge case handling

**Suggestions (Nice to Have)**:

- Performance optimizations
- Readability improvements
- Additional test coverage

---

## Review Completion Criteria

Minimum for approval:

- [ ] All functional requirements implemented
- [ ] No critical or major issues remaining
- [ ] Build/compilation successful
- [ ] All existing tests pass
- [ ] Documentation updated per project standards

---

## Post-Review: Create Review File

After completing the review, create a summary file in `docs/3-code-review/`.

**File naming**: `CR_wa_vx.y.z.md` (a=project week, x.y.z=version)

**Template**:

```markdown
# Code Review: [Feature/Change Name]

**Review Date**: [Date]
**Version**: x.y.z
**Files Reviewed**: [List of files]

---

## Executive Summary

[Brief assessment - APPROVED / APPROVED with observations / NEEDS REVISION]

---

## Changes Overview

[What was changed and why]

---

## Findings

### Critical Issues

[List or "None"]

### Major Issues

[List or "None"]

### Minor Issues

[List or "None"]

### Suggestions

[List or "None"]

---

## Checklist

- [ ] Functional requirements verified
- [ ] Code quality (DRY, KISS) verified
- [ ] Architectural compliance verified
- [ ] Error handling reviewed
- [ ] Performance impact assessed

---

## Verdict

**[APPROVED / NEEDS REVISION]**

[Final notes]
```

**Important:** the checklist in the review file must be checked after the review is properly completed.
You should always check all the points, but if for any reason you didn't check it, add a note explaining why.
