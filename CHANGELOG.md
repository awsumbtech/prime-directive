# Changelog

All notable changes to Prime Directive are recorded here. Versions follow
semantic versioning. Tag each release in git so `/claudesync` can report what
changed since the last pinned version.

## [0.5.0] - 2026-09-13

The first Tier 0 release. Until now every Prime Directive rule was prose or
an agent definition, while `rules/SOLUTION_HIERARCHY.md` told everyone to
reach for hooks first. Three rules that can be checked mechanically now are.

### Added
- `hooks/write-gate.js`: PreToolUse hook on Write, Edit, MultiEdit,
  NotebookEdit, and Bash. Denies content containing an em dash, and content
  matching credential shapes (AWS and GitHub and Slack and Anthropic keys,
  private key blocks, Azure storage keys, connection-string passwords,
  literal password or token assignments). Placeholder values pass. Per-session
  overrides through `PRIME_DIRECTIVE_STYLE_GATE=off` and
  `PRIME_DIRECTIVE_SECRETS_GATE=off`.
- `hooks/regression-gate.js`: SubagentStop hook on the implementer and
  tester. Runs the test command from CLAUDE.md, compares with the baseline
  at `.claude/baseline.json`, and blocks with the failing lines on any
  net-new failure. `--baseline` records the "before" state; `--check` runs
  the comparison by hand. Honors `stop_hook_active` so a subagent is never
  looped forever. Stands down, with a message, when there is no test command
  or no baseline.
- `hooks/merge-settings.js` and `hooks/settings.hooks.json`: idempotent
  registration of the hook entries into a settings.json, with backup. Both
  installers call it; Node.js is now required for hook registration and the
  installers say so if it is missing.
- `docs/intake.md` and `docs/candidates.md`: the five-step process for
  adding, changing, or retiring anything in the framework, including
  improvements to ponytail and Ralph, and the ledger that tracks candidates
  through it.

### Changed
- `install.ps1` and `install.sh` copy or link `hooks/` alongside agents,
  skills, and rules, then register the hooks.
- `/execute` Step 0 and `/debug` Step 1 record the hook baseline so the gate
  compares against the same state the skill captured.
- `/primedirective` fills the `- Test:` line knowing the hook reads it, and
  proposes ignoring `.claude/baseline.json`.
- `templates/CLAUDE.md` states, under Commands, that the Test line drives the
  regression gate.
- README and architecture describe the hooks and the intake process.

## [0.4.0] - 2026-09-13

Adds the ponytail minimalism layer. Ponytail (github.com/DietrichGebert/ponytail,
MIT) is a ladder that stops code from being written when reuse, the standard
library, or a platform feature already covers the need. It is consumed as a
Claude Code plugin, not vendored, because its value comes from hook-based
injection at session and subagent start. An independent benchmark found the
same ruleset installed as a bare skill self-activated zero times in ten
sessions. That is the Solution Hierarchy in one sentence: the hook is Tier 0,
the prose is Tier 3, and copying the prose would have kept the words and lost
the mechanism.

### Added
- `skills/pr-review/dimensions/simplicity.md`: a sixth review dimension that
  hunts over-engineering only (delete, stdlib, native, yagni, shrink), in the
  shared contract format with severity guidance that keeps it from ever
  producing a blocker on its own.
- `templates/settings.ponytail.json`: scopes ponytail's subagent injection to
  the implementer and debugger through `PONYTAIL_SUBAGENT_MATCHER`, so the
  tester keeps full coverage and the explorer, reviewer, and documenter keep
  their reporting contracts.
- `NOTICE.md`: MIT attribution for the adapted ponytail material.
- `/primedirective` Phase 4b: detects whether the ponytail plugin is
  installed, gives the two install commands if not, and proposes the
  settings merge if so.

### Changed
- `implementer` carries a condensed version of the ladder as a floor for
  sessions where the plugin is absent, with the explicit boundary that the
  ladder shortens the solution and never the reading, the baseline, or the
  verification.
- `tester` states the one place ponytail and the Prime Directive disagree
  and which one wins: ponytail's one-check minimum is a floor, not a
  ceiling, because a thin suite makes "no net-new failures" meaningless.
- `debugger` prefers the fix at the point all callers route through, which
  is both the smaller diff and the one that does not leave a sibling caller
  broken.
- `templates/CLAUDE.md` house style names the ladder for production code and
  the test-coverage exception in one bullet.
- `docs/architecture.md` gains a fifth moving part describing the division
  of labor: ponytail governs the shape of production code, the Prime
  Directive governs process and verification.
- README documents the plugin install and the settings merge.

### Unchanged on purpose
- `ralph` is untouched. It remains the escape hatch in `skills/ralph/`,
  registered as `/ralph`, listed in the routing table, the CLAUDE.md
  template, the README, and the architecture doc. Ponytail contains no loop
  or autonomous component of its own; when the plugin is installed its
  SessionStart hook applies the ladder to each headless Ralph iteration
  automatically, with no change to `ralph.sh` or `RALPH.md`.

## [0.3.0] - 2026-09-13

