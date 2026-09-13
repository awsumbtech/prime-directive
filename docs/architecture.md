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

## The six moving parts

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

The workflow skills are the Prime Directive in motion:

- `brainstorm`: forces agreed, checkable success criteria before any work.
- `plan`: decomposes into tasks, each with criteria, expected files, and a
  must-not-break list, written to `docs/plans/`.
- `execute`: runs a plan with a baseline, a regression gate after every task,
  and the reviewer as the final word on each one. User-invoked only.
- `review-gate`: the sixty-second check: task done, scope respected, baseline
  held. Escalates to `pr-review` when a minute is not enough.
- `debug`: debugger diagnoses, implementer fixes, tester guards, reviewer
  verifies. Re-enters at diagnosis if the fix introduces new failures.
- `handoff`: packages context for another session or agent with portable
  anchors only, written to `docs/handoffs/`. User-invoked only.

The meta-skills maintain the system itself:

- `primedirective`: installs the whole system into a project (`/primedirective`).
- `claudesync`: audits the system for drift (`/claudesync`).
- `skillforge`: authors and validates new skills with SSL-style manifests.
- `ralph`: an autonomous PRD-execution escape hatch (`/ralph`).
- `pr-review`: multi-dimensional fan-out review with a shared output contract.

### 5. The hooks

Until version 0.5.0 every rule in this repo was Tier 2 or Tier 3 while the
Solution Hierarchy said to reach for Tier 0 first. The hooks close that gap
for the three rules that can be checked mechanically. The write gate is a
PreToolUse hook that denies em dashes and credential-shaped content in any
write or command. The regression gate is a SubagentStop hook on the
implementer and tester that runs the project's test command and blocks on
any failure absent from the recorded baseline. Both are Node scripts in
`hooks/`, registered by the installers through `merge-settings.js`, and both
stand down rather than block when they lack what they need: no test command,
no baseline, unparseable input. A gate that blocks on its own bug is worse
than no gate. The scope-creep check stays in `review-gate` at Tier 3 until a
hook can read the plan's expected files; `docs/candidates.md` tracks that.

### 6. Ponytail

Ponytail (github.com/DietrichGebert/ponytail, MIT) is the minimalism layer:
a ladder that stops code from being written when reuse, the standard library,
or a platform feature already covers the need. It is consumed as a Claude
Code plugin rather than vendored here, for a Solution Hierarchy reason. The
plugin injects its ruleset through SessionStart and SubagentStart hooks, which
is Tier 0. An independent benchmark found the same ruleset installed as a bare
skill self-activated zero times in ten sessions, which is Tier 3 behaving
exactly as this document predicts. Copying the skill file would have kept the
words and lost the mechanism.

The division of labor is explicit. Ponytail governs the shape of production
code. The Prime Directive governs process and verification: success criteria,
baseline, blast radius, regression gate, review. Where the two disagree, on
test coverage, the Prime Directive wins; ponytail's one-check minimum is a
floor, not a ceiling. `templates/settings.ponytail.json` scopes the subagent
injection to the implementer and debugger so the explorer, tester, reviewer,
and documenter keep their own contracts. The `implementer` carries a
condensed ladder as a floor for sessions where the plugin is absent, and
`pr-review` has a `simplicity` dimension that hunts over-engineering in the
shared contract format.

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
