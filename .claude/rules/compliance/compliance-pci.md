# PCI DSS Compliance Rules

Load when: `compliance.pci: true` (automatically true if `features.payments: true`).
We use Stripe — this dramatically reduces PCI scope to SAQ-A level.

---

## Scope Reduction via Stripe

**The golden rule: Never touch raw card data. Ever.**

By using Stripe.js / Stripe Elements / Payment Intents on the client and Stripe API on the server, we achieve **SAQ-A compliance** — the minimal PCI scope. Stripe handles the cardholder data environment (CDE).

| What Stripe handles | What WE handle |
|--------------------|----------------|
| Card number (PAN) | Stripe Customer ID (T4 RESTRICTED) |
| CVV / CVC | Stripe Payment Method ID (T4 RESTRICTED) |
| Expiry date | Stripe Subscription ID (T2 INTERNAL) |
| Cardholder name on card | Billing name / address (T3 CONFIDENTIAL) |
| PCI-compliant storage | Webhook signature verification |
| Encryption in transit | Idempotency keys |

---

## Mandatory Implementation Rules

### Client-Side (Always)
```typescript
// ✅ CORRECT — Stripe Elements handles card input
// Card data NEVER touches your JavaScript
import { loadStripe } from '@stripe/stripe-js'
const stripe = await loadStripe(process.env.VITE_STRIPE_PUBLISHABLE_KEY!)

// Stripe.js creates a payment method — you get a token, never card data
const { paymentMethod, error } = await stripe.createPaymentMethod({
  type: 'card',
  card: cardElement, // Stripe Element — card data stays in Stripe's iframe
})

// ❌ WRONG — never accept card fields in your own form
// <input name="card_number" /> — NEVER
// <input name="cvv" /> — NEVER
```

### Server-Side (Always)
```typescript
// ✅ CORRECT — work with tokens only
const paymentIntent = await stripe.paymentIntents.create({
  amount: 2000,
  currency: 'usd',
  customer: stripeCustomerId,  // T4 stored in your DB
  payment_method: paymentMethodId,  // from client token
})

// ❌ WRONG — never log payment details
logger.info('Payment created', { card: '4242...', cvv: '123' }) // NEVER
logger.info('Payment created', { intentId: paymentIntent.id }) // ✅
```

### Webhook Handling (Always)
```typescript
// ✅ REQUIRED — always verify Stripe webhook signature
app.post('/api/webhooks/stripe', async (c) => {
  const sig = c.req.header('stripe-signature')!
  const body = await c.req.text() // raw body — NOT parsed JSON

  let event: Stripe.Event
  try {
    event = stripe.webhooks.constructEvent(
      body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET! // T4 env var
    )
  } catch (err) {
    return c.json({ error: 'Invalid signature' }, 400)
  }

  // Process event IDEMPOTENTLY — Stripe may send duplicates
  const processed = await db.query.webhookEvents.findFirst({
    where: eq(webhookEvents.stripeEventId, event.id)
  })
  if (processed) return c.json({ received: true }) // Already handled

  // Handle event...
})
```

---

## What To Store (and What Never To)

```typescript
// DB Schema — only store what Stripe gives you, never raw card data
export const customers = pgTable('customers', {
  id: text('id').primaryKey(),          // T2: Your internal user ID
  stripeCustomerId: text('stripe_customer_id').notNull(), // T4:RESTRICTED — encrypted
  stripeSubscriptionId: text('stripe_subscription_id'),  // T2:INTERNAL
  stripePriceId: text('stripe_price_id'),               // T2:INTERNAL
  plan: text('plan').notNull(),                          // T2:INTERNAL
  status: text('status').notNull(),                      // T2:INTERNAL
  currentPeriodEnd: integer('current_period_end'),       // T2:INTERNAL (Unix timestamp)
  // Billing address — T3:CONFIDENTIAL (for tax/invoice purposes)
  billingName: text('billing_name'),
  billingEmail: text('billing_email'),
  billingCountry: text('billing_country'),
  // NEVER STORE:
  // card_number, cvv, expiry — NEVER
  // full_pan, card_last4 only if Stripe returns it
})
```

---

## Environment Variables (PCI-Required)

```bash
# .env.example — these MUST be in env vars, NEVER in code

# Stripe keys — T4:RESTRICTED
STRIPE_SECRET_KEY=sk_live_...         # Server only, NEVER client
STRIPE_WEBHOOK_SECRET=whsec_...       # Server only, NEVER client
STRIPE_PUBLISHABLE_KEY=pk_live_...    # Client-safe (not sensitive, but treat as T2)

# Key rotation: rotate Stripe webhook secrets every 90 days
# Key naming: STRIPE_SECRET_KEY not STRIPE_KEY (be explicit)
```

---

## PCI SAQ-A Compliance Checklist

For Stripe-powered SAQ-A (the minimal scope):

- [ ] All card data entry via Stripe.js / Elements (never your own form fields)
- [ ] HTTPS enforced everywhere — no HTTP, no mixed content
- [ ] Stripe webhook signatures verified on every webhook
- [ ] Stripe Customer ID and Payment Method ID encrypted at rest (T4)
- [ ] No card data in logs, error messages, or Sentry
- [ ] No card data in URLs or query strings
- [ ] Stripe keys in environment variables, never in code or git
- [ ] Stripe keys rotated annually (or on suspected compromise)
- [ ] Quarterly: confirm Stripe's PCI DSS certificate is current
- [ ] Annual: complete SAQ-A self-assessment questionnaire
- [ ] Vendor inventory includes Stripe with their PCI compliance docs

---

## Payment Flow Security Rules

1. **Idempotency on all payment mutations** — use `idempotencyKey` on every Stripe API call
2. **Webhook-first architecture** — trust Stripe webhook events, not direct API responses for state changes
3. **Never fulfill orders on frontend** — always wait for `payment_intent.succeeded` webhook
4. **Test vs Live key separation** — use `STRIPE_ENV=test|live` guard, never mix environments
5. **Refund audit trail** — log all refunds with reason and operator ID in your own DB
6. **Dispute monitoring** — set up Stripe Radar + email alerts for disputes

---

## Subscription Lifecycle Events (Handle All of These)

```typescript
// Every Stripe webhook event that affects entitlements — MUST handle:
const REQUIRED_EVENTS = [
  'customer.subscription.created',      // Grant access
  'customer.subscription.updated',      // Plan change, downgrade
  'customer.subscription.deleted',      // Revoke access
  'customer.subscription.trial_will_end', // 3-day warning
  'invoice.payment_succeeded',          // Renew period
  'invoice.payment_failed',             // Grace period, notify user
  'invoice.finalized',                  // Send receipt
  'payment_intent.succeeded',           // One-time payment
  'payment_intent.payment_failed',      // One-time failure
  'customer.updated',                   // Billing details changed
  'charge.dispute.created',             // Dispute — alert immediately
]
```
