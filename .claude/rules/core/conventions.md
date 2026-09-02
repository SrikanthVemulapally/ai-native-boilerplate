# Code Conventions
> Always loaded. Consistency is the cheapest quality you can buy.

---

## Naming Conventions

### Files
| Type | Convention | Example |
|------|-----------|---------|
| React components | `PascalCase.tsx` | `UserCard.tsx` |
| Hooks | `camelCase.ts` (prefix `use`) | `useUser.ts` |
| Utilities | `camelCase.ts` | `formatDate.ts` |
| Constants | `camelCase.ts` | `apiEndpoints.ts` |
| Types/Schemas | `PascalCase.ts` | `UserSchema.ts` |
| Routes (TanStack) | `route-name.tsx` or `_layout.tsx` | `users.$id.tsx` |
| Tests | `<file>.test.ts` | `UserCard.test.tsx` |
| Styles | `<component>.css` (if needed) | `UserCard.css` |
| Config | `kebab-case.json` | `boilerplate.config.json` |

### Variables & Functions
```typescript
// ✅ Variables: camelCase, descriptive
const userPermissions = await getPermissions(userId);
const isLoading = true;           // booleans: is/has/can/should prefix
const hasAccess = true;
const shouldRedirect = false;

// ✅ Functions: camelCase, verb-first
async function createUser() {}     // verb + noun
function validateInput() {}        // verb + noun
function formatCurrency() {}       // verb + noun

// ✅ Constants: SCREAMING_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = '/api/v1';
const SECONDS_PER_DAY = 86400;

// ✅ Types/Interfaces: PascalCase
type User = { id: string; email: string; };
interface PostRepository { findById(id: string): Promise<Post>; }

// ✅ Enums: PascalCase type, camelCase values
enum SubscriptionStatus {
  active = 'active',
  trialing = 'trialing',
  canceled = 'canceled',
}
```

### Database
- Tables: `snake_case`, plural (`users`, `posts`, `subscription_events`)
- Columns: `snake_case` (`created_at`, `user_id`, `is_active`)
- Foreign keys: `<table_singular>_id` (`user_id`, `post_id`)
- Indexes: `<table>_<columns>_idx` (`users_email_idx`)
- Booleans: `is_` or `has_` prefix (`is_active`, `has_paid`)

### API
- Routes: kebab-case (`/api/v1/user-profiles/:id`)
- Query params: camelCase (`?sortBy=createdAt&pageSize=20`)
- Request/response body: camelCase (`{ userId, createdAt }`)
- Webhook event types: `<domain>.<action>` (`user.created`, `payment.failed`)

---

## Error Handling Standards

### Error Classes
```typescript
// Base class — all custom errors extend this
export class AppError extends Error {
  constructor(
    public code: string,      // machine-readable: 'USER_NOT_FOUND'
    public statusCode: number, // HTTP status: 404
    public details?: unknown,  // additional context (Zod errors, etc.)
  ) {
    super(code);
    this.name = this.constructor.name;
  }
}

// Specific errors
export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource.toUpperCase()}_NOT_FOUND`, 404, { resource, id });
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Authentication required') {
    super('UNAUTHORIZED', 401, { message });
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Insufficient permissions') {
    super('FORBIDDEN', 403, { message });
  }
}

