---
name: ralph
description: Autonomous execution escape hatch. Hand it a PRD and it loops, completing one story per iteration until the PRD is done. Bypasses multi-agent routing on purpose. Use when you have a clear PRD and want headless autonomous execution rather than the full governance workflow. User-invoked via /ralph.
disable-model-invocation: true
---

# ralph

An escape hatch. When you have a PRD and just want it built without the full
brainstorm-plan-execute governance layer, `/ralph` runs an autonomous loop:
one story per iteration until the PRD reports done.

This is a deliberate bypass of the multi-agent routing. It trades the
governance overhead for simplicity and momentum. Use it when the work is
well-specified and you are comfortable with autonomous execution.

## How to run

1. Write your stories into `prd.json` (see the template in this skill folder).
2. Run `./ralph.sh` from the project root.
3. The loop reads `RALPH.md` as the per-iteration prompt, executes one
   incomplete story, marks it done, and repeats until none remain.

## Files

- `RALPH.md`: the per-iteration agent prompt.
- `ralph.sh`: the loop script.
- `prd.json`: the story template.

## Guard

That is the entire system. Do not add more. The value of Ralph is its
simplicity; every feature added to it makes it worse at the one thing it is for.
If you need governance, use `/execute`, not this.
