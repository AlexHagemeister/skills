#!/usr/bin/env bash
# Author-side setup: symlink every skill in this repo into ~/.claude/skills/
# so in-place edits land in the repo. Idempotent. Run once per machine.
#
# Usage: scripts/link.sh            (links into ~/.claude/skills)
#        SKILLS_DIR=~/.agents/skills scripts/link.sh   (another agent dir)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"
mkdir -p "$SKILLS_DIR"

for src in "$REPO_ROOT"/skills/*/; do
  name="$(basename "$src")"
  dst="$SKILLS_DIR/$name"
  if [ -L "$dst" ]; then
    ln -sfn "${src%/}" "$dst"
    echo "relinked  $name"
  elif [ -e "$dst" ]; then
    echo "SKIP      $name (a real directory exists at $dst; move it aside first)"
  else
    ln -s "${src%/}" "$dst"
    echo "linked    $name"
  fi
done
