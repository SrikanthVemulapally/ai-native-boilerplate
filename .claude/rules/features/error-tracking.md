# Feature Rules: Error Tracking & Observability
> Loaded when: features.error-tracking=true

## Stack: Sentry + Structured Logging

Use **Sentry** for runtime error tracking (exceptions, crashes, performance traces).
Use **structured JSON logging** for operational logs (Cloudflare Logpush → R2 or external).
Use **Cloudflare Analytics Engine** for custom metrics.

Never use `console.log` in production. Never lose an error silently.

## Required Files

```
packages/shared/src/
  lib/
    sentry.ts           ← Sentry client singleton (lazy init)
    logger.ts           ← Structured logger (all environments)
    errors.ts           ← Typed error hierarchy

workers/api/src/
  middleware/
    error-handler.ts    ← Global error handler (catch + log + respond)
    sentry.ts           ← Sentry Cloudflare Workers integration

apps/web/app/
  lib/
    sentry.ts           ← Sentry browser client
  root.tsx              ← Sentry ErrorBoundary wrapping entire app

apps/agent/src-tauri/src/
  error.rs              ← Sentry Rust integration (if Tauri variant)
```

## Sentry Setup (Cloudflare Workers)

```typescript
// workers/api/src/middleware/sentry.ts
import * as Sentry from '@sentry/cloudflare'

export function initSentry(env: Env) {
  Sentry.init({
    dsn: env.SENTRY_DSN,
    environment: env.ENVIRONMENT,     // production | staging | development
    tracesSampleRate: env.ENVIRONMENT === 'production' ? 0.1 : 1.0,
    release: env.APP_VERSION,         // set via CI
    beforeSend(event) {
      // Strip PII before sending to Sentry
      if (event.user?.email) {
        event.user.email = '[redacted]'
      }
      return event
    },
  })
}

// Wrap all Worker handlers:
export default {
  fetch: Sentry.withSentry(
    (env) => ({ dsn: env.SENTRY_DSN }),
    handler.fetch,
  ),
}
```

## Sentry Setup (Browser / TanStack)

```typescript
// apps/web/app/lib/sentry.ts
import * as Sentry from '@sentry/react'
import { useEffect } from 'react'
import { useLocation } from '@tanstack/react-router'

export function initSentry() {
  if (import.meta.env.VITE_SENTRY_DSN) {
    Sentry.init({
      dsn: import.meta.env.VITE_SENTRY_DSN,
      environment: import.meta.env.MODE,
      integrations: [
        Sentry.browserTracingIntegration(),
        Sentry.replayIntegration({
          maskAllText: true,       // ← GDPR: mask user content in replays
          blockAllMedia: true,
        }),
      ],
      tracesSampleRate: 0.1,
      replaysSessionSampleRate: 0.01,   // 1% of sessions
      replaysOnErrorSampleRate: 1.0,    // 100% of error sessions
    })
  }
}

// Root error boundary
// apps/web/app/root.tsx
import { Sentry } from '@sentry/react'
export function App() {
  return (
    <Sentry.ErrorBoundary fallback={ErrorPage} showDialog>
      <RouterProvider router={router} />
    </Sentry.ErrorBoundary>
  )
}
```

## Structured Logger

```typescript
// packages/shared/src/lib/logger.ts
type LogLevel = 'debug' | 'info' | 'warn' | 'error'

interface LogEntry {
  level: LogLevel
  message: string
  timestamp: string
  requestId?: string
  userId?: string
  [key: string]: unknown
}

export function createLogger(requestId?: string) {
  function log(level: LogLevel, message: string, data?: Record<string, unknown>) {
    const entry: LogEntry = {
      level,
      message,
      timestamp: new Date().toISOString(),
      requestId,
      ...data,
    }

    // NEVER log PII — scrub before logging
    const safe = scrubPII(entry)

    // In Workers, console.log writes to Cloudflare Logpush
    console[level === 'error' ? 'error' : level === 'warn' ? 'warn' : 'log'](
      JSON.stringify(safe)
    )

    // Forward errors to Sentry
    if (level === 'error' && data?.error instanceof Error) {
      Sentry.captureException(data.error, { extra: safe })
    }
  }

  return {
    debug: (msg: string, data?: Record<string, unknown>) => log('debug', msg, data),
    info:  (msg: string, data?: Record<string, unknown>) => log('info', msg, data),
    warn:  (msg: string, data?: Record<string, unknown>) => log('warn', msg, data),
    error: (msg: string, data?: Record<string, unknown>) => log('error', msg, data),
  }
}

// Fields to scrub from all log entries
const PII_FIELDS = ['email', 'password', 'token', 'secret', 'credit_card', 'ssn', 'dob']

function scrubPII(obj: Record<string, unknown>): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(obj).map(([k, v]) => [
      k,
      PII_FIELDS.some(f => k.toLowerCase().includes(f)) ? '[REDACTED]' : v
    ])
  )
}
```

