#!/usr/bin/env bash
# Author-side promotion: move a skill that was piloted in ~/.claude/skills/
# into this repo, then symlink it back so editing keeps working in place.
# Nothing is committed or pushed; review the diff, then commit.
#
# Usage: scripts/promote.sh <skill-name>

set -euo pipefail

name="${1:?usage: promote.sh <skill-name>}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"
src="$SKILLS_DIR/$name"
dst="$REPO_ROOT/skills/$name"

[ -d "$src" ] || { echo "no skill at $src"; exit 1; }
[ -L "$src" ] && { echo "$src is already a symlink (already promoted?)"; exit 1; }
[ -e "$dst" ] && { echo "$dst already exists in the repo"; exit 1; }
[ -f "$src/SKILL.md" ] || { echo "$src has no SKILL.md"; exit 1; }

mv "$src" "$dst"
ln -s "$dst" "$src"
echo "moved   $src -> $dst"
echo "linked  $src -> $dst"
echo
echo "Next: grep it for anything personal, add a row to README.md, then commit."
