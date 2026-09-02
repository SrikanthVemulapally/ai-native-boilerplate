# /refactor [file-or-directory]

Audit and refactor a specific file or directory against all project rules. More thorough than `/simplify` — this covers types, structure, naming, security, and conventions, not just complexity.

**Usage:** `/refactor src/components/UserDashboard.tsx`

---

## Phase 1 — Audit (Read Only, No Changes)

Read the target file(s) completely. Then check against every rule category:

### Structure
- [ ] File > 300 lines? → must split
- [ ] Function > 50 lines? → must extract
- [ ] Nesting > 3 levels? → must flatten
- [ ] Cyclomatic complexity > 10? → must refactor

### Types
- [ ] Any `any` types? → replace with proper types
- [ ] Missing return types on exported functions? → add them
- [ ] Type assertions (`as Foo`) without justification? → investigate
- [ ] Missing Zod validation on external input? → add it

### Naming
- [ ] Functions named by implementation not intent? → rename
- [ ] Boolean variables not prefixed with `is/has/can/should`? → rename
- [ ] Constants not SCREAMING_SNAKE_CASE? → rename
- [ ] Files not matching their primary export name? → rename

### Security
- [ ] `process.env` access in client-side code? → move to server
- [ ] Any hardcoded values that should be env vars? → extract
- [ ] User input reaching DB/shell without validation? → add validation
- [ ] Secrets in code comments? → remove

### Conventions
- [ ] Violates any rule in `.claude/rules/`? → list them
- [ ] Missing error handling on async operations? → add it
- [ ] Sequential awaits that could be `Promise.all`? → parallelize
- [ ] Missing graceful shutdown hooks in entry points? → add them

### Tests
- [ ] Is there a co-located test file? → if not, flag
- [ ] Test assertions < 3 per test case? → flag
- [ ] Tests testing implementation not behavior? → flag

---

## Phase 2 — Present Findings

Present a prioritised findings list:

```
🔴 CRITICAL (must fix — security or correctness)
  1. [finding] — [file:line] — [fix]

🟡 IMPORTANT (should fix — rules violation)
  1. [finding] — [file:line] — [fix]

🟢 NICE TO HAVE (minor improvements)
  1. [finding] — [file:line] — [fix]
```

Ask: "Which findings should I fix? (all / critical-only / [list numbers])"

---

## Phase 3 — Implement Fixes

For each approved finding:
1. Make the smallest change that fixes the issue
2. Run typecheck after every file change
3. Run tests after structural changes
4. Commit in logical groups: `refactor: [what was fixed] in [file]`

**Rules:**
- NEVER change behavior — refactor only
- Tests must pass before and after every commit
- If a fix would change behavior, STOP and ask
- Max 3 files changed per commit during refactor

---

## Phase 4 — Verify

```bash
pnpm typecheck     # must pass
pnpm test          # must pass (same tests, same results)
pnpm lint          # must pass
```

Report: "Refactor complete. [N] findings fixed. Types: ✅ Tests: ✅ Lint: ✅"
