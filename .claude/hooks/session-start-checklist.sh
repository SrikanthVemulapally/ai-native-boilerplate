#!/usr/bin/env bash
# session-start-checklist.sh
# SessionStart
# Injects the mandatory session start checklist as context.

SPEC_STATUS="❌ NOT FOUND"
ARCH_STATUS="❌ NOT FOUND"
DESIGN_STATUS="❌ NOT FOUND"
DECISIONS_STATUS="❌ NOT FOUND"
MDD_STATUS="no features documented"

[ -f "docs/SPEC.md" ] && SPEC_STATUS="✅ exists ($(wc -l < docs/SPEC.md) lines)"
[ -f "docs/ARCHITECTURE.md" ] && ARCH_STATUS="✅ exists"
[ -f "docs/DESIGN.md" ] && DESIGN_STATUS="✅ exists"
[ -f "docs/DECISIONS.md" ] && DECISIONS_STATUS="✅ exists"

if [ -d ".mdd/docs" ]; then
  MDD_COUNT=$(ls .mdd/docs/*.md 2>/dev/null | wc -l | tr -d ' ')
  MDD_STATUS="$MDD_COUNT feature doc(s) exist"
fi

CHANGELOG_STATUS="❌ NOT FOUND"
[ -f "docs/CHANGELOG.md" ] && CHANGELOG_STATUS="✅ exists"

CHECKLIST="🚀 SESSION START CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━
docs/SPEC.md:         $SPEC_STATUS
docs/ARCHITECTURE.md: $ARCH_STATUS
docs/DESIGN.md:       $DESIGN_STATUS
docs/DECISIONS.md:    $DECISIONS_STATUS
docs/CHANGELOG.md:    $CHANGELOG_STATUS
.mdd/docs/:           $MDD_STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━
READ ALL OF THESE BEFORE WRITING ANY CODE.
Follow the lifecycle: START → PLAN → IMPLEMENT → VERIFY → SYNC → SHIP → MONITOR → MAINTAIN
If SPEC.md is missing or empty, STOP and create it first.
The spec is the law. The architecture is the blueprint. The decisions log is the memory.
Read the last 5 DECISIONS entries and last 10 CHANGELOG entries to understand recent context."

jq -n --arg checklist "$CHECKLIST" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $checklist}}'
exit 0
