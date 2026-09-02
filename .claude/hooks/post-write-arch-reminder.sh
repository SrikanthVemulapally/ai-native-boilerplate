#!/usr/bin/env bash
# post-write-arch-reminder.sh
# PostToolUse — Write|Edit|MultiEdit
# Fires after file writes to architecture-relevant paths.
# Reminds the agent to keep ARCHITECTURE.md and DECISIONS.md in sync.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Patterns that indicate architectural significance
ARCH_PATTERNS=(
  "schema.ts"
  "schema/"
  "migrations/"
  "services/"
  "middleware"
  "wrangler.toml"
  "packages/shared"
  "workers/"
  "src-tauri/"
  "routes/api/"
  "lib/auth"
  "lib/db"
)

TRIGGERED=""
for pattern in "${ARCH_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -q "$pattern"; then
    TRIGGERED="$pattern"
    break
  fi
fi

if [ -z "$TRIGGERED" ]; then
  exit 0
fi

# Don't fire for docs files themselves
if echo "$FILE_PATH" | grep -q "^docs/"; then
  exit 0
fi

# Don't fire for test files
if echo "$FILE_PATH" | grep -q "\.test\.\|\.spec\."; then
  exit 0
fi

jq -n --arg file "$FILE_PATH" --arg pattern "$TRIGGERED" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("📐 ARCHITECTURE REMINDER: You just modified \($file) (matches pattern: \($pattern)).\n\nBefore your next action, verify:\n1. Does docs/ARCHITECTURE.md still describe reality? Update if not.\n2. Was this a significant decision? Log it in docs/DECISIONS.md.\n3. Did you change a shared type or service interface? Check if other feature docs need updating.\n\nIf this was a DB schema change: confirm a migration was generated and tested on local D1.\nIf this was a service interface change: check all consumers still compile.")
  }
}'

exit 0
