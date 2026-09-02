#!/usr/bin/env bash
# post-compact-reinject.sh
# PostCompact
# After context compaction, reinjests critical project context so Claude
# doesn't lose track of what it was doing.

MARKER="${TMPDIR:-/tmp}/.claude_compacted_$(git rev-parse --short HEAD 2>/dev/null || echo 'session')"

CONTEXT="⚠️ CONTEXT WAS COMPACTED — RE-READ THESE BEFORE CONTINUING:

1. CLAUDE.md — behavioral rules (the law)
2. docs/SPEC.md — what we're building
3. docs/ARCHITECTURE.md — how it's structured
4. .mdd/docs/ — feature-level memory

Current branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')
Status: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') files changed

Do NOT continue from memory. Re-read the docs first, then resume work."

# Clean up marker
rm -f "$MARKER"

jq -n --arg context "$CONTEXT" '{hookSpecificOutput: {hookEventName: "PostCompact", additionalContext: $context}}'
exit 0
