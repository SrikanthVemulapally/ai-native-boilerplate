# GDPR & DPDPA Compliance Rules

Load when: `compliance.gdpr: true` (EU/UK users) and/or `compliance.dpdpa: true` (Indian users).
GDPR and DPDPA share ~80% of controls. Differences are flagged inline.

---

## Legal Basis for Processing (Lawful Basis)

Before collecting any T3/T4 data, document the lawful basis:

| Basis | When To Use | Example |
|-------|------------|---------|
| **Consent** | Optional features, marketing, analytics | Email newsletter, product recommendations |
| **Contract** | Core service delivery | Account creation, billing, product usage |
| **Legitimate Interest** | Security, fraud prevention | Abuse detection, system logs |
| **Legal Obligation** | Tax, compliance | Invoice retention, audit logs |

**DPDPA difference:** DPDPA recognizes "legitimate use" as the primary basis (consent + deemed consent). Explicit consent required for sensitive personal data.

**Document in `docs/DATA_PROCESSING.md`:**
```markdown
| Data | Purpose | Lawful Basis | Retention |
|------|---------|--------------|-----------|
| Email | Account delivery | Contract | Duration + 90 days |
| IP address | Security / fraud | Legitimate Interest | 90 days |
| Marketing preferences | Newsletter | Consent | Until withdrawn |
```

---

## Consent Management

### What Requires Explicit Consent
- Marketing emails / newsletters
- Non-essential cookies and analytics
- Sharing data with third parties for their own purposes
- AI/LLM processing of personal data beyond core service
- Sensitive personal data (health, biometrics, political views)

### Consent Implementation Rules
```typescript
// Consent must be:
// ✅ Freely given (no dark patterns, no consent walls)
// ✅ Specific (separate consent per purpose)
// ✅ Informed (plain language, no legalese)
// ✅ Unambiguous (opt-in, not pre-ticked)
// ✅ Withdrawable (as easy to withdraw as to give)
// ✅ Timestamped and stored (for audit)

interface ConsentRecord {
  userId: string           // T2
  purpose: string          // e.g. 'marketing_email'
  granted: boolean
  grantedAt: Date
  withdrawnAt?: Date
  ipAddress: string        // T3 — truncated to /24
  userAgent: string        // T2
  version: string          // consent text version
}
```

### Cookie Consent (GDPR)
- Cookie banner required before non-essential cookies set
- Categories: Necessary (no consent) / Analytics (consent) / Marketing (consent)
- Respect `DNT` header where feasible
- Re-collect consent annually or on policy change
- **DPDPA:** Similar requirement — notice before collection

---

## Data Subject / Principal Rights

Must be implemented as actual API endpoints and UI flows:

| Right | GDPR | DPDPA | SLA | Implementation |
|-------|------|-------|-----|---------------|
| **Access** | Art. 15 | Sec. 11 | 30 days | Export all user data as JSON/CSV |
| **Rectification** | Art. 16 | Sec. 12 | 30 days | Allow user to edit profile data |
| **Erasure** | Art. 17 | Sec. 13 | 30 days | Delete all T3/T4 data, cascade |
| **Portability** | Art. 20 | Sec. 11 | 30 days | Machine-readable export (JSON) |
| **Restriction** | Art. 18 | — | 30 days | Freeze processing on request |
| **Object** | Art. 21 | Sec. 12 | 30 days | Opt-out of legitimate interest |

**Implementation pattern:**
```typescript
// POST /api/privacy/request
// Body: { type: 'erasure' | 'access' | 'portability' | 'rectification' }
// Returns: requestId for tracking
// Triggers: automated workflow + email confirmation
// SLA: 30 days (log start date, alert at day 25)
```

**Erasure cascade MUST include:**
- user record anonymized (not deleted — preserve accounting records)
- all T3/T4 fields set to null or anonymized placeholder
- email → `deleted-{uuid}@deleted.example`
- name → `[Deleted User]`
- Stripe: cancel subscription, do NOT delete Stripe customer (tax records)
- backups: flag for erasure on next backup rotation cycle

