---
name: performance
description: Audit and fix performance — Core Web Vitals, bundle size, API latency, DB queries
user-invocable: true
---

Run performance audit: $ARGUMENTS

## Phase 1: Frontend — Core Web Vitals

### Bundle Analysis

```bash
pnpm build
pnpm build:analyze  # Opens bundle visualizer (add to package.json if missing)
```

Check:
- [ ] Total JS bundle < 150KB gzipped (initial load)
- [ ] Largest chunk < 50KB gzipped
- [ ] No unexpected large dependencies (moment.js, lodash full, etc.)
- [ ] Heavy libs lazy-loaded (charts, editor, date picker)

Flag any import that is:
- A full lodash import (`import _ from 'lodash'`) → should be `import debounce from 'lodash/debounce'`
- A large icon library fully imported → should import individual icons
- A date library > 20KB → switch to `date-fns` or `Temporal` API

### Core Web Vitals (Real User)

Run in Chrome DevTools > Lighthouse on:
- `/` (landing page) — most critical
- `/dashboard` (auth'd) — main user experience
- `/pricing` — conversion page

Targets:
| Metric | Target | Current |
|---|---|---|
| LCP | < 2.5s | [measure] |
| CLS | < 0.1 | [measure] |
| FID/INP | < 100ms | [measure] |
| TTFB | < 200ms | [measure] |

**Common fixes:**
- LCP slow → preload hero image, use SSR, optimize image format (WebP/AVIF)
- CLS → add `width` + `height` to all images, avoid late-injected content
- High TTFB → check Worker cold start, D1 query time, avoid unnecessary awaits in loaders

### Image Optimization

```bash
# Check for unoptimized images
find . -name "*.png" -o -name "*.jpg" | grep -v node_modules | xargs ls -la
```

Every image should be:
- [ ] Served as WebP or AVIF
- [ ] Has `width` and `height` attributes (prevents CLS)
- [ ] Uses `loading="lazy"` for below-fold images
- [ ] Responsive: `srcset` for different viewports

## Phase 2: API Latency

### Identify Slow Endpoints

```bash
# Check Cloudflare dashboard → Workers → Metrics for P95 latency
# Or: grep logs for slow requests
grep '"duration":' logs/ | awk -F'"duration":' '{print $2}' | sort -n | tail -20
```

For each endpoint > 200ms P95:
1. Add timing instrumentation:
```typescript
const t0 = Date.now()
const result = await db.select()...
console.log(JSON.stringify({ op: 'db_query', duration: Date.now() - t0, endpoint: c.req.path }))
```
2. Identify if slow due to: DB query, external API call, computation, or cold start

### Database Query Analysis

```bash
# Check for N+1 patterns in recent code
grep -r "for.*await.*db\." src/ --include="*.ts"
grep -r "forEach.*await.*db\." src/ --include="*.ts"
```

For each N+1 found, rewrite to use a single query with JOINs or `IN` clauses.

Check missing indexes:
```sql
-- Run this on D1 to find full table scans
EXPLAIN QUERY PLAN SELECT * FROM [table] WHERE [condition];
-- "SCAN TABLE" = no index → add an index
-- "SEARCH TABLE" = index used → ok
```

Add indexes for every column used in:
- `WHERE` clauses in API filters
- `ORDER BY` columns
- Foreign keys (D1 doesn't auto-index FKs)
- Join conditions

### Cloudflare-Specific Optimizations

```typescript
// Use KV for read-heavy, rarely-changing data (< 1KB)
// D1 for relational data
// R2 for files
// Analytics Engine for write-heavy metrics

// Cache expensive D1 queries in KV
const cached = await env.KV.get(`cache:user:${userId}`, 'json')
if (cached) return cached

const user = await db.select().from(users).where(eq(users.id, userId)).get()
await env.KV.put(`cache:user:${userId}`, JSON.stringify(user), { expirationTtl: 60 })
return user
```

## Phase 3: Tauri Agent (if applicable)

```bash
# Check binary size
cargo build --release
ls -lh target/release/[app-name]  # should be < 10MB
du -sh src-tauri/target/release/bundle/
```

- [ ] App bundle < 10MB (Tauri default is ~4MB — watch for asset bloat)
- [ ] Startup time < 500ms (measure with `time ./app`)
- [ ] Memory usage < 100MB at idle (check Activity Monitor / Task Manager)
- [ ] No synchronous IPC calls in render path (use async commands)

## Phase 4: Output Report

```
## Performance Audit — [date]

### Frontend
- LCP: [Xs] [✅ PASS / ❌ FAIL target: 2.5s]
- CLS: [X] [✅ PASS / ❌ FAIL target: 0.1]
- Bundle: [XKB] [✅ PASS / ❌ FAIL target: 150KB]
- Images: [N unoptimized images found]

### API
- P95 latency: [Xms] [✅ PASS / ❌ FAIL target: 200ms]
- Slowest endpoints: [list with times]
- N+1 queries found: [N] [list]
- Missing indexes: [list]

### Issues Found (Prioritized)
| Priority | Area | Issue | Estimated Fix Time |
|---|---|---|---|
| HIGH | Frontend | LCP 4.2s — hero image not preloaded | 30min |
| HIGH | API | N+1 on /api/posts (100 queries per request) | 2h |
| MEDIUM | Bundle | lodash fully imported (adds 70KB) | 1h |

### Recommended Actions
1. [Action 1 — do this first]
2. [Action 2]
```

Apply all HIGH priority fixes in the same session. Log MEDIUM/LOW in `docs/DECISIONS.md` as tech debt.
