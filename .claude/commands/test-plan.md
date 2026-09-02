---
name: test-plan
description: Generate a comprehensive test strategy for a feature or the whole project
user-invocable: true
---

Test plan: $ARGUMENTS

## What This Produces

A structured test plan document saved to `.mdd/docs/<feature>-test-plan.md` that defines:
- What to test (behaviors, not functions)
- How to test each (unit, component, integration, E2E)
- What NOT to test (generated code, trivial getters, third-party libs)
- Edge cases and error scenarios
- Coverage targets
- Eval requirements (if AI features)

## Workflow

### Step 1: Read the Spec
Read `docs/SPEC.md` and `.mdd/docs/<feature>.md` to understand:
- What behaviors are required?
- What are the acceptance criteria?
- What edge cases are documented?
- What error scenarios are mentioned?

### Step 2: Read the Implementation
Read the source files for this feature:
- What functions/components exist?
- What are the branches and conditions?
- What external dependencies are there?
- What database operations?
- What API endpoints?

### Step 3: Build the Test Matrix

```markdown
# Test Plan: [feature name]

## Behaviors to Test

| # | Behavior | Type | Priority | Edge Cases |
|---|----------|------|----------|------------|
| 1 | User can create account | E2E | P0 | duplicate email, weak password, invalid email |
| 2 | Password is hashed | Unit | P0 | empty, unicode, max length |
| 3 | Login returns JWT | Integration | P0 | wrong password, expired token, revoked session |
| ... | ... | ... | ... | ... |

## Test Inventory

### Unit Tests (target: 60% of tests)
- `src/services/auth.service.ts`
  - hashPassword: empty, unicode, max length, timing
  - verifyPassword: correct, incorrect, malformed hash
  - createToken: valid payload, expired, missing fields
  - ...

### Component Tests (target: 20% of tests)
- `src/components/SignupForm.tsx`
  - renders all fields
  - validates email format on blur
  - shows password strength
  - submits on valid input
  - shows error on API failure
  - ...

### Integration Tests (target: 15% of tests)
- POST /api/auth/register
  - 201 on valid input
  - 400 on invalid email
  - 400 on weak password
  - 409 on duplicate email
  - 500 on DB error (graceful)
- POST /api/auth/login
  - 200 with token on valid credentials
  - 401 on wrong password
  - 401 on non-existent email
  - 429 on rate limit exceeded
  - ...

### E2E Tests (target: 5% of tests)
- Full signup → login → dashboard flow
- Full signup → verify email → login flow
- Password reset flow end-to-end

## What NOT to Test
- Drizzle generated query builder code
- Zod runtime (tested by Zod's own suite)
- React internals (rendering, reconciliation)
- Third-party UI components (shadcn/ui)

## AI Evals (if applicable)
- Eval cases: 20+ inputs covering happy path, edge cases, adversarial
- Rubric: accuracy 40%, completeness 30%, safety 20%, format 10%
- Threshold: 80% pass rate
- Regression: score must not drop below baseline

## Coverage Targets
- Lines: 80% on changed files
- Branches: 75% on changed files
- Functions: 80% on changed files
- Critical paths: 100% (auth, payments, data integrity)

## CI Integration
- Unit + component: every commit
- Integration: every PR
- E2E: every PR (smoke) + nightly (full)
- AI evals: every PR touching AI features + weekly scheduled
```

### Step 4: Estimate Effort
```markdown
## Effort Estimate
- Unit tests: ~N tests, ~N hours
- Component tests: ~N tests, ~N hours
- Integration tests: ~N tests, ~N hours
- E2E tests: ~N tests, ~N hours
- AI evals: ~N cases, ~N hours
- Total: ~N hours
```

### Step 5: Save and Report
Save to `.mdd/docs/<feature>-test-plan.md`.
Report the matrix and ask for confirmation before generating any tests.
