---
name: compound
description: Extract learnings from the current session into rules, skills, and docs
user-invocable: true
---

Compound: $ARGUMENTS

## What This Does

At the end of a session (or after a complex feature), extract what was learned and bake it into the project so future sessions benefit. This is how the codebase gets smarter over time.

## Workflow

### Step 1: Review the Session
Scan the current session's work:
- What was built/changed?
- What patterns were discovered?
- What mistakes were made and corrected?
- What edge cases were found?
- What assumptions were validated?

### Step 2: Classify Learnings

Each learning goes into one of these buckets:

| Type | Where It Goes | Example |
|------|--------------|---------|
| **Anti-pattern discovered** | `CLAUDE.md` anti-patterns section | "Don't use `Date.now()` in Durable Objects — use `ctx.storage.setAlarm`" |
| **Pattern that works** | `CLAUDE.md` patterns section | "Stripe webhook idempotency: check `event.id` in KV before processing" |
| **Stack-specific gotcha** | `.claude/rules/stack/<stack>.md` | "Zod 4 `.merge()` removed — use `.extend()`" |
| **Feature-specific rule** | `.claude/rules/features/<feature>.md` | "R2 presigned URLs expire in 7 days max" |
| **Convention to enforce** | `.claude/rules/core/conventions.md` | "Error responses use `{ error: { code, message, details } }` shape" |
| **Test insight** | `.claude/rules/core/testing.md` | "Miniflare D1 needs `--experimental-local-dev` flag" |
| **Deployment lesson** | `.claude/rules/core/deployment.md` | "Wrangler deploy fails if D1 binding name has uppercase" |
| **Architecture decision** | `docs/DECISIONS.md` | "Chose SSE over WebSocket for real-time — simpler, no DO needed" |
| **Recurring task** | New slash command or skill | "Add `/clear-cache` command for R2 cache invalidation" |

### Step 3: Apply
For each learning:
1. Read the target file
2. Find the right section
3. Append the new knowledge (don't duplicate existing rules — check first)
4. If it contradicts an existing rule, REPLACE the old one, don't append

### Step 4: Report
```
## Session Learnings Extracted: N items

### Added to CLAUDE.md
- [anti-pattern] Don't use Date.now() in Durable Objects
- [pattern] Stripe webhook idempotency via KV event.id check

### Added to rules/
- [stack/tauri] Tauri IPC validation must use Zod on both sides
- [features/payments] R2 presigned URLs expire in 7 days max

### Added to docs/
- [DECISIONS] Chose SSE over WebSocket for real-time updates

### New Commands
- Suggested: /clear-cache (R2 cache invalidation workflow)
```

## Rules
- **Don't duplicate.** Search the target file for similar content before adding.
- **Replace, don't stack.** If a new rule contradicts an old one, replace the old one.
- **Be specific.** "Be careful with dates" is useless. "Durable Objects alarm API uses epoch milliseconds, not Date objects" is useful.
- **Only extract real learnings.** If the session was routine with nothing new, say so — don't manufacture insights.