---

## Privacy by Design (GDPR Art. 25 / DPDPA Sec. 8)

Rules for every new feature:

1. **Default to private** — new features collect minimum data by default
2. **Purpose limitation** — data collected for one purpose cannot be reused for another without new basis
3. **Storage limitation** — define retention before collecting
4. **Integrity and confidentiality** — T4 encrypted, T3 access controlled
5. **Accountability** — document decisions in `docs/DATA_PROCESSING.md`

**Pre-feature checklist (DPIA trigger):**
Any feature that does any of the following requires a Data Protection Impact Assessment (DPIA):
- [ ] Processes special category data (health, biometrics, political)
- [ ] Involves systematic monitoring of individuals
- [ ] Processes data of children (under 13 COPPA / under 18 DPDPA)
- [ ] New AI/ML model trained on personal data
- [ ] Large-scale profiling of users

---

## Data Transfers

### GDPR (EU → non-EU)
Data leaving the EU requires a transfer mechanism:
- **Standard Contractual Clauses (SCCs)** — for transfers to US/other countries
- **Adequacy Decision** — UK, Switzerland, Japan have these
- **Binding Corporate Rules** — for intra-group transfers

**Cloudflare Workers:** Verify data residency. Use EU-only Workers deployment if required.
**Database:** Cloudflare D1 — configure nearest location, review residency.

### DPDPA (India → outside India)
- Cross-border transfer allowed unless government restricts specific countries
- Contractual safeguards (DPA) required with receiving party
- Significant Data Fiduciaries (SDF) may have additional restrictions

---

## Children's Data

- **GDPR:** Parental consent required for users under 16 (13 in some member states)
- **DPDPA:** Parental consent required for users under 18
- **COPPA (US):** Parental consent for users under 13

If your product may have minors:
- Age gate at registration (DOB or checkbox)
- Separate consent flow for minors (parental)
- Enhanced data protection for minor accounts
- No behavioral advertising to minors

---

## Breach Notification

```
GDPR:  72 hours → Supervisory Authority (if risk to individuals)
       "Without undue delay" → Affected individuals (if high risk)
DPDPA: 72 hours → Data Protection Board of India
       Notify affected individuals if Board directs
CCPA:  "Expedient time" — document immediately, notify promptly
```

**Breach response workflow:**
1. Detect → classify severity (low/medium/high/critical)
2. High/Critical: notify DPA within 72 hours
3. Document: what data, how many individuals, likely consequences, remediation
4. Post-incident: update controls, document in incident log

---

## Privacy Policy & Notice Requirements

Your privacy policy must cover (GDPR Art. 13/14, DPDPA Sec. 5):
- Who you are and contact details
- What data you collect and why
- Lawful basis for each processing activity
- Who you share data with
- How long you keep it
- Data subject rights and how to exercise them
- Right to lodge complaint with supervisory authority
- Whether automated decision-making / profiling occurs

**Template location:** `docs/PRIVACY.md` — fill before launch. This is a legal document; have a lawyer review before publishing.

---

## Implementation Checklist

- [ ] Consent management implemented for non-essential data collection
- [ ] Cookie banner live before non-essential cookies set
- [ ] Privacy rights endpoints implemented (`/api/privacy/request`)
- [ ] Data erasure cascade tested end-to-end
- [ ] Data portability export produces valid JSON
- [ ] Data Processing Record complete in `docs/DATA_PROCESSING.md`
- [ ] All vendors handling T3/T4 have signed DPAs
- [ ] SCCs in place for data transfers outside EU (GDPR)
- [ ] Age gate if product may have minor users
- [ ] Breach notification workflow documented in `docs/RUNBOOK.md`
- [ ] Privacy Policy reviewed by legal before launch
