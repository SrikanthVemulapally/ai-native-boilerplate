# /data-map

Generate or update the Data Map in `docs/ARCHITECTURE.md` by scanning the codebase.

## What This Does

Scans all Drizzle schema files, identifies every table and column, classifies each field based on name patterns and annotations, and produces a formatted Data Map table.

## Execution Steps

### Step 1: Find All Schema Files
```bash
find src/ -name "schema.ts" -o -name "*.schema.ts" | head -20
```

### Step 2: Parse Tables and Columns
For each schema file:
- Extract table name and all column definitions
- Read any inline T1/T2/T3/T4 annotations from comments
- Note column type (text, integer, boolean, jsonb, timestamp)

### Step 3: Auto-Classify Unclassified Columns

Use these pattern rules for auto-classification:

| Pattern | Classification | Reasoning |
|---------|---------------|-----------|
| `id`, `*_id`, `created_at`, `updated_at` | T2: INTERNAL | Non-PII structural fields |
| `email`, `phone`, `ip_address`, `username` | T3: CONFIDENTIAL | Direct PII |
| `name`, `full_name`, `first_name`, `last_name` | T3: CONFIDENTIAL | PII identifier |
| `password*`, `*_hash`, `*_token`, `*_secret` | T4: RESTRICTED | Credentials |
| `stripe_*`, `payment_*`, `card_*` | T4: RESTRICTED | Payment data |
| `ssn`, `dob`, `date_of_birth`, `passport*` | T4: RESTRICTED | Sensitive PII |
| `diagnosis`, `medication*`, `health_*`, `phi_*` | T4: RESTRICTED | PHI |
| `address`, `city`, `zip*`, `postal*` | T3: CONFIDENTIAL | Location PII |
| `plan`, `status`, `feature_flags`, `settings` | T2: INTERNAL | Non-PII config |
| `content`, `title`, `description`, `body` | T2: INTERNAL | User-generated, not PII |
| `public_*`, `slug`, `url`, `metadata` | T1: PUBLIC | Public data |

**Flag for human review:** Any column that doesn't match these patterns with `⚠️ REVIEW`.

### Step 4: Check Encryption Status
- T4 fields: check if there's an encryption annotation or a corresponding encrypted_ column
- Mark as `Encrypted: ✅` or `Encrypted: ❌ REQUIRED`

### Step 5: Generate Data Map

Output to `docs/ARCHITECTURE.md` under `## Data Map` section:

```markdown
## Data Map

_Last updated: [date] by /data-map_

| Table | Column | Type | Classification | Encrypted | Notes |
|-------|--------|------|----------------|-----------|-------|
| users | id | text | T2: INTERNAL | — | UUIDv7 primary key |
| users | email | text | T3: CONFIDENTIAL | — | Indexed; mask in logs |
| users | password_hash | text | T4: RESTRICTED | bcrypt | Never return in API |
| users | stripe_customer_id | text | T4: RESTRICTED | ❌ REQUIRED | Stripe token |
| sessions | token | text | T4: RESTRICTED | ✅ AES-256 | Rotated on use |
| events | user_id | text | T2: INTERNAL | — | FK reference only |
| events | ip_address | text | T3: CONFIDENTIAL | — | Truncate to /24 for analytics |
```

### Step 6: Flag Issues

After generating the map, report:

```markdown
### Data Map Issues Found

**🔴 Encryption Missing (Fix Now):**
- `customers.stripe_customer_id` — T4 field, not encrypted at rest

**⚠️ Classification Needs Review:**
- `orders.metadata` — jsonb field with unknown content, review manually

**✅ All T4 fields encrypted:** [list]
**✅ Total fields classified:** [N] / [N]
```

## When To Run
- After every migration that adds new tables or columns
- Before `/compliance-check`
- When onboarding to a new project (existing codebase)
- Quarterly review
