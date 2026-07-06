# The Solution Hierarchy

When a behavior needs to change (an agent keeps doing the wrong thing, a rule
keeps getting ignored, a mistake keeps recurring), the question is not "what
should I write?" but "at which level should this be enforced?"

Levels are ranked by reliability. Higher levels hold because the agent cannot
route around them. Lower levels are advisory and are frequently ignored. Always
prefer the highest level that can solve the problem.

## The tiers

### Tier 0 - Environment and harness (most reliable)

The agent never sees these, so they always hold. Hooks, settings, sandbox
constraints, permission boundaries, pre-commit hooks, CI gates, `.claudeignore`
scope, git guardrails that block dangerous commands before they run.

If a behavior can be made structurally impossible or automatically enforced
here, do it here. This is the first thing to reach for, not the last.

### Tier 1 - Tooling enforcement

The agent is forced to react because a tool fails loudly. Linter errors,
type-checker failures, test failures, analyzer warnings, CLI commands that exit
non-zero. The agent cannot honestly report success while these are red.

If Tier 0 cannot capture it, encode it as something that breaks the build or
fails a check.

### Tier 2 - Templates and scaffolding

Applied once, at creation time, so the right structure exists from the start.
CLAUDE.md templates, agent definitions, skill scaffolds, file templates,
project-init output. The behavior is baked into the starting point rather than
requested repeatedly.

### Tier 3 - Instructions and prose (least reliable)

SKILL.md prose, CLAUDE.md rules, agent instructions. This is advisory. Agents
ignore prose regularly, especially as context fills. Prose is the **last**
resort, not the first move.

## The decision rule

Before adding any Tier 3 prose, you must answer: **why not Tier 0, 1, or 2?**

State the reason explicitly. "It can't be a hook because it depends on runtime
judgment." "It can't be a lint rule because the condition isn't statically
detectable." If you cannot articulate why the higher tiers fail, you have not
earned the right to add prose. Most 'add another rule' impulses die here.

## The generalization test

Before adding any rule at any tier, name **three other situations** where it
would help. If you cannot, the rule is too narrow: it is a scenario-specific
patch masquerading as governance, and it will bloat the system without earning
its keep. Narrow patches belong in the specific file they fix, not in the
shared governance layer.

## Why this exists

The default failure mode of any AI governance system is action bias: every
problem gets answered with another paragraph of instructions, the prose grows
without bound, and the signal-to-noise ratio collapses until the agent ignores
all of it. The Solution Hierarchy is the discipline that fights that. It forces
every change to justify its level and its generality before it is allowed in.
