# Testing Strategy
> Always loaded. Tests are not optional. They are how you know you're done.

---

## Test Pyramid

```
        /\
       /E2E\          Few, slow, high-confidence (user flows)
      /------\
     /Integration\    Some, medium speed (API + DB + services)
    /--------------\
   /   Component    \  Many, fast (UI components in isolation)
  /------------------\
 /      Unit         \  Many, fastest (pure functions, services)
/---------------------\
```

### Proportions
- Unit: ~60% of tests. Run in < 10ms each.
- Component: ~20%. Run in < 100ms each.
- Integration: ~15%. Run in < 1s each.
- E2E: ~5%. Run in < 10s each.

---

## Tool Stack

| Test Type | Tool | Config File |
|-----------|------|-------------|
| Unit + Component + Integration | Vitest | `vitest.config.ts` |
| E2E | Playwright | `playwright.config.ts` |
| AI Evals | Custom runner (see `add-eval` command) | `evals/` directory |
| Coverage | V8 via Vitest | `vitest.config.ts` (`coverage` section) |
| Visual regression | Playwright snapshots | `playwright.config.ts` |

---

## Unit Tests

### What to Unit Test
- Pure functions (formatters, parsers, calculators)
- Service layer functions (with mocked DB — or better, D1 local)
- Schema validation (Zod schemas — every edge case)
- Utility functions
- Hooks (via `@testing-library/react` `renderHook`)

### Structure
```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { formatCurrency } from '../format-currency';

describe('formatCurrency', () => {
  describe('when amount is positive', () => {
    it('formats USD correctly', () => {
      expect(formatCurrency(1234.56, 'USD')).toBe('$1,234.56');
    });
  });

  describe('when amount is zero', () => {
    it('returns $0.00', () => {
      expect(formatCurrency(0, 'USD')).toBe('$0.00');
    });
  });

  describe('when amount is negative', () => {
    it('formats with negative sign', () => {
      expect(formatCurrency(-50, 'USD')).toBe('-$50.00');
    });
  });
});
```

### Rules
- Arrange-Act-Assert structure. Always.
- One logical assertion per test.
- Test names describe the scenario and expected outcome.
- No shared mutable state between tests. `beforeEach` for setup.
- Mock at the boundary (DB, external APIs), not at internal modules.
- Prefer real implementations for cheap dependencies (formatters, validators).

---

## Component Tests

### What to Component Test
- Components with conditional rendering (shows/hides based on props/state)
- Form components (validation, submission, error display)
- Components that emit events (onClick, onSubmit, onChange)
- Components that consume context/providers

### Structure
```typescript
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { SearchInput } from '../SearchInput';

describe('SearchInput', () => {
  it('calls onSearch when user types and presses Enter', async () => {
    const onSearch = vi.fn();
    render(<SearchInput onSearch={onSearch} />);

    await userEvent.type(screen.getByRole('textbox'), 'hello world');
    await userEvent.keyboard('{Enter}');

    expect(onSearch).toHaveBeenCalledWith('hello world');
  });

  it('does not call onSearch for empty input', async () => {
    const onSearch = vi.fn();
    render(<SearchInput onSearch={onSearch} />);

    await userEvent.keyboard('{Enter}');

    expect(onSearch).not.toHaveBeenCalled();
  });
});
```

### Rules
- Test accessibility roles (`getByRole`, `getByLabelText`), not test IDs.
- `userEvent` over `fireEvent` — simulates real user behavior.
- Test what the user sees and does, not internal state.
- No snapshot testing for components (brittle, low value). Test behavior.

---

## Integration Tests

### What to Integration Test
- API route → service → DB round trip
- Auth flow (register → login → access protected route)
- Stripe webhook → DB update → user notification
- Queue producer → queue consumer → DB update

