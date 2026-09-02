---
name: simplify
description: Reduce code complexity without changing behavior — refactoring with safety
user-invocable: true
---

Simplify: $ARGUMENTS

## What This Does

Analyzes code for complexity and reduces it — WITHOUT changing behavior. Tests must pass before and after. This is safe refactoring, not feature work.

## Targets

- **No argument** → analyze recently changed files (`git diff --name-only HEAD~1`)
- **File path** → simplify that file (e.g., `/simplify src/services/billing.ts`)
- **Directory** → simplify all files in that directory

## Analysis Checklist

For each target file, check:

### 1. Complexity
- [ ] Cyclomatic complexity > 10? → extract functions
- [ ] Nesting depth > 3? → early returns, guard clauses
- [ ] Function length > 40 lines? → extract
- [ ] File length > 300 lines? → split by responsibility
- [ ] Parameter count > 4? → group into object

### 2. Dead Code
- [ ] Unused imports? → remove
- [ ] Unused private functions? → remove
- [ ] Commented-out code? → remove (git has history)
- [ ] Unreachable branches? → remove
- [ ] Redundant type assertions? → remove

### 3. Duplication
- [ ] Same logic in 2+ places? → extract shared function
- [ ] Similar patterns with minor variation? → parameterize
- [ ] Repeated validation? → extract Zod schema
- [ ] Repeated error handling? → extract wrapper

### 4. Framework Leverage
- [ ] Manual loading state? → use TanStack Query's `isLoading`
- [ ] Manual form state? → use TanStack Form
- [ ] Manual debounce? → use framework utility
- [ ] Re-implementing a shadcn component? → use the component

### 5. Readability
- [ ] Vague names? (`data`, `item`, `result`, `temp`) → rename to specific
- [ ] Boolean parameters? → split into two functions or use enum
- [ ] Double negatives? (`!isNotDisabled`) → invert
- [ ] Magic numbers? → extract named constant

## Workflow

### Step 1: Baseline
```bash
pnpm test
```
Confirm all tests pass. If any fail, STOP — fix tests first.

### Step 2: Analyze
Read the file(s). Apply the checklist. List findings:
```
## Simplification Findings: [file]
| # | Category | Issue | Fix | Impact |
|---|----------|-------|-----|--------|
| 1 | Complexity | billing.ts:45 — 15 branches | Extract `calculateTier` function | Medium |
| 2 | Dead code | billing.ts:12 — unused import | Remove `lodash` import | Low |
| ... | ... | ... | ... | ... |
```

### Step 3: Apply (Surgical)
Apply ONE simplification at a time. After each:
```bash
pnpm test
```
If tests pass → continue. If tests fail → revert that change, move to next finding.

### Step 4: Verify
```bash
pnpm test
pnpm typecheck
pnpm lint
```
All must pass. No new warnings.

### Step 5: Report
```
## Simplified: [file]
- Changes: N (list each)
- Lines removed: N
- Complexity reduced: from X to Y
- Tests: all pass ✅
- Behavior: unchanged ✅
```

## Rules
- **Behavior unchanged.** If any test breaks, you changed behavior — revert.
- **One change at a time.** Don't batch 5 refactors and hope tests catch it.
- **No new features.** This is simplification only.
- **No style changes.** No renaming variables for "taste." Only structural improvements.
- **Preserve comments that explain WHY.** Remove comments that explain WHAT.
