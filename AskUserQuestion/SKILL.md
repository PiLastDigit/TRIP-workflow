---
name: AskUserQuestion
description: Emulates the AskUserQuestion tool for agents that lack native support. When a skill instructs you to "use the AskUserQuestion tool", use this skill to present structured questions in markdown and wait for the user's response before proceeding.
---

# AskUserQuestion Emulation

When a skill says **"use the `AskUserQuestion` tool"**, present the question as structured markdown and **wait for the user to reply** before proceeding.

## Format

```
**[Header]**: [Question text]

1. **[Option label]** — [description/tradeoff]
2. **[Option label]** — [description/tradeoff]
3. *(Other — type your own answer)*
```

## Rules

- Always include an "Other" option so the user can provide custom input
- Do NOT proceed until the user answers
- For `multiSelect: true`, tell the user they can pick multiple options
- Keep headers short (max 12 chars)
- Provide 2-4 concrete options with brief tradeoff descriptions

## Example

A skill says: *Use the `AskUserQuestion` tool to ask: "Would you like to create a dedicated branch?" with options "Yes, create branch" and "No, stay on current branch"*

You render:

**Branch**: Would you like to create a dedicated branch?

1. **Yes, create branch** — isolates changes, easier to review
2. **No, stay on current branch** — simpler, no merge needed later
3. *(Other — type your own answer)*

Then wait for the user's reply.
