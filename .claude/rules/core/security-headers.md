# Security Headers & Web Hardening

> **Non-negotiable for all web-facing apps.** These headers prevent the most common web attacks. Every response must include them.

## Required Security Headers

```typescript
// Cloudflare Worker / Hono middleware
const securityHeaders = {
  'Strict-Transport-Security': 'max-age=63072000; includeSubDomains; preload',  // 2 years, HSTS
  'X-Content-Type-Options': 'nosniff',              // prevents MIME sniffing
  'X-Frame-Options': 'DENY',                        // prevents clickjacking
  'Referrer-Policy': 'strict-origin-when-cross-origin',  // limits referrer leakage
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',  // disables unused APIs
  'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self' https:; frame-ancestors 'none';",
  'Cross-Origin-Opener-Policy': 'same-origin',
  'Cross-Origin-Embedder-Policy': 'require-corp',
  'Cross-Origin-Resource-Policy': 'same-origin',
};
```

## Header Explanations

| Header | What It Prevents |
|--------|-----------------|
| `Strict-Transport-Security` | Protocol downgrade attacks — forces HTTPS for 2 years |
| `X-Content-Type-Options` | MIME type confusion attacks |
| `X-Frame-Options: DENY` | Clickjacking — page cannot be embedded in iframe |
| `Referrer-Policy` | Referrer leakage to third parties |
| `Permissions-Policy` | Unauthorized access to camera, mic, location |
| `Content-Security-Policy` | XSS, data injection, unauthorized resource loading |
| `Cross-Origin-*` | Spectre-class attacks, cross-origin data leakage |

## Content-Security-Policy Tuning

### Base CSP (safe for most apps)
```
default-src 'self';
script-src 'self' 'unsafe-inline';
style-src 'self' 'unsafe-inline';
img-src 'self' data: https:;
font-src 'self';
connect-src 'self' https:;
frame-ancestors 'none';
```

### Strict CSP (use nonce-based, remove 'unsafe-inline')
```
default-src 'self';
script-src 'self' 'nonce-{RANDOM}';
style-src 'self' 'nonce-{RANDOM}';
img-src 'self' data: https:;
font-src 'self';
connect-src 'self' https://api.myapp.com;
frame-ancestors 'none';
base-uri 'self';
form-action 'self';
```

### CSP per provider
- **Stripe:** `script-src` needs `https://js.stripe.com`, `frame-src` needs `https://js.stripe.com`
- **PostHog:** `script-src` needs `https://us.i.posthog.com` or `https://eu.i.posthog.com`
- **Google Analytics:** `script-src` needs `https://www.googletagmanager.com`, `connect-src` needs `https://*.google-analytics.com`
- **Sentry:** `connect-src` needs your Sentry ingest URL
- **reCAPTCHA:** `script-src` needs `https://www.google.com/recaptcha/`, `frame-src` needs `https://www.google.com/recaptcha/`

### CSP reporting
Add `report-uri /api/csp-report` or `report-to` header to collect violations without blocking. Review reports weekly.

## CORS Configuration

```typescript
// ❌ BAD — too permissive
app.use(cors({ origin: '*' }));

// ✅ GOOD — explicit allowlist
const allowedOrigins = [
  'https://myapp.com',
  'https://app.myapp.com',
  process.env.NODE_ENV === 'development' && 'http://localhost:3000',
].filter(Boolean);

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['Location'],
  maxAge: 86400,  // preflight cache: 24 hours
}));
```

### CORS Rules
1. **Never use `origin: '*'` with `credentials: true`.** Browsers block this.
2. **Explicit origin allowlist.** Read from config, not hardcoded.
3. **No wildcard methods or headers.** List exactly what the API accepts.
4. **Preflight cache max 24h.** Reduces OPTIONS requests.

## Health Checks

```typescript
// Health (liveness) — is the process running?
app.get('/health', (c) => c.json({ status: 'ok' }));

// Readiness — is the app ready to serve traffic?
app.get('/ready', async (c) => {
  try {
    await db.execute('SELECT 1');  // DB reachable?
    return c.json({ status: 'ready', checks: { database: 'ok' } });
  } catch (err) {
    return c.json({ status: 'not_ready', checks: { database: 'error' } }, 503);
  }
});
```

- `/health` — no dependencies checked, always 200 if process is alive
- `/ready` — checks DB, cache, external services. 503 if any fail.
- Both must respond in < 500ms
- Never log health check requests (fills logs)

## Error Boundaries (React)

```typescript
// app-error.tsx — root error boundary (TanStack Start)
import { ErrorComponent } from '@/components/error-boundary';

export function ErrorBoundary({ error }: { error: Error }) {
  // Report to Sentry
  if (process.env.NODE_ENV === 'production') {
    Sentry.captureException(error);
  }

  return <ErrorComponent error={error} />;
}
```

### Rules
1. **Every route has an error boundary.** A crash in one route must not blank the whole app.
2. **Root error boundary catches everything.** Shows generic error with Sentry error ID for support.
3. **Error boundaries never crash.** They're the last line of defense — always render something.
4. **Report errors to Sentry from the boundary, not from try/catch.** Centralized error reporting.
5. **Show user-friendly message.** Not the stack trace. Stack trace goes to Sentry only.
6. **Include a recovery action.** "Try again" button that reloads the route.

## Subresource Integrity (SRI)

For external scripts (analytics, payment SDKs), add SRI hashes:

```html
<script src="https://js.stripe.com/v3/"
        integrity="sha384-..."
        crossorigin="anonymous"></script>
```

If the CDN is compromised and the script changes, the browser refuses to execute it.

## AI Agent Rules

1. **Always add security headers middleware.** First thing when scaffolding a web app.
2. **Never use `origin: '*'` in CORS.** Always explicit allowlist.
3. **Always scaffold `/health` and `/ready` endpoints.** From day one.
4. **Always add error boundaries.** Every route, not just root.
5. **When adding a third-party script (analytics, payments, chat), update CSP.** Add the domain to the correct directive.
6. **Never disable security headers for "debugging."** Fix the actual issue.
