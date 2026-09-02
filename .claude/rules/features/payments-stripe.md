# Feature Rules: Payments (Stripe)
> Loaded when: features.payments=true

## Architecture: Webhook-First

**The webhook is the source of truth. Not the API response.**

Why: Payment state changes asynchronously. Checkout can succeed but webhook can fail. Your database must reflect Stripe's state, not your API call's response.

```
User → Checkout → Stripe → Webhook → Your DB → Your UI
                              ↑
                         This is truth
```

## Required Files

```
workers/api/src/
  routes/
    payments/
      checkout.ts       ← Create checkout sessions
      portal.ts         ← Customer portal sessions
      webhook.ts        ← Webhook handler (the most important file)
  lib/
    stripe.ts           ← Stripe client singleton
    subscription.ts     ← Subscription state helpers

packages/db/
  schema/
    subscriptions.ts    ← Subscription + plan schema
```

## Stripe Client — Singleton Pattern

```typescript
// workers/api/src/lib/stripe.ts
import Stripe from 'stripe'

export function getStripe(env: Env): Stripe {
  return new Stripe(env.STRIPE_SECRET_KEY, {
    apiVersion: '2024-11-20.acacia',
    typescript: true,
  })
}
```

## Webhook Handler — Non-Negotiable Pattern

```typescript
// workers/api/src/routes/payments/webhook.ts
export async function handleStripeWebhook(c: Context<{ Bindings: Env }>) {
  const body = await c.req.text()
  const sig = c.req.header('stripe-signature')!

  // 1. ALWAYS verify webhook signature
  let event: Stripe.Event
  try {
    event = stripe.webhooks.constructEvent(body, sig, c.env.STRIPE_WEBHOOK_SECRET)
  } catch {
    return c.json({ error: 'Invalid signature' }, 400)
  }

  // 2. Handle idempotently — use event.id as idempotency key
  const processed = await c.env.DB
    .prepare('SELECT id FROM processed_webhooks WHERE stripe_event_id = ?')
    .bind(event.id).first()
  if (processed) return c.json({ ok: true }) // Already handled

  // 3. Handle the event
  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutComplete(c.env.DB, event.data.object)
      break
    case 'customer.subscription.updated':
    case 'customer.subscription.deleted':
      await handleSubscriptionChange(c.env.DB, event.data.object)
      break
    case 'invoice.payment_failed':
      await handlePaymentFailed(c.env.DB, event.data.object)
      break
  }

  // 4. Mark as processed
  await c.env.DB
    .prepare('INSERT INTO processed_webhooks (stripe_event_id, processed_at) VALUES (?, ?)')
    .bind(event.id, new Date().toISOString()).run()

  return c.json({ ok: true })
}
```

## Database Schema (Required)

```typescript
// packages/db/schema/subscriptions.ts
export const subscriptions = sqliteTable('subscriptions', {
  id:                    text('id').primaryKey().$defaultFn(() => uuidv7()),
  user_id:               text('user_id').notNull().references(() => users.id),
  stripe_customer_id:    text('stripe_customer_id').notNull().unique(),
  stripe_subscription_id:text('stripe_subscription_id').unique(),
  plan:                  text('plan', { enum: ['free', 'starter', 'pro', 'enterprise'] }).notNull().default('free'),
  status:                text('status').notNull().default('active'),
  current_period_end:    integer('current_period_end', { mode: 'timestamp' }),
  cancel_at_period_end:  integer('cancel_at_period_end', { mode: 'boolean' }).default(false),
  created_at:            integer('created_at', { mode: 'timestamp' }).$defaultFn(() => new Date()),
  updated_at:            integer('updated_at', { mode: 'timestamp' }).$onUpdateFn(() => new Date()),
})

export const processedWebhooks = sqliteTable('processed_webhooks', {
  stripe_event_id: text('stripe_event_id').primaryKey(),
  processed_at:    text('processed_at').notNull(),
})
```

## Subscription Gating Pattern

```typescript
// Middleware — check subscription before route
export async function requireSubscription(c: Context, next: Next, plan: Plan[]) {
  const sub = await getUserSubscription(c.env.DB, c.get('userId'))
  if (!sub || !plan.includes(sub.plan) || sub.status !== 'active') {
    return c.json({ error: 'Subscription required', upgrade_url: '/pricing' }, 403)
  }
  await next()
}
```

## Rules

- **Never store full card details.** Stripe tokenizes. You store only Stripe IDs.
- **Test mode in dev/staging, live mode in prod.** Enforced via environment config.
- **Webhook endpoint must be idempotent.** Same event, same result, always.
- **Customer portal for all subscription management.** No custom cancellation/upgrade UI.
- **Stripe CLI for local webhook testing.** Document `stripe listen` command in README.
- **Every pricing change = new Price object.** Never modify existing Prices in Stripe.
