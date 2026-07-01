#!/usr/bin/env bash
#
# Append a session entry to the current branch's decision log under docs/.
#
#   docs/<branch>.md   where slashes in the branch name become hyphens
#                      (feat/staticbase-skill -> docs/feat-staticbase-skill.md)
#
# One file per branch. Every run appends a new timestamped "## Session" block,
# so multiple sessions on the same branch accumulate in one file.
#
# Usage:
#   append-session.sh <body-file>     # entry markdown read from the file
#   some-cmd | append-session.sh      # or from stdin if no arg is given
#
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "error: not inside a git repository — cannot resolve the project root." >&2
  exit 1
}

# symbolic-ref resolves the branch name for both normal and unborn branches
# (a branch checked out before its first commit) and fails only on detached HEAD.
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || true)
if [ -z "$BRANCH" ]; then
  echo "error: could not determine a named branch (detached HEAD?). Check out a branch first." >&2
  exit 1
fi

# Read the entry body before touching the filesystem so a missing body fails early.
if [ "${1:-}" ]; then
  [ -f "$1" ] || { echo "error: body file not found: $1" >&2; exit 1; }
  BODY=$(cat "$1")
else
  BODY=$(cat)
fi
if [ -z "${BODY//[[:space:]]/}" ]; then
  echo "error: empty session body — nothing to append." >&2
  exit 1
fi

SLUG=${BRANCH//\//-}
DOCS_DIR="$ROOT/docs"
FILE="$DOCS_DIR/${SLUG}.md"

mkdir -p "$DOCS_DIR"

if [ ! -f "$FILE" ]; then
  printf '# %s\n\nDecision & tradeoff log for branch `%s`.\n' "$BRANCH" "$BRANCH" > "$FILE"
fi

TS=$(date "+%Y-%m-%d %H:%M %Z")

{
  printf '\n## Session — %s\n\n' "$TS"
  printf '%s\n' "$BODY"
} >> "$FILE"

echo "Appended session entry to $FILE"
