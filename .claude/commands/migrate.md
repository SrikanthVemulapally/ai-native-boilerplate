---
name: migrate
description: Safely manage database schema migrations — generate, review, apply, verify, rollback
user-invocable: true
---

Run database migration workflow: $ARGUMENTS

> ⚠️ Migrations are IRREVERSIBLE in production. Follow this workflow exactly. Never skip steps.

## Phase 1: Understand What Changed

Before generating anything, understand the schema change:

```bash
git diff packages/db/schema/
```

List every table, column, or index that changed. State it explicitly:
- Tables added: [list]
- Columns added: [list with type and nullability]
- Columns dropped: [list — DANGEROUS, data loss]
- Indexes added/dropped: [list]
- Constraints changed: [list]

**If any column is being DROPPED or RENAMED:** STOP. Ask the user to confirm.
Column drops = permanent data loss. Column renames = must use a multi-step migration.

## Phase 2: Generate

```bash
pnpm db:generate
```

This generates a SQL migration file in `drizzle/migrations/`.

**Review the generated file immediately:**

```bash
# Show the most recent migration
ls -t drizzle/migrations/*.sql | head -1 | xargs cat
```

Check that:
- [ ] The SQL matches what you described in Phase 1
- [ ] No unexpected table drops or alterations
- [ ] Data types are correct (especially dates — D1 uses INTEGER for timestamps)
- [ ] Nullable columns have a DEFAULT or are truly optional in existing rows

If anything looks wrong: **delete the migration file** and fix the schema first.

## Phase 3: Apply (Development)

```bash
pnpm db:migrate
```

Then immediately verify:

```bash
pnpm db:studio  # or: sqlite3 .wrangler/state/v3/d1/[db-name]/*.sqlite ".schema"
```

Confirm the schema in the DB matches what you generated.

## Phase 4: Typecheck

```bash
pnpm typecheck
```

If it fails: fix type errors before proceeding. A migration that breaks TypeScript is incomplete.

## Phase 5: Test

```bash
pnpm test:unit
pnpm test:integration
```

All tests must pass. If a test fails because of the schema change — fix the code, not the test.

## Phase 6: Commit (Migration + Schema Change Together)

```bash
git add packages/db/schema/ drizzle/migrations/
git commit -m "feat(db): [describe schema change]

Migration: [migration filename]
Change: [what changed and why]
Impact: [what features are affected]"
```

**CRITICAL:** Schema file + migration file must be committed together in the same commit.
Never commit one without the other.

## Phase 7: Staging Verification

Before production:
1. Deploy to staging with migration
2. Run `pnpm db:migrate` on staging DB
3. Run smoke tests
4. Verify no errors in Sentry

## Rollback Protocol

Drizzle D1 migrations are NOT automatically reversible.

**If migration fails in staging:**
1. Identify the failing migration file
2. Write a manual reverse migration: `drizzle/migrations/XXXX_rollback_[name].sql`
3. Apply it: `wrangler d1 execute [db-name] --file=drizzle/migrations/XXXX_rollback.sql`
4. Fix the schema error
5. Regenerate

**If migration fails in production:**
1. DO NOT regenerate — the migration file is already in the DB migration history
2. Write a targeted SQL fix: `wrangler d1 execute [db-name] --remote --command="ALTER TABLE..."`
3. Log the incident in `docs/DECISIONS.md`
4. Post-mortem: how did this pass staging?

## Multi-Step Migration Pattern (for Column Renames)

Never rename a column in a single migration — it's destructive. Use this pattern:

```sql
-- Step 1: Add new column (deploy this)
ALTER TABLE users ADD COLUMN display_name TEXT;

-- Step 2: Backfill (run as a one-time script after step 1 deploys)
UPDATE users SET display_name = name WHERE display_name IS NULL;

-- Step 3: Update app code to use new column (deploy this)
-- ...code changes...

-- Step 4: Drop old column (deploy this AFTER step 3 is stable for 1 week)
ALTER TABLE users DROP COLUMN name;
```

## Safety Checklist

Before marking migration complete:
- [ ] Migration file reviewed line by line
- [ ] No unintended table drops
- [ ] No data loss for existing rows (nullable or has DEFAULT)
- [ ] TypeScript passes
- [ ] All tests pass
- [ ] Schema + migration committed together
- [ ] Applied and verified in staging before production
- [ ] Logged in `docs/DECISIONS.md` if schema change is significant
