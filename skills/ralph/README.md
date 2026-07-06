# ralph

An autonomous build loop. Hand it a PRD, it builds one story at a time until
done. This is the Prime Directive escape hatch for when you want momentum over
governance.

## Install

Place this folder at `.claude/skills/ralph/` in your project (or install it
globally via `/primedirective`). Make the script executable:

```bash
chmod +x ralph.sh
```

## Requirements

- Claude Code CLI available as `claude` on your PATH.
- `jq` installed.

## Use

1. Copy `prd.json` and fill in your stories. Each story needs a title and
   acceptance criteria. Leave `done` and `blocked` as `false`.
2. Run the loop from your project root:

```bash
./ralph.sh
```

3. Optionally cap iterations or point at a different PRD:

```bash
MAX_ITERATIONS=20 ./ralph.sh my-feature-prd.json
```

## What it does

Each iteration runs one headless Claude Code call using `RALPH.md` as the
prompt. The agent implements exactly one incomplete story, marks it done in the
PRD, and stops. The loop repeats until no incomplete stories remain, or until a
story is marked blocked, at which point it stops for human review.

## When NOT to use it

If the work needs the full governance workflow (success criteria negotiation,
blast-radius analysis, multi-agent review), use `/execute` instead. Ralph
deliberately skips all of that. It is for well-specified work you are
comfortable running autonomously.

## Philosophy

Simplicity is the feature. Do not add orchestration, retries, or cleverness. If
it needs governance, it is not a Ralph job.
