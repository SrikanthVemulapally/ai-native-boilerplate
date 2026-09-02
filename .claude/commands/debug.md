---
name: debug
description: Systematic debugging — reproduce, isolate, fix, verify, prevent
user-invocable: true
---

Debug: $ARGUMENTS

## Debugging Workflow

### Phase 1: Reproduce
- Can you reproduce the bug reliably? What steps trigger it?
- What is the exact error message, stack trace, or wrong behavior?
- What was the last thing that changed before the bug appeared? (`git log --oneline -10`)

### Phase 2: Isolate
- Narrow down to the smallest code that reproduces the issue.
- Check: is this a data issue, logic issue, or environment issue?
- Trace the data flow from input to output — where does it go wrong?

### Phase 3: Root Cause
Before fixing, state:
- **Exact root cause:** [one sentence, specific to the code, not "there's a bug"]
- **Why it wasn't caught:** [gap in tests, missing validation, etc.]
- **Blast radius:** [what else might be affected?]

### Phase 4: Write a Failing Test First
```
it('should [correct behavior] when [condition]', async () => {
  // Reproduce the bug
  // Assert the correct behavior
  expect.fail('Not fixed yet'); // confirm it fails
});
```

Run the test. Confirm it fails. Then fix.

### Phase 5: Fix (Surgical)
- Change ONLY what's necessary to fix the root cause.
- Do not refactor adjacent code.
- Do not add unrelated improvements.

### Phase 6: Verify
1. The failing test now passes.
2. The full test suite still passes (no regressions).
3. Manual verification in the real environment.

### Phase 7: Prevent
- Is there a pattern here that could happen elsewhere?
- Should a rule be added to `CLAUDE.md` or `docs/DECISIONS.md`?
- Should the Zod schema be tightened?
