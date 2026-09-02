#!/usr/bin/env bash
# Hook: Stop — eval compliance gate
# When features.ai is enabled, checks that every AI feature has evals.
# Blocks Claude from finishing if AI features lack eval coverage.

# Read .mdd/docs/ to find AI features
AI_FEATURES=""
if [ -d ".mdd/docs" ]; then
  AI_FEATURES=$(grep -rl "type: ai" .mdd/docs/ 2>/dev/null || true)
fi

if [ -z "$AI_FEATURES" ]; then
  exit 0
fi

MISSING_EVALS=""

for doc in $AI_FEATURES; do
  FEATURE_NAME=$(basename "$doc" .md)
  EVAL_DIR="evals/${FEATURE_NAME}"

  if [ ! -d "$EVAL_DIR" ] || [ ! -f "$EVAL_DIR/cases.jsonl" ]; then
    MISSING_EVALS="${MISSING_EVALS}\n  - ${FEATURE_NAME} (doc: ${doc}, expected: ${EVAL_DIR}/)"
  fi
done

if [ -n "$MISSING_EVALS" ]; then
  echo "🚫 EVAL COMPLIANCE GATE: The following AI features lack evals:" >&2
  echo -e "$MISSING_EVALS" >&2
  echo "" >&2
  echo "Every AI feature MUST have evals with minimum 20 test cases." >&2
  echo "Run: /add-eval <feature-name>" >&2
  exit 2
fi

exit 0
