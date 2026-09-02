# Database Rules (Drizzle ORM)

Loaded when working with schema, migrations, or DB queries.

## Migration Discipline
- **NEVER edit an existing migration file.** It's a permanent historical record.
- Workflow: edit `schema.ts` → `pnpm db:generate` → review the generated SQL → `pnpm db:migrate`
- Migration naming: Drizzle auto-generates. Do not rename.
- Before deploying: verify migration runs on a staging DB first.

## Schema Conventions
```typescript
// ✅ CORRECT — proper Drizzle schema
export const users = sqliteTable('users', {
  id: text('id').primaryKey().$defaultFn(() => createId()), // UUIDv7 or CUID2
  email: text('email').notNull().unique(),
  createdAt: integer('created_at', { mode: 'timestamp' })
    .notNull()
    .$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' })
    .notNull()
    .$defaultFn(() => new Date())
    .$onUpdateFn(() => new Date()),
});

// ✅ CORRECT — explicit index
export const usersByEmail = index('users_email_idx').on(users.email);
```

## Query Rules
- No raw SQL unless Drizzle cannot express it — if you must, document why with a comment.
- Every query that filters by `userId` must include that filter. No accidental data leaks.
- Paginate all list queries. No `SELECT *` without a `LIMIT`.
- Add indexes for every column used in `WHERE`, `JOIN ON`, or `ORDER BY`.

## Cloudflare D1 Specifics
- D1 is SQLite — check SQLite compatibility for any advanced SQL.
- Use `drizzle-orm/d1` adapter.
- Batch writes using D1 batch API when inserting multiple rows.
- D1 has a 10ms CPU budget per query in Workers — keep queries simple.

## Service Layer Pattern
```typescript
// ✅ CORRECT — DB access only in service layer
export async function getUserById(db: DrizzleD1, id: string) {
  return db.select().from(users).where(eq(users.id, id)).get();
}

// ❌ WRONG — DB access in route handler
app.get('/api/users/:id', async (c) => {
  const user = await c.env.DB.prepare('SELECT * FROM users WHERE id = ?')
    .bind(c.req.param('id')).first(); // NEVER
});
```
