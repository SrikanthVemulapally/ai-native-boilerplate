#!/usr/bin/env bash
# stop-quality-gate.sh
# Stop event
# Blocks Claude from finishing when 3+ source files were modified,
# forcing a quality gate pass before completion.

INPUT=$(cat)

# Prevent infinite loop — check if we're already in review
REVIEW_FLAG="${TMPDIR:-/tmp}/.claude_stop_hook_reviewing"
if [ -f "$REVIEW_FLAG" ]; then
  rm -f "$REVIEW_FLAG"
  exit 0
fi

# Check how many files changed this session
TRACKER="${TMPDIR:-/tmp}/.claude_changed_files_$(git rev-parse --short HEAD 2>/dev/null || echo 'session')"

if [ ! -f "$TRACKER" ]; then
  exit 0
fi

COUNT=$(wc -l < "$TRACKER" | tr -d ' ')

if [ "$COUNT" -lt 3 ]; then
  # Clean up tracker
  rm -f "$TRACKER"
  exit 0
fi

# 3+ files changed — force quality gate
touch "$REVIEW_FLAG"

CHANGED_FILES=$(cat "$TRACKER")
rm -f "$TRACKER"

jq -n --arg files "$CHANGED_FILES" --arg count "$COUNT" '{
  decision: "block",
  reason: ("QUALITY GATE REQUIRED (" + $count + " files changed)\n\nFiles modified:\n" + $files + "\n\nBefore completing this session, you must verify ALL of the following:\n\n1. SIMPLICITY: Could any of these files be shorter without losing clarity?\n2. SECURITY: Any auth bypasses, unvalidated inputs, exposed secrets?\n3. ARCHITECTURE: Does every change respect layer boundaries in docs/ARCHITECTURE.md?\n4. CONVENTIONS: Naming, error handling, and logging follow conventions.md?\n5. NFRs: Performance budgets, rate limiting, observability considered?\n6. TYPES: Run pnpm typecheck and confirm it passes.\n7. TESTS: Run pnpm test and confirm all tests pass.\n8. DOC SYNC: Does ARCHITECTURE.md still match reality? Update if not.\n9. DECISIONS: Any significant decision made? Log in DECISIONS.md.\n10. CHANGELOG: Add entry under Unreleased in CHANGELOG.md.\n\nReport findings for each, then you may stop.")
}'

exit 0
