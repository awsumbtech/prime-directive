# Agent Routing Rules

This file governs how work is dispatched to the six specialist agents. It is
referenced from the project CLAUDE.md.

## Agent selection

| Task type | Agent | When to use |
|---|---|---|
| Research and discovery | `explorer` | Understanding code, finding patterns, mapping dependencies, blast-radius analysis. Read only. |
| Writing or changing code | `implementer` | Creating features, fixing bugs, refactoring. Always with baseline and regression checking. |
| Quality and regression check | `reviewer` | Post-implementation: success-criteria verification, blast-radius audit, regression detection. |
| Test creation | `tester` | Writing tests, adding coverage, running baseline comparisons. |
| Documentation | `documenter` | READMEs, architecture docs, API docs, inline comments. |
| Bug investigation | `debugger` | Systematic root-cause analysis with blast-radius mapping. |

## Skill triggers

| Situation | Skill | Triggers |
|---|---|---|
| Starting something new | `brainstorm` | "let's build", "I want to add", "new feature". Forces success-criteria definition. |
| Breaking down work | `plan` | "plan this", "break this down". Every task gets success criteria plus "must not break". |
| Running a plan | `execute` | "execute", "do it", "run the plan". Baseline capture, regression gates at every step. |
| Something's broken | `debug` | "bug", "broken", "not working". Root cause first, blast radius mapped, no band-aids. |
| Autonomous PRD execution | `ralph` | "/ralph". Escape hatch: hand it a PRD and let it loop. Bypasses multi-agent routing by design. |

## Routing logic

1. Match the user's request against the trigger keywords above.
2. If the request spans multiple agents (for example "fix the bug and add
   tests"), break it into sequential tasks and route each to the right agent.
3. If the request is ambiguous, default to `explorer` first to gather context,
   then route based on findings.
4. For workflow skills (`/brainstorm`, `/plan`, `/execute`, `/debug`,
   `/handoff`), the skill handles its own agent orchestration. Do not manually
   route inside a skill-driven workflow.

## Multi-step workflows

Common sequences:

- New feature: explorer -> implementer -> tester -> reviewer
- Bug fix: debugger -> implementer -> tester -> reviewer
- Refactor: explorer -> implementer -> reviewer
- Investigation only: explorer

The `/execute` skill automates these sequences from a plan. Use it for anything
beyond a single-agent task.

## Handoff protocol

When transferring work between agents during execution:

- Package context for the receiving agent: task description, blast radius,
  baseline results, predecessor output, permissions.
- The receiving agent assesses the task before acting.
- Each agent's handoff contract (in its definition file) specifies exactly what
  it receives and emits.

## Rules

- Every multi-step workflow ends with the `reviewer` agent.
- If an agent is stuck (same error three times), escalate to the user.
- If scope creep is detected (an agent working outside the stated task), stop
  and redirect.
- Never skip review. Even "quick fixes" get reviewed.
