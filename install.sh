#!/usr/bin/env bash
#
# install.sh - install Prime Directive into a target .claude directory.
#
# Copies or symlinks agents, skills, and rules from this repo into a target
# Claude Code directory. Copy mode is self-contained and pin-friendly. Symlink
# mode keeps every install in sync with the repo via git pull.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.claude"
MODE="copy"

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --mode)   MODE="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

if [ "$MODE" != "copy" ] && [ "$MODE" != "symlink" ]; then
  echo "Mode must be 'copy' or 'symlink'."
  exit 1
fi

PARTS=(agents skills rules)

# Back up an existing install before touching it.
if [ -d "$TARGET" ]; then
  ts=$(date +%Y%m%d-%H%M%S)
  backup="$TARGET/backups/install-$ts"
  mkdir -p "$backup"
  for p in "${PARTS[@]}"; do
    if [ -e "$TARGET/$p" ]; then
      cp -r "$TARGET/$p" "$backup/" 2>/dev/null || true
    fi
  done
  echo "Backed up existing install to $backup"
fi

mkdir -p "$TARGET"

for p in "${PARTS[@]}"; do
  src="$REPO_ROOT/$p"
  dst="$TARGET/$p"

  rm -rf "$dst"

  if [ "$MODE" = "symlink" ]; then
    ln -s "$src" "$dst"
    echo "Linked $p -> $src"
  else
    cp -r "$src" "$dst"
    echo "Copied $p"
  fi
done

echo ""
echo "Prime Directive installed to $TARGET (mode: $MODE)."
echo "Restart Claude Code so the skills register."
