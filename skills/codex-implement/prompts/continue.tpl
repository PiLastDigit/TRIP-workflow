Continue the implementation session for `{{TARGET}}`.

The working tree may have changed since your last turn — the requester reviews your work and
may adjust it directly. Run `git status -s` and `git diff HEAD` to resync first; treat the
current tree as authoritative, and do not revert the requester's adjustments.

## Requester's review notes (may be empty)

{{IMPLEMENTER_NOTES}}

These explain what the requester fixed after your last turn and why. Any convention stated
here is binding for the rest of the session — do not reintroduce corrected patterns.

## New instructions

{{EXTRA_PROMPT}}

Same rules as before: stay within the stated scope, tick completed plan checkboxes, leave the
project's lint and type-check/build green, no tests unless asked, no commit/version/changelog
ceremony.

Same report format (files changed, deviations, leftovers, lint/build status), ending with
exactly one tag on its own line:
  IMPLEMENTATION_COMPLETE
  IMPLEMENTATION_PARTIAL
