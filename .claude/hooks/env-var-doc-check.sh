#!/usr/bin/env bash
# env-var-doc-check.sh
# PostToolUse — Write|Edit|MultiEdit
# Detects new environment variable usage in source files.
# Enforces that every env var is documented in .env.example.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f ".env.example" ]; then
  exit 0
fi

# Only check source files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.mjs|*.rs) ;;
  *) exit 0 ;;
esac

# Don't check test files
if echo "$FILE_PATH" | grep -q "\.test\.\|\.spec\."; then
  exit 0
fi

# Extract env var references from the file
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Find process.env.VAR_NAME or c.env.VAR_NAME patterns
ENV_VARS=$(grep -oE '(process\.env|c\.env|Deno\.env\.get)\(["\x27]?([A-Z_][A-Z0-9_]+)["\x27]?\)|process\.env\.([A-Z_][A-Z0-9_]+)|c\.env\.([A-Z_][A-Z0-9_]+)' "$FILE_PATH" 2>/dev/null | \
  grep -oE '[A-Z_][A-Z0-9_]{2,}' | sort -u)

if [ -z "$ENV_VARS" ]; then
  exit 0
fi

# Check which ones are NOT in .env.example
MISSING=""
for VAR in $ENV_VARS; do
  # Skip common non-env patterns
  case "$VAR" in
    NODE_ENV|VITE_|PUBLIC_|CI|PATH|HOME|USER) continue ;;
  esac
  
  if ! grep -q "^${VAR}=" .env.example 2>/dev/null && \
     ! grep -q "^# ${VAR}" .env.example 2>/dev/null; then
    MISSING="$MISSING $VAR"
  fi
done

if [ -z "$MISSING" ]; then
  exit 0
fi

jq -n --arg missing "$MISSING" --arg file "$FILE_PATH" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("🔧 ENV VAR DOCUMENTATION REQUIRED\n\nFile \($file) references env vars not documented in .env.example:\n\($missing)\n\nBefore continuing, add each missing var to .env.example with:\n1. The variable name and a placeholder value\n2. A comment explaining what it is and how to get it\n\nFormat:\n# Description of what this is and where to get it\nVAR_NAME=your_value_here\n\nExample:\n# Stripe secret key - get from https://dashboard.stripe.com/apikeys\nSTRIPE_SECRET_KEY=sk_test_...")
  }
}'

exit 0