### Setup
```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { createTestContext } from '../test-helpers';

describe('POST /api/v1/posts', () => {
  let ctx: TestContext;

  beforeAll(async () => {
    ctx = await createTestContext(); // creates isolated D1, test user, auth token
  });

  afterAll(async () => {
    await ctx.cleanup(); // drops test data
  });

  it('creates a post and returns 201', async () => {
    const res = await ctx.request
      .post('/api/v1/posts')
      .set('Authorization', `Bearer ${ctx.token}`)
      .send({ title: 'Test Post', body: 'Content' });

    expect(res.status).toBe(201);
    expect(res.body.data).toMatchObject({ title: 'Test Post' });
    expect(res.body.data.id).toBeDefined();
  });

  it('returns 401 without auth', async () => {
    const res = await ctx.request
      .post('/api/v1/posts')
      .send({ title: 'Test Post' });

    expect(res.status).toBe(401);
  });

  it('returns 400 for invalid input', async () => {
    const res = await ctx.request
      .post('/api/v1/posts')
      .set('Authorization', `Bearer ${ctx.token}`)
      .send({ title: '' }); // empty title fails validation

    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });
});
```

### Rules
- Use a real D1 local instance (Miniflare/`wrangler dev`), not a mock DB.
- Each test suite gets an isolated database or transaction rollback.
- Test the full request-response cycle, not just the service function.
- Seed test data in `beforeAll`, clean up in `afterAll`.
- Test error paths, not just happy paths.

---

## E2E Tests

### What to E2E Test
- Critical user journeys only (signup, checkout, key feature flow)
- Smoke tests for every deploy (login → dashboard → one core action)
- Cross-page flows (search → click result → take action)

### Structure
```typescript
import { test, expect } from '@playwright/test';

test.describe('User signup flow', () => {
  test('user can sign up and reach dashboard', async ({ page }) => {
    await page.goto('/signup');

    await page.fill('[name=email]', 'test@example.com');
    await page.fill('[name=password]', 'SecurePass123!');
    await page.click('button[type=submit]');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome');
  });

  test('shows error for duplicate email', async ({ page }) => {
    await page.goto('/signup');

    await page.fill('[name=email]', 'existing@example.com');
    await page.fill('[name=password]', 'SecurePass123!');
    await page.click('button[type=submit]');

    await expect(page.locator('[role=alert]')).toContainText('already exists');
  });
});
```

### Rules
- Run against a real staging environment, not localhost.
- Use test data that's cleaned up after the run.
- 10-20 E2E tests max. More = slow CI, flaky tests.
- Retry flaky tests once. If still flaky → fix the test or the code.
- Use `data-testid` only when semantic selectors aren't enough.

---

## Red Gate / Green Gate Protocol (MANDATORY)

Every feature implementation MUST pass through both gates:

### Red Gate (Before Implementation)
1. Write test skeletons for all documented behaviors
2. **RUN the tests** — they MUST fail
3. If any test passes unexpectedly:
   - The test is not testing real behavior — rework it
   - Or the feature is already implemented — verify and mark complete
4. Confirm: "Red Gate passed — N tests fail as expected"
5. **Do NOT proceed to implementation until Red Gate passes**

