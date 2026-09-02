---
name: add-payment
description: Wire up Stripe subscription or one-time payment with webhook-first architecture
user-invocable: true
---

Add payment feature: $ARGUMENTS

## Before Starting

Read:
- `docs/SPEC.md` → pricing section (the spec defines prices, not this command)
- `docs/ARCHITECTURE.md` → existing Stripe integration if any
- `.mdd/docs/` → existing payment feature docs

## Workflow

### Step 1: Confirm Requirements
- Subscription or one-time payment?
- Which plans/prices? (Get from spec — not hardcoded)
- What features unlock per plan?
- What happens on failed payment / cancellation?

### Step 2: Stripe Setup
1. Create products/prices in Stripe Dashboard (test mode).
2. Add Price IDs to environment config (never hardcode).
3. Configure webhook endpoint in Stripe Dashboard.

### Step 3: Scaffold (in order)
```
1. db/schema → subscriptions table (userId, stripeCustomerId, status, plan, periodEnd)
2. pnpm db:generate → migration
3. pnpm db:migrate → apply
4. lib/stripe.ts → Stripe client (singleton, server-only)
5. services/subscription.ts → business logic (create, cancel, get status)
6. api/stripe/checkout.ts → create checkout session handler
7. api/stripe/portal.ts → customer portal handler
8. api/stripe/webhook.ts → webhook handler (signature verify → handle events)
9. middleware/requirePlan.ts → guard middleware for gated routes
10. UI → upgrade page, billing page
```

### Step 4: Webhook Events to Handle
- `checkout.session.completed` → activate subscription
- `invoice.payment_succeeded` → extend subscription period
- `invoice.payment_failed` → mark past_due
- `customer.subscription.deleted` → deactivate
- `customer.subscription.updated` → handle plan changes

### Step 5: Testing
- Use Stripe CLI: `stripe listen --forward-to localhost:3000/api/stripe/webhook`
- Test each webhook event with `stripe trigger <event>`
- Write integration tests that mock Stripe and test service logic

### Step 6: Quality Gate
- No prices hardcoded anywhere
- Webhook signature verified on every call
- Idempotency keys present on all Stripe API calls
- Subscription state only changes via webhook (never via checkout redirect)