Forward rebuild. Keeps everything in 0.1.0 that worked, adds the six workflow
skills that the routing rules and the CLAUDE.md template had been promising,
and brings the agent definitions in line with what Claude Code actually reads.
Version 0.2.0 was assigned to a package that was built in a chat session and
never saved, so it is skipped rather than reconstructed.

### Fixed
- Agent `tools` lists used names Claude Code does not recognize (`view`,
  `str_replace`, `create_file`). They now use the real tool names: `Read`,
  `Edit`, `Write`, `Bash`, `Grep`, `Glob`. Before this fix every agent ran
  with a tool allowlist that matched nothing.
- `/claudesync` did not exist. Claude Code derives a personal or project
  skill's command from its directory name, not from the `name` field, so the
  skill at `skills/primedirectivesync/` registered as `/primedirectivesync`.
  The directory is now `skills/claudesync/` and the documented command works.
- `install.ps1` symlink mode failed on any Windows account without the
  symlink privilege. It now falls back to a directory junction, which needs no
  elevation. It also no longer backs up or recursively deletes a linked
  directory, which previously risked touching the repo through the link.
- README install example used a hard-coded user path. It now uses
  `$env:USERPROFILE`.

### Added
- `brainstorm` (`/brainstorm`): agreed, checkable success criteria and
  non-goals before any work starts. Model-invocable on "let's build", "I want
  to add", "new feature".
- `plan` (`/plan`): decomposes into tasks, each with success criteria,
  expected files, a must-not-break list, and a verification command. Writes
  to `docs/plans/`.
- `execute` (`/execute`): runs an approved plan with a captured baseline, a
  regression gate and scope check after every task, and the reviewer as the
  final word on each. User-invoked only.
- `review-gate` (`/review-gate`): the sixty-second check. Task done, files
  changed outside the stated scope flagged, baseline held. Escalates rather
  than growing into a full review.
- `debug` (`/debug`): debugger diagnoses, implementer fixes, tester adds the
  regression guard, reviewer verifies. If the fix introduces failures not in
  the baseline the cycle re-enters at diagnosis instead of patching the patch.
- `handoff` (`/handoff`): packages context for another session or agent using
  portable anchors only, written to `docs/handoffs/`. User-invoked only.
- `docs/handoffs/`: decision records from session handoffs, starting with the
  one that drove this release.

### Changed
- Agent frontmatter now uses `tools`, `disallowedTools`, `model`, and `color`,
  verified against the current Claude Code subagent reference. Read-only
  agents (`explorer`, `reviewer`) deny `Write`, `Edit`, and `NotebookEdit`
  explicitly so the restriction survives a later widening of `tools`. The
  `debugger` keeps `Edit` for temporary instrumentation but denies `Write`.
  `memory` and `permissionMode` were considered and left unset: `memory`
  writes into every project it runs in, and `permissionMode` is better
  inherited from the session than fixed per agent. Both are one line to add
  per project if wanted.
- `skillforge` moved its SSL manifest under the `metadata:` frontmatter key,
  the one free-form map Claude Code passes through without interpreting.
  Every other frontmatter key in the repo is now one Claude Code documents.
- `rules/agent-routing.md` lists `review-gate` and `handoff` in the skill
  triggers table and names `/debug` as the automated bug-fix sequence.
- `templates/CLAUDE.md` Workflow section names all six workflow skills.
- `/primedirective` creates `docs/handoffs/` alongside `docs/plans/`.

## [0.1.0] - 2026-07-06

First versioned release. Consolidates the Prime Directive system into a single
tracked repository.

### Agents
- Six specialist agents with explicit handoff contracts: explorer,
  implementer, reviewer, tester, documenter, debugger.

### Rules
- `agent-routing.md`: dispatch logic, multi-step workflow sequences, handoff
  protocol.
- `SOLUTION_HIERARCHY.md`: the Tier 0-3 decision rule, the "why not a higher
  tier" justification requirement, and the three-situations generalization
  test.

### Templates
- `CLAUDE.md`: the base governance template with the Prime Directive block,
  success-criteria rules, Solution Hierarchy reference, agent routing, and
  house style.
- `.claudeignore`.

### Skills
- `primedirective` (`/primedirective`): idempotent project installer with
  backup, ADD/MERGE/UNTOUCHED categorization, and `@`-reference proposal.
- `primedirectivesync` (`/claudesync`): three-mode drift audit (structural,
  governance content, invocation hygiene) that proposes before applying.
- `skillforge`: skill authoring and validation with SSL-style three-layer
  manifests (scheduling, structural, logical) and a five-point validation
  gate.
- `ralph` (`/ralph`): autonomous PRD-execution escape hatch. SKILL.md,
  RALPH.md, ralph.sh, prd.json template, README.
- `pr-review`: multi-dimensional fan-out review. Orchestrator, PowerShell
  diff-capture helper, shared output contract, and five dimension reviewers
  (correctness, security, solution-hierarchy, tests, docs).

### Tooling
- `install.ps1` and `install.sh`: copy or symlink install into a target
  `.claude` directory, with backup of any existing install.

### Known caveats
- `collect-diff.ps1` and `ralph.sh` were authored in a non-PowerShell,
  non-Claude-CLI sandbox. Validate `collect-diff.ps1` live with `-Scope
  working` and `ralph.sh` against a small PRD before trusting either end to
  end.
