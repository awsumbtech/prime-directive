#!/usr/bin/env bash
#
# install.sh - install Prime Directive into a target .claude directory.
#
# Copies or symlinks agents, skills, rules, and hooks from this repo into a
# target Claude Code directory, then registers the hooks in that directory's
# settings.json. Copy mode is self-contained and pin-friendly. Symlink mode
# keeps every install in sync with the repo via git pull.
#
# The hooks are Node scripts. If node is not on PATH the files are still
# installed but not registered, and the script says so.

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

PARTS=(agents skills rules hooks)

for p in "${PARTS[@]}"; do
  if [ ! -d "$REPO_ROOT/$p" ]; then
    echo "Repo is missing '$p'. Run this script from a full checkout."
    exit 1
  fi
done

# Back up an existing install before touching it. Linked parts are skipped:
# they point at the repo, so there is nothing local to preserve.
if [ -d "$TARGET" ]; then
  ts=$(date +%Y%m%d-%H%M%S)
  backup="$TARGET/backups/install-$ts"
  backed_up=0
  for p in "${PARTS[@]}"; do
    if [ -e "$TARGET/$p" ] && [ ! -L "$TARGET/$p" ]; then
      mkdir -p "$backup"
      cp -r "$TARGET/$p" "$backup/" 2>/dev/null || true
      backed_up=1
    fi
  done
  if [ "$backed_up" -eq 1 ]; then
    echo "Backed up existing install to $backup"
  fi
fi

mkdir -p "$TARGET"

for p in "${PARTS[@]}"; do
  src="$REPO_ROOT/$p"
  dst="$TARGET/$p"

  if [ -L "$dst" ]; then
    rm "$dst"          # remove the link itself, never the repo directory
  elif [ -e "$dst" ]; then
    rm -rf "$dst"
  fi

  if [ "$MODE" = "symlink" ]; then
    ln -s "$src" "$dst"
    echo "Linked $p -> $src"
  else
    cp -r "$src" "$dst"
    echo "Copied $p"
  fi
done

# Register the hooks in this directory's settings.json.
if command -v node >/dev/null 2>&1; then
  node "$TARGET/hooks/merge-settings.js" "$TARGET/settings.json" "$TARGET/hooks"
else
  echo "WARNING: node not found on PATH. Hook files were installed but not registered."
  echo "Install Node.js, then run: node \"$TARGET/hooks/merge-settings.js\" \"$TARGET/settings.json\" \"$TARGET/hooks\""
fi

echo ""
echo "Prime Directive installed to $TARGET (mode: $MODE)."
echo "Restart Claude Code so the skills and hooks register."
