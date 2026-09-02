# Stack Rules: Cloudflare Workers — Headless API
> Loaded when: stack.frontend=none AND stack.backend=cloudflare-workers
> Use for pure API services, background processors, or headless backends.

## Project Structure

```
workers/
  api/                    ← Main Hono API worker
    src/
      routes/             ← Route handlers
      middleware/         ← Auth, logging, CORS, rate-limit
      lib/                ← Utilities
    wrangler.toml
  queue-processor/        ← Queue consumer worker
  scheduled/              ← Cron trigger worker

packages/
  shared/                 ← Types + schemas (Zod)
  db/                     ← Drizzle schema + migrations
```

## Hono Rules

- **Hono for all routing.** No vanilla fetch handler for complex APIs.
- **Zod validator middleware on all routes** — use `@hono/zod-validator`.
- **Typed env bindings via `Env` interface** passed to Hono's `Context`.
- **Route files grouped by resource.** One file per resource type.

```typescript
// ✅ Correct — typed Hono with Zod validation
const app = new Hono<{ Bindings: Env }>()

app.post('/users',
  zValidator('json', CreateUserSchema),
  async (c) => {
    const data = c.req.valid('json')
    const user = await createUser(c.env.DB, data)
    return c.json({ data: user }, 201)
  }
)
```

## Cloudflare Workers Rules
(Same as tanstack-cloudflare.md Worker rules — stateless, use bindings, 30s CPU limit, batch D1 queries, idempotent queue consumers.)

## OpenAPI — Required for Headless APIs

- Generate OpenAPI spec from Hono routes using `@hono/zod-openapi`.
- Serve spec at `/doc` (JSON) and `/ui` (Swagger UI) in non-production.
- Every route must have `.openapi()` descriptor with request + response schemas.

## Security — No Frontend = Stricter API Discipline

- All origins must be explicitly allowlisted in CORS config.
- No wildcard `*` in CORS for authenticated endpoints.
- API keys (for service-to-service) rotated quarterly, stored in Worker secrets.
- Every endpoint has an explicit auth requirement — no "open by default".
