#!/usr/bin/env bash
# auto-format.sh
# PostToolUse — Write|Edit|MultiEdit
# Runs the formatter on every file Claude edits. Silent on non-TS/JS files.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip generated files and non-source files
SKIP_PATTERNS=(
  "node_modules"
  ".pnpm"
  "dist/"
  ".next/"
  "build/"
  ".turbo/"
  "routeTree.gen.ts"
  "__generated__"
  ".mdd/"
  "design_system.html"
)

for skip in "${SKIP_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$skip"* ]]; then
    exit 0
  fi
done

# Determine extension
EXT="${FILE_PATH##*.}"

case "$EXT" in
  ts|tsx|js|jsx|mjs|cjs|json|css|html|md)
    # Use Biome if available, fall back to Prettier
    if command -v biome &>/dev/null; then
      biome check --write "$FILE_PATH" --no-errors-on-unmatched 2>/dev/null
    elif command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null
    fi
    ;;
  rs)
    # Rust — for Tauri agent projects
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null
    fi
    ;;
  *)
    # Unknown extension — skip silently
    ;;
esac

exit 0
