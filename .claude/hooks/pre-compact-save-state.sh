#!/usr/bin/env bash
# pre-compact-save-state.sh
# PreCompact
# Saves a marker before context compaction so PostCompact can reinject context.

MARKER="${TMPDIR:-/tmp}/.claude_compacted_$(git rev-parse --short HEAD 2>/dev/null || echo 'session')"
touch "$MARKER"

# Save current branch and any in-progress notes
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
echo "branch=$BRANCH" > "$MARKER"
echo "compacted_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$MARKER"

exit 0
