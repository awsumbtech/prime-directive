# Prime Directive architecture

Prime Directive is a governance system for Claude Code. Its purpose is to stop
the single most common failure mode of an AI coding agent: fixing one thing
while silently breaking another. Everything in this repo exists to enforce one
promise.

## The promise

**Every change must leave the project in a better state than it was found.**

Operationally that means: define success criteria, capture a baseline, map the
blast radius, make a minimal change, re-run the baseline, and verify the actual
goal. No change is "done" until it is proven to have caused no regression.

## The four moving parts

### 1. The Prime Directive itself

A block of governance that lives in every project's CLAUDE.md. It is the
constitution: success criteria, no net-new failures, no silent side effects, no
tunnel vision, confirm rather than assume. See `templates/CLAUDE.md`.

### 2. The six agents

Specialists, each with a narrow job and an explicit handoff contract so work
passes between them cleanly:

- `explorer`: read-only discovery and blast-radius mapping.
- `implementer`: minimal, scoped changes with baseline and regression checks.
- `reviewer`: the final gate; success-criteria and regression verification.
- `tester`: the real safety net; happy path plus edge cases.
- `documenter`: docs that match reality, examples that run.
- `debugger`: root cause, never band-aids.

Routing between them is governed by `rules/agent-routing.md`.

### 3. The Solution Hierarchy

The discipline that keeps the governance layer from bloating. When a behavior
needs changing, it must land at the highest-reliability tier that can solve it:
Tier 0 environment/harness, Tier 1 tooling, Tier 2 templates, Tier 3 prose.
Prose is the last resort and must justify why the higher tiers cannot do the
job. See `rules/SOLUTION_HIERARCHY.md`.

### 4. The skills

- `primedirective`: installs the whole system into a project (`/primedirective`).
- `primedirectivesync`: audits the system for drift (`/claudesync`).
- `skillforge`: authors and validates new skills with SSL-style manifests.
- `ralph`: an autonomous PRD-execution escape hatch (`/ralph`).
- `pr-review`: multi-dimensional fan-out review with a shared output contract.

## How a typical task flows

```
brainstorm  ->  plan  ->  execute
   |             |           |
 success      blast       explorer -> implementer -> tester -> reviewer
 criteria     radius +    (baseline captured, regression gates at each step,
              plan        review is never skipped)
```

For well-specified work where governance overhead is not wanted, `/ralph`
bypasses this and loops through a PRD one story at a time.

## Design principles

- **Higher tiers beat prose.** Structural enforcement is reliable; instructions
  are ignored. Reach up the hierarchy first.
- **Signal over volume.** The Team Lead Test filters every review comment and
  every proposed rule. If a competent team lead would not raise it, it does not
  get raised.
- **Generalize or localize.** A rule that cannot name three situations where it
  helps is too narrow for the shared layer.
- **Propose, then apply.** The setup and sync skills back up before writing and
  never clobber customized work without approval.