export class ValidationError extends AppError {
  constructor(details: ZodError) {
    super('VALIDATION_ERROR', 400, details.flatten());
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super('CONFLICT', 409, { message });
  }
}
```

### Error Response Shape (consistent across all endpoints)
```typescript
// Error
{
  error: {
    code: string,        // 'NOT_FOUND' | 'VALIDATION_ERROR' | ...
    message: string,     // human-readable, safe to show users
    details?: unknown,   // field-level errors, Zod flatten, etc.
    requestId?: string,  // for support tracing
  }
}
```

### Error Handling Rules
- **Never swallow errors.** `catch (e) {}` is forbidden. At minimum, log the error.
- **Catch at the boundary.** Route handlers catch errors and convert to appropriate HTTP response.
- **Throw typed errors.** Service layer throws `AppError` subclasses. Route handler catches and formats.
- **User messages are safe.** Error messages in responses must be safe to show to users. No stack traces, no internal paths, no SQL.
- **Log the full error server-side.** The logged error includes stack trace, request ID, user ID, full context.
- **No error code drift.** Error codes are defined once, used everywhere. No ad-hoc string codes.

### Global Error Handler
```typescript
// In route setup
app.onError((err, c) => {
  const requestId = c.get('requestId');

  if (err instanceof AppError) {
    return c.json({ error: { code: err.code, message: err.message, details: err.details, requestId } }, err.statusCode);
  }

  // Unexpected error — log full detail, return generic message
  logger.error({ event: 'unhandled_error', requestId, error: err.message, stack: err.stack });
  return c.json({ error: { code: 'INTERNAL_ERROR', message: 'Something went wrong', requestId } }, 500);
});
```

---

## Logging Standards

### Structured Log Format
Every log entry MUST be a JSON object with these fields:
```typescript
{
  event: string,         // 'user.created' | 'payment.failed' | 'api.request'
  level: 'error' | 'warn' | 'info' | 'debug',
  timestamp: string,     // ISO 8601
  requestId?: string,    // for tracing
  userId?: string,       // if authenticated
  orgId?: string,        // if applicable
  duration_ms?: number,  // for performance events
  [key: string]: unknown // event-specific fields
}
```

### What to Log at Each Level

**error** — Something broke that affects users:
```typescript
logger.error({ event: 'payment.failed', userId, stripeError: err.code, amount });
```

**warn** — Something unexpected but handled:
```typescript
logger.warn({ event: 'rate_limit.exceeded', userId, endpoint, count });
```

**info** — Significant business events:
```typescript
logger.info({ event: 'user.created', userId, orgId, source: 'web' });
```

**debug** — Development only, never in production:
```typescript
logger.debug({ event: 'db.query', table: 'users', duration_ms: 12, rows: 1 });
```

### Log Scrubbing
- Emails → `***@domain.com`
- Phone numbers → `***-***-1234`
- Names → `[REDACTED]`
- Token/password fields → never logged at all
- Implement scrubbing at the logger level, not at each call site

---

## Async Patterns

### Promise.all for Independent Operations (MANDATORY)

When multiple `await` calls are independent — none depends on the other's result — use `Promise.all`. **Never await independent operations sequentially.**

```typescript
// ✅ CORRECT — parallel, fast
const [user, orders, products] = await Promise.all([
  getUser(id),
  getOrders(id),
  getProducts(),
]);

// ❌ WRONG — sequential for no reason (3× slower)
const user = await getUser(id);
const orders = await getOrders(id);      // waits for user unnecessarily
const products = await getProducts();    // waits for orders unnecessarily
```

**Before writing sequential awaits, ask:** "Does call #2 need call #1's result?" If no → `Promise.all`.

Sequential IS correct when there's a real dependency:
```typescript
// ✅ Sequential because user.id is needed
const user = await getUser(email);
const orders = await getOrders(user.id); // genuinely needs user first
```

### Graceful Shutdown (MANDATORY for all entry points)

Every Node.js entry point MUST handle termination signals. Never let the process exit without closing connections.

```typescript
// At the bottom of every server/worker entry point
process.on('SIGTERM', () => shutdown(0));
process.on('SIGINT', () => shutdown(0));
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  shutdown(1);
});
process.on('unhandledRejection', (reason) => {
  console.error('Unhandled Rejection:', reason);
  shutdown(1);
});

async function shutdown(code: number) {
  // 1. Stop accepting new requests
  // 2. Drain in-flight requests (timeout: 30s)
  // 3. Close DB connections
  // 4. Close queue connections
  // 5. Exit
  process.exit(code);
}
```

**NEVER call `process.exit()` directly** — always go through `shutdown()` so connections close cleanly.

## Import/Export Conventions

### Order
```typescript
// 1. Node/platform builtins
import { createHash } from 'node:crypto';

