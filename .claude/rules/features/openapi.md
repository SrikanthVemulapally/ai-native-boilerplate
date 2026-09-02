# Feature Rules: OpenAPI / API Documentation
> Loaded when: variants.api.openapi=true

## Stack: Hono + Zod OpenAPI (or ts-rest)

Generate OpenAPI 3.1 specs **from code** — never write YAML by hand.
Every route's request/response types are defined in Zod first, then the spec is auto-derived.

## Architecture

```
Zod schemas (source of truth)
  → Route definitions (Hono OpenAPI or ts-rest contract)
  → OpenAPI 3.1 spec (auto-generated)
  → Swagger UI / Scalar (mounted at /docs)
  → Client SDK (optional, generated via openapi-typescript)
```

## Required Files

```
workers/api/src/
  lib/
    openapi.ts          ← OpenAPI app config + spec generation
  routes/
    [feature]/
      schemas.ts        ← Zod schemas (input + output, named)
      [route].ts        ← Routes with OpenAPI decorators

apps/web/app/ (if generating client SDK)
  lib/
    api-client.ts       ← Generated typed client
```

## Implementation Pattern (Hono + @hono/zod-openapi)

```typescript
// workers/api/src/lib/openapi.ts
import { OpenAPIHono } from '@hono/zod-openapi'

export const app = new OpenAPIHono()

// Mount Swagger UI at /docs (dev + staging only — not production)
if (process.env.ENVIRONMENT !== 'production') {
  app.doc('/openapi.json', {
    openapi: '3.1.0',
    info: {
      title: process.env.PROJECT_NAME ?? 'API',
      version: process.env.APP_VERSION ?? '0.1.0',
      description: 'Auto-generated API documentation',
    },
    servers: [
      { url: process.env.API_URL ?? 'http://localhost:8787', description: 'Current' },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  })

  app.get('/docs', swaggerUI({ url: '/openapi.json' }))
}
```

## Route Definition Pattern

```typescript
// workers/api/src/routes/posts/schemas.ts
import { z } from '@hono/zod-openapi'

export const PostSchema = z.object({
  id:        z.string().uuid().openapi({ example: '018f3b7c-...' }),
  title:     z.string().min(1).max(255).openapi({ example: 'Hello World' }),
  body:      z.string().openapi({ example: 'Post content here' }),
  authorId:  z.string().uuid(),
  createdAt: z.string().datetime(),
}).openapi('Post')

export const CreatePostSchema = z.object({
  title: z.string().min(1).max(255),
  body:  z.string().min(1),
}).openapi('CreatePost')

export const PostListSchema = z.object({
  data:  z.array(PostSchema),
  total: z.number(),
  page:  z.number(),
}).openapi('PostList')

// workers/api/src/routes/posts/list.ts
import { createRoute } from '@hono/zod-openapi'

export const listPostsRoute = createRoute({
  method: 'get',
  path: '/posts',
  tags: ['Posts'],
  summary: 'List all posts',
  security: [{ bearerAuth: [] }],
  request: {
    query: z.object({
      page:  z.coerce.number().min(1).default(1),
      limit: z.coerce.number().min(1).max(100).default(20),
    }),
  },
  responses: {
    200: {
      content: { 'application/json': { schema: PostListSchema } },
      description: 'Paginated list of posts',
    },
    401: {
      content: { 'application/json': { schema: ErrorSchema } },
      description: 'Unauthorized',
    },
  },
})

app.openapi(listPostsRoute, async (c) => {
  // Handler — types fully inferred from route definition
  const { page, limit } = c.req.valid('query')
  const user = c.get('user')
  // ...
})
```

## API Versioning

```typescript
// Version prefix — all routes under /api/v1/
const v1 = new OpenAPIHono().basePath('/api/v1')

// When breaking changes are needed:
// 1. Create /api/v2/ with the new contract
// 2. Keep /api/v1/ running with deprecation headers
// 3. Deprecation window: minimum 90 days
// 4. Log a DECISIONS.md entry for every breaking change

v1.use('*', async (c, next) => {
  await next()
  // Add deprecation notice if endpoint is deprecated
  if (DEPRECATED_ROUTES.has(c.req.path)) {
    c.header('Deprecation', 'true')
    c.header('Sunset', '2025-12-31')  // date it goes away
    c.header('Link', '</api/v2/endpoint>; rel="successor-version"')
  }
})
```

## Generating a Typed Client SDK

```bash
# Generate TypeScript client from OpenAPI spec
pnpm dlx openapi-typescript http://localhost:8787/openapi.json -o src/api-client.d.ts

# Then use with openapi-fetch (zero runtime cost, fully typed)
import createClient from 'openapi-fetch'
import type { paths } from './api-client'

const client = createClient<paths>({ baseUrl: process.env.VITE_API_URL })
const { data, error } = await client.GET('/api/v1/posts', {
  params: { query: { page: 1, limit: 20 } }
})
```

## CI: Spec Validation + Breaking Change Detection

```yaml
# .github/workflows/api.yml
- name: Generate OpenAPI spec
  run: pnpm api:generate-spec

- name: Check for breaking changes
  uses: oasislabs/openapi-diff-action@v1
  with:
    old-spec: main-openapi.json
    new-spec: openapi.json
    fail-on-breaking: true  # Breaking changes block merge
```

## Rules

- **Zod schemas are the source of truth.** Never write OpenAPI YAML directly.
- **Every schema must have an `.openapi()` name.** Anonymous schemas create ugly spec output.
- **Add examples to all schemas.** Developers reading `/docs` need real examples.
- **`/docs` is dev/staging only.** Never expose Swagger UI in production.
- **`/openapi.json` may be public in staging.** Protect it in production if the API is private.
- **Breaking changes require a version bump.** `/v1/` → `/v2/`. Log in DECISIONS.md.
- **Deprecation window: 90 days minimum.** Add `Deprecation` and `Sunset` headers immediately.
- **Generate the client SDK in CI.** Check it into the repo — never regenerate ad hoc.
- **Every route has a `summary` and `tags`.** Undocumented routes are invisible in Swagger UI.
- **Every error response is documented.** 401, 403, 404, 422, 500 at minimum.
