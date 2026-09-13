# Shared output contract

Every dimension sub-agent writes its findings in exactly this format. The
uniformity is what lets the orchestrator consolidate mechanically. Do not
deviate from it.

## Finding format

Each finding is one block:

```
### [SEVERITY] Short title
- dimension: <correctness | security | solution-hierarchy | tests | docs | simplicity>
- file: <path>
- line: <line number or range, or "n/a">
- problem: <one or two sentences, what is wrong>
- fix: <the concrete change to make, not a vague suggestion>
```

## Severity vocabulary

Use exactly these four, no others:

- `blocker`: must be fixed before merge. Regression, security exposure,
  broken build, unmet success criterion.
- `major`: should be fixed before merge. Real defect or risk, but not
  catastrophic.
- `minor`: worth fixing, not blocking. A genuine improvement.
- `nit`: trivial. Include only if it survives the Team Lead Test, which most
  nits do not.

## Rules for every sub-agent

- Stay in your dimension. Do not report findings that belong to another
  dimension; the sub-agent for that dimension will catch them.
- Every finding must have a concrete `fix`. "Consider improving this" is not a
  fix. If you cannot state the fix, you do not understand the problem yet.
- Apply the Team Lead Test before writing any finding: would a competent team
  lead raise this in a real review? If not, do not write it.
- If your dimension is clean, say so explicitly: output `No findings for
  <dimension>.` Do not invent work to look thorough.

## What the orchestrator does with this

It collects every block, deduplicates by file+line, sorts by severity, applies
the Team Lead Test once more across the merged set, and emits one review. Your
job is to produce clean, contract-conformant blocks so that step is trivial.
