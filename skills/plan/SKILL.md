---
name: plan
description: Breaks agreed work into ordered tasks, each with its own success criteria, the files it is expected to touch, and a "must not break" list. Use when the user says "plan this" or "break this down", or after /brainstorm has produced success criteria. Writes the plan to docs/plans/ so /execute can run it. Does not implement anything.
argument-hint: "[feature, or the brainstorm output]"
---

# plan

Turns agreed success criteria into a plan that `/execute` can run task by task
with a regression gate between each one. The plan is a file, not a chat
message, because it has to survive the session and be readable by whichever
agent picks up each task.

What is being planned: $ARGUMENTS

## Preconditions

There must be agreed success criteria. If there are none, run `/brainstorm`
first. Do not invent criteria inside a plan; a plan built on guessed criteria
verifies the wrong thing.

## Procedure

Read the success criteria and the non-goals. If anything in them is not
checkable, send it back to `/brainstorm` rather than planning around it.

Dispatch the `explorer` agent to map the blast radius of the whole change
before decomposing it. The explorer's findings tell you which files are in
scope, which consumers depend on them, and where the existing tests are. Plan
from the map, not from memory of how the code probably works.

Decompose into tasks. A good task is small enough to verify on its own, ordered
so that each one leaves the project working, and has one clear owner agent.
Three to eight tasks is typical. If a task cannot be verified until a later
task lands, merge them. If a task touches two unrelated areas, split it.

For every task, write five things. The goal, in one sentence. The success
criteria for that task alone, checkable. The files it is expected to touch,
listed by repo-relative path, because `/execute` and `/review-gate` treat any
change outside that list as scope creep to be justified. The must-not-break
list: the existing behaviors, consumers, and tests that this task is most
likely to disturb, taken from the explorer's blast radius. And the verification
command, the exact command that proves the task is done.

Write the plan-level sections: the baseline command (usually the full test
suite) that `/execute` runs before touching anything, and the final
verification that maps each original success criterion to the task that
satisfies it. Every criterion from the brainstorm must appear here. If one
does not map to any task, the plan is incomplete.

Write the plan to `docs/plans/<yyyy-mm-dd>-<slug>.md` using the template
below. Create `docs/plans/` if it does not exist. Then show the user the file
and ask for approval. `/execute` refuses a plan that is not marked approved.

## Plan template

```
# Plan: <title>

Date: <yyyy-mm-dd>
Status: draft | approved | in progress | complete
Source: <brainstorm title, or "criteria supplied directly">

## Success criteria (from brainstorm)
1. <criterion>

## Non-goals
- <non-goal>

## Baseline
Command: <full test command>
Result: <filled in by /execute>

## Tasks

### Task 1: <goal in one sentence>
Agent: implementer | tester | documenter
Success criteria:
- <checkable condition>
Expected files:
- <repo-relative path>
Must not break:
- <behavior, consumer, or test>
Verify: <exact command>

### Task 2: ...

## Final verification
| Criterion | Satisfied by | Check |
|---|---|---|
| 1 | Task 2 | <command or observation> |

## Execution log
<filled in by /execute>
```

## Rules

Do not implement anything in this skill, not even a scaffold. Use only
repo-relative paths in the plan so it is portable across machines. If the
explorer reports open questions that affect task boundaries, resolve them with
the user before writing the plan, not after.
