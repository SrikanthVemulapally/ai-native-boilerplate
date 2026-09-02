# Stack Rules: TanStack Start + Cloudflare Workers/D1/R2/Queues
> Loaded when: stack.frontend=tanstack-start AND stack.backend=cloudflare-workers

## Project Structure

```
apps/
  web/                    ← TanStack Start app
    app/
      routes/             ← File-based routing (TanStack Router)
        __root.tsx        ← Root layout, global providers
        index.tsx         ← Home page
        _auth/            ← Auth-gated routes (prefix with _)
        _public/          ← Public routes
      components/
        ui/               ← Primitive UI components (shadcn-style)
        features/         ← Feature-specific composed components
        layouts/          ← Page layout wrappers
      lib/
        api.ts            ← API client (typed fetch wrapper)
        auth.ts           ← Auth utilities
        utils.ts          ← Shared utilities
      styles/
        globals.css       ← Global styles + Tailwind base

workers/
  api/                    ← Main API worker (Hono or vanilla)
    src/
      routes/             ← API route handlers
      middleware/         ← Auth, logging, CORS, rate-limit
      lib/                ← Worker utilities
    wrangler.toml
  queue-processor/        ← Queue consumer worker
  scheduled/              ← Cron trigger worker

packages/
  shared/                 ← Types, schemas, constants shared across apps+workers
  db/                     ← Drizzle schema + migrations + query helpers

drizzle.config.ts
wrangler.toml             ← Root wrangler config
```

## TanStack Start Rules

- **File-based routing only.** No programmatic route creation.
- **Server functions (`createServerFn`) over REST for internal calls.** REST only for external consumers.
- **Data loading in route loaders, not components.** Components receive data; they do not fetch it.
- **Error boundaries at every route.** No unhandled promise rejections in UI.
- **Suspense boundaries for async UI.** No spinners in useEffect.

```typescript
// ✅ Correct — loader fetches, component renders
export const Route = createFileRoute('/dashboard')({
  loader: async () => getDashboardData(),
  component: Dashboard,
  errorComponent: DashboardError,
  pendingComponent: DashboardSkeleton,
})

// ❌ Wrong — component fetching its own data
export function Dashboard() {
  const [data, setData] = useState(null)
  useEffect(() => { fetch('/api/dashboard').then(...) }, [])
}
```

## Cloudflare Workers Rules

- **Every worker is stateless.** No in-memory state between requests.
- **Use bindings, not env vars, for platform resources.** D1, R2, KV, Queues via `c.env.BINDING_NAME`.
- **Wrangler types generated and committed.** `wrangler types` after every binding change.
- **Request timeout is 30s CPU time.** Offload to Queues for anything longer.
- **Never do N+1 queries.** D1 has per-request query limits. Batch everything.

```typescript
// ✅ Correct — use binding
const result = await c.env.DB.prepare('SELECT * FROM users WHERE id = ?').bind(id).first()

// ❌ Wrong — raw fetch to own API
const result = await fetch('https://api.myapp.com/users/' + id)
```

## Drizzle ORM Rules

- **Schema first, always.** Define in `packages/db/schema.ts`, generate migration, then implement.
- **Never modify migrations after they run.** Add new migrations instead.
- **Use UUIDv7 for all primary keys.** Ordered, sortable, index-friendly.
- **Soft deletes with `deleted_at`.** No hard deletes for user data.
- **All timestamps in UTC.** `integer('created_at', { mode: 'timestamp' }).$defaultFn(() => new Date())`

```typescript
// ✅ Correct schema pattern
export const users = sqliteTable('users', {
  id:         text('id').primaryKey().$defaultFn(() => uuidv7()),
  email:      text('email').notNull().unique(),
  created_at: integer('created_at', { mode: 'timestamp' }).$defaultFn(() => new Date()),
  updated_at: integer('updated_at', { mode: 'timestamp' }).$onUpdateFn(() => new Date()),
  deleted_at: integer('deleted_at', { mode: 'timestamp' }),
})
```

## Cloudflare R2 Rules

- **Never serve R2 directly from Workers for large files.** Use presigned URLs.
- **All file keys are UUIDs.** Never expose original filenames in keys.
- **Set appropriate Cache-Control on public assets.**
- **R2 bucket per environment.** `my-app-prod`, `my-app-staging`, `my-app-dev`.

## Cloudflare Queues Rules

- **All background work goes through Queues.** No fire-and-forget in request handlers.
- **Idempotent consumers only.** Every message MUST be safe to process twice.
- **Dead letter handling is mandatory.** Wire a DLQ binding for every queue.
- **Batch processing.** Always use `waitUntil` or batch handlers, not per-message awaits.

## TypeScript Rules

- **Strict mode always.** `"strict": true` in tsconfig. No exceptions.
- **No `any`.** Use `unknown` and narrow. If you must — add a comment explaining why.
- **Zod for all runtime validation.** Every API input, every env var, every config.
- **Export types from packages/shared.** Never duplicate type definitions.

## Performance Rules

- **Lazy load routes.** TanStack Router handles this — don't bypass it.
- **Image optimization mandatory.** `<img>` with width/height. Use Cloudflare Images if needed.
- **No layout shift (CLS = 0).** Skeleton loaders for all async content.
- **Bundle size budget: 150KB gzipped per route chunk.** Enforce in CI.
