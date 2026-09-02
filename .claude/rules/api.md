# API Rules (Cloudflare Workers + Hono)

Loaded when working on API routes, workers, or queue processors.

## Route Structure
```
All API routes under: /api/v1/...
Webhook routes under: /api/webhooks/...
Health: /api/health
```
Every route is versioned from day one. No `/api/resource` — always `/api/v1/resource`.

## Request/Response Pattern
```typescript
// ✅ CORRECT — thin route handler
app.post('/api/v1/posts', authMiddleware, async (c) => {
  const body = await c.req.json();
  const input = CreatePostSchema.parse(body); // Zod — throws on invalid
  const post = await postService.create(c.var.userId, input); // service layer
  return c.json({ data: post }, 201);
});

// ✅ CORRECT — consistent error response shape
return c.json({
  error: {
    code: 'VALIDATION_ERROR',
    message: 'Invalid input',
    details: zodError.flatten()
  }
}, 400);
```

## Error Response Shape (always consistent)
```typescript
// Success
{ data: T }

// Error
{
  error: {
    code: string,     // machine-readable: 'NOT_FOUND' | 'UNAUTHORIZED' | 'VALIDATION_ERROR'
    message: string,  // human-readable
    details?: any     // Zod errors, field-level errors
  }
}
```

## Status Codes (strict)
- 200 — OK (GET success, PUT/PATCH success)
- 201 — Created (POST success that created a resource)
- 204 — No Content (DELETE success)
- 400 — Bad Request (validation error)
- 401 — Unauthorized (not authenticated)
- 403 — Forbidden (authenticated but not allowed)
- 404 — Not Found (resource doesn't exist)
- 409 — Conflict (duplicate, already exists)
- 422 — Unprocessable Entity (valid format, invalid business logic)
- 429 — Too Many Requests (rate limited)
- 500 — Internal Server Error (unexpected, log this)

## Cloudflare Workers Rules
- Every Worker has a 10ms CPU budget (unblocked by I/O await, but still a limit).
- Use `c.env` for environment bindings (D1, R2, Queue, KV).
- Never use `process.env` — use `c.env.VAR_NAME` or context bindings.
- Workers are stateless — no global mutable state.
- Queue consumers (`queue.send()`) must be idempotent — they may be retried.

## Queue / Background Processing
- Every queue message must include: `{ id, type, payload, sentAt }`.
- Consumer workers must handle duplicates (check for prior processing by `id`).
- Dead-letter queue for messages that fail 3+ times.
- Never do heavy work in the request handler — offload to queue.
