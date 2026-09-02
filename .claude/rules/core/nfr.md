# Non-Functional Requirements (NFRs)
> Always loaded. Non-negotiable. These are not "nice to have" — they are the contract.

---

## Performance

### Budgets (enforce from day one)
| Metric | Budget | How to Measure |
|--------|--------|----------------|
| LCP (Largest Contentful Paint) | < 2.5s | Lighthouse, Core Web Vitals |
| FID/INP (Interaction) | < 200ms | Lighthouse, Core Web Vitals |
| CLS (Cumulative Layout Shift) | < 0.1 | Lighthouse, Core Web Vitals |
| JS bundle (initial) | < 150KB gzipped | `vite-bundle-visualizer` |
| API response (p50) | < 200ms | Application metrics |
| API response (p99) | < 2s | Application metrics |
| Time to interactive (TTI) | < 3.5s | Lighthouse |
| Worker CPU time | < 10ms (Cloudflare) | Worker observability |

### Rules
- Lazy-load routes and heavy components — `React.lazy()` + `Suspense`.
- Code-split every route. No single bundle > 150KB gzipped.
- Images: `WebP`/`AVIF` format, `loading="lazy"` on below-fold, explicit `width`/`height` to prevent CLS.
- Fonts: `font-display: swap`, preload critical fonts, subset to used glyphs.
- No render-blocking scripts. Async or defer everything.
- Memoize expensive computations (`useMemo`, `React.memo`) — but only when measured. No premature memoization.
- Database queries: avoid N+1. Use `Promise.all` for parallel fetches. Batch D1 writes.
- Pagination mandatory on all list endpoints. No unbounded queries.

### Monitoring
- Track Core Web Vitals in production (analytics or RUM).
- Alert on p99 API latency > 5s.
- Alert on bundle size regression > 10% from baseline.

---

## Scalability

### Architecture Rules
- **Stateless workers.** No global mutable state. All state in D1/R2/KV/Queues.
- **Idempotent operations.** Every write operation must be safe to retry. Use idempotency keys.
- **Horizontal scaling by design.** No sticky sessions. No in-memory session stores.
- **Cache aggressively, invalidate precisely.** Use KV for edge caching, `Cache-Control` headers for CDN.
- **Queue heavy work.** Never do > 100ms work in a request handler — offload to Queues.
- **Connection pooling.** D1 manages this, but never open raw connections in Workers.

### Caching Strategy
| Layer | Tool | TTL | Invalidation |
|-------|------|-----|--------------|
| Edge CDN | Cloudflare CDN | `s-maxage=3600` | Tag-based or path purge |
| KV store | Cloudflare KV | 60s–300s | Write-through on update |
| Client | TanStack Query | `staleTime: 60_000` | Refetch on focus/mutation |
| In-memory | `useMemo` / module cache | Session | Garbage collected |

### Scale Anti-Patterns (never do)
- Loading all records then filtering client-side.
- Synchronous processing of large batches in a single request.
- Polling endpoints at high frequency (> 1/min). Use websockets or SSE instead.
- Storing large blobs in D1 — use R2.

---

## Reliability & Resilience

### Error Handling Patterns
- **Retries with exponential backoff:** `delay = min(base * 2^attempt, maxDelay) + jitter`.
- **Max 3 retries** for external API calls. Log each attempt.
- **Circuit breaker:** After 5 consecutive failures, stop calling for 60s. Log state transitions.
- **Graceful degradation:** If a non-critical service fails, return partial data + warning, not a 500.
- **Dead-letter queue:** Messages that fail 3+ times go to DLQ for manual inspection.
- **Timeouts:** Every external call has a timeout. Default 10s. Never infinite await.

### Idempotency
- Every mutation API accepts an `Idempotency-Key` header.
- Server checks: have I seen this key? If yes, return the original response.
- Stripe webhooks: check `event.id` against processed events table before processing.

### Health Checks
- `GET /api/health` returns `{ status: "ok", version, timestamp }`.
- Deep health check: `GET /api/health/deep` verifies D1 connectivity, R2 access, external services.
- Worker health: Cloudflare automatically health-checks workers. No manual config needed.

---

## Observability

### Structured Logging
```typescript
// ✅ CORRECT — structured log entry
logger.info({
  event: 'user.created',
  userId: user.id,
  orgId: user.orgId,
  duration_ms: 142,
  timestamp: new Date().toISOString(),
});

// ❌ WRONG — unstructured
console.log('User created:', user.id);
```

