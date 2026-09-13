---
name: brainstorm
description: Turns a vague request into an agreed definition of done before any work starts. Use when the user says "let's build", "I want to add", "new feature", or describes something new without saying what success looks like. Produces checkable success criteria, explicit non-goals, and the questions that must be answered before planning. Never writes code.
argument-hint: "[what you want to build or change]"
---

# brainstorm

The Prime Directive says no code changes until success criteria exist. This
skill is where they come from. It takes a request that is still an idea and
turns it into a definition of done that the user has explicitly agreed to, so
that `/plan` has something concrete to decompose and `/execute` has something
concrete to verify against.

The request under discussion: $ARGUMENTS

## When this applies

Anything new that does not yet have agreed success criteria. A feature, a
behavior change, a refactor with a goal, an integration. If the user has
already stated checkable criteria, skip this and go to `/plan`.

This skill does not apply to bugs (use `/debug`), to work that already has an
approved plan (use `/execute`), or to a one-line change whose success is
obvious from the request. Do not brainstorm a typo fix.

## Procedure

Start by restating the request in your own words, in one paragraph. If your
restatement and the user's intent differ, that gap is the first thing to
resolve. Do not proceed on a restatement the user has not confirmed.

Then find what is undecided. The usual gaps are: who or what triggers the
behavior, what the inputs and outputs are, what happens on the failure paths
(empty input, missing data, auth failure, network error, concurrent use), what
existing behavior must keep working, and what is explicitly out of scope. Ask
about the gaps one sharp question at a time. Batch questions only when they are
independent of each other. Never fill a gap with an assumption and move on; a
guessed criterion is worse than a missing one because it looks agreed.

If the area is unfamiliar, dispatch the `explorer` agent before asking the
user anything the code could answer. Do not ask the user how a module works
when the module is right there.

Draft the success criteria. Each one must be checkable by someone other than
you: a test that passes, a command that exits zero, a specific observable
behavior. "Works correctly" is not a criterion. "Returns 404 with an empty body
when the id does not exist" is. Include the edge cases in the criteria, not in
a separate wish list.

Write the non-goals with the same care. A non-goal is something a reasonable
person might expect this work to include and which it deliberately will not.
Non-goals are what stop scope creep later.

Present the draft and get an explicit yes. Not silence, not "sounds good, also
could it...". If the user adds something, fold it in and present again.

## Output

When the user has agreed, emit this block and nothing else, so it can be handed
straight to `/plan`:

```
## Brainstorm: <short title>

### Request
<one paragraph, confirmed restatement>

### Success criteria
1. <checkable condition>
2. <checkable condition>

### Non-goals
- <what this deliberately does not do>

### Must keep working
- <existing behavior that must not change>

### Open questions
- <anything still unresolved, or "none">

### Agreed by user: yes
```

## Rules

Never write code in this skill. Never start planning tasks in this skill; that
is `/plan`. If the user wants to skip the criteria and just start, say plainly
that the Prime Directive requires them, offer to write the minimal set, and
let the user decide.
