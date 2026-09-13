---
name: execute
description: Runs an approved plan from docs/plans/ task by task with a captured baseline and a regression gate after every task. Orchestrates explorer, implementer, tester, and reviewer per task and never skips the reviewer. User-invoked only via /execute so a plan is never run without the user choosing to.
argument-hint: "[path to plan file]"
disable-model-invocation: true
---

# execute

Runs a plan the way the Prime Directive requires: baseline first, one task at
a time, full suite after each task, no task is done until the reviewer says
so. This skill is the orchestrator. It does not write code itself; it
dispatches the specialist agents and holds them to the plan.

Plan to run: $ARGUMENTS

## Preconditions

Read the plan file. Refuse to start unless its status is `approved`. Refuse if
any task lacks success criteria, expected files, or a verification command;
send it back to `/plan`. Check `git status` and tell the user if the working
tree already has uncommitted changes, because those will confuse the scope
check. Confirm the baseline command in the plan actually runs. If tests cannot
be run in this environment, stop and say so; do not proceed on an unverifiable
baseline.

## Step 0: capture the baseline

Run the plan's baseline command. Record the pass and fail counts and the names
of any failing tests in the plan's Baseline section and in the execution log.
This snapshot is the reference for every regression gate that follows. Set the
plan status to `in progress`.

## Per-task loop

For each task, in order:

Package the handoff. The receiving agent gets the task's goal, its success
criteria, its expected files, its must-not-break list, the baseline result,
and the output of any predecessor task it depends on. Use the handoff protocol
in `rules/agent-routing.md`. Repo-relative paths only.

Dispatch the explorer only if the task touches shared code and the plan's
must-not-break list for it is thin. Most tasks skip this because `/plan`
already mapped the blast radius.

Dispatch the task's owner agent, usually `implementer`. Its handoff contract
requires it to report a change summary, baseline versus after, regression
status, and scope notes. Do not accept a report that omits any of these.

Dispatch the `tester` if the task added or changed behavior and the
implementer did not add a test that would catch its regression. A task that
changes behavior with no test guarding it is not finished.

Run the regression gate. Execute the full baseline command again and compare
to Step 0. Then apply the `/review-gate` check to the task: list the files
actually changed since the task started and compare to the expected files.
Any file outside the list must be justified by the implementer's scope note
or the task fails.

Dispatch the `reviewer` with the task's criteria, the baseline, the current
results, and the change summary. The reviewer returns PASS or FAIL. Every task
goes through the reviewer, including the ones that look trivial.

On PASS, append the task's outcome to the execution log and move on.

On FAIL, hand the reviewer's must-fix list back to the implementer. Allow two
attempts. If the same failure persists after two attempts, or if a fix
introduces a failure that was not in the baseline, stop the loop and switch to
`/debug` with the failing test as the symptom. Do not let the implementer keep
patching; that is how one fix becomes three bugs.

## Stop conditions

Stop and report to the user when: a task fails review twice, the regression
gate shows a failure that was not in the baseline and the implementer cannot
explain it, an agent reports being stuck (same error three times), scope creep
cannot be justified, or the plan turns out to be wrong about the code. Never
push through a stop condition to finish the plan. A half-executed plan with an
honest log is better than a finished plan that broke something.

## Completion

After the last task, run the plan's Final verification table: check every
original success criterion against the running code, not against the log.
Set the plan status to `complete` only if every row checks out. Then report:

```
Execution complete: <plan title>

Baseline: <pass>/<total> passing
After:    <pass>/<total> passing
Net-new failures: none | <list>

Tasks: <n> of <n> passed review
Scope: all changes within expected files | <justified exceptions>

Criteria:
1. <criterion>: met (<evidence>)

Follow-ups noticed but not done:
- <item, or "none">
```

## Rules

Never skip the reviewer. Never mark a task done on the implementer's word
alone. Never widen a task to absorb something the plan did not include; note
it as a follow-up. If the user asks you to skip the baseline to save time,
explain that the regression gate is meaningless without it and let them decide
with that stated.
