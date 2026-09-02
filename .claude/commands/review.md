---
name: review
description: Deep code review against spec, architecture, security, and quality standards
user-invocable: true
---

Review $ARGUMENTS

Fork a code-reviewer subagent for this task. The reviewer operates independently with fresh context.

## Review Checklist

### 1. Spec Alignment
- [ ] Does this implementation match what's documented in `docs/SPEC.md`?
- [ ] Are there any features implemented that weren't in scope?
- [ ] Are there any required features missing?

### 2. Architecture Integrity
- [ ] Does this respect the layer boundaries in `docs/ARCHITECTURE.md`?
- [ ] No logic in the UI layer?
- [ ] No direct DB access from route handlers?
- [ ] Cross-feature dependencies documented in `.mdd/docs/`?

### 3. Security
- [ ] All user input validated with Zod (or equivalent)?
- [ ] No hardcoded secrets?
- [ ] Authentication checks on all non-public endpoints?
- [ ] No trust in client-supplied IDs for authorization?
- [ ] Stripe webhooks signature-verified?
- [ ] No PII in logs?

### 4. Code Quality
- [ ] Simplicity: could this be simpler without losing clarity?
- [ ] Dead code: any imports, variables, or functions that aren't used?
- [ ] Error handling: are all error cases handled and logged?
- [ ] Types: no `any` casts?

### 5. Testing
- [ ] Tests exist for documented behaviors?
- [ ] Tests are not modified to make code pass?
- [ ] Integration tests cover real-environment scenarios?

### 6. Performance
- [ ] Database queries have proper indexes?
- [ ] No N+1 queries?
- [ ] No blocking operations in request handlers?

### 7. Surgical Changes
- [ ] Did the implementation avoid touching unrelated code?
- [ ] Style consistent with existing code?

## Output Format

```
## Review: [feature name]
**Verdict: APPROVE / REQUEST CHANGES**

### Strengths
- ...

### Issues Found
| Severity | File | Line | Issue | Fix |
|---|---|---|---|---|
| CRITICAL | ... | ... | ... | ... |
| HIGH | ... | ... | ... | ... |
| MEDIUM | ... | ... | ... | ... |
| LOW | ... | ... | ... | ... |

### Summary
[1-2 sentences on overall quality and whether it's ready to merge]
```

**CRITICAL** = security issue, data loss risk, or spec violation → blocks merge
**HIGH** = bug or architectural violation → must fix before merge
**MEDIUM** = code quality issue → fix in same PR
**LOW** = suggestion → fix in follow-up