### Log Levels
| Level | When to Use |
|-------|-------------|
| `error` | Something broke. User-facing failure. Needs alert. |
| `warn` | Something unexpected but handled. Degraded mode. |
| `info` | Significant business event (signup, payment, export). |
| `debug` | Development only. Never in production. |

### What to Log
- ✅ Event type, userId, orgId, resource ID, duration, timestamp
- ✅ Error stack traces (server-side only)
- ✅ Request ID for tracing across services
- ❌ Passwords, tokens, API keys, PII (emails in non-essential logs)
- ❌ Full request/response bodies (unless debugging with explicit opt-in)
- ❌ `process.env` or environment variables

### Metrics to Track
- Request count, latency (p50/p95/p99), error rate per endpoint
- Queue depth, processing time, DLQ count
- Worker CPU time, memory usage
- D1 query count, query latency
- Stripe webhook processing time, failure count

### Error Tracking
- All unhandled errors flow to error tracking service (Sentry, Logflare, or equivalent).
- Source maps uploaded on every deploy.
- Error grouping by: endpoint + error type + status code.
- Alert on: error rate > 1% of requests, any 5xx spike, new error type.

### Distributed Tracing
- Generate `X-Request-ID` at the edge. Propagate to all downstream calls.
- Include `X-Request-ID` in all log entries.
- Log at service boundaries: "received request from X", "sending to Y".

---

## Privacy & Compliance

### Data Handling
- **PII inventory:** Maintain a list of all PII fields in `docs/ARCHITECTURE.md` under "Data Map".
- **Encryption at rest:** D1 encrypts at rest. R2 encrypts at rest. Verify for any third-party stores.
- **Encryption in transit:** HTTPS everywhere. No HTTP endpoints. HSTS header on all responses.
- **Data minimization:** Only collect what the feature requires. No "nice to have" PII.
- **Data retention:** Define retention period per data type in `docs/SPEC.md`. Auto-delete after period.

### GDPR / Privacy Rights
- **Right to access:** Export endpoint that returns all user data in JSON.
- **Right to deletion:** Delete endpoint that cascades to all related data. Log the deletion (not the data).
- **Right to rectification:** User profile edit endpoint. Log the change (not the old value).
- **Cookie consent:** If using analytics cookies — show consent banner. Respect Do Not Track.
- **Data Processing Agreement:** If using third-party processors (Stripe, analytics) — link to their DPA in privacy policy.

### Privacy by Design
- No PII in URLs (no `?email=user@example.com`).
- No PII in client-side analytics events.
- Logs auto-scrub PII fields (email → `***@example.com`).
- Database backups encrypted. Access logged.

---

## Rate Limiting & Throttling

### Strategy
| Endpoint Type | Limit | Window | Key |
|---------------|-------|--------|-----|
| Auth (login/register) | 5 | per minute | IP + email |
| Public API | 100 | per minute | IP |
| Authenticated API | 1000 | per minute | userId |
| Webhook receivers | — | — | Validate signature, no rate limit |
| File upload | 10 | per minute | userId |

### Implementation
- Use Cloudflare KV or Durable Objects for distributed rate limiting.
- Return `429 Too Many Requests` with `Retry-After` header.
- Response headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.
- Exponential backoff on client side: respect `Retry-After` header.

### Client-Side Throttling
- Debounce search inputs (300ms).
- Throttle scroll/resize handlers (100ms via `requestAnimationFrame`).
- Disable submit button on click, re-enable on response.

---

## API Lifecycle & Versioning

### Versioning Rules
- All routes under `/api/v1/...`. Never `/api/resource` without version.
- Breaking changes = new major version (`/api/v2/...`). Old version maintained for 6 months minimum.
- Non-breaking changes (add fields, add endpoints) within same version.
- Deprecation: add `Deprecation` header + `Sunset` header to old version responses.

### Breaking Change Protocol
1. Create new version (`v2`) alongside old (`v1`).
2. Both versions active simultaneously.
3. Add `Deprecation: true` + `Sunset: <date>` headers to `v1` responses.
4. Notify all API consumers via email + changelog.
5. Monitor `v1` traffic — only deprecate when traffic < 1% of total.
6. Remove `v1` after sunset date. Return `410 Gone`.

### Schema Evolution
- Adding fields: safe. No version bump.
- Removing fields: breaking. Version bump required.
- Changing field types: breaking. Version bump required.
- Renaming fields: breaking. Version bump required.
- Use `@deprecated` JSDoc tags on deprecated fields/endpoints.

---

## Deployment & CI/CD

