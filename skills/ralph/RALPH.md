# Ralph iteration prompt

You are running one iteration of an autonomous build loop. Do one thing well,
then stop. The loop will call you again for the next story.

## Your task this iteration

1. Read `prd.json`. Find the first story where `"done": false`.
2. If there is no such story, output exactly `ALL_STORIES_COMPLETE` and stop.
3. Implement that one story. Only that story. Do not start the next one.

## How to implement

- Understand the story's acceptance criteria before writing code.
- Make the change minimal and focused on this story alone.
- Follow the existing conventions of the codebase.
- If the project has tests, run them. Do not mark the story done if you
  introduced a failure that was not there before.

## When the story is complete

- Set that story's `"done"` field to `true` in `prd.json`.
- Write a one-line note in the story's `"note"` field describing what you did.
- Stop. Do not continue to the next story. The loop handles that.

## Rules

- One story per iteration. No exceptions.
- If you cannot complete the story (blocked, ambiguous, missing dependency),
  set `"blocked": true` and `"note"` to the reason, then stop. Do not guess and
  do not thrash.
- Do not refactor unrelated code. Do not expand scope.
- No band-aids. If the story reveals a real problem, note it honestly rather
  than papering over it.
