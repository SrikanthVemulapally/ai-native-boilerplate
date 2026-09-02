# Rule: Markdown-Driven Development (MDD)
> Always loaded. Non-negotiable.

## What is MDD?

Every significant feature starts with a Markdown document — NOT code.
The document is the design. The code is the implementation. The doc comes first.

## The MDD Workflow

```
1. SPEC         → Define what you're building (SPEC.md + feature doc)
2. DESIGN       → Define how it looks (DESIGN.md + component list)
3. ARCHITECTURE → Define how it works (ARCHITECTURE.md + data flow)
4. TESTS        → Define what success looks like (test cases)
5. CODE         → Implement it
6. VERIFY       → Check against all 4 docs above
7. SYNC         → Update any docs that reality diverged from
```

**Never skip steps. Never reorder steps.**

## Feature Document Template

Before starting ANY new feature, create `.mdd/docs/<feature-name>.md`:

```markdown
# Feature: <Name>
**Status:** draft | in-progress | done | deprecated
**Spec section:** docs/SPEC.md#section-name
**Author:** <who>
**Date:** YYYY-MM-DD

## Goal
One sentence: what user problem does this solve?

## Acceptance Criteria
- [ ] Criterion 1 (testable, specific)
- [ ] Criterion 2
- [ ] Criterion 3

## Design
- UI components involved
- User flow (step by step)
- Edge cases

## Architecture
- Files that will change
- New files that will be created
- API endpoints
- Database schema changes
- External services involved

## Tests
- Happy path test cases
- Error case test cases
- Edge case test cases

## Notes
- Decisions made during implementation
- Things to revisit
```

## Enforcement

- Claude will not scaffold a feature without a `.mdd/docs/<feature>.md` file existing first.
- `/implement` command reads the feature doc before writing any code.
- Stop hook checks: if >3 files changed, was there a feature doc? If not — warn.
