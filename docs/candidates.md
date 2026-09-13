# Candidates

One row per idea that has entered the intake process described in
`intake.md`. Status is one of: captured, measuring, gated (with the gate it
is waiting on), trial, adopted (with version), rejected (with the gate it
failed), retired (with version).

| Candidate | Source | Claim | Status | Notes |
|---|---|---|---|---|
| ponytail plugin | github.com/DietrichGebert/ponytail | Less code, lower cost | adopted 0.4.0 | Independent test measured 15% less code and 10% lower cost against 54% and 20% advertised. Taken as a plugin because the value is in its hooks. Test-coverage conflict resolved in favor of the Prime Directive. |
| Style and secrets gate | this repo | Hard constraints enforced at Tier 0 instead of prose | adopted 0.5.0 | PreToolUse hook on writes and Bash. Em dash and credential patterns. |
| Regression gate | this repo | "No net-new failures" enforced on implementer and tester stop | adopted 0.5.0 | SubagentStop hook. Signature comparison against a recorded baseline; heuristic, documented as such. |
| Scope-creep hook | this repo | Deny writes outside the plan's expected files | gated (tier) | Needs the plan's expected-files list available to a hook. review-gate covers it at Tier 3 until then. |
| Dangerous git guard | this repo | Block force-push and hard reset from agents | gated (overlap) | Auto mode's classifier covers most of this. Measure how often it would fire before adding. |