## Typed Error Hierarchy

```typescript
// packages/shared/src/lib/errors.ts
export class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public statusCode: number = 500,
    public context?: Record<string, unknown>,
  ) {
    super(message)
    this.name = 'AppError'
  }
}

export class ValidationError extends AppError {
  constructor(message: string, context?: Record<string, unknown>) {
    super('VALIDATION_ERROR', message, 400, context)
    this.name = 'ValidationError'
  }
}

export class AuthError extends AppError {
  constructor(message = 'Unauthorized') {
    super('AUTH_ERROR', message, 401)
    this.name = 'AuthError'
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') {
    super('FORBIDDEN_ERROR', message, 403)
    this.name = 'ForbiddenError'
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super('NOT_FOUND', `${resource} not found`, 404)
    this.name = 'NotFoundError'
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super('CONFLICT', message, 409)
    this.name = 'ConflictError'
  }
}
```

## Global Error Handler (Workers)

```typescript
// workers/api/src/middleware/error-handler.ts
import { AppError } from '@project/shared'
import { createLogger } from '@project/shared'
import * as Sentry from '@sentry/cloudflare'

export async function errorHandler(c: Context, next: Next) {
  try {
    await next()
  } catch (error) {
    const logger = createLogger(c.get('requestId'))

    if (error instanceof AppError) {
      // Known error — log as warn, return structured response
      logger.warn('Application error', {
        code: error.code,
        message: error.message,
        statusCode: error.statusCode,
        context: error.context,
      })

      return c.json({
        error: {
          code: error.code,
          message: error.message,
          ...(error.context ? { details: error.context } : {}),
        }
      }, error.statusCode as StatusCode)
    }

    // Unknown error — log as error, capture to Sentry
    logger.error('Unexpected error', { error })
    Sentry.captureException(error)

    return c.json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'An unexpected error occurred',
      }
    }, 500)
  }
}
```

## Tauri Agent Error Tracking (Rust)

```toml
# Cargo.toml
[dependencies]
sentry = { version = "0.34", features = ["anyhow", "panic", "tracing"] }
```

```rust
// src-tauri/src/main.rs
fn main() {
    let _guard = sentry::init(sentry::ClientOptions {
        dsn: std::env::var("SENTRY_DSN").ok().map(|d| d.parse().unwrap()),
        release: sentry::release_name!(),
        ..Default::default()
    });

    tauri::Builder::default()
        .setup(|app| {
            // App setup
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Performance Monitoring

```typescript
// Track custom metrics in Sentry
export function trackPerformance(name: string, fn: () => Promise<unknown>) {
  return Sentry.startSpan({ name, op: 'function' }, fn)
}

// Usage: wrap slow operations
const result = await trackPerformance('generate-report', () => generateReport(userId))
```

## Alerting Rules (Set in Sentry Dashboard)

Configure these alerts immediately after Sentry setup:
- **Error rate spike:** > 1% error rate on any endpoint → alert within 5 min
- **New error type:** Any new `AppError` code or unhandled exception → alert immediately  
- **P95 latency spike:** API P95 > 2s → alert
- **Crash-free rate drop:** < 99.5% → alert (Tauri agent only)

## Rules

- **Never catch and swallow errors.** Every `catch` must log or rethrow.
- **Typed errors always.** Never `throw new Error('something failed')` — use the error hierarchy.
- **No PII in Sentry.** The `beforeSend` hook must scrub before any data leaves the app.
- **Sentry DSN in env only.** Never hardcode.
- **Source maps uploaded in CI.** Required for readable stack traces.
- **Error boundary on every async boundary.** Web app root, admin root, and each route segment.
- **Request ID propagated.** Generate `X-Request-ID` at edge, thread through all logs.
- **Structured logs only.** No `console.log('user data:', user)` — use the logger.

## Environment Variables Required

```bash
SENTRY_DSN=https://xxx@sentry.io/xxx
VITE_SENTRY_DSN=https://xxx@sentry.io/xxx  # browser (safe, public)
SENTRY_AUTH_TOKEN=xxx                       # CI only — for source map upload
SENTRY_ORG=your-org
SENTRY_PROJECT=your-project
APP_VERSION=$COMMIT_SHA                     # injected by CI
```
