#!/usr/bin/env bash
# track-changed-files.sh
# PostToolUse — Write|Edit|MultiEdit
# Tracks how many source files have been modified this session.
# Used by the stop quality gate to know when to force a review.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip non-source files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.rs|*.py)
    ;;
  *)
    exit 0
    ;;
esac

# Track in a session temp file
TRACKER="${TMPDIR:-/tmp}/.claude_changed_files_$(git rev-parse --short HEAD 2>/dev/null || echo 'session')"

# Add file to tracker (deduplicated)
touch "$TRACKER"
if ! grep -qF "$FILE_PATH" "$TRACKER" 2>/dev/null; then
  echo "$FILE_PATH" >> "$TRACKER"
fi

COUNT=$(wc -l < "$TRACKER" | tr -d ' ')

# Warn at 3+ files (stop hook will enforce)
if [ "$COUNT" -ge 3 ]; then
  jq -n --arg count "$COUNT" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: "📊 SESSION SCOPE: \($count) source files modified. When you stop, a quality gate review will be required (simplicity + security + architecture check)."}}'
fi

exit 0
