# Product Specification — [App Name]

> **This is the law.** All implementation must align with this document.
> AI agents must read this before writing any code.
> Changes require explicit user approval + an entry in DECISIONS.md.

**Version:** 0.1
**Last updated:** YYYY-MM-DD
**Status:** Draft | In Progress | Stable

---

## 1. What Is This?

[1-2 sentences. What does this product do and for whom?]

**Problem:** [The specific pain this solves]
**Solution:** [How this product solves it]
**Target user:** [Who uses this?]

---

## 2. Variant

- [ ] **Web-only** — TanStack Start + Cloudflare Workers
- [ ] **Agent + Web** — Desktop agent (Tauri) + Web admin panel

---

## 3. Features In Scope (v1)

### Must Have (launch blockers)
- [ ] Feature A — [1-line description]
- [ ] Feature B — ...
- [ ] Authentication — email/password + [OAuth providers if any]
- [ ] Subscription billing — [plan names]

### Should Have (v1.1)
- [ ] Feature X

### Won't Have (explicitly out of scope)
- Feature Y — [why excluded]

---

## 4. User Flows

### 4.1 Onboarding
1. User visits landing page.
2. User clicks "Sign up".
3. User enters email + password.
4. User verifies email.
5. User is redirected to dashboard.

### 4.2 [Other Key Flow]
1. ...

---

## 5. Pricing & Plans

| Plan | Price | Features |
|---|---|---|
| Free | $0/mo | [feature list] |
| Pro | $XX/mo | [feature list] |
| Team | $XX/mo | [feature list] |

**Billing:** Monthly and annual options.
**Trial:** [X days / no trial]
**Free tier:** [Yes/No — what's included]

> Prices are defined here. They must be configured in Stripe Dashboard.
> Prices must NEVER be hardcoded in application code.

---

## 6. Pages & Routes

### Public (unauthenticated)
| Route | Page | SEO Priority |
|---|---|---|
| `/` | Landing page | HIGH |
| `/pricing` | Pricing page | HIGH |
| `/blog` | Blog index | MEDIUM |
| `/login` | Login | LOW |
| `/register` | Register | LOW |

### Authenticated
| Route | Page | Notes |
|---|---|---|
| `/dashboard` | Main dashboard | |
| `/settings` | Account settings | |
| `/billing` | Billing & subscription | |

---

## 7. Data Model (high level)

### Entities
- **User** — id, email, name, createdAt
- **Subscription** — id, userId, plan, status, periodEnd, stripeCustomerId

[Add entities as needed. Full schema lives in `src/db/schema.ts`.]

---

## 8. Non-Functional Requirements

### Performance
- API response time P95: < 200ms
- LCP: < 2.5s on public pages
- Uptime: 99.9%

### Security
- All endpoints authenticated unless explicitly public.
- All inputs validated with Zod.
- Stripe webhook signature verified.
- No PII in logs.

### SEO
- All public pages have meta tags, OG, and canonical URLs.
- Public pages use SSR (no client-only rendering for content).
- Sitemap.xml generated.

### Accessibility
- WCAG 2.1 AA minimum.

---

## 9. Integrations

| Service | Purpose | Required |
|---|---|---|
| Stripe | Subscriptions + payments | Yes |
| [Email provider] | Transactional email | Yes |
| [Error tracking] | Runtime error reporting | Yes |
| [Analytics] | Usage analytics | Optional |

---

## 10. Open Questions

- [ ] Q: [Unresolved question that needs an answer before building]
- [ ] Q: ...

---

## 11. Out of Scope (Permanent)

These will NOT be built, ever, without a spec revision:
- [Item]
- [Item]

---

*Spec changes require: (1) user approval, (2) entry in docs/DECISIONS.md, (3) impact assessment on existing code.*
