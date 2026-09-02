# Feature Rules: Analytics
> Loaded when: features.analytics=true

## Privacy-First Architecture

Use **Cloudflare Analytics Engine** (built-in, zero cost, no third-party cookies) as primary.
PostHog self-hosted or Plausible as secondary for product analytics.

**No Google Analytics.** It triggers cookie banners, shares data with Google, and violates GDPR by default.

## What to Track

```typescript
// Product events — user actions worth tracking
export const EVENTS = {
  // Auth
  user_signed_up:    'user_signed_up',
  user_logged_in:    'user_logged_in',
  
  // Core product
  feature_used:      'feature_used',       // { feature: string }
  
  // Conversion
  trial_started:     'trial_started',
  subscription_created: 'subscription_created', // { plan: string }
  subscription_cancelled: 'subscription_cancelled',
  
  // Engagement
  session_started:   'session_started',
  report_generated:  'report_generated',
} as const
```

## Tracking Pattern

```typescript
// Never track in components — always via server events
// workers/api/src/lib/analytics.ts
export async function track(
  env: Env,
  event: string,
  properties: Record<string, string | number>,
  userId?: string,
) {
  // Cloudflare Analytics Engine
  env.ANALYTICS.writeDataPoint({
    blobs: [event, userId ?? 'anonymous'],
    doubles: [1],
    indexes: [event],
  })
}
```

## Rules

- **No PII in analytics events.** User ID ok. Email, name, IP — never.
- **Server-side tracking only for core events.** Client-side only for page views.
- **Cookie consent required for client-side tracking.** Default: opt-out.
- **Analytics must not block page load.** Fire-and-forget. Async always.
- **Data retention policy defined.** Default: 90 days for raw events, aggregated forever.