### Environments
| Environment | Purpose | Branch | URL Pattern |
|-------------|---------|--------|-------------|
| `local` | Development | — | `localhost:3000` |
| `preview` | PR review | `pr-*` | `pr-<n>.preview.app.com` |
| `staging` | Pre-prod testing | `staging` | `staging.app.com` |
| `production` | Live | `main` | `app.com` |

### CI Pipeline (every PR)
1. **Lint** — `pnpm lint` (ESLint, zero warnings allowed)
2. **Type check** — `pnpm typecheck` (`tsc --noEmit`)
3. **Unit tests** — `pnpm test` (Vitest, ≥80% coverage on changed files)
4. **Integration tests** — `pnpm test:integration`
5. **E2E tests** — `pnpm test:e2e` (Playwright, smoke tests on preview)
6. **Bundle size check** — fail if > 10% regression from baseline
7. **Security scan** — `pnpm audit` + dependency vulnerability check
8. **Build** — `pnpm build` (must succeed without warnings)

### Deployment Strategy
- **Cloudflare Workers:** `wrangler deploy` — atomic deploy, instant rollback via `wrangler rollback`.
- **D1 migrations:** run `pnpm db:migrate` on staging first, verify, then production.
- **Zero downtime:** Workers deploy atomically. No blue-green needed for Workers.
- **For agent apps (Tauri):** GitHub Releases with auto-update feed. Staged rollout (10% → 50% → 100%).

### Rollback
- Workers: `wrangler rollback` — instant, one command.
- D1: migrations must be reversible. Every `up` migration needs a `down` migration.
- Frontend: deploy previous git commit. CDN cache purge.
- Agent: bump update feed to previous version. Users auto-rollback on next check.

### Health Check Post-Deploy
- Hit `/api/health` immediately after deploy. Fail = auto-rollback.
- Monitor error rate for 5 minutes post-deploy. > 1% = rollback.
- Monitor p99 latency for 5 minutes. > 5s = rollback.

---

## Cost Optimization

### Cloudflare Cost Rules
- D1: minimize query count. Batch reads. Avoid `SELECT *`. Only select needed columns.
- R2: use lifecycle rules to move old objects to cheaper storage. Delete orphans.
- Workers: stay within CPU budget. Offload heavy work to Queues (cheaper per-operation).
- KV: use long TTLs for stable data. Batch reads with `kv.list()` + `kv.get()` patterns.
- Queues: batch messages with `sendBatch()` (chunks of 100). Never `send()` in a loop.

### Frontend Cost Rules
- No unnecessary dependencies. Every `pnpm add` must justify its bundle size cost.
- Tree-shake everything. Verify with bundle analyzer.
- No client-side analytics that send data on every interaction. Batch and flush.
- Self-host fonts. No Google Fonts CDN (privacy + performance).

### Monitoring Costs
- Track monthly Cloudflare bill. Alert at 80% of budget.
- Track D1 row count. Alert at 80% of plan limit.
- Track R2 storage size. Alert at 80% of plan limit.
- Review costs monthly in `docs/DECISIONS.md` if significant changes.

---

## Disaster Recovery

### Backup Strategy
| Data | Backup Method | Frequency | Retention |
|------|--------------|-----------|-----------|
| D1 database | Cloudflare automated + manual export | Daily | 30 days |
| R2 objects | Versioning enabled + cross-region replication | Continuous | 90 days |
| KV data | Can be rebuilt from D1 | N/A | N/A |
| Config/env | Stored in Cloudflare dashboard + 1Password | On change | Infinite |

### RPO/RTO
- **RPO (Recovery Point Objective):** 24 hours (daily D1 backup). For critical apps: use D1 replication.
- **RTO (Recovery Time Objective):** 1 hour. Restore from backup + redeploy Worker.

### Incident Response
1. **Detect:** Alert triggers (error rate, latency, health check fail).
2. **Assess:** Is this user-facing? How many users affected?
3. **Communicate:** Status page update. Notify via email/Discord.
4. **Mitigate:** Rollback if deploy-related. Disable feature flag if feature-related.
5. **Resolve:** Fix root cause. Deploy fix.
6. **Post-mortem:** Within 48 hours. Document in `docs/DECISIONS.md` as incident ADR.
   Format: Timeline → Root Cause → Impact → Resolution → Prevention.

### Incident Severity
| Severity | Impact | Response Time | Escalation |
|----------|--------|---------------|------------|
| SEV-1 | Total outage / data loss | Immediate | All hands |
| SEV-2 | Major feature broken | 15 min | On-call + lead |
| SEV-3 | Minor feature degraded | 1 hour | On-call |
| SEV-4 | Cosmetic / non-urgent | Next sprint | Ticket |
