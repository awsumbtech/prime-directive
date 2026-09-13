# Prime Directive

A governance system for Claude Code. It exists to enforce one promise:

> **Every change must leave the project in a better state than you found it.**

Prime Directive stops the most common AI coding failure, where the agent fixes
one thing and quietly breaks another, by requiring success criteria, baseline
capture, blast-radius mapping, and regression verification before any change is
considered done.

## What is in here

```
prime-directive/
├── agents/                     Six specialist agents with handoff contracts
│   ├── explorer.md
│   ├── implementer.md
│   ├── reviewer.md
│   ├── tester.md
│   ├── documenter.md
│   └── debugger.md
├── rules/
│   ├── agent-routing.md        How work is dispatched to the agents
│   └── SOLUTION_HIERARCHY.md   Where behavior changes belong (Tier 0-3)
├── templates/
│   ├── CLAUDE.md               The base governance template for a project
│   ├── settings.ponytail.json  Scopes ponytail injection to code-writing agents
│   └── .claudeignore
├── skills/
│   ├── brainstorm/             /brainstorm   success criteria before any work
│   ├── plan/                   /plan         tasks with criteria and must-not-break
│   ├── execute/                /execute      runs a plan with regression gates
│   ├── review-gate/            /review-gate  sixty-second scope and baseline check
│   ├── debug/                  /debug        root cause first, then fix and guard
│   ├── handoff/                /handoff      portable context for the next session
│   ├── primedirective/         /primedirective  installs the system
│   ├── claudesync/             /claudesync      audits for drift
│   ├── skillforge/             authors + validates new skills (SSL manifests)
│   ├── ralph/                  /ralph  autonomous PRD execution escape hatch
│   └── pr-review/              multi-dimensional fan-out review (six dimensions)
├── docs/
│   ├── architecture.md         How the pieces fit together
│   └── handoffs/               Decision records from session handoffs
├── install.ps1                 Windows installer (symlink or copy)
├── install.sh                  Linux/macOS installer (symlink or copy)
├── VERSION
├── CHANGELOG.md
└── LICENSE
```

## Core concepts

**The six agents.** Each does one job and hands off through an explicit
contract (what it receives, what it emits), which is what lets the multi-step
workflows and the fan-out review consolidate cleanly.

**The Solution Hierarchy.** When something needs to change, it lands at the
highest-reliability tier that can solve it: Tier 0 environment/harness, Tier 1
tooling, Tier 2 templates, Tier 3 prose. Prose is the last resort because
agents ignore it. New prose must justify why the higher tiers cannot do the job,
and any new rule must pass the generalization test (name three situations where
it helps).

**The Team Lead Test.** The signal-to-noise gate applied to every review
comment and every proposed rule: would a competent team lead raise this in a
real review? If not, drop it.

## Quick start

Install the system into a project by running the setup skill from inside Claude
Code:

```
/primedirective
```

It detects the project type, backs up anything at risk, installs the agents,
skills, rules, and a filled-in CLAUDE.md, and proposes `@`-references for key
files. It is idempotent and safe to re-run.

To keep an installed setup honest as the project evolves:

```
/claudesync
```

This audits for drift (stale commands, moved directories, missing or dangling
`@`-references, mis-tiered governance, invocation-hygiene problems) and proposes
fixes without applying them until you approve.

## Installing this repo across machines

Use the installer for your platform. Symlink mode means a `git pull` updates
every project at once; copy mode gives per-project isolation, which is safer
when you want a frozen version pinned to a specific engagement.

```powershell
# Windows
./install.ps1 -Mode copy -Target "$env:USERPROFILE\.claude"
```

Symlink mode on Windows needs a privilege that ordinary accounts do not have.
When symlink creation is denied, `install.ps1` falls back to a directory
junction, which behaves the same way for this purpose and needs no elevation.

```bash
# Linux / macOS
./install.sh --mode copy --target ~/.claude
```

## Ponytail

Prime Directive pairs with the [ponytail](https://github.com/DietrichGebert/ponytail)
plugin for production-code minimalism. Ponytail decides how little code to
write; the Prime Directive decides how to prove the change is safe. Install
it from inside Claude Code, then restart:

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

By default ponytail injects its ruleset into every subagent. Merge
`templates/settings.ponytail.json` into your `.claude/settings.json` to
limit that to the implementer and debugger, so the tester keeps full
coverage and the explorer and reviewer keep their reporting contracts.

## Versioning

The `VERSION` file plus git tags anchor `/claudesync` drift detection. Tag each
release (`git tag v0.3.0`) so a sync can report what changed since the last
pinned version.

## License

See `LICENSE`.
