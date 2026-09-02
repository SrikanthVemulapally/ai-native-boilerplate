#!/usr/bin/env bash
# protect-sensitive-files.sh
# PreToolUse — Write|Edit|MultiEdit
# Blocks writes to files that should never be auto-modified by Claude.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Files that are ALWAYS blocked
BLOCKED_EXACT=(
  ".env"
  ".env.local"
  ".env.production"
  ".env.staging"
  ".env.test"
  "CLAUDE.md"
)

# Check exact matches
for blocked in "${BLOCKED_EXACT[@]}"; do
  if [ "$(basename "$FILE_PATH")" = "$blocked" ]; then
    echo "🚫 BLOCKED: Writing to '$FILE_PATH' is not allowed." >&2
    echo "Reason: Sensitive file protected by project hook." >&2
    echo "To edit .env files, make changes manually." >&2
    echo "To edit CLAUDE.md, request explicit approval — it's the project law." >&2
    jq -n '{permissionDecision: "deny", reason: "Sensitive file protected"}'
    exit 0
  fi
done

# Patterns that are blocked (glob-style prefix matches)
BLOCKED_PATTERNS=(
  "drizzle/migrations/"    # Never edit existing migrations
  ".github/workflows/"     # CI config — don't auto-modify
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    # Check if it's an existing file (new migrations are OK)
    if [ -f "$FILE_PATH" ]; then
      echo "🚫 BLOCKED: Editing existing file in protected path: '$FILE_PATH'" >&2
      echo "Reason: Files in '$pattern' must not be edited after creation." >&2
      jq -n '{permissionDecision: "deny", reason: "Protected path"}'
      exit 0
    fi
  fi
done

exit 0
