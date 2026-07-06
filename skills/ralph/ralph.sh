#!/usr/bin/env bash
#
# ralph.sh - autonomous build loop
#
# Reads stories from prd.json, runs one Claude Code iteration per incomplete
# story using RALPH.md as the prompt, and stops when all stories are done or a
# story is blocked. Keep this simple. Do not add features.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD="${1:-prd.json}"
PROMPT="$SCRIPT_DIR/RALPH.md"
MAX_ITERATIONS="${MAX_ITERATIONS:-50}"

if [ ! -f "$PRD" ]; then
  echo "No PRD found at $PRD. Create one from prd.json template first."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed."
  exit 1
fi

iteration=0
while [ "$iteration" -lt "$MAX_ITERATIONS" ]; do
  # Count stories still to do (not done and not blocked).
  remaining=$(jq '[.stories[] | select(.done == false and (.blocked // false) == false)] | length' "$PRD")

  if [ "$remaining" -eq 0 ]; then
    echo "No remaining stories. Stopping."
    break
  fi

  iteration=$((iteration + 1))
  echo "=== Iteration $iteration ($remaining stories remaining) ==="

  # Run one headless Claude Code iteration with the per-story prompt.
  cat "$PROMPT" | claude --dangerously-skip-permissions --print

  # If any story got blocked this iteration, stop and surface it.
  blocked=$(jq '[.stories[] | select((.blocked // false) == true)] | length' "$PRD")
  if [ "$blocked" -gt 0 ]; then
    echo "A story is blocked. Stopping for human review."
    jq -r '.stories[] | select((.blocked // false) == true) | "BLOCKED: \(.title) - \(.note)"' "$PRD"
    exit 2
  fi
done

echo "Ralph loop finished after $iteration iteration(s)."
jq -r '.stories[] | "[\(if .done then "x" else " " end)] \(.title)"' "$PRD"
