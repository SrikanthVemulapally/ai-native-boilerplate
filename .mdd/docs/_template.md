---
id: NN-feature-name
title: Feature Title
depends_on: []          # List other feature doc IDs this depends on
source_files:
  - src/services/feature.ts
  - src/routes/api/v1/feature.ts
routes:
  - GET /api/v1/feature
  - POST /api/v1/feature
models:
  - feature_table
test_files:
  - src/services/feature.test.ts
  - tests/integration/feature.test.ts
last_synced: YYYY-MM-DD
status: draft           # draft | in-progress | complete | deprecated
phase: documentation    # documentation | implementation | complete
mdd_version: 1
known_issues: []
---

# Feature Title

## Purpose

[1-2 sentences. Why does this feature exist? What user problem does it solve?]

Reference: `docs/SPEC.md §X.Y` — [section name]

---

## Architecture

[How does this feature fit into the system? Which layers does it touch?]

```
[Request flow for this feature]
[Browser] → [Route] → [Middleware] → [Service] → [DB]
```

---

## Data Model

```typescript
// Table definition (matches schema.ts)
export const featureTable = sqliteTable('feature', {
  id: text('id').primaryKey(),
  // ... fields
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
```

**Fields:**
| Field | Type | Required | Description |
|---|---|---|---|
| id | string | Yes | UUIDv7 primary key |
| ... | ... | ... | ... |

---

## API Contracts

### GET /api/v1/feature

**Auth:** Required (session cookie)
**Query params:**
- `page` (number, default 1)
- `limit` (number, default 20, max 100)

**Success response (200):**
```json
{
  "data": [
    { "id": "...", "..." }
  ],
  "pagination": { "page": 1, "total": 50 }
}
```

**Error responses:**
- `401` — Unauthorized (no session)
- `400` — Invalid query params

### POST /api/v1/feature

**Auth:** Required
**Body:**
```json
{
  "field1": "string",
  "field2": 123
}
```

**Success response (201):**
```json
{ "data": { "id": "...", "..." } }
```

**Error responses:**
- `400` — Validation error (with Zod details)
- `401` — Unauthorized
- `409` — Conflict (if duplicate)

---

## Business Rules

1. [Rule 1 — what the system enforces]
2. [Rule 2]
3. [Edge case — what happens when X occurs]

---

## Data Flow

[Trace every value from input to output]

1. User submits `field1` from the form.
2. Route handler validates with `CreateFeatureSchema.parse(body)`.
3. `featureService.create(userId, input)` is called.
4. Service checks [business rule].
5. DB insert via Drizzle.
6. Returns `{ id, ...fields }`.

---

## Dependencies

[List what this feature depends on and what depends on it]

**This feature depends on:**
- Auth (session must exist)
- [other feature if applicable]

**Features that depend on this:**
- [none at time of writing]

---

## Known Issues / Edge Cases

- [Known limitation or edge case to handle]
- [None at time of writing]

---

## Test Coverage

**Unit tests** (`src/services/feature.test.ts`):
- [ ] Creates feature successfully
- [ ] Validates required fields (rejects empty input)
- [ ] Enforces [business rule]
- [ ] Returns correct data shape

**Integration tests** (`tests/integration/feature.test.ts`):
- [ ] POST returns 201 with valid input
- [ ] POST returns 401 when unauthenticated
- [ ] POST returns 400 with invalid input
- [ ] GET returns list for authenticated user

---

*This doc is the source of truth for this feature. Code must match this doc. If they diverge, update code — not this doc (unless spec changed).*
