---
name: primedirectivesync
description: Audits CLAUDE.md, CLAUDE.local.md, agents, and skills for drift against the actual project. Detects stale commands, missing @ references, outdated tech stack, changed structure, and invocation-hygiene problems. Proposes specific fixes and writes them only with approval. User-invoked via /claudesync.
disable-model-invocation: true
---

# primedirectivesync

Detects drift between the Prime Directive governance files and the project as
it actually is now. Run it with `/claudesync` whenever the project has changed
or things feel out of sync. It proposes; it never edits without your approval.

## Audit mode 1: Structural drift

Compare what CLAUDE.md and the rules claim against reality.

```bash
echo "=== Declared test/lint/build commands (from CLAUDE.md) ==="
grep -E "Test:|Lint:|Build:" CLAUDE.md
echo "=== Actual scripts available ==="
cat package.json 2>/dev/null | grep -A20 '"scripts"'
ls Makefile justfile 2>/dev/null
```

Check for:

- **Stale commands**: a `Test:` command in CLAUDE.md that no longer exists.
- **Outdated tech stack**: dependencies or languages that changed since setup.
- **Changed structure**: directories referenced in rules that moved or vanished.
- **Missing @ references**: central files (schemas, types, config, glossary)
  that should be `@`-referenced but are not.
- **Dangling @ references**: `@`-referenced files that no longer exist.

## Audit mode 2: Governance content drift

- Agents or skills that reference tools, paths, or conventions the project no
  longer uses.
- Rules that contradict each other or the current CLAUDE.md.
- Prose that should have been promoted to a higher Solution Hierarchy tier
  (a rule repeatedly ignored is a candidate for a hook or a check).

## Audit mode 3: Invocation hygiene

If skill-load log lines are present (format: `Loaded <skill>: need=yes,
relevance=yes, reason=...`), classify each load into one of seven buckets:

- `clean`: loaded, needed, relevant, used.
- `phantom`: loaded but never actually used.
- `need_misjudged`: loaded on a task that did not require it.
- `relevance_drift`: loaded for a purpose adjacent to but not matching its job.
- `scope_creep`: used beyond what its manifest declares.
- `missed_load`: a task that needed a skill that was not loaded.
- `correctly_skipped`: correctly not loaded.

For each problem bucket, propose the fix: sharpen a trigger, narrow a
description, split an over-broad skill (hand off to `skillforge`), or add a
missing trigger.

## Output: propose, do not apply

Present findings as a numbered list, each with:

- What drifted (specific file and line).
- Why it matters.
- The exact proposed change (a diff, not a description).
- The Solution Hierarchy tier the fix belongs at.

Wait for explicit approval before writing anything. Back up before applying, the
same way `/primedirective` does.

## Notes

- User-invoked only. The agent does not auto-run drift audits.
- Run this after any significant project change: new framework, moved
  directories, changed build tooling, or a batch of new skills.
