---
name: implement
description: Implement a feature end-to-end with spec check, MDD workflow, and quality gates
user-invocable: true
---

Implement the following: $ARGUMENTS

Follow this exact workflow — do not skip steps:

## Phase 0: Spec Check
1. Read `docs/SPEC.md` — confirm this feature is in scope.
2. Read `docs/ARCHITECTURE.md` — identify the correct layer for this change.
3. Read `.mdd/docs/` — check if this feature already exists or is partially built.
4. If anything is unclear or contradicts the spec, STOP and ask before proceeding.

## Phase 1: Clarify
- State your interpretation of the request.
- List any assumptions you're making.
- Identify any tradeoffs or design decisions needed.
- Ask if anything is ambiguous. Wait for confirmation before proceeding.

## Phase 2: Design (if 3+ files will change)
- Describe the data model, API contracts, and component structure.
- Identify all files that will be created or modified.
- Run impact analysis: who consumes the code you're changing?
- Present the plan. Get approval.

## Phase 3: MDD Feature Doc
- Create `.mdd/docs/<NN>-<feature-name>.md` with the standard MDD frontmatter.
- Include: purpose, architecture, data model, API contracts, business rules, known edge cases.
- Show the doc. Get confirmation this is correct before writing any code.

## Phase 4: Test Skeletons
- Write test skeletons for all documented behaviors (unit + integration as needed).
- Run tests. Confirm ALL skeletons fail (Red Gate).
- If any skeleton passes unexpectedly, investigate and resolve before proceeding.

## Phase 5: Implementation Plan
- Break into commit-worthy blocks: each block has a runnable end-state + verification command.
- Show the plan. Confirm before starting.

## Phase 6: Implement (Green Gate loop)
For each block:
1. Implement the block.
2. Run verification command.
3. If it fails: state root cause, apply targeted fix, rerun. Max 5 iterations.
4. Run full test suite to check for regressions.
5. Commit the block: `git commit -m "feat(scope): description"`

## Phase 7: Integration Verification
- Test against real environment (real HTTP, real DB, real browser if applicable).
- Confirm documented behavior matches actual behavior.
- Update `.mdd/docs/<feature>.md` with `status: complete` and `last_synced: today`.

## Phase 8: Docs Update
- Update `docs/ARCHITECTURE.md` if any architectural change was made.
- Update `docs/DECISIONS.md` with any significant design decisions.
- Update `docs/CHANGELOG.md` with what was added.

## Phase 9: Quality Gate
- pnpm typecheck → must pass.
- pnpm lint → must pass.
- pnpm test:unit → must pass.
- pnpm build → must pass (no errors, no warnings).

Only report done when ALL gates pass.
