---
name: TRIP-research
description: Exploratory research or spike - investigation without production code
disable-model-invocation: true
argument-hint: "what do you want to investigate?"
---

# Research Mode

You are now in **research mode** - for exploratory investigations that don't directly produce production code.

Use this for:

- Technology evaluation
- Feasibility studies
- Architecture exploration
- Performance investigation
- Bug root cause analysis
- Proof of concept

## Your Task

Research: $ARGUMENTS

---

## Step 0: Read fully @docs/ARCHI.md

## Step 1: Define Scope

### 1.1 Clarify the Question

> **"What specific question(s) are we trying to answer?"**

Document the research question(s) clearly:

- What do we need to find out?
- What would a successful outcome look like?
- What decisions will this research inform?

### 1.2 Compute Box

> **"How much thinking effort does this research require?"**

Based on the complexity of the question(s), suggest an appropriate thinking level:

| Level            | When to Use                               | Research Type                                               |
| ---------------- | ----------------------------------------- | ----------------------------------------------------------- |
| **quick**        | Simple lookup, straightforward answer     | "What's the syntax for X?"                                  |
| **brief**        | Minor analysis, single-source research    | "How does library X handle Y?"                              |
| **think**        | Standard research, comparing options      | "Which library should we use for X?"                        |
| **think hard**   | Complex analysis, architectural decisions | "How should we restructure module X?"                       |
| **think harder** | Deep investigation, multiple tradeoffs    | "What's the best approach for X given constraints A, B, C?" |
| **ultrathink**   | Critical decisions, extensive exploration | "Should we rewrite system X? What are all implications?"    |

**Use the `AskUserQuestion` tool** to confirm the thinking level:

- **Question**: "Based on this research scope, I suggest using `[level]` thinking. Does that seem appropriate?"
- **Options**: "Yes, use [level]" (proceed with suggested level), "Use a different level" (I want to adjust the thinking effort)

Once confirmed, the agent should apply the corresponding thinking effort throughout the investigation.

---

## Step 2: Research Plan

Create a lightweight research plan (not a full TRIP plan):

```markdown
# Research: [Topic]

## Question(s)

- [Primary question]
- [Secondary questions if any]

## Approach

1. [First thing to investigate]
2. [Second thing to investigate]
3. [...]

## Success Criteria

- [ ] [What we need to determine]
- [ ] [What we need to determine]

## Compute Level

[quick / brief / think / think hard / think harder / ultrathink]
```

---

## Step 3: Confirm & Start

Present the research plan summary to the user, then **use the `AskUserQuestion` tool** with two questions:

**Question 1** (header: "Start"):
- **Question**: "Research plan ready — Question: [primary question], Approach: [brief summary], Compute: [level]. Ready to start?"
- **Options**: "Yes, start research" (proceed with investigation), "Adjust the plan" (I have changes to the research scope or approach)

**Question 2** (header: "Output"):
- **Question**: "How do you want the findings delivered?"
- **Options**: "Chat only" (respond directly in the conversation), "Write a memo" (create a file in `docs/6-memo/`)

**If "Adjust"**: Modify the plan based on user feedback, then re-present using `AskUserQuestion`.

**If "Yes"**: Proceed with investigation. Remember the output preference for Step 5.

---

## Step 4: Investigation

Conduct the research:

### For Technology Evaluation

- Review documentation
- Check community/ecosystem health
- Look at alternatives
- Consider maintenance burden
- Assess learning curve

### For Feasibility Study

- Identify constraints
- Prototype critical parts (throwaway code OK)
- Identify risks and unknowns
- Estimate effort

### For Performance Investigation

- Establish baseline metrics
- Identify bottlenecks
- Test hypotheses
- Measure improvements

### For Bug Investigation

- Reproduce the issue
- Trace the root cause
- Identify contributing factors
- Consider similar vulnerabilities

---

## Step 5: Present Findings

### If "Chat only" was selected

Present the findings directly in the conversation, structured as:

1. **Summary** (2-3 sentences)
2. **Key Findings** (numbered list)
3. **Recommendations** (what to do, rationale, alternatives)
4. **Open Questions** (if any)

Then **use the `AskUserQuestion` tool**:

- **Question**: "Research complete. What would you like to do next?"
- **Options**: "Elaborate on findings" (dive deeper into specific results), "Save as memo" (write findings to `docs/6-memo/` after all), "Plan implementation" (create a TRIP plan based on these results), "Done" (no further action needed)

If "Save as memo": write the memo using the template below, then confirm the file location.

### If "Write a memo" was selected

Create findings document in `docs/6-memo/`:

**File**: `docs/6-memo/research_[date]_[topic].md`

```markdown
# Research: [Topic]

**Date**: DD-MM-YYYY
**Author**: [Name]

## Summary

[2-3 sentence executive summary]

## Questions Investigated

### Q1: [Question]

**Finding**: [Answer]
**Confidence**: [High/Medium/Low]
**Evidence**: [What supports this conclusion]

### Q2: [Question]

[...]

## Key Findings

1. **[Finding 1]**: [Details]
2. **[Finding 2]**: [Details]
3. **[Finding 3]**: [Details]

## Recommendations

- **Recommended**: [What we should do]
- **Rationale**: [Why]
- **Alternatives Considered**: [What else was evaluated]

## Open Questions

- [Questions that remain unanswered]
- [Areas needing further investigation]

## Next Steps

- [ ] [Action item 1]
- [ ] [Action item 2]

## Appendix (optional)

### Code Snippets / Prototypes

[Any throwaway code created during research]

### References

- [Links to documentation, articles, etc.]
```

Then **use the `AskUserQuestion` tool**:

- **Question**: "Research documented at `docs/6-memo/research_[date]_[topic].md`. What would you like to do next?"
- **Options**: "Elaborate on findings" (dive deeper into specific results), "Plan implementation" (create a TRIP plan based on these results), "Done" (no further action needed)

---

## What This Workflow Produces

- Clear recommendations
- Basis for future TRIP planning
- Optionally: documented findings in `docs/6-memo/`

## What This Workflow Does NOT Produce

- No production code
- No version bump
- No changelog entry
- No commits to main

---

## Transition to Implementation

If research concludes that implementation should proceed, **use the `AskUserQuestion` tool**:

- **Question**: "Based on this research, would you like me to create a TRIP plan for implementation?"
- **Options**: "Yes, create a plan" (use findings to inform `TRIP-1-plan`), "Not yet" (I'll decide later)

If yes, use findings to inform `TRIP-1-plan`.
