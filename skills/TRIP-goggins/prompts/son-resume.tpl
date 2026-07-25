Next round for `{{TARGET}}`.

Run `git status -s` and `git diff HEAD` to resync first; the current tree is authoritative.
If the tree looks older than your last round, the judge rolled it back to a better-scoring
round on purpose — work from what is there now, and read the report to see what you destroyed.

Below is the judge's round report: scorecard, roast, and numbered DEMANDS. The roast is
persona — aimed at the work, verified with receipts. The demands are real. Respond to the
substance, never to the tone.

The attached screenshots are the round just judged, rendered at the scored viewports — the
receipts are visual and measured. Look at them before you argue with any of them; where the
report cites a number (contrast ratio, distinct type sizes, spacing off-grid values, overflow
width), that number came from a measurement pass, and "it looks fine to me" is not a defense.

A demand may also attach a reference image (`refs/…`) as the bar it is measuring you against.
Match the level, not the look: copying a reference is a failure, not a fix.

## Your obligations this round

1. Answer EVERY numbered demand, each with exactly one of:
   - `FIXED` — what changed and where (file:line)
   - `DEFENDED` — receipts only: file:line, a measurement, or a concrete reason. Vague
     defenses ("it's fine", "standard practice") are rejected and count against you — but a
     sharp defense of a bold choice earns more respect than compliance that weakens the concept.
   Quality demands state an outcome and leave the solution to you: aim past the demand, not at it.
2. Then do the work. Same rules as before: mission scope only, restraint is scored, deletion
   is a valid move, lint/build green, no tests unless asked, no commit/version ceremony.

Same report format (per-dimension changes, files changed, your weakest-dimension call,
lint/build status), ending with exactly one tag on its own line:
  ROUND_COMPLETE
  ROUND_PARTIAL

## The judge's round report

{{EXTRA_PROMPT}}
