#!/usr/bin/env bash
# Author-side: publish whatever changed in this repo, once a night, without
# having to remember to. Run it from launchd, cron, or by hand.
#
#   1. Nothing changed and nothing waiting to push: exit quietly.
#   2. Check the plugin (claude plugin validate) and every skill's frontmatter.
#   3. Stage everything git does not ignore, then scan the added lines and the
#      staged file names against a private pattern list. Binary files hold too,
#      since the scan cannot read them.
#      The scan covers everything that would leave: local commits the remote
#      does not have yet (however they were made) plus the new changes.
#   4. Any problem: unstage, write a hold file, notify, and stop. Nothing is
#      committed. Fix the problem and the next run goes on. To publish a
#      flagged line on purpose, commit and push it by hand.
#   5. Otherwise commit and push. A failed push is retried on the next run.
#
# Private patterns live in .publish-patterns at the repo root (git-ignored):
# one extended regex per line, matched case-insensitively; blank lines and
# lines starting with # are skipped. A missing or empty file holds every run,
# so the scan can never be skipped by accident.
#
# Environment:
#   DRY_RUN=1          do every check, then stop before commit and push
#   NOTIFY_CMD=<cmd>   run as: <cmd> "<message>" when a run holds or fails
#                      (default: a macOS notification, if osascript exists)
#   CLAUDE_BIN=<path>  the claude CLI (default: claude on PATH)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT" || exit 1
PATTERNS="$REPO_ROOT/.publish-patterns"
HOLD_FILE="$REPO_ROOT/.nightly-push-hold"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
DRY_RUN="${DRY_RUN:-0}"
STAMP="$(date '+%Y-%m-%d %H:%M')"

say() { echo "[$STAMP] $*"; }

notify() {
  local msg="skills nightly push: $1"
  if [ -n "${NOTIFY_CMD:-}" ]; then
    $NOTIFY_CMD "$msg" || say "notify command failed"
  elif command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"${msg//\"/\'}\" with title \"Skills repo\"" || true
  fi
}

# Unstage, record why, notify, stop. Never commits.
hold() {
  git reset -q
  { echo "$STAMP"; echo "$1"; [ -n "${2:-}" ] && printf '%s\n' "$2"; } > "$HOLD_FILE"
  say "HOLD: $1"
  [ -n "${2:-}" ] && printf '%s\n' "$2"
  notify "held. $1 See $HOLD_FILE"
  exit 2
}

push_pending() {
  git push -q 2>&1 || { git pull --rebase -q 2>&1 && git push -q 2>&1; }
}

# 1. Anything to do?
git fetch -q 2>/dev/null || say "fetch failed (offline?); continuing"
base="$(git merge-base '@{u}' HEAD 2>/dev/null)" \
  || hold "no upstream branch to compare against; set one with git push -u."
if [ -z "$(git status --porcelain)" ] && [ "$(git rev-parse HEAD)" = "$base" ]; then
  rm -f "$HOLD_FILE"; say "nothing to publish."; exit 0
fi

# 2. Checks.
if ! command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
  hold "claude CLI not found (set CLAUDE_BIN)."
fi
if ! out="$("$CLAUDE_BIN" plugin validate . 2>&1)"; then
  hold "plugin validation failed." "$out"
fi

bad=""
for f in skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$f")")"
  [ "$(head -n 1 "$f")" = "---" ] || { bad+="$f: no opening --- line"$'\n'; continue; }
  fm="$(awk 'NR==1{next} /^---[[:space:]]*$/{found=1; exit} {print} END{exit !found}' "$f")" \
    || { bad+="$f: frontmatter never closes"$'\n'; continue; }
  name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -n 1 | tr -d "\"'")"
  [ "$name" = "$dir" ] || bad+="$f: name is '$name', folder is '$dir'"$'\n'
  printf '%s\n' "$fm" | grep -qE '^description:[[:space:]]*[^[:space:]]' \
    || printf '%s\n' "$fm" | grep -qE '^description:[[:space:]]*[>|]' \
    || bad+="$f: no description"$'\n'
done
for d in skills/*/; do
  [ -f "$d/SKILL.md" ] || bad+="$d: no SKILL.md"$'\n'
done
[ -z "$bad" ] || hold "a skill is malformed." "$bad"

# 3. Stage and scan everything that would leave: commits not yet on the
#    remote (made by this script, by hand, or by anyone) plus the new changes.
git add -A
if [ -z "$(git diff --cached --name-only "$base")" ]; then
  git reset -q; rm -f "$HOLD_FILE"; say "only ignored files changed."; exit 0
fi

patterns="$(grep -vE '^[[:space:]]*(#|$)' "$PATTERNS" 2>/dev/null)"
[ -n "$patterns" ] || hold "no scan patterns found in $PATTERNS; refusing to publish unscanned."

binaries="$(git diff --cached --numstat "$base" | awk '$1=="-"{print $3}')"
[ -z "$binaries" ] || hold "binary files would be published (the scan cannot read them)." "$binaries"

scan_text="$( { git diff --cached --name-only "$base"; git diff --cached -U0 "$base" | grep -E '^\+' | grep -vE '^\+\+\+ '; } )"
hits="$(printf '%s\n' "$scan_text" | grep -n -E -i -f <(printf '%s\n' "$patterns"))"
rc=$?
[ $rc -le 1 ] || hold "the private scan errored (bad pattern?)."
[ $rc -eq 1 ] || hold "the private scan matched something." "$hits"

# 4. Commit and push.
files="$(git diff --cached --name-only)"
if [ "$DRY_RUN" = 1 ]; then
  pub="$(git diff --cached --name-only "$base")"
  git reset -q; rm -f "$HOLD_FILE"
  say "dry run: checks and scan passed; would publish:"
  printf '  %s\n' $pub
  exit 0
fi
if [ -n "$files" ]; then
  git commit -q -m "Nightly sync $(date '+%Y-%m-%d')" -m "$(printf -- '- %s\n' $files)" \
    || hold "git commit failed."
  say "committed: $(echo $files)"
fi
if push_pending; then
  rm -f "$HOLD_FILE"; say "pushed."
else
  notify "the push failed; commits are waiting locally and the next run retries."
  say "push failed; the next run retries."; exit 3
fi
