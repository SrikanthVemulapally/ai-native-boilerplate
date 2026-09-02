# /compliance-check

Run a compliance gap analysis against the frameworks declared in `boilerplate.config.json`.

## What This Does

1. Read `boilerplate.config.json` — identify active compliance frameworks
2. Read `docs/ARCHITECTURE.md` — check Data Map completeness
3. Read `docs/DATA_PROCESSING.md` — check processing record exists
4. Read `docs/VENDOR_INVENTORY.md` — check vendor/DPA coverage
5. Read `docs/RUNBOOK.md` — check incident response coverage
6. Scan codebase for common violations
7. Produce a prioritized gap report with P1/P2/P3 findings

## Execution Steps

### Step 1: Framework Identification
Read `boilerplate.config.json` → `compliance` section. List active frameworks.

### Step 2: Data Map Audit
- Does `docs/ARCHITECTURE.md` have a "Data Map" section?
- Are all DB tables represented?
- Is every column classified (T1–T4)?
- Are T4 columns marked as encrypted?

### Step 3: Code Scanning (Run These Checks)
```bash
# Check for PII in logs
grep -r "console.log\|logger\." src/ | grep -E "email|phone|password|ssn|dob" | grep -v "test"

# Check for hardcoded secrets
grep -r "sk_live_\|pk_live_\|whsec_" src/ | grep -v ".env"

# Check for PII in URL params
grep -r "email=\|phone=\|ssn=" src/ | grep -v "test"

# Check for missing webhook signature verification (Stripe)
grep -r "stripe.webhooks" src/ | grep -v "constructEvent"

# Check for T4 fields without encryption annotation
grep -r "T4:RESTRICTED" src/ | grep -v "encrypted"

# Check for raw PHI in logs (if HIPAA)
grep -r "diagnosis\|medication\|phi" src/ | grep "logger\|console"
```

### Step 4: Framework-Specific Checks

**If GDPR:**
- Does `/api/privacy/request` endpoint exist?
- Is there a consent management implementation?
- Is cookie consent implemented?
- Do auth flows include privacy policy acceptance?

**If PCI:**
- Is Stripe.js used for card input (not custom form fields)?
- Is webhook signature verified?
- Are Stripe keys only in env vars?
- Is raw card data absent from all schemas?

**If HIPAA:**
- Are BAAs documented in `docs/VENDOR_INVENTORY.md`?
- Is PHI access log table present?
- Is PHI encrypted at rest (check schema annotations)?
- Is session timeout configured for PHI pages?

**If SOC2:**
- Is MFA documented as required?
- Are access review records present in `docs/`?
- Is vulnerability scanning in CI pipeline?
- Is incident log maintained?

**If EU AI Act:**
- Are AI features labeled in UI?
- Is AI transparency disclosure present?
- For high-risk AI: is technical documentation written?
- Is human oversight mechanism implemented?

### Step 5: Gap Report

Output format:
```markdown
## Compliance Gap Report — [Date]

**Active Frameworks:** GDPR, PCI, SOC2

### 🔴 P1 — Critical (Fix Before Launch)
1. **[Framework] [Control]** — [What's missing] — [How to fix]

### 🟡 P2 — Important (Fix Within 30 Days)
2. **[Framework] [Control]** — [What's missing] — [How to fix]

### 🟢 P3 — Recommended (Fix Within 90 Days)
3. **[Framework] [Control]** — [What's missing] — [How to fix]

### ✅ Passing Controls
- [List of controls confirmed present]

**Overall Readiness:** L[0-4] — [Description]
**Estimated effort to L3:** [X days]
```

## When To Run
- Before first enterprise customer conversation
- Before SOC 2 audit engagement
- After significant architecture changes
- Quarterly as part of ongoing compliance program
- After adding new third-party vendor
