#!/usr/bin/env bash
# cleanup-worktrees.sh — Remove all worktrees and their branches after merging
# Usage: ./scripts/cleanup-worktrees.sh
# WARNING: Only run after all worktree branches are merged to main.

set -e

# Confirm
echo "⚠️  This will remove ALL worktrees and their branches."
echo "   Only run this after all branches are merged to main."
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Get all worktrees except main
WORKTREES=$(git worktree list --porcelain | grep "^worktree " | tail -n +2 | sed 's/^worktree //')

if [ -z "$WORKTREES" ]; then
  echo "No worktrees to clean up."
  exit 0
fi

for wt in $WORKTREES; do
  BRANCH=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

  # Check if branch is merged
  if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ]; then
    MERGED=$(git branch --merged main | grep -w "$BRANCH" || true)
    if [ -z "$MERGED" ]; then
      echo "⚠️  Branch '$BRANCH' is NOT merged to main — skipping $wt"
      continue
    fi
  fi

  echo "Removing worktree: $wt (branch: $BRANCH)"
  git worktree remove "$wt" --force 2>/dev/null || true

  if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ]; then
    git branch -D "$BRANCH" 2>/dev/null || true
    echo "  ✅ Removed branch: $BRANCH"
  fi
done

git worktree prune
echo ""
echo "✅ Cleanup complete."
