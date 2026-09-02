# Compliance Core — Framework Selection & Shared Controls

## Framework Selector

Set `compliance` flags in `boilerplate.config.json`. Claude loads only the frameworks your project needs.

```json
{
  "compliance": {
    "gdpr": true,          // EU/UK users or Indian users (DPDPA)
    "hipaa": false,        // Healthcare / PHI data
    "soc2": false,         // B2B SaaS selling to US enterprises
    "pci": true,           // Payments (always true if Stripe enabled)
    "eu_ai_act": false,    // AI features deployed to EU users
    "dpdpa": true,         // Indian users (often combined with gdpr)
    "ccpa": false          // California users (subset of GDPR controls)
  }
}
```

**Minimum for any project:** data-classification.md is always loaded.
**Stripe enabled:** PCI rules always loaded — no exceptions.
**EU users:** GDPR always loaded.
**Indian users:** DPDPA always loaded (can coexist with GDPR — shared controls apply).
**AI features + EU deployment:** EU AI Act loaded.

---

## Shared Controls (Apply to ALL Frameworks)

These 9 controls are required regardless of which frameworks are active.

### 1. Access Control
- RBAC with principle of least privilege — no role grants more than needed
- MFA on all production systems, admin consoles, CI/CD, cloud consoles
- Service accounts use short-lived tokens, not long-lived API keys
- Access reviews: quarterly audit of who has access to what
- Offboarding: revoke all access within 24 hours of departure
- Audit log: all privileged actions logged with user + timestamp + action

### 2. Encryption
- TLS 1.2+ for all data in transit — TLS 1.0/1.1 disabled
- AES-256 for all T4 data at rest
- Never hardcode encryption keys — use environment variables or KMS
- Backups encrypted and geographically separated
- Test backup restoration quarterly

### 3. Vulnerability Management
- Dependency scanning on every PR (`npm audit`, Snyk, or Dependabot)
- Critical CVEs patched within 72 hours
- High CVEs patched within 14 days
- Annual penetration test (bi-annual for enterprise)
- SBOM (Software Bill of Materials) maintained for all dependencies

### 4. Incident Response
- Written Incident Response Plan (IRP) in `docs/RUNBOOK.md`
- Breach notification timelines:
  - GDPR: 72 hours to supervisory authority
  - HIPAA: 60 days to HHS (breach > 500 individuals)
  - DPDPA: 72 hours to Data Protection Board of India
  - CCPA: "expedient" — no hard deadline but document immediately
- Incident log maintained for all events, minor and major
- Annual tabletop exercise with team

### 5. Vendor Risk
- Formal vendor inventory: all third parties with data access
- Data Processing Agreements (DPAs) with all vendors handling T3/T4 data
- Annual review of vendor compliance certifications
- No vendor with access to PHI without BAA (HIPAA)
- Vendor SOC 2 / ISO 27001 reports collected and reviewed

### 6. Logging & Audit Trail
- All authentication events logged (login, logout, failed attempts, MFA)
- All T4 data access logged (who, what, when, why)
- All admin actions logged
- Log retention: minimum 12 months (90 days immediately accessible)
- Logs stored in tamper-evident, append-only storage
- No PII/PHI in logs — scrub before writing

### 7. Data Minimization
- Collect only what the feature explicitly requires
- No "nice to have" fields — every field needs a business justification
- Default to not collecting rather than collecting and not using
- Review collected data annually — delete what's no longer needed

### 8. Security Awareness
- Security training for all team members at onboarding
- Developer secure coding training annually
- Phishing simulation quarterly (for teams > 5)
- Acceptable Use Policy documented and signed

### 9. Change Management
- No direct commits to main (enforced by git hooks)
- All changes reviewed before merge
- Schema migrations reviewed for data impact before running
- Compliance-impacting changes flagged in PR description

---

## Compliance Documentation (Required Files)

The following must exist in `docs/` for any project with compliance obligations:

| File | Purpose | When Required |
|------|---------|---------------|
| `docs/ARCHITECTURE.md` > Data Map | All data fields classified | Always |
| `docs/PRIVACY.md` | Privacy policy template | GDPR / DPDPA / CCPA |
| `docs/DATA_PROCESSING.md` | Processing activities record | GDPR Article 30 |
| `docs/RUNBOOK.md` | Incident response plan | Always |
| `docs/VENDOR_INVENTORY.md` | Third-party vendor list with DPA status | Always |
| `docs/DECISIONS.md` | Security and compliance decisions | Always |

---

## Compliance Readiness Levels

Track your compliance maturity:

| Level | Description | Signals |
|-------|-------------|---------|
| **L0: Unaware** | No compliance controls | No data classification, PII in logs, no audit trail |
| **L1: Aware** | Basic controls | Data classified, encryption in place, access controlled |
| **L2: Documented** | Controls documented + tested | Data map complete, IRP written, vendor inventory done |
| **L3: Audit-Ready** | Evidence collectable | Logs retained 12mo, controls automated, annual review |
| **L4: Certified** | Third-party verified | SOC 2 Type II, ISO 27001, or HIPAA audit passed |

**Target for any production SaaS: L3 before first enterprise customer.**

---

## Compliance Anti-Patterns (Never Do These)

❌ Storing raw card numbers (even temporarily)
❌ PII in error messages or logs
❌ PII in URL query strings (`?email=user@example.com`)
❌ Sending T4 data to third parties without DPA
❌ Sharing prod data with dev/staging environments
❌ Keeping data "just in case" with no retention policy
❌ Manual compliance tracking in spreadsheets (automate it)
❌ Compliance as a one-time project (it's continuous)
❌ Treating CCPA as "covered by GDPR" — they have different rights
❌ AI prompts containing user PII without explicit consent
