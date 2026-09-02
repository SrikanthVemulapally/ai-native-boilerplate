# Data Classification & Sensitivity

Every field in the database, every API response, every log line — must be classified.
This is the foundation of all compliance. You cannot protect what you haven't identified.

---

## The 4-Tier Classification System

| Tier | Label | Definition | Examples |
|------|-------|------------|---------|
| T1 | **PUBLIC** | Safe to expose publicly. No harm if leaked. | Product names, public prices, marketing copy, docs |
| T2 | **INTERNAL** | For authenticated users only. Low-harm if leaked. | Usage stats, feature flags, non-personal analytics, audit logs |
| T3 | **CONFIDENTIAL** | Personal data. Regulated. Medium-harm if leaked. | Email, name, phone, IP address, usage patterns, preferences |
| T4 | **RESTRICTED** | Sensitive personal/financial/health data. High-harm if leaked. | Passwords (hashed), payment tokens, SSN, DOB, PHI, biometrics, government IDs |

---

## Classification Rules for AI Agents

### Before Writing Any Schema

1. **Classify every column before creating it.** Add a comment: `-- T3: CONFIDENTIAL — user email`
2. **Never create a T4 column without explicit spec justification.**
3. **T4 fields must be encrypted at rest** — no exceptions.
4. **T3 fields must be masked in logs** — no exceptions.
5. **T1/T2 fields may appear in logs, analytics, error tracking** — T3/T4 never.

### The Data Map (docs/ARCHITECTURE.md)

Every project MUST maintain a Data Map section in ARCHITECTURE.md:

```markdown
## Data Map

| Table | Column | Classification | Encrypted | Notes |
|-------|--------|----------------|-----------|-------|
| users | id | T2: INTERNAL | No | UUIDv7 |
| users | email | T3: CONFIDENTIAL | No | Indexed, hashed for search |
| users | password_hash | T4: RESTRICTED | bcrypt | Never returned in API |
| users | stripe_customer_id | T4: RESTRICTED | No | Tokenized by Stripe |
| sessions | token | T4: RESTRICTED | Yes | AES-256 at rest |
| events | user_id | T2: INTERNAL | No | FK only, no PII |
| events | ip_address | T3: CONFIDENTIAL | No | Truncated to /24 for analytics |
```

**Update the Data Map before every migration.** The stop-quality-gate hook enforces this.

---

## PII / PHI / PCI Definitions

### PII — Personally Identifiable Information (T3/T4)
Directly identifies a person or can be combined to identify them.

**Direct PII (T4):** Full name + one other identifier, SSN, passport number, driver's license, biometrics, precise geolocation
**Indirect PII (T3):** Email, phone, IP address, device ID, cookies, behavioral profiles, username, date of birth alone

**Rules:**
- Never log direct PII
- Never include PII in error messages sent to Sentry
- Never store PII in URLs or query strings
- Mask indirect PII in logs: `user@example.com` → `u***@example.com`
- Delete PII on user deletion (right to erasure)

### PHI — Protected Health Information (T4, HIPAA-only)
Any PII + health condition, treatment, or payment for healthcare.

**Examples:** Diagnosis codes, medication records, lab results, appointment history, mental health notes, insurance details

**Rules (if `compliance.hipaa: true`):**
- PHI must never leave the system unencrypted
- PHI access requires audit log entry with user, timestamp, purpose
- PHI must be de-identified for analytics (Safe Harbor or Expert Determination method)
- Business Associate Agreements (BAAs) required with every vendor handling PHI

### PCI — Payment Card Industry Data (T4)
Cardholder data: PAN, CVV, expiration date, cardholder name.

**Hard rule: Never store raw card data.** Always use Stripe tokens.
- PAN: Never store, never log, never transmit except via Stripe SDK
- CVV: Forbidden to store under any circumstances
- Stripe Customer ID: T4 RESTRICTED — encrypted at rest
- Stripe Payment Method ID: T4 RESTRICTED — encrypted at rest

---

## Data Handling by Classification

| Action | T1 PUBLIC | T2 INTERNAL | T3 CONFIDENTIAL | T4 RESTRICTED |
|--------|-----------|-------------|-----------------|---------------|
| API response (authed) | ✅ | ✅ | ✅ with purpose | ⚠️ never raw |
| API response (public) | ✅ | ❌ | ❌ | ❌ |
| Server logs | ✅ | ✅ | Masked only | ❌ Never |
| Error tracking (Sentry) | ✅ | ✅ | Scrubbed | ❌ Never |
| Analytics events | ✅ | ✅ | ❌ | ❌ |
| AI/LLM prompts | ✅ | ✅ | With consent only | ❌ Never |
| Backups | ✅ | ✅ | Encrypted | Encrypted + access-controlled |
| Third-party vendors | ✅ | ✅ | DPA required | DPA + BAA if PHI |

---

## Retention Policy

| Tier | Default Retention | Delete On |
|------|------------------|-----------|
| T1 PUBLIC | Indefinite | N/A |
| T2 INTERNAL | 2 years | Account closure + 90 days |
| T3 CONFIDENTIAL | 1 year active + 90 days | User deletion request + 30 days |
| T4 RESTRICTED | Minimum necessary | User deletion request + 7 days |

**Deletion must be cascading:** If user is deleted, all T3/T4 data across all tables must be deleted or anonymized within the SLA window.

---

## Annotation Convention (Code)

```typescript
// In schema files — annotate every sensitive column:
email: text('email').notNull(),          // T3:CONFIDENTIAL — mask in logs
passwordHash: text('password_hash'),     // T4:RESTRICTED — never return in API
stripeCustomerId: text('stripe_customer_id'), // T4:RESTRICTED — encrypted at rest
ipAddress: text('ip_address'),           // T3:CONFIDENTIAL — truncate for analytics

// In API handlers — annotate responses containing sensitive data:
// RETURNS: T3:CONFIDENTIAL — requires auth, strip before logging
return c.json({ email: user.email, name: user.name })

// In log statements — always use scrubbed versions:
logger.info('User login', { userId: user.id }) // ✅ T2 only
logger.info('User login', { email: user.email }) // ❌ T3 in logs
```

---

## Pre-Implementation Checklist (Data)

Before creating any feature that handles user data:

- [ ] Every new field classified (T1–T4) and added to Data Map
- [ ] T4 fields confirmed encrypted at rest
- [ ] T3/T4 fields excluded from logs and analytics
- [ ] Retention period documented
- [ ] Deletion cascade verified
- [ ] No PII in AI prompts unless explicit user consent obtained
- [ ] Third-party vendors handling T3/T4 have signed DPAs
