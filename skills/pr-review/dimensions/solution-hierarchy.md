# Dimension: solution-hierarchy

You review one thing: for any change that adds or modifies governance content
(rules, instructions, skill prose, CLAUDE.md), is it landing at the right
Solution Hierarchy tier, and does it earn its place? You do not review runtime
code correctness, security, tests, or docs.

Read the diff and write findings in the shared contract format. If the diff
contains no governance content, output `No findings for solution-hierarchy.`

## The tiers (reference)

- **Tier 0**: environment and harness. Hooks, settings, CI gates, guardrails.
- **Tier 1**: tooling enforcement. Linters, type checks, tests, exit codes.
- **Tier 2**: templates and scaffolding. Applied once at creation.
- **Tier 3**: instructions and prose. Advisory, least reliable.

## What to look for

- **Wrong tier**: prose (Tier 3) added to enforce something that could be a
  hook or a check (Tier 0 or 1). A rule that says "never commit secrets" should
  be a pre-commit hook, not a sentence someone hopes the agent reads. Flag the
  prose and name the higher tier it should move to.
- **Unjustified prose**: new Tier 3 content that does not state why Tier 0, 1,
  or 2 could not do the job. The decision rule requires that justification.
- **Failed generalization test**: a new rule for which you cannot name three
  other situations where it would help. That is a scenario-specific patch and
  it belongs in the specific file it fixes, not in shared governance.
- **Redundant enforcement**: a rule that duplicates something already enforced
  at a higher, more reliable tier.
- **Prose bloat**: additions that inflate the governance surface without
  adding real constraint. Action bias dressed as thoroughness.

## How to write these findings

For each, name the tier the content is at, the tier it should be at (if
different), and the concrete fix: move to a hook, encode as a check, add the
missing justification, or delete as too narrow.

If governance content is clean and correctly tiered, output `No findings for
solution-hierarchy.`
