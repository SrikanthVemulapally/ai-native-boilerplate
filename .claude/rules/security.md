# Security Rules

Loaded automatically when working in security-sensitive areas.

## Authentication
- Use `better-auth` (or the auth library configured in ARCHITECTURE.md) — never roll your own auth.
- Session tokens must be stored in `httpOnly` cookies — never localStorage.
- NEVER trust user-supplied `userId` for authorization. Always verify against session.
- Rate limit authentication endpoints (login, register, password reset).

## API Security
- Every route handler must check authentication BEFORE doing any work.
- Every route handler must check authorization (does this user own this resource?) BEFORE returning data.
- Return 401 for unauthenticated, 403 for unauthorized — never 404 to hide resource existence (unless spec requires it for privacy).

## Input Handling
- All user input is hostile until validated.
- Use Zod for ALL inputs — query params, body, path params, headers, cookies.
- Validate file type by magic bytes, not extension.
- Limit file sizes at the edge (before processing).

## Stripe Security
```typescript
// CORRECT: Always verify webhook signatures
const event = stripe.webhooks.constructEvent(
  rawBody,        // raw Buffer, not parsed JSON
  sig,            // from stripe-signature header
  webhookSecret   // from env, never hardcoded
);

// CORRECT: Get price from server
const price = await stripe.prices.retrieve(priceId);

// WRONG: Trust client price
const amount = req.body.amount; // NEVER DO THIS
```

## Logging
- Log: event type, userId, timestamp, resource ID.
- NEVER log: passwords, tokens, card numbers, SSNs, raw request bodies.
- Use structured logging (JSON) — no `console.log` in production code.

## Environment
- Secrets in `.env` only, referenced via `process.env.VAR_NAME`.
- `.env` files are in `.gitignore` — verify before any commit.
- Never `console.log(process.env)` — even in debugging.
- Client-side code never sees `process.env.STRIPE_SECRET_KEY` — only server-side.
