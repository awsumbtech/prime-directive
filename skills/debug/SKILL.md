---
name: debug
description: Root-cause workflow for anything broken. Use when the user says "bug", "broken", "not working", "failing", or pastes an error. The debugger agent diagnoses before anything changes, the implementer applies the fix, the tester adds a regression guard, and the reviewer confirms no net-new failures. If the fix introduces new failures the cycle re-enters at diagnosis instead of patching the patch.
argument-hint: "[symptom, error text, or failing test]"
---

# debug

Bugs are where the Prime Directive is most often broken, because the pressure
to make the error go away is strongest exactly when understanding is weakest.
This skill enforces the order: diagnose, then fix, then guard, then verify. No
agent touches code until the debugger has named the root cause.

Symptom: $ARGUMENTS

## Step 1: capture the symptom and the baseline

Write down the symptom exactly as observed: the error text, the failing test
name, the wrong output. Then run the full test suite and record the result.
The baseline matters more here than anywhere else, because a bug fix that
breaks two other tests is a net loss and only the baseline proves it.

Record the hook baseline too, so the regression-gate hook on the implementer
and tester compares against the state before the fix:

```bash
node "$HOME/.claude/hooks/regression-gate.js" --baseline
```

If the suite cannot run, say so and record what manual check will stand in
for it. Do not skip this step because the bug looks obvious. Obvious bugs are
the ones that get band-aided.

## Step 2: dispatch the debugger

Hand the `debugger` agent the symptom, the reproduction steps if known, and
the baseline. Its handoff contract requires it to return a reproduction, a
root cause with evidence, the symptom chain, a recommended fix with blast
radius, and the band-aids it rejected. Do not accept a diagnosis without
evidence. "It is probably the cache" is a hypothesis, not a root cause.

Never dispatch the implementer first. If the user says "just fix it, I know
what it is", pass their theory to the debugger as the first hypothesis to test.
That costs a minute and it is the minute that stops a wrong theory from
becoming a wrong fix.

## Step 3: checkpoint with the user when the fix is large

If the recommended fix touches shared code, changes a public contract, or has
a blast radius wider than the symptom suggested, show the user the diagnosis
and the proposed fix before proceeding. The user may prefer a smaller fix now
and a tracked follow-up; that is their call, made with the real cause in front
of them. A band-aid chosen knowingly with the root cause documented is
acceptable. A band-aid applied because nobody looked is not.

## Step 4: dispatch the implementer

Hand the `implementer` the debugger's diagnosis, the recommended fix, the
blast radius, and the baseline. The implementer fixes the root cause, not the
symptom. Its scope note must list anything in the blast radius it deliberately
did not touch.

## Step 5: dispatch the tester

Hand the `tester` the root cause and the fix. It writes the test that would
have caught this bug: one that fails on the code before the fix and passes
after. If such a test cannot be written, the tester says why and the gap is
recorded. A bug fix with no regression guard will come back.

## Step 6: regression gate and review

Run the full suite and compare to the baseline from Step 1. Then dispatch the
`reviewer` with the original symptom, the diagnosis, the change summary, the
baseline, and the current results.

## The re-entry rule

If the after-run shows any failure that was not in the baseline, do not hand
it to the implementer as a follow-up fix. Go back to Step 2 with the new
failure as the symptom and the previous diagnosis attached as context. The
debugger decides whether the new failure is a consequence of an incomplete
root cause, a second bug the fix exposed, or a wrong fix. Patching a patch
without re-diagnosing is exactly the spiral this skill exists to prevent.

Allow two re-entries. On the third, stop, offer to revert to the baseline
state, and report everything observed. Same hypothesis disproven three times
means the model of the problem is wrong, and more edits will not fix a wrong
model.

## Completion

```
Debug complete: <symptom>

Root cause: <one sentence, with the file and symbol>
Fix: <what changed>
Regression guard: <test name> | none (<reason>)
Baseline: <pass>/<total>  After: <pass>/<total>  Net-new failures: none
Review: PASS
Rejected band-aids: <list, or "none proposed">
```
