---
description: "Exploratory research or spike - investigation without production code"
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

Ask the user:

> **"Based on this research scope, I suggest using `[level]` thinking. Does that seem appropriate, or would you prefer a different level?"**

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

Present the research plan summary to the user:

> **"Here's the research plan:"**
>
> - **Question(s)**: [Primary question]
> - **Approach**: [Brief summary of investigation steps]
> - **Compute Level**: [level]
>
> **"Ready to start research? (y/n)"**

**If NO**: Adjust the plan based on user feedback.

**If YES**: Proceed with investigation.

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

## Step 5: Document Findings

Create findings document in `docs/6-memo/`:

**File**: `docs/6-memo/research_[date]_[topic].md`

```markdown
# Research: [Topic]

**Date**: DD-MM-YYYY
**Time Spent**: [X hours]
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

---

## Step 6: Present Findings

Summarize for the user:

> **"Research complete. Here's what I found:"**
>
> **Question**: [What we investigated]
> **Answer**: [Key finding]
> **Recommendation**: [What to do next]
> **Confidence**: [High/Medium/Low]
>
> **Full findings documented at**: `docs/6-memo/research_[topic]_[date].md`
>
> **"Would you like me to elaborate on any finding, or proceed to plan implementation based on these results?"**

---

## What This Workflow Produces

- ✅ Documented findings in `docs/6-memo/`
- ✅ Clear recommendations
- ✅ Basis for future TRIP planning

## What This Workflow Does NOT Produce

- ❌ Production code
- ❌ Version bump
- ❌ Changelog entry
- ❌ Commits to main

---

## Transition to Implementation

If research concludes that implementation should proceed:

> **"Based on this research, would you like me to create a TRIP plan for implementation?"**

If yes, use findings to inform `/TRIP:Plan`.
