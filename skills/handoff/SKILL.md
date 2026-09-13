---
name: handoff
description: Packages the current state of a piece of work so another session, agent, or person can pick it up cold. Records where things stand, what was decided and why, the baseline and blast radius when known, and the exact first action for the receiver, using only portable anchors such as repo-relative paths, symbols, and module names. User-invoked only via /handoff.
argument-hint: "[short slug for this handoff]"
disable-model-invocation: true
---

# handoff

Context does not survive a session boundary unless someone writes it down.
This skill writes it down in a form that is useful to a receiver who has none
of the conversation, may be on a different machine, and may be a different
agent. The output is a file in `docs/handoffs/`, not a chat message.

Handoff slug: $ARGUMENTS

## Portable anchors only

Everything in a handoff must resolve on another machine. Use repo-relative
paths, function and type names, module names, test names, git commit hashes,
and branch names. Never use absolute paths, drive letters, machine names,
session identifiers, or tool-result file locations. If a home directory must
be mentioned, write `$HOME`, `~`, or `$env:USERPROFILE`, never the expanded
form. The receiver will run a scan for these; a handoff that fails the scan
is not portable and gets sent back.

## What to capture

Start with what the work is and where it stands: done, not done, and in
progress, each anchored to files and commits. Then the decisions made along
the way and the reason for each, because the receiver will otherwise re-argue
them. Then the baseline, if one was captured: the test command and its pass
and fail counts, so the receiver can tell whether they inherited a green
state. Then the blast radius, if the explorer or a plan mapped it. Then the
open questions and anything the user said that constrains the approach. Last,
and most important, the first action: the single concrete thing the receiver
should do before anything else. That first action is always to assess, never
to build. A receiver who starts by acting on a handoff they have not verified
will act on something that has since changed.

Leave out the conversation history, the false starts that led nowhere, and
anything the repo already records. The handoff is a map, not a transcript.

## Procedure

Gather the facts from the environment, not from memory: `git status`, the
recent log, the current branch, the plan file if one exists, and the last
recorded baseline. Write the file to `docs/handoffs/<yyyy-mm-dd>-<slug>.md`
using the template below. Create the directory if needed.

Before presenting it, scan the file for em dashes and for absolute paths.
Both scans must return nothing:

```bash
grep -n $'\xe2\x80\x94' docs/handoffs/<file>.md
grep -nE '[A-Za-z]:[\\/]|/(home|Users)/' docs/handoffs/<file>.md
```

Then show the user the file and confirm the first action is the right one.

## Template

```
# Handoff: <title>

Written <yyyy-mm-dd>. Receiver: assess before acting.

## Where we are
<one paragraph: what the work is, branch, last commit hash, plan file if any>

## Done
- <item, anchored to a file, symbol, or commit>

## Not done
- <item, and why it stopped if it stopped>

## Decisions and rationale
- <decision>: <reason>

## Baseline
Command: <test command> | not captured
Result: <pass>/<total>, failing: <names or none>

## Blast radius
<from explorer or plan, or "not mapped">

## Open questions
- <question, or "none">

## Constraints
- <anything the user said that limits the approach>

## First action
<the one concrete thing to do first, which is always to verify the above
against the current state of the repo before building anything>
```

## Receiver protocol

If you are reading a handoff rather than writing one: read it fully, then
check its claims against the repo before acting. Confirm the branch and
commit, re-run the baseline, and diff the "done" list against the actual
files. Only then follow the first action. If the handoff has drifted from
reality, say so before doing anything else.
