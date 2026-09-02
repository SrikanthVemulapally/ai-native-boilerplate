---
name: security-check
description: Full security audit — auth, input validation, secrets, Stripe, CORS, injection
user-invocable: true
---

Run a security audit: $ARGUMENTS

Spawn a security-auditor subagent with fresh context to avoid bias from the implementation session.

## Audit Checklist

### Authentication & Authorization
- [ ] Every non-public API endpoint has auth middleware
- [ ] Authorization checks use server-side DB lookup, not client-supplied claims
- [ ] JWT/session validation is correct and not bypassable
- [ ] Password hashing uses bcrypt/argon2 (not MD5/SHA)
- [ ] Rate limiting on auth endpoints

### Input Validation
- [ ] All API inputs validated with Zod before processing
- [ ] No raw user input in database queries
- [ ] File upload types and sizes validated
- [ ] URL parameters validated and sanitized

### Secrets & Configuration
- [ ] No secrets hardcoded in any source file
- [ ] `.env` files in `.gitignore`
- [ ] No `console.log` of sensitive data
- [ ] API keys not exposed in client bundle

### Stripe / Payments
- [ ] Webhook signature verification (`stripe.webhooks.constructEvent`)
- [ ] Prices come from Stripe/server — never from client
- [ ] No subscription state changes without webhook confirmation
- [ ] Idempotency keys on Stripe API calls

### Cross-Site Attacks
- [ ] CORS configured correctly (not `*` in production)
- [ ] CSP headers set
- [ ] CSRF protection on state-changing routes
- [ ] XSS: no dangerouslySetInnerHTML without sanitization

### Dependencies
- [ ] Run `pnpm audit` — check for known vulnerabilities
- [ ] No obviously abandoned packages

### Data
- [ ] No PII in logs
- [ ] No PII in URLs or query params
- [ ] Data deletion works correctly for user account removal

## Output Format

```
## Security Audit Report — [date]

### Summary: [PASS / ISSUES FOUND]

### Critical Issues (Block Deploy)
- ...

### High Issues (Fix Before Release)
- ...

### Medium Issues (Fix Soon)
- ...

### Low / Suggestions
- ...

### pnpm audit output
[paste here]
```