// 2. External packages
import { z } from 'zod';
import { eq } from 'drizzle-orm';

// 3. Internal packages (monorepo)
import { UserSchema } from '@workspace/shared';

// 4. Internal modules (relative)
import { UserService } from '../services/user-service';
import { Button } from '../components/ui/Button';

// 5. Types (type-only import)
import type { User } from '../types';
```

### Rules
- `import type` for type-only imports (smaller bundles, clearer intent).
- Named exports only. No default exports (except route components where TanStack requires it).
- No barrel files (`index.ts` that re-exports everything) — they break tree-shaking and hide dependencies.
- No circular imports. If you need a circular import → the architecture is wrong. Redesign.

---

## Code Review Checklist

### For AI Agents Reviewing Their Own Work (Pre-Commit)
- [ ] Does the code match the spec? (Check `docs/SPEC.md` feature section)
- [ ] Does the code match the architecture? (Check `docs/ARCHITECTURE.md`)
- [ ] Are all inputs validated with Zod?
- [ ] Are all errors handled with typed errors?
- [ ] Are all database queries scoped by userId where applicable?
- [ ] Are there tests for happy path + at least one error case?
- [ ] No `any` types?
- [ ] No `console.log`? (Use logger)
- [ ] No commented-out code?
- [ ] No magic numbers?
- [ ] Naming follows conventions?
- [ ] Files < 200 lines? (If > 500 → must justify in PR description)
- [ ] No new dependencies without justification in DECISIONS.md?
- [ ] Docs updated (ARCHITECTURE, SPEC, DECISIONS, CHANGELOG)?

### For AI Agents Reviewing Another Agent's PR
- [ ] Does the PR description explain WHY, not just WHAT?
- [ ] Does the diff only touch files related to the stated feature?
- [ ] Are there any "drive-by" changes to unrelated files?
- [ ] Are tests meaningful? (Not just `expect(true).toBe(true)`)
- [ ] Are error messages user-safe?
- [ ] Are there any security concerns? (Auth bypass, SQL injection, XSS)
- [ ] Are there any performance concerns? (N+1 queries, unbounded lists)
- [ ] Is the code consistent with existing patterns in the codebase?
- [ ] Are there any hidden breaking changes?

---

## File Organization Rules

### Size Limits
| Type | Soft Limit | Hard Limit | Action if Exceeded |
|------|-----------|-----------|-------------------|
| Component | 150 lines | 300 lines | Extract sub-components |
| Hook | 50 lines | 100 lines | Split into smaller hooks |
| Service function | 100 lines | 200 lines | Extract helper functions |
| Route handler | 30 lines | 50 lines | Move logic to service |
| Test file | 200 lines | 500 lines | Split by test group |
| Config file | — | — | No limit, but document |

### Module Boundaries
- A module exports a clear interface. Internal implementation is private.
- No reaching into another module's internals. Use the exported API only.
- A module has one responsibility. If it does two things → split it.
- Modules depend on interfaces, not implementations (for service-to-service).

---

## Comment Standards

### When to Comment
- **WHY, not WHAT.** The code already shows what it does.
- **Non-obvious business logic.** "We charge tax only for EU customers because..."
- **Workarounds.** "Cloudflare D1 doesn't support X, so we use Y instead"
- **TODOs with tickets.** `// TODO(TICKET-123): refactor when API v2 lands`
- **Safety comments.** `// This is intentionally not await'd — fire-and-forget`

### When NOT to Comment
- What the code does (read the code)
- Obvious type information (read the types)
- "This function does X" above a function named `doX`
- Commented-out code (delete it — git remembers)
- JSDoc on internal functions that are self-documenting

### Format
```typescript
// Single line for brief notes

// Multi-line for detailed explanations.
// Wrap at 80 chars.
// Use plain English, no jargon that a junior wouldn't understand.

/**
 * JSDoc for exported APIs only.
 * @param userId - The user's UUIDv7 identifier
 * @returns The user's active subscription, or null if none
 * @throws {NotFoundError} if user doesn't exist
 */
```
