#!/usr/bin/env bash
# check-spec-alignment.sh
# PreToolUse — Write|Edit|MultiEdit
# Checks if the file being written to is in a known feature area.
# Warns if it seems unrelated to the spec (not blocking, just contextual).

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "docs/SPEC.md" ]; then
  exit 0
fi

# Only care about source files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.rs|*.py|*.sql) ;;
  *) exit 0 ;;
esac

# Check if spec mentions anything related to this file's directory
DIR=$(dirname "$FILE_PATH")
FEATURE=$(basename "$DIR")

# This is a soft check — just inject context if the feature area seems new
if ! grep -qi "$FEATURE" docs/SPEC.md 2>/dev/null; then
  jq -n --arg feature "$FEATURE" --arg file "$FILE_PATH" '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: "📋 SPEC CHECK: Writing to \($file). The feature area \"\($feature)\" was not found in docs/SPEC.md. Confirm this change is required by the spec before proceeding. If adding a new feature, update docs/SPEC.md first."}}'
fi

exit 0
