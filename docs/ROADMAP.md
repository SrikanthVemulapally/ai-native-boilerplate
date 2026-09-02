# Roadmap — [App Name]

> **This is a living document.** Update it as priorities shift.
> Spec = what we build. Roadmap = when and in what order.
> AI agents read this to understand sequencing and what NOT to build yet.

---

## Current Phase: [Phase Name]

**Goal:** [What this phase achieves]
**Target date:** YYYY-MM-DD
**Success metric:** [How you know this phase is complete]

---

## Phases

### 🔴 Phase 0 — Foundation (Weeks 1–2)
*What: Core scaffold, auth, billing skeleton. Nothing user-facing.*

- [x] Project scaffold (monorepo, CI, deploy pipeline)
- [x] Database schema (users, sessions, subscriptions)
- [ ] Authentication (email/password + magic link)
- [ ] Stripe integration (checkout, webhook, customer portal)
- [ ] Basic landing page (not polished — functional)
- [ ] Error tracking (Sentry setup)

**Exit criteria:** A real user can sign up, subscribe, and log in.

---

### 🟡 Phase 1 — Core Product (Weeks 3–6)
*What: The actual product — the reason users pay.*

- [ ] [Core feature 1]
- [ ] [Core feature 2]
- [ ] [Core feature 3]
- [ ] Basic admin panel (usage, user management)
- [ ] Email transactionals (welcome, payment confirmation, failed payment)

**Exit criteria:** A user can accomplish [primary job-to-be-done] end-to-end.

---

### 🟢 Phase 2 — Polish & Growth (Weeks 7–10)
*What: UX polish, SEO, conversion optimization.*

- [ ] Landing page v2 (designed, copywritten, optimized)
- [ ] SEO (meta tags, OG, structured data, sitemap)
- [ ] Onboarding flow (first-run, activation, trial-to-paid)
- [ ] Analytics (Cloudflare Analytics Engine + product events)
- [ ] Pricing page
- [ ] Blog (if part of SEO strategy)

**Exit criteria:** Strangers find the product and convert without help.

---

### 🔵 Phase 3 — Scale & Team (Post-launch)
*What: Features that require traction to prioritize.*

- [ ] [Advanced feature — only if users ask]
- [ ] Multi-user / team support
- [ ] API for integrations
- [ ] Mobile app (if warranted by usage data)
- [ ] i18n (if warranted by geographic demand)

**Exit criteria:** [TBD based on what users ask for]

---

## Won't Build (Unless Spec Changes)

> These are explicitly out of scope. AI agents must not implement these.

- [Item] — [reason: out of scope for v1 / better served by X / too early]
- [Item]

---

## Feature Request Backlog

> User requests that haven't been prioritized yet. Not in scope — logged for future consideration.

| Request | Source | Date | Status |
|---|---|---|---|
| [Feature] | [User/channel] | YYYY-MM-DD | considering / declined / deferred |

---

## Dependencies & Risks

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| [Risk 1] | medium | high | [How to mitigate] |
| [Risk 2] | low | high | [How to mitigate] |

---

*Roadmap changes require a `docs/DECISIONS.md` entry explaining why priorities shifted.*
