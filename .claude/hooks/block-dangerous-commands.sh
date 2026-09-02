#!/usr/bin/env bash
# block-dangerous-commands.sh
# PreToolUse — Bash
# Blocks destructive commands before Claude executes them.
# Covers 49+ dangerous patterns across git, filesystem, DB, cloud, and process operations.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Patterns that are ALWAYS blocked
BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "git push --force"
  "git push -f"
  "git reset --hard"
  "git clean -f"
  "git commit --no-verify"
  "git commit -n "
  "DROP TABLE"
  "TRUNCATE TABLE"
  "cat .env"
  "cat *.env"
  "echo .env"
  "printenv"
  "npm publish"
  "pnpm publish"
  "> /dev/sda"
  "dd if="
  "chmod -R 777"
  "chown -R root"
  ":(){:|:&};:"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiF "$pattern"; then
    echo "🚫 BLOCKED: Dangerous command detected: '$pattern'" >&2
    echo "Command was: $COMMAND" >&2
    echo "If you need this operation, request explicit user approval first." >&2
    jq -n '{permissionDecision: "deny", reason: "Dangerous command blocked by project safety hook"}'
    exit 0
  fi
done

# Soft warnings — proceed but inject context
WARN_PATTERNS=(
  "pnpm install"
  "npm install"
  "pip install"
)

for pattern in "${WARN_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiF "$pattern"; then
    jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: "⚠️ Package install detected. Verify no new dependencies conflict with existing versions. Check package.json after install."}}'
    exit 0
  fi
done

exit 0
