# Architecture — [App Name]

> AI agents must read this before making any structural change.
> Update this file whenever the architecture changes.
> Do not let it drift from reality.

**Last updated:** YYYY-MM-DD

---

## Overview

[2-3 sentences. What is this system and how does it work at a high level?]

---

## Stack

| Layer | Technology | Version | Purpose |
|---|---|---|---|
| Web framework | TanStack Start | latest | SSR + routing + API |
| Runtime | Cloudflare Workers | — | Edge compute |
| Database | Cloudflare D1 (SQLite) | — | Primary data store |
| ORM | Drizzle ORM | latest | Type-safe DB access |
| Storage | Cloudflare R2 | — | File uploads |
| Queue | Cloudflare Queues | — | Background processing |
| Auth | better-auth | latest | Authentication |
| Payments | Stripe | latest | Subscriptions |
| Validation | Zod | v4+ | Input/output validation |
| Testing | Vitest | latest | Unit + integration tests |
| Linting | Biome | latest | Lint + format |
| Desktop | Tauri v2 | — | Native desktop agent (if variant B) |

---

## Directory Structure

```
├── apps/
│   ├── web/                    # TanStack Start web app
│   │   ├── src/
│   │   │   ├── routes/         # File-based routes (pages + API)
│   │   │   │   ├── _layout.tsx         # Root layout
│   │   │   │   ├── _public/            # Unauthenticated pages
│   │   │   │   ├── _auth/              # Authenticated pages (guarded)
│   │   │   │   └── api/v1/             # API endpoints
│   │   │   │       ├── webhooks/       # Webhook handlers
│   │   │   ├── components/     # React components
│   │   │   │   ├── ui/                 # Primitive components
│   │   │   │   └── features/           # Feature-specific
│   │   │   ├── services/       # Business logic (no HTTP coupling)
│   │   │   ├── hooks/          # React hooks
│   │   │   ├── lib/            # Pure utilities
│   │   │   └── db/             # DB schema + migrations
│   │   │       ├── schema.ts           # Drizzle schema
│   │   │       └── migrations/         # Generated migrations (DO NOT EDIT)
│   │
│   └── agent/                  # Tauri desktop agent (variant B only)
│       ├── src-tauri/          # Rust backend
│       └── src/                # React frontend
│
├── workers/
│   ├── ingest/                 # Data ingestion worker
│   └── processor/              # Background processing worker
│
├── packages/
│   ├── shared/                 # Types + utils shared across apps
│   ├── db/                     # Shared Drizzle config
│   └── config-resolver/        # Config resolution logic
│
├── evals/                      # LLM eval harness (if AI features)
│
├── docs/
│   ├── SPEC.md                 # Product requirements (the law)
│   ├── ARCHITECTURE.md         # This file
│   ├── DESIGN.md               # Design system rules
│   ├── DECISIONS.md            # Architecture decision records
│   └── CHANGELOG.md            # What changed and when
│
└── .mdd/
    └── docs/                   # MDD feature-level documentation
```

---

## Data Flow

### Request Lifecycle (Web)
```
[Browser]
  → TanStack Router (file-based routing)
  → Route Loader / Server Function
  → Auth Middleware (session check)
  → Service Layer (business logic)
  → Drizzle ORM (DB query)
  → Cloudflare D1 (SQLite)
```

### Background Job Lifecycle
```
[API route] → Queue.send({ type, payload })
  → [Queue Consumer Worker]
  → Service Layer
  → D1 / R2 / External API
```

### Webhook Lifecycle (Stripe)
```
[Stripe] → POST /api/webhooks/stripe
  → Signature verification (constructEvent)
  → Event router (switch on event.type)
  → Subscription service (update DB state)
  → D1
```

---

## Layer Boundaries (NON-NEGOTIABLE)

```
┌─────────────────────────────────┐
│  UI Layer (routes/, components/)│  → render + events only
├─────────────────────────────────┤
│  API Layer (routes/api/)        │  → validate input → call service → return response
├─────────────────────────────────┤
│  Service Layer (services/)      │  → business logic, no HTTP context
├─────────────────────────────────┤
│  Data Layer (db/, ORM)          │  → DB queries only
└─────────────────────────────────┘
```

- UI cannot import from services directly. Use API routes or server functions.
- API routes cannot import from `db/` directly. Use service functions.
- Service functions cannot import from `routes/`. No circular deps.
- Shared types live in `packages/shared/`.

---

## Authentication Model

- **Provider:** better-auth
- **Session storage:** Database (D1) — not JWT-stateless
- **Cookie:** `httpOnly`, `secure`, `sameSite: lax`
- **Session check:** Middleware on all `_auth/` routes
- **OAuth:** [list providers configured]

---

## Multi-Tenancy (if applicable)

[Describe org isolation model — per-user data, per-org data, row-level security pattern]

---

## Desktop Agent (Variant B only)

```
[Tauri App]
  → React UI (frontend)
  → Tauri Commands (Rust backend bridge)
  → Local SQLite (offline-first storage)
  → Outbox: batch sync to Cloudflare ingest worker every 30s
  ↕
[Tauri Updater]
  → Check update endpoint on startup
  → Download + verify signature
  → Prompt user → apply
```

Auto-update endpoint: `https://[domain]/api/releases/[platform]/[arch]/[version]`

---

## Error Handling

- All service layer functions throw typed errors (custom error classes).
- API layer catches and maps to HTTP responses.
- Unhandled errors: global error handler → structured log → error tracking.
- Client errors: caught by React error boundary → logged → user-facing message.

---

## Known Constraints

- D1 has a 10ms CPU budget per query in Workers.
- Cloudflare Workers have a 128MB memory limit.
- D1 SQLite doesn't support all PostgreSQL features.
- [Add project-specific constraints]

---

*Update this file whenever any architectural decision changes. If you're not sure whether to update it — update it.*
