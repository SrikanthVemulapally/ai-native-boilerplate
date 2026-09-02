#!/usr/bin/env bash
# setup-worktrees.sh — Create git worktrees for parallel agent development
# Usage: ./scripts/setup-worktrees.sh auth export dashboard
# Each feature gets an isolated worktree on its own branch.

set -e

FEATURES=("$@")
BASE=$(pwd)

if [ ${#FEATURES[@]} -eq 0 ]; then
  echo "Usage: ./scripts/setup-worktrees.sh <feature1> <feature2> ..."
  echo "Example: ./scripts/setup-worktrees.sh auth billing dashboard"
  exit 1
fi

# Must be on main and up to date
CURRENT=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT" != "main" ]; then
  echo "❌ Must be on main branch to create worktrees. Current: $CURRENT"
  exit 1
fi

git pull --ff-only

mkdir -p worktrees

for feature in "${FEATURES[@]}"; do
  BRANCH="feat/$feature"
  WTPATH="worktrees/agent-$feature"

  if [ -d "$WTPATH" ]; then
    echo "⚠️  Worktree already exists: $WTPATH — skipping"
    continue
  fi

  echo "Creating worktree: $WTPATH (branch: $BRANCH)"
  git worktree add "$WTPATH" -b "$BRANCH"
  echo "  ✅ $WTPATH"
done

echo ""
echo "✅ Worktrees ready. Assign agents:"
for feature in "${FEATURES[@]}"; do
  echo "  Agent $feature → worktrees/agent-$feature (feat/$feature)"
done
echo ""
echo "⚠️  Coordination rules: see .claude/rules/core/worktrees.md"
echo "⚠️  NEVER let agents modify packages/shared/ simultaneously."
