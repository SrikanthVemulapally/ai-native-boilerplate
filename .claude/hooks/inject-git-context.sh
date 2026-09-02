#!/usr/bin/env bash
# inject-git-context.sh
# UserPromptSubmit
# Injects git context into every prompt so Claude always knows where it is.

# Get git context
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
RECENT_COMMITS=$(git log --oneline -5 2>/dev/null || echo "none")
CHANGED_FILES=$(git status --porcelain 2>/dev/null | head -20 || echo "none")
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "no tags")

# Build context
CONTEXT="📍 GIT CONTEXT
Branch: $BRANCH
Last tag: $LAST_TAG

Recent commits:
$RECENT_COMMITS

Working tree changes:
$CHANGED_FILES"

jq -n --arg context "$CONTEXT" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $context}}'
exit 0
