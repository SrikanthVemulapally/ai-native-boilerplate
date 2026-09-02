# 12-Factor App Methodology

> **Non-negotiable for all deployments.** These 12 rules separate stateless, portable apps from fragile ones.

## The 12 Factors

### I. Codebase
One codebase per app. Multiple deployments (dev, staging, prod) share one codebase. If you need a different codebase, it's a different app → different repo.

### II. Dependencies
Declare ALL dependencies explicitly via `package.json` (or equivalent). Never rely on system-wide packages. `pnpm install` must produce identical environments.

### III. Config
**Config lives in environment variables, not code.** Nothing environment-specific (URLs, keys, feature flags) is hardcoded.

```typescript
// ❌ BAD
const API_URL = "https://api.myapp.com";

// ✅ GOOD
const API_URL = process.env.API_URL;  // or via app.config.ts reader
```

Use `app.config.ts` to read and validate env vars at startup:

```typescript
// src/config.ts
import { z } from 'zod';

const config = z.object({
  APP_URL: z.string().url(),
  API_URL: z.string().url(),
  DATABASE_URL: z.string(),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  SENTRY_DSN: z.string().url().optional(),
}).parse(process.env);  // throws on missing — fail fast at boot

export default config;
```

### IV. Backing Services
Treat databases, queues, email services, caching as attached resources. Swap by changing a URL in config, not by rewriting code.

### V. Build, Release, Run
Three strictly separated stages:
- **Build:** `pnpm build` → produces immutable artifacts
- **Release:** combine build + config → release ID
- **Run:** execute the release

Never build on the server. CI builds, server runs.

### VI. Processes
App runs as **stateless processes**. All state lives in backing services (DB, cache, object storage). No in-memory session stores, no local file storage for persistent data.

### VII. Port Binding
App self-contains its web server. No Apache/Nginx in front for routing (Cloudflare Workers handles this). App binds to a port and serves directly.

### VIII. Concurrency
Scale by adding processes, not threads. Workers handle different work types (web, queue processor, scheduled tasks). Each is independently scalable.

### IX. Disposability
**Fast startup and graceful shutdown.**
- Startup: < 10 seconds
- Shutdown: SIGTERM → stop accepting new requests → finish in-flight → close DB connections → exit
- Never lose data on shutdown (drain queues, flush buffers)

### X. Dev/Prod Parity
Minimize gap between dev and prod:
- Same OS (Docker/devcontainer if needed)
- Same dependencies (same versions, not "close enough")
- Same backing services (use real D1 in staging, not SQLite mock in dev)

### XI. Logs
Logs are **events streamed to stdout/stderr**, not files. Format: structured JSON. The platform (Cloudflare, Vercel) handles aggregation.

```typescript
// ✅ structured log
console.log(JSON.stringify({ level: 'info', msg: 'user.created', userId, timestamp: new Date().toISOString() }));

// ❌ never
fs.writeFileSync('app.log', 'user created');
```

### XII. Admin Processes
One-off tasks (migrations, data fixes, backfills) run as identical environments to the app. Same codebase, same dependencies.

```bash
pnpm db:migrate          # not a separate script
pnpm tsx scripts/backfill.ts  # uses same config.ts and env
```

## AI Agent Rules

1. **Never hardcode environment-specific values.** If it differs between dev/staging/prod, it's an env var.
2. **Never write logs to files.** stdout/stderr only.
3. **Never store state in memory across requests.** Workers are stateless — use KV, D1, or Durable Objects.
4. **Always validate env vars at startup.** Zod schema, fail fast. Missing `STRIPE_SECRET_KEY` = boot error, not runtime crash.
5. **Always use the same dependencies in dev and prod.** Never `if (process.env.NODE_ENV === 'development')` to swap providers.
6. **Always make one-off scripts use the app's config system.** Not a separate hardcoded connection string.

## Environment Variable Documentation

Every env var must be documented in `.env.example` with:
- Name
- Description (what it's for)
- Example value (placeholder, never real)
- Required: yes/no
- Default: if any

```bash
# .env.example
# App
APP_URL=https://myapp.com           # Production URL. Required.
API_URL=https://api.myapp.com       # API URL. Required.

# Database
DATABASE_URL=                       # D1 connection string. Required.

# Stripe (only if payments enabled)
STRIPE_SECRET_KEY=sk_test_...       # Stripe API key. Required if payments.
STRIPE_WEBHOOK_SECRET=whsec_...     # Stripe webhook signing secret. Required if payments.

# Sentry (only if error tracking enabled)
SENTRY_DSN=                         # Sentry DSN. Optional. If set, error tracking active.
```

The `env-var-doc-check.sh` hook enforces this — any `process.env.NEW_VAR` in source without a corresponding entry in `.env.example` triggers a reminder.