### Green Gate (After Implementation)
1. Implement the feature
2. **RUN the same tests** — they MUST pass now
3. If any test still fails:
   - State the root cause (don't guess — read the error)
   - Apply a targeted fix (don't rewrite the feature)
   - Rerun. Max 5 iterations.
   - If still failing after 5 iterations: STOP and report to user
4. Run the FULL test suite to check for regressions
5. Confirm: "Green Gate passed — N tests pass, 0 regressions"

### Why This Matters
- Tests that pass before implementation are worthless — they prove nothing
- Tests that fail for the wrong reason (import errors, setup issues) give false confidence
- The Red Gate catches both: only proceed when tests fail because the FEATURE doesn't exist yet

---

## AI Evals (when `features.ai` is enabled)

### Structure
```
evals/
  <feature-name>/
    cases.jsonl          # input → expected output pairs
    rubric.md            # evaluation criteria
    runner.ts            # custom runner
    results/             # last run results
```

### Case Format (JSONL)
```json
{"input": "Summarize this article: ...", "expected": "contains key points", "category": "summary"}
{"input": "Translate to French: ...", "expected": "grammatically correct French", "category": "translation"}
```

### Rubric Format
```markdown
# Eval Rubric: <feature>
## Criteria
1. **Accuracy** (40%): Does the output match the expected result?
2. **Completeness** (30%): Does it cover all required information?
3. **Safety** (20%): No harmful, biased, or inappropriate content?
4. **Format** (10%): Follows the specified output format?
## Pass threshold: 80%
```

### Eval Compliance Enforcement

- **Eval compliance gate hook** runs at Stop — blocks Claude from finishing if any AI feature (`type: ai` in `.mdd/docs/`) lacks evals
- **Minimum 20 test cases** per AI feature
- **Baseline tracking**: run `tsx evals/<feature>/runner.ts --set-baseline` to record the current score
- **Regression detection**: run `tsx evals/<feature>/runner.ts --check-regression` in CI — fails if score drops below baseline
- **Eval runner template**: copy `evals/_template/` to `evals/<feature-name>/` and implement the `yourAIFeature()` call

### Rules
- Minimum 20 test cases per AI feature.
- Run evals on every change to AI prompts, model configs, or feature logic.
- Track eval scores over time (regression detection).
- < 60% pass rate = block deploy.
- < 80% pass rate = warning, investigate before merging.
- Version eval cases alongside code (they ARE tests).
- Use LLM-as-judge for subjective criteria. Use exact match / regex for objective criteria.
- Eval cases must cover: happy path, edge cases, adversarial inputs, format compliance, safety.
- **Eval regression in CI = block merge**, same as a failing unit test.

---

## Coverage Rules

| Metric | Threshold | Scope |
|--------|-----------|-------|
| Lines | 80% | Changed files only |
| Functions | 80% | Changed files only |
| Branches | 75% | Changed files only |
| Statements | 80% | Changed files only |

- Coverage enforced in CI via Vitest's `--coverage` flag.
- Focus on meaningful coverage, not 100% number. Testing getters/setters is waste.
- Uncovered lines must have `// v8-ignore-next-line` with a reason comment.

---

## Assertion Minimums (MANDATORY)

Every test case MUST have at least **3 assertions** covering:
1. **State/URL** — where are we / what changed?
2. **Visibility** — is the right element present?
3. **Content/Data** — is the right data showing?

```typescript
// ✅ CORRECT — 3 assertions minimum
await expect(page).toHaveURL('/dashboard');                              // 1. URL
await expect(page.locator('h1')).toBeVisible();                          // 2. Visible
await expect(page.locator('[data-testid="username"]'))
  .toContainText('test@example.com');                                    // 3. Data

// ❌ WRONG — "page loads" is not a test
await page.goto('/dashboard');
// no assertions — this test proves nothing
```

For unit tests:
1. **Return value** — what did the function return?
2. **Side effects** — what did it change?
3. **Error case** — what happens when it fails?

**A test with fewer than 3 assertions is incomplete.** The `/test` command will flag these.

## Test Port Isolation

E2E tests MUST run on different ports than development servers:

| Environment | Ports |
|-------------|-------|
| Development | 3000, 3001, 3002 |
| E2E Test | 4000, 4010, 4020 |

Never run E2E tests against a dev server. Always spawn a fresh test server on test ports. This prevents test pollution and makes CI predictable.

```bash
# Kill test ports before running E2E
pnpm test:kill-ports    # kills 4000, 4010, 4020
pnpm test:e2e           # spawns fresh servers on test ports
```

## Test File Location

Tests live NEXT TO the code they test:

```
src/
  services/
    user-service.ts
    user-service.test.ts     ← right here
  components/
    UserCard.tsx
    UserCard.test.tsx         ← right here
```

No central `__tests__/` directory. No `test/` folder at root. Tests are co-located.

---

## CI Integration

```yaml
# GitHub Actions / CI config
jobs:
  test:
    steps:
      - run: pnpm test:unit --coverage --changed=origin/main
      - run: pnpm test:integration
      - run: pnpm test:e2e --project=chromium  # smoke: chromium only
      - run: pnpm eval:run  # if AI features
      - name: Coverage check
        run: pnpm test:unit --coverage --threshold 80
```

- Unit + component tests: every commit.
- Integration tests: every PR.
- E2E tests: every PR (smoke set) + nightly (full set).
- AI evals: every PR that touches AI features.
