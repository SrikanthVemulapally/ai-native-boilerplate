#!/usr/bin/env bash
# schema-migration-reminder.sh
# PostToolUse — Write|Edit|MultiEdit
# Injects a reminder when schema-adjacent files are modified.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Files that trigger migration reminder
SCHEMA_FILES=(
  "schema.ts"
  "schema.sql"
  "auth.ts"        # better-auth schema changes
  "db.ts"
)

# Check if file is a schema-adjacent file
FILENAME=$(basename "$FILE_PATH")
for schema_file in "${SCHEMA_FILES[@]}"; do
  if [ "$FILENAME" = "$schema_file" ]; then
    jq -n '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: "⚠️ SCHEMA CHANGE DETECTED: You modified '"$FILE_PATH"'. Remember to:\n1. Run: pnpm db:generate (generate migration)\n2. Run: pnpm db:migrate (apply migration)\n3. Run: pnpm typecheck (verify types)\nDo NOT forget the migration — schema drift breaks production."}}'
    exit 0
  fi
done

# Also trigger on any file in db/ or schema/ directories
if [[ "$FILE_PATH" == *"/db/"* ]] || [[ "$FILE_PATH" == *"/schema/"* ]]; then
  jq -n '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: "⚠️ DB CHANGE DETECTED: You modified a file in a database directory. Verify migration status with: pnpm db:status"}}'
  exit 0
fi

exit 0
