---
name: primedirective
description: Sets up the Prime Directive Claude Code environment in the current project. Copies agents, skills, rules, and templates from the master source. Smart-merges with existing setups by backing up before overwriting and preserving custom work. Auto-scans for important files and proposes @ context references. User-invoked only via /primedirective.
disable-model-invocation: true
---

# primedirective

Installs the Prime Directive governance system into the current project. Run it
with `/primedirective`. It is idempotent and safe to run on an existing setup:
it backs up before it overwrites and it never destroys custom work.

## Phase 1: Detect project state

Determine what already exists:

```bash
echo "=== Existing .claude ===" && ls -la .claude/ 2>/dev/null || echo "none"
echo "=== Existing CLAUDE.md ===" && test -f CLAUDE.md && echo "present" || echo "absent"
echo "=== Project type signals ===" && ls package.json requirements.txt *.csproj project.godot go.mod Cargo.toml 2>/dev/null
```

Classify the project (Node/TypeScript, Python, .NET, Godot, Go, Rust, mixed)
from the signals. This drives the CLAUDE.md fill-ins and the `.claudeignore`.

## Phase 2: Back up anything at risk

If `.claude/` or `CLAUDE.md` already exist, create a timestamped backup before
touching anything:

```bash
ts=$(date +%Y%m%d-%H%M%S)
mkdir -p ".claude/backups/$ts"
cp -r .claude/agents .claude/skills .claude/rules CLAUDE.md .claudeignore ".claude/backups/$ts/" 2>/dev/null
echo "Backed up to .claude/backups/$ts"
```

## Phase 3: Categorize every file as ADD / MERGE / UNTOUCHED

For each file the Prime Directive provides:

- **ADD**: it does not exist in the project. Copy it in.
- **MERGE**: it exists and differs. For CLAUDE.md, merge the Prime Directive
  blocks into the existing file without deleting the user's project-specific
  content. For agents/skills/rules that the user has customized, do NOT
  overwrite; report the difference and let the user decide.
- **UNTOUCHED**: it exists and matches. Skip.

Never blindly overwrite a customized file. The backup exists as a safety net,
not as permission to clobber.

## Phase 4: Install the structure

Lay down the directories and files:

```bash
mkdir -p .claude/agents .claude/skills .claude/rules docs/plans docs/handoffs
```

Copy from the master source:

- `agents/*` -> `.claude/agents/`
- `skills/*` -> `.claude/skills/`
- `rules/*` -> `.claude/rules/`
- `templates/CLAUDE.md` -> `CLAUDE.md` (filled in for this project type)
- `templates/.claudeignore` -> `.claudeignore`

Fill the CLAUDE.md placeholders ({PROJECT_NAME}, {TECH_STACK}, {TEST_COMMAND},
etc.) from what Phase 1 detected. Leave {PROJECT_SPECIFIC_NOTES} for the user.

## Phase 4b: ponytail plugin

The Prime Directive expects the ponytail plugin for production-code
minimalism. It is a Claude Code plugin, not a file in this repo, so this
skill cannot copy it. Check whether it is installed: a ponytail entry under
`~/.claude/plugins/marketplaces/`, or `enabledPlugins` in
`~/.claude/settings.json` listing it. If it is absent, give the user the two
commands and move on:

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

If it is present, propose merging `templates/settings.ponytail.json` into the
project's `.claude/settings.json` so the ruleset is injected only into the
agents that write production code. Show the merge before applying it.

## Phase 5: Propose @ context references

Scan for files that are referenced widely and would benefit from being loaded
into every request (schemas, central type definitions, core config, a domain
glossary). Propose adding them as `@`-references at the bottom of CLAUDE.md.
Do not add them without showing the user the list first.

```bash
echo "=== Candidate @-reference files ===" 
ls prisma/schema.prisma src/types.ts src/config.* CONTEXT.md 2>/dev/null
```

## Phase 6: Verify and summarize

Confirm everything landed:

```bash
echo "=== Agents ===" && ls -1 .claude/agents/
echo "=== Skills ===" && ls -1 .claude/skills/
echo "=== Rules ===" && ls -1 .claude/rules/
echo "=== Root files ===" && ls -1 CLAUDE.md .claudeignore
echo "=== Plans and handoffs dirs ===" && ls -d docs/plans docs/handoffs
```

Then present:

```
Prime Directive setup complete.

CLAUDE.md        Customized for this project
6 agents         explorer, implementer, reviewer, tester, documenter, debugger
skills           /brainstorm, /plan, /execute, /review-gate, /debug, /handoff, and meta-skills
rules            agent-routing, SOLUTION_HIERARCHY
.claudeignore    configured for {project_type}
docs/plans/      ready for implementation plans
docs/handoffs/   ready for session handoffs

The Prime Directive is active: every change requires success criteria, baseline
testing, blast-radius checks, and regression verification before it is "done".
```

## Notes

- File must be named exactly `SKILL.md`. No blank line before the opening `---`.
- Restart Claude Code after installing global skills for them to register.
- This skill is user-invoked only (`disable-model-invocation: true`) so the
  agent never auto-runs a project setup.
