---
name: pr-review
description: Multi-dimensional PR review via parallel sub-agents. Captures a diff, fans out to specialist reviewers (correctness, security, solution-hierarchy, tests, docs, simplicity), each writing to a shared output contract, then consolidates into one prioritized review. Applies the Team Lead Test to keep it high-signal. Invoke for reviewing a branch, a PR, or a set of staged changes.
---

# pr-review

Reviews a change along several dimensions at once by fanning out to specialist
sub-agents, each of which reviews one dimension and writes its findings into a
shared output contract. The results are then consolidated mechanically into a
single prioritized review. This gets you depth (a real security pass, a real
test pass) without one reviewer holding everything in its head.

## Step 1: Capture the diff

Get the change under review into a stable form so every sub-agent reviews the
same thing.

- On Windows / PowerShell: run `collect-diff.ps1` with the appropriate scope.
- Scope options: `working` (uncommitted), `staged`, or `branch` (vs the base
  branch).

```powershell
./collect-diff.ps1 -Scope branch -BaseBranch main
```

This writes the diff and a file manifest that the sub-agents read. Verify the
diff is non-empty before fanning out.

## Step 2: Fan out to dimension reviewers

Dispatch one sub-agent per dimension, in parallel. Each reads the diff and its
own dimension file, and each writes its findings into the shared contract
format defined in `dimensions/_shared-contract.md`. The dimensions:

- `dimensions/correctness.md`
- `dimensions/security.md`
- `dimensions/solution-hierarchy.md`
- `dimensions/tests.md`
- `dimensions/docs.md`
- `dimensions/simplicity.md`

Each sub-agent stays in its lane. The correctness reviewer does not comment on
docs; the docs reviewer does not comment on security. This is what keeps the
review focused and lets the consolidation be mechanical.

## Step 3: Consolidate

Because every sub-agent wrote to the same contract, consolidation is mechanical:

1. Collect all findings.
2. Deduplicate where two dimensions flagged the same line.
3. Sort by severity: `blocker` > `major` > `minor` > `nit`.
4. Apply the **Team Lead Test** one final time across the merged set: would a
   competent team lead raise this in a real review? Drop anything that fails.
5. Emit a single review: a one-line verdict (approve / request changes), then
   findings grouped by severity, each with file, line, dimension, and the fix.

## The Team Lead Test

The signal-to-noise gate for every finding. Drop: style nits a linter handles,
restatements, context inflation, scenario-specific patches, redundant
enforcement, and action bias. Keep: real defects, unmet criteria, unhandled
edge cases, security exposure, blast-radius violations.

## Notes

- The `collect-diff.ps1` git logic should be validated live with `-Scope
  working` on a real repo before trusting it end to end.
- To run under a non-PowerShell environment, replace the diff-capture step with
  an equivalent `git diff` invocation; the rest of the pipeline is host-neutral.
