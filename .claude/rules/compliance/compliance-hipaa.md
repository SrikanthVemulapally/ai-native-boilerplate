# HIPAA Compliance Rules

Load when: `compliance.hipaa: true` — any product handling Protected Health Information (PHI).

---

## PHI Definition (Know This Before Writing Any Schema)

PHI = any health information that can identify an individual. The 18 HIPAA identifiers:

1. Names
2. Geographic data (smaller than state)
3. Dates (except year) — DOB, admission, discharge, death
4. Phone numbers
5. Fax numbers
6. Email addresses
7. Social security numbers
8. Medical record numbers
9. Health plan beneficiary numbers
10. Account numbers
11. Certificate/license numbers
12. Vehicle identifiers/serial numbers
13. Device identifiers/serial numbers
14. Web URLs
15. IP addresses
16. Biometric identifiers (fingerprints, voiceprints)
17. Full-face photographs
18. Any other unique identifier

**If your data contains health info + ANY of the above = PHI = HIPAA applies.**

---

## The 3 HIPAA Rules

### 1. Privacy Rule
- Patients (individuals) control their health information
- Covered entities (you) can only use/disclose PHI for treatment, payment, healthcare operations
- Minimum necessary standard: only access/share minimum PHI needed
- Individual rights: access, amendment, accounting of disclosures

### 2. Security Rule (Technical Safeguards — Most Relevant to Dev)

**Access Controls:**
```typescript
// Unique user identification — no shared logins
// Emergency access procedure documented
// Automatic logoff: sessions expire after inactivity
// Encryption/decryption: PHI encrypted at rest and in transit

// PHI access MUST be logged:
interface PHIAccessLog {
  userId: string         // Who accessed
  patientId: string      // Whose PHI (anonymized in logs)
  action: 'read' | 'write' | 'delete' | 'export'
  purpose: string        // 'treatment' | 'payment' | 'operations'
  timestamp: Date
  resourceType: string   // 'medical_record' | 'lab_result' etc.
  resourceId: string
}
```

**Audit Controls:**
- Log all PHI access, modification, and deletion
- Logs must be retained for 6 years minimum
- Logs must be tamper-evident (append-only)

**Integrity Controls:**
- PHI must not be improperly altered or destroyed
- Integrity verification on PHI at rest (checksums)

**Transmission Security:**
- TLS 1.2+ for all PHI in transit
- Never transmit PHI via email without encryption
- Never transmit PHI in URL parameters

### 3. Breach Notification Rule
- Notify HHS within 60 days of breach discovery
- Notify affected individuals "without unreasonable delay" (< 60 days)
- Breach > 500 individuals: notify prominent media outlets in affected state
- Log all breaches even if below notification threshold

---

## Business Associate Agreements (BAAs)

**MANDATORY before any vendor touches PHI:**

You are a Covered Entity (or Business Associate). Every vendor that handles PHI on your behalf must sign a BAA.

| Vendor | BAA Available | Notes |
|--------|--------------|-------|
| Cloudflare | Yes | Enterprise plan required |
| AWS | Yes | Standard |
| Google Cloud | Yes | Standard |
| Stripe | Yes | For payment data tied to health services |
| Sentry | Yes | Configure to scrub PHI before sending |
| SendGrid / Resend | Yes | For health-related email |
| Analytics providers | Verify | Most don't offer BAAs — avoid for PHI |

**If a vendor won't sign a BAA: You cannot use them for PHI processing.**

---

## Technical Implementation Rules

### Database Schema for PHI
```typescript
// PHI fields must be clearly annotated
export const medicalRecords = pgTable('medical_records', {
  id: text('id').primaryKey(),
  patientId: text('patient_id').notNull(),  // T4:RESTRICTED:PHI
  providerId: text('provider_id').notNull(), // T2:INTERNAL
  // PHI fields — ALL T4:RESTRICTED:PHI
  diagnosis: text('diagnosis'),             // T4:RESTRICTED:PHI — encrypted
  medications: jsonb('medications'),        // T4:RESTRICTED:PHI — encrypted
  notes: text('notes'),                     // T4:RESTRICTED:PHI — encrypted
  // Dates — T4 when combined with health info
  visitDate: date('visit_date'),            // T4:RESTRICTED:PHI
  // Audit fields
  createdAt: timestamp('created_at').notNull(),
  createdBy: text('created_by').notNull(),  // Required for audit
  updatedAt: timestamp('updated_at').notNull(),
  updatedBy: text('updated_by').notNull(),  // Required for audit
})

// PHI access log — separate table, append-only
export const phiAccessLog = pgTable('phi_access_log', {
  id: text('id').primaryKey(),
  userId: text('user_id').notNull(),
  patientId: text('patient_id').notNull(),
  action: text('action').notNull(),
  purpose: text('purpose').notNull(),
  resourceType: text('resource_type').notNull(),
  resourceId: text('resource_id').notNull(),
  timestamp: timestamp('timestamp').defaultNow().notNull(),
  // This table is INSERT-ONLY — no UPDATE, no DELETE ever
})
```

### De-identification for Analytics
PHI must be de-identified before use in analytics or AI training.

Two methods (HIPAA Safe Harbor):
1. **Safe Harbor:** Remove all 18 identifiers. Dates → year only. Geographic data → state only.
2. **Expert Determination:** Statistical analysis confirms re-identification risk < 0.09%.

```typescript
// Safe Harbor de-identification
function deidentify(phi: MedicalRecord): SafeHarborRecord {
  return {
    // Remove all 18 identifiers
    // Keep only: year, state, general health info
    visitYear: phi.visitDate.getFullYear(),
    state: phi.address.state,
    diagnosisCategory: mapToGeneralCategory(phi.diagnosis),
    // No name, no DOB, no ID, no location < state level
  }
}
```

---

## HIPAA Implementation Checklist

- [ ] BAAs signed with ALL vendors handling PHI
- [ ] PHI fields encrypted at rest (AES-256)
- [ ] PHI access log implemented (append-only, 6-year retention)
- [ ] Automatic session timeout for PHI access (configurable, default 15 min)
- [ ] MFA required for PHI access
- [ ] Minimum necessary access enforced (RBAC per PHI type)
- [ ] PHI never in logs, error messages, or Sentry
- [ ] PHI never in URL parameters
- [ ] PHI never in analytics events
- [ ] De-identification applied before analytics/AI use
- [ ] Breach notification workflow in `docs/RUNBOOK.md`
- [ ] Annual HIPAA risk assessment documented
- [ ] Security awareness training completed by all team members
- [ ] Business Continuity Plan covers PHI systems
- [ ] Backup encryption and retention (6 years minimum for PHI)
