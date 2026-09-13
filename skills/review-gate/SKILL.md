---
name: review-gate
description: A sixty-second sanity check on a change, not a full review. Confirms the stated task was done, flags any file changed outside the stated scope, and checks the test baseline held. Use after a small change, before a commit, or between tasks in /execute. For a thorough multi-dimension review use pr-review instead.
argument-hint: "[one-line description of the task, and expected files if known]"
---

# review-gate

The fast gate. It answers three questions and nothing else: did the change do
what was asked, did it touch anything it was not supposed to, and did the
tests that passed before still pass. If answering takes more than a minute of
real thinking, the change needs `pr-review` or the `reviewer` agent, and this
skill says so instead of pretending.

Task under review: $ARGUMENTS

## Procedure

Establish the stated task. If the user gave one line, use it. If `/execute`
invoked this, use the task's goal and expected files from the plan. If there
is no stated task at all, ask for one; scope creep cannot be detected without
a scope.

List what actually changed:

```bash
git status --porcelain
git diff --stat
git diff --name-only HEAD
```

Compare the changed files to the expected files. Every changed file that is
not in the expected list is a scope flag. A scope flag is not automatically a
failure; it is a question the author must answer. A formatter touching an
unrelated file, a shared type that had to change, a test file the task
implied: these are usually fine once stated. An unrelated bug fix, a rename
done while passing through, a config change nobody asked for: these fail the
gate and go back to the author to revert or to split into their own task.

Confirm the task was done. Read the diff with the stated task next to it. Does
the change do that thing? Not "does it look reasonable" but "does it do what
the sentence says". If the task had a verification command, run it.

Check the baseline if one exists. Run the test command. If the pass count
dropped or a previously passing test now fails, the gate fails regardless of
anything else.

## Verdict

Emit exactly one of these, first, then the evidence:

```
REVIEW GATE: PASS
Task: <stated task>
Changed files: <n>, all within scope
Tests: <pass>/<total>, baseline held

REVIEW GATE: PASS WITH SCOPE NOTES
Task: <stated task>
Out-of-scope files: <path> (<author's justification>)
Tests: <pass>/<total>, baseline held

REVIEW GATE: FAIL
Task: <stated task>
Reason: <task not done | unjustified scope creep | baseline broken>
Detail: <the one specific thing that failed>

REVIEW GATE: ESCALATE
Reason: <why sixty seconds is not enough>
Recommend: pr-review | reviewer agent
```

## Rules

Do not review style, naming, or structure here. Do not suggest improvements.
Do not expand into a full review because the diff is interesting. The value of
this gate is that it is cheap enough to run every time; if it grows, it will
be skipped.
