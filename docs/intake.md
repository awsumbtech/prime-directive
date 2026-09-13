# Intake: how something new gets into Prime Directive

Prime Directive changes when a rule keeps being ignored, when a tool or skill
from outside looks useful, or when a session uncovers a better way to do
something ponytail or Ralph already does. Every one of those goes through the
same five steps, because the alternative is action bias: every idea becomes a
paragraph, the governance layer grows, and the agent stops reading it. The
ponytail evaluation that produced version 0.4.0 is the worked example; its
advertised savings were two to four times the independently measured ones,
and only the measured figure was allowed to matter.

Candidates are tracked in `candidates.md` next to this file, one row each,
with the gate they are waiting on.

## 1. Capture

Write down what the candidate is, where it came from, what it claims, and
what evidence exists that is not the author's own benchmark. A candidate
with no independent evidence waits at this step until someone measures it
in one real project. Marketing numbers do not advance a row.

## 2. Four gates, in order

Overlap. Does Prime Directive, ponytail, or Ralph already do this? If yes,
the candidate is either redundant or an improvement to the thing that
already does it, and it is handled as that.

Tier. Where in the Solution Hierarchy would it land, and why not one tier
higher? A hook that could be a check, a check that could be a template, a
template that could be prose: each must justify its level in a sentence.

Generalization. Name three situations where it helps. If the third one is
a stretch, the candidate is a scenario patch and belongs in the project that
needs it, not in the shared layer.

Evidence. The measured effect, in one project, with the baseline it was
measured against. A candidate that cannot be measured at all is prose and is
held to the prose standard: it must state why the higher tiers cannot do
the job.

## 3. Form

Choose how it enters, and prefer the form that keeps the mechanism. When the
value lives in hooks, take the upstream plugin; copying its skill file keeps
the words and loses the injection, and that failure was measured, not
predicted. When it is a rule, adapt it into the agent or review dimension
that already owns that concern and attribute it in `NOTICE.md`. Vendor a
copy only when upstream is unmaintained.

Improvements to ponytail go upstream as pull requests, not local forks; a
local adaptation lives only in Prime Directive's own agents and dimensions.
Anything touching Ralph must survive Ralph's own guard, which says do not
add more. A Ralph enhancement that cannot be expressed as a smaller
`RALPH.md` or a shorter loop is not a Ralph enhancement.

## 4. Trial

Install it in one project. After a few sessions run `/claudesync` and read
the invocation-hygiene audit: phantom loads, relevance drift, and scope creep
are the signals that a candidate is polluting retrieval rather than helping.
A hook is trialed by counting how often it fires and how often the block was
wrong.

## 5. Ship

Run `pr-review` on the diff so the solution-hierarchy and simplicity
dimensions see it. Write the CHANGELOG entry with the rationale, not only the
change, so the next reader can tell why it was worth the space. Bump the
version, tag, push, and reinstall. Move the candidate row to adopted with
the version number, or to rejected with the gate it failed.

## Retiring

The same process runs backwards. A rule that the audit shows is never
loaded, or a hook that blocks wrongly more than it blocks rightly, gets a
row, goes through the tier and evidence gates, and is removed with a
CHANGELOG entry explaining what the measurement showed.
