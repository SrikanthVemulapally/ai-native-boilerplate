#!/usr/bin/env bash
# Hook: PreToolUse (Write|Edit) — file length guard
# Prevents source files from growing beyond a maintainable size.
# Triggers a warning at 300 lines, blocks at 500 lines.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check source files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.rs|*.go|*.py|*.rb)
    ;;
  *)
    exit 0
    ;;
esac

# Skip generated files, tests, config, migrations
case "$FILE_PATH" in
  *.test.*|*.spec.*|*.config.*|*.gen.*|*routeTree*|*migrations*|*.d.ts|node_modules/*)
    exit 0
    ;;
esac

# Check if file exists (new files are fine — length check is for existing growing files)
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

LINE_COUNT=$(wc -l < "$FILE_PATH")

# Warning threshold
if [ "$LINE_COUNT" -gt 300 ] && [ "$LINE_COUNT" -le 500 ]; then
  jq -n --arg msg "⚠️  File length: ${FILE_PATH} is ${LINE_COUNT} lines (recommended max: 300). Consider splitting by responsibility." \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $msg}}'
  exit 0
fi

# Hard block threshold
if [ "$LINE_COUNT" -gt 500 ]; then
  echo "🚫 BLOCKED: ${FILE_PATH} is ${LINE_COUNT} lines. Files must not exceed 500 lines. Split this file by responsibility before adding more." >&2
  exit 2
fi

exit 0
