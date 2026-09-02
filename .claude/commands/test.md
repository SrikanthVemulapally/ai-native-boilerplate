---
name: test
description: Generate or run tests for a file, feature, or module
user-invocable: true
---

Test: $ARGUMENTS

## Mode Detection

- **No argument** → run the full test suite (`pnpm test`)
- **File path** → generate tests for that file (e.g., `/test src/services/user-service.ts`)
- **Feature name** → generate tests for that feature (e.g., `/test user-auth`)

## When Generating Tests

### Step 1: Read the Target
Read the file or feature files to understand behavior.

### Step 2: Read the Spec
Read `docs/SPEC.md` and `.mdd/docs/<feature>.md` for documented requirements and edge cases.

### Step 3: Read Existing Patterns
Find an existing test file in the same directory and match its style, imports, and structure.

### Step 4: Generate Tests Following the Pyramid

**Unit tests** (co-located, `*.test.ts`):
- Every exported function gets a `describe` block
- Test: happy path, edge cases, error cases, boundary values
- Arrange-Act-Assert structure
- 3+ assertions per test (one assertion proves nothing)
- Test names: `it('does X when Y', ...)`

**Component tests** (co-located, `*.test.tsx`):
- Test what the user sees and does, not internal state
- Use `userEvent` over `fireEvent`
- Query by role/label, not test ID
- Test: rendering, user interaction, conditional rendering, error states
- No snapshot tests (brittle, low value)

**Integration tests** (co-located or `__tests__/`):
- Real database (Miniflare D1 local), not mocked
- Full request→handler→DB→response cycle
- Test: success, validation error, auth failure, not-found, conflict
- Isolated data per test suite (beforeAll/afterAll cleanup)

### Step 5: Red Gate (MANDATORY)
Run the generated tests. They MUST fail (the feature isn't implemented yet, or existing tests should pass).
- If tests pass immediately → they're not testing real behavior. Rework them.
- If tests error → fix the test setup, not the test logic.
- Confirm: "Red Gate passed — N tests fail as expected."

### Step 6: Report
```
## Tests Generated: [file/feature]
- Unit: N tests across N files
- Component: N tests across N files
- Integration: N tests across N files
- Coverage: ~N% of exported functions covered
- Red Gate: ✅ All tests fail as expected
Files:
  - src/services/user-service.test.ts (12 tests)
  - src/components/UserCard.test.tsx (5 tests)
```

## When Running Tests

### Full Suite
```bash
pnpm test
```
Report: pass/fail counts, any failures with file + test name + error.

### Changed Files Only
```bash
pnpm test -- --changed=origin/main
```

### With Coverage
```bash
pnpm test -- --coverage
```
Report: line/branch/function coverage for changed files, any files below 80%.

### Watch Mode
```bash
pnpm test -- --watch
```
