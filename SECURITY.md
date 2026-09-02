# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | ✅ Yes             |

## Reporting a Vulnerability

**Please do NOT open a public GitHub issue for security vulnerabilities.**

Report security issues privately:

1. **GitHub Private Advisory:** [Report a vulnerability](https://github.com/SrikanthVemulapally/ai-native-boilerplate/security/advisories/new)
2. **Email:** security@yourdomain.com

### What to include
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (optional)

### Response timeline
- **Acknowledgement:** within 48 hours
- **Status update:** within 7 days
- **Fix timeline:** within 30 days for critical issues

### Scope
This is a boilerplate/template repository. Security issues in the hook scripts, CI workflows, or generated configuration files are in scope. Issues in your own project built from this boilerplate are out of scope.

## Security Best Practices in This Boilerplate

This boilerplate enforces:
- Secret scanning (TruffleHog in CI)
- Dependency auditing (`pnpm audit` in CI)
- Security headers (CSP, HSTS, X-Frame-Options)
- Data classification (T1–T4 tiers)
- OWASP Top 10 rules
- Never-commit-secrets hooks

See `.claude/rules/security.md` and `.claude/rules/core/security-headers.md` for details.
