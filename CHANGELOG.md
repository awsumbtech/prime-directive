# Changelog

All notable changes to Prime Directive are recorded here. Versions follow
semantic versioning. Tag each release in git so `/claudesync` can report what
changed since the last pinned version.

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
