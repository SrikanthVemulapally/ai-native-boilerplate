# Feature Rules: Authentication & Authorization
> Loaded when: features.auth=true

## Architecture: JWT + Refresh Token Rotation

```
Login → access_token (15min) + refresh_token (30 days, httpOnly cookie)
Request → verify access_token → if expired → use refresh_token → rotate both
Logout → invalidate refresh_token in DB
```

## Required Files

```
workers/api/src/
  routes/auth/
    login.ts          ← Email/password + magic link
    logout.ts
    refresh.ts        ← Token rotation
    me.ts             ← Current user
  middleware/
    auth.ts           ← JWT verification middleware
  lib/
    jwt.ts            ← Token generation + verification
    password.ts       ← Argon2 hashing

packages/db/schema/
  users.ts
  sessions.ts         ← Refresh token store (invalidation)

apps/web/app/lib/
  auth.ts             ← Client-side auth state
```

## Rules

- **Passwords hashed with Argon2id.** Never bcrypt (weaker), never MD5 (criminal).
- **Access tokens: 15 minutes.** Refresh tokens: 30 days.
- **Refresh tokens stored in DB.** Allows invalidation (logout everywhere).
- **httpOnly + Secure + SameSite=Strict cookies for refresh tokens.**
- **RBAC enforced at middleware layer.** Not in components, not in route loaders.
- **Never return password hash in any API response.** Ever.
- **Rate limit login attempts.** 5 attempts per 15 minutes per IP.
- **Email verification before full access.** Magic link or verification code.

## RBAC Pattern

```typescript
// middleware/auth.ts
export async function requireRole(c: Context, next: Next, roles: Role[]) {
  const user = c.get('user')
  if (!user || !roles.includes(user.role)) {
    return c.json({ error: 'Forbidden' }, 403)
  }
  await next()
}

// Usage in routes
app.get('/admin/users', authMiddleware, (c, next) => requireRole(c, next, ['admin', 'superadmin']), handler)
```

## Session Schema

```typescript
export const sessions = sqliteTable('sessions', {
  id:            text('id').primaryKey().$defaultFn(() => uuidv7()),
  user_id:       text('user_id').notNull().references(() => users.id),
  refresh_token: text('refresh_token').notNull().unique(), // hashed
  user_agent:    text('user_agent'),
  ip_address:    text('ip_address'),
  expires_at:    integer('expires_at', { mode: 'timestamp' }).notNull(),
  created_at:    integer('created_at', { mode: 'timestamp' }).$defaultFn(() => new Date()),
})
```
