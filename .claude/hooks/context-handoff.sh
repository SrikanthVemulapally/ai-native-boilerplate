#!/usr/bin/env bash
# context-handoff.sh
# PreCompact
# Saves a structured context handoff before compaction.
# The handoff document gives the post-compact agent full context to continue.

HANDOFF_DIR=".claude/handoffs"
mkdir -p "$HANDOFF_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
HANDOFF_FILE="$HANDOFF_DIR/handoff_$TIMESTAMP.md"

# Gather git state
GIT_LOG=$(git log --oneline -10 2>/dev/null || echo "no git history")
GIT_STATUS=$(git status --short 2>/dev/null || echo "no git status")
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Gather recent spec/arch info
SPEC_EXCERPT=""
if [ -f "docs/SPEC.md" ]; then
  SPEC_EXCERPT=$(head -30 docs/SPEC.md)
fi

# Gather active feature docs
FEATURE_DOCS=""
if [ -d ".mdd/docs" ]; then
  for doc in .mdd/docs/*.md; do
    [ -f "$doc" ] || continue
    name=$(basename "$doc")
    status=$(grep -m1 "^\*\*Status:\*\*" "$doc" 2>/dev/null | sed 's/\*\*Status:\*\* //')
    FEATURE_DOCS="$FEATURE_DOCS\n- $name: $status"
  done
fi

# Write the handoff document
cat > "$HANDOFF_FILE" << HANDOFF
# Context Handoff — $TIMESTAMP

> This document was auto-generated before context compaction.
> Read this file if context was lost or session resumed after long break.

## Git State at Handoff

**Branch:** $GIT_BRANCH

**Recent commits:**
$GIT_LOG

**Uncommitted changes:**
$GIT_STATUS

## Active Feature Docs
$FEATURE_DOCS

## Spec Summary (first 30 lines)
$SPEC_EXCERPT

## Context Recovery Instructions

On resume, run `/catchup` for full project state, then:
1. Read `.claude/handoffs/handoff_$TIMESTAMP.md` (this file)
2. Check what's dirty in git — finish or stash before new work
3. Read the feature doc for whatever was being worked on
4. Continue from where the session left off

## Notes

(This section is intentionally empty — the agent should have added notes before compaction
via the pre-compact-save-state.sh hook. If empty, read recent git commits for context.)
HANDOFF

# Also update the .mdd startup file
if [ -f ".mdd/.startup.md" ]; then
  LAST_HANDOFF="Last handoff: $HANDOFF_FILE ($TIMESTAMP)"
  # Update the last handoff line if it exists, otherwise append
  if grep -q "Last handoff:" ".mdd/.startup.md"; then
    sed -i "s|Last handoff:.*|$LAST_HANDOFF|" ".mdd/.startup.md" 2>/dev/null || true
  fi
fi

jq -n --arg file "$HANDOFF_FILE" '{
  hookSpecificOutput: {
    hookEventName: "PreCompact",
    additionalContext: ("💾 CONTEXT HANDOFF SAVED\n\nHandoff document written to: \($file)\n\nBefore compaction completes, make sure you have noted in the handoff file:\n- What you were in the middle of doing\n- What the next step is\n- Any decisions made this session not yet logged in DECISIONS.md\n- Any open questions that need answering\n\nThe handoff file will be read by the resumed session to pick up exactly where you left off.")
  }
}'

exit 0
