# Architecture Decision Records (ADRs)

> Append-only. Never delete or edit existing entries.
> Record every significant decision that would be costly to revisit.
> Format: date, context, decision, consequences.

---

## Template

```
## YYYY-MM-DD — [Decision Title]
**Context:** Why was this decision needed?
**Decision:** What was decided?
**Alternatives considered:** What else was evaluated?
**Consequences:** What does this enable / constrain going forward?
**Owner:** Who made this call?
```

---

## YYYY-MM-DD — Initial Stack Selection

**Context:** Needed to choose a stack for a new [web-only / agent+web] project.

**Decision:** TanStack Start + Cloudflare Workers + D1 + Drizzle + Stripe + [Tauri if agent].

**Alternatives considered:**
- Next.js + Vercel — more ecosystem support but higher cost at scale, vendor lock-in.
- Remix + Fly.io — good DX but less edge-native.
- SvelteKit — smaller ecosystem for this team's TypeScript-first workflow.

**Consequences:**
- Edge-native: no server to manage, global latency.
- SQLite (D1) limits: no CTEs in older versions, no PostgreSQL-specific features.
- Tauri agent: cross-platform desktop with Rust backend and web frontend — fast, small bundle.

**Owner:** [name]

---

## YYYY-MM-DD — Webhook-First Subscription State

**Context:** Stripe checkout returns a success redirect, but redirects can be spoofed or missed.

**Decision:** Subscription state ONLY changes via Stripe webhooks. The checkout success redirect shows a loading state until the webhook fires and updates the DB.

**Alternatives considered:**
- Trust the success redirect — simpler, but unreliable and exploitable.
- Poll the subscription endpoint after redirect — adds latency and complexity.

**Consequences:**
- Subscription state is always accurate and can't be spoofed.
- There's a 1-3 second delay between checkout completion and subscription activation.
- The webhook handler must be idempotent (handle duplicate events gracefully).

**Owner:** [name]

---

*Add all significant decisions below. One entry per decision. Append only.*
