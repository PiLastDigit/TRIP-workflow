---
name: TRIP-compact
description: Compact ARCHI.md when it exceeds recommended size - smart compression without losing relevance
disable-model-invocation: true
---

# ARCHI Compaction Mode

You are now in **compaction mode** - intelligently reducing ARCHI.md size while preserving its value.

## Why Compact?

ARCHI.md should not exceed _~20k tokens_. A bloated ARCHI:

- Consumes tokens that could be used for actual work
- Slows down every command that reads it
- May contain redundant or outdated information
- Defeats the purpose of "balanced detail vs token usage"

## Your Task

Compact: @docs/ARCHI.md

---

## Step 1: Assess Current State

First, measure the actual token count using the bundled script:

```bash
bash .claude/skills/TRIP-compact/count-tokens.sh docs/ARCHI.md
```

Then read the full ARCHI.md and evaluate:

1. **Identify bloat sources**:
   - Verbose explanations where concise would suffice
   - Redundant information repeated across sections
   - Implementation details that belong in code comments, not architecture docs
   - Overly detailed file listings
   - Excessive examples

**If token count > 20,000**, report the assessment to the user, then **use the `AskUserQuestion` tool**:

- **Question**: "ARCHI.md is at ~[X] tokens (target: ~10,000-15,000). Main bloat sources: [list top 3-5]. Proceed with compaction?"
- **Options**: "Yes, compact" (proceed with compaction strategies), "No, leave as-is" (stop here)

**If token count <= 20,000**, report to the user, then **use the `AskUserQuestion` tool**:

- **Question**: "ARCHI.md is at ~[X] tokens — within acceptable range. Would you still like to compact it further?"
- **Options**: "Yes, compact anyway" (proceed with compaction), "No, it's fine" (stop here)

If "No" in either case, stop here.

---

## Step 2: Compaction Strategies

Apply these strategies **in order of priority**:

### 2.1 Remove Redundancy (First Pass)

- Eliminate repeated information across sections
- Consolidate overlapping descriptions
- Remove "see above" or "as mentioned" patterns - restructure instead

### 2.2 Increase Information Density

Transform verbose patterns into dense ones:

**Before (verbose):**

```markdown
## Authentication System

The authentication system in this project uses Supabase for managing user
authentication. When a user logs in, the system calls the Supabase auth API
to verify their credentials. After successful authentication, a session is
created and stored. The session token is then used for subsequent API calls
to authenticate the user. We also support role-based access control where
users can have either an ADMIN role or a USER role, which determines what
actions they can perform in the application.
```

**After (dense):**

```markdown
## Authentication

**Provider**: Supabase Auth
**Flow**: Login → Supabase API → Session created → Token for subsequent calls
**RBAC**: `ADMIN` (full access) | `USER` (read-only library, settings)
```

### 2.3 Convert Prose to Structured Formats

- Use tables instead of paragraphs for comparisons
- Use bullet points instead of sentences
- Use `code` for paths, commands, types
- Use diagrams (mermaid) to replace lengthy flow descriptions

### 2.4 Collapse Implementation Details

Keep: **What** and **Why**
Remove: **How** (implementation specifics)

**Before:**

```markdown
The useTranscription hook manages the transcription state by using useState
for the segments array, useEffect to fetch data when videoId changes, and
useCallback for memoized handlers. It also implements error boundaries...
```

**After:**

```markdown
`useTranscription`: Orchestrates transcription data fetching and state management
```

### 2.5 Summarize File Listings

**Before:**

```markdown
- `src/components/auth/LoginForm.tsx` - Login form component
- `src/components/auth/LogoutButton.tsx` - Logout button component
- `src/components/auth/RegisterForm.tsx` - Registration form component
- `src/components/auth/ForgotPassword.tsx` - Password reset component
- `src/components/auth/AuthProvider.tsx` - Auth context provider
```

**After:**

```markdown
- `src/components/auth/` - Auth UI components (Login, Logout, Register, ForgotPassword, AuthProvider)
```

### 2.6 Use References Instead of Duplication

Instead of explaining the same pattern in multiple places:

```markdown
See [Pattern Name](#pattern-name) for details.
```

---

## Step 3: Preserve Critical Information

**NEVER compress or remove:**

- Project overview and purpose
- Technology stack with versions
- Directory structure (can be summarized but not removed)
- Core architectural principles
- Key patterns and their locations
- Data flow diagrams
- API contracts/interfaces
- Configuration requirements
- Build/deployment commands

**These are the backbone** - compress everything else first.

---

## Step 4: Validate Compression

After compaction, verify:

- [ ] All major sections still present
- [ ] Technology stack complete
- [ ] Directory structure understandable
- [ ] Key patterns still documented
- [ ] No broken internal links
- [ ] Mermaid diagrams still valid
- [ ] New developer could still onboard with this doc

---

## Step 5: Measure & Present Changes

Run the script again on the compacted file:

```bash
bash .claude/skills/TRIP-compact/count-tokens.sh docs/ARCHI.md
```

Present the compaction results to the user, then **use the `AskUserQuestion` tool**:

- **Question**: "Compaction complete: ~[X] → ~[Y] tokens ([Z]% reduction). Changes: [brief summary]. How does the compacted ARCHI.md look?"
- **Options**: "Looks good" (compaction is complete), "Restore some detail" (specific sections need more detail), "Too aggressive" (undo and try lighter compaction)

---

## Step 6: Iterate if Needed

If user identifies sections that need more detail:

- Restore specific details for those sections
- Compensate by further compressing less critical sections

If still over 15k tokens after smart compression:

- Consider splitting into ARCHI.md (core) + ARCHI-detailed.md (deep dives)
- Only the core file is read by default

---

## Compaction Principles

1. **Density over length** - Same information, fewer words
2. **Structure over prose** - Tables, bullets, code blocks
3. **References over repetition** - Link, don't duplicate
4. **What/Why over How** - Architecture, not implementation
5. **Current over historical** - Remove obsolete content
6. **Essential over comprehensive** - 80/20 rule applies

---

## When to Run This Skill

- ARCHI.md feels sluggish to read
- You notice redundant information
- Periodically (every few months) as maintenance
- When token usage becomes a concern
