#!/usr/bin/env bash
# Hook: PostToolUse (Write|Edit) — test file co-location check
# When a new source file is created, reminds to create a corresponding test file.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check source files in src/
case "$FILE_PATH" in
  src/**/*.ts|src/**/*.tsx)
    ;;
  *)
    exit 0
    ;;
esac

# Skip tests, types, constants, index files, generated files
case "$FILE_PATH" in
  *.test.*|*.spec.*|*.d.ts|*types*|*constants*|*index*|*.gen.*)
    exit 0
    ;;
esac

# Determine expected test file path
TEST_FILE=""
case "$FILE_PATH" in
  *.ts)
    TEST_FILE="${FILE_PATH%.ts}.test.ts"
    ;;
  *.tsx)
    TEST_FILE="${FILE_PATH%.tsx}.test.tsx"
    ;;
  *)
    exit 0
    ;;
esac

# Check if test file exists
if [ -f "$TEST_FILE" ]; then
  exit 0
fi

# Remind to create test
jq -n --arg msg "📝 No test file found for ${FILE_PATH}. Expected: ${TEST_FILE}. Write tests before or alongside this file. Run: /test ${FILE_PATH}" \
  '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'

exit 0
