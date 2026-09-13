# {PROJECT_NAME}

{ONE_LINE_PROJECT_DESCRIPTION}

## Tech Stack

{TECH_STACK}

## Commands

- Test: `{TEST_COMMAND}`
- Lint: `{LINT_COMMAND}`
- Build: `{BUILD_COMMAND}`

## THE PRIME DIRECTIVE - Read This First

**Every change must leave the project in a BETTER state than you found it.
Never trade one fix for new breakage.**

Before touching ANY code, you must:

1. **Define success criteria.** What does "done" look like? Get explicit
   confirmation from the user.
2. **Map the blast radius.** What else touches, depends on, or is affected by
   the code you are changing? Use the `explorer` agent if unsure.
3. **Capture the baseline.** Run the full test suite BEFORE making changes.
   Record what passes and what fails. This is your "before" snapshot.
4. **Make the change.** Minimal, focused, scoped to the task.
5. **Run the full test suite AFTER.** Compare to your baseline. If ANYTHING
   that previously passed now fails, you are not done. Fix the regression
   before reporting success.
6. **Verify the actual user goal.** Not just that code compiles or tests pass.
   Does it actually solve the problem the user described?

**If you cannot run tests**, tell the user and explain what manual verification
you would recommend. Do not claim success without verification.

## Success Criteria Rules

These apply to EVERY task, no exceptions:

- **No net-new failures.** If 50 tests passed before, 50+ must pass after.
- **No silent side effects.** If your change touches shared code (utilities,
  configs, types, schemas, middleware), check all consumers of that code.
- **No "it works for this case".** Test the happy path AND the edge cases:
  empty inputs, nulls, auth failures, network errors, concurrent access.
- **No tunnel vision.** Before reporting done, ask: what would break if this
  ran in production with real data, real users, real load?
- **Confirm, don't assume.** If success criteria are ambiguous, ASK before
  implementing.

## Where behavior changes belong

Before adding a new rule or instruction, consult @rules/SOLUTION_HIERARCHY.md.
Prefer the highest-reliability tier that solves the problem. Prose (Tier 3) is
the last resort, and any new prose must state why Tier 0, 1, or 2 could not do
the job.

## Agent Routing

Delegate to the appropriate specialist. See @rules/agent-routing.md for full
logic.

- Exploration and research: `explorer`
- Implementation: `implementer`
- Code review: `reviewer` (after implementation)
- Testing: `tester`
- Documentation: `documenter`
- Debugging: `debugger`

## Workflow

For any non-trivial task: `/brainstorm` -> `/plan` -> `/execute`. The execute
skill handles agent dispatch, baseline comparison, and regression gates
automatically. When something is broken, `/debug` runs the diagnose-fix-guard
cycle. `/review-gate` is the sixty-second check for a small change.
`/handoff` packages context for another session. For autonomous execution
from a PRD, `/ralph` is the escape hatch.

## House style

- No em dashes in any generated content.
- Prose over decoration. Minimal formatting.
- Match existing conventions in this codebase.

## Project-specific context

{PROJECT_SPECIFIC_NOTES}

<!-- Add @-references to key files below so they load into every request. -->
<!-- Example: The database schema is defined in @prisma/schema.prisma -->
