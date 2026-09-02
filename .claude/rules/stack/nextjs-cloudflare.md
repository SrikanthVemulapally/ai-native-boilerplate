# Stack Rules: Next.js + Cloudflare Workers
> Loaded when: stack.frontend=nextjs AND stack.backend=cloudflare-workers

## Project Structure

```
apps/
  web/                    ← Next.js app (App Router)
    app/
      (public)/           ← Public routes
      (auth)/             ← Authenticated routes
      api/                ← API Routes (use Workers for heavy logic)
    components/
      ui/                 ← shadcn/ui components
      features/           ← Feature-specific components
    lib/
      api.ts              ← Typed fetch wrapper
      auth.ts             ← Auth utilities

workers/
  api/                    ← Main Hono worker
  queue-processor/        ← Queue consumer

packages/
  shared/                 ← Types + schemas
  db/                     ← Drizzle schema + migrations
```

## Next.js App Router Rules

- **Server Components by default.** Use `'use client'` only when you need interactivity.
- **Data fetching in Server Components or Route Handlers.** Not in useEffect.
- **Route handlers only for auth callbacks and webhooks.** All other API logic in Cloudflare Workers.
- **`loading.tsx` and `error.tsx` at every route level.**
- **`metadata` export on every page** — never dynamic `<title>` in JSX.

```typescript
// ✅ Correct — metadata export
export const metadata: Metadata = {
  title: 'Page Title | App Name',
  description: 'Page description under 160 chars',
}

// ✅ Correct — Server Component with data fetch
export default async function Page() {
  const data = await fetch('https://api.yourapp.com/v1/data', {
    headers: { Authorization: `Bearer ${getToken()}` }
  })
  return <Component data={data} />
}
```

## Cloudflare Integration

- Use Cloudflare Workers for all business logic (not Next.js API routes).
- Next.js API routes only for: NextAuth callbacks, Stripe webhooks, ISR revalidation.
- Deploy to Cloudflare Pages with `@cloudflare/next-on-pages`.

## TypeScript Rules
- Strict mode always. Same as TanStack stack.
- No `any`. Use `unknown` and narrow.
- Zod for all runtime validation.

## Differences from TanStack Stack
- No server functions (`createServerFn`) — use fetch to Workers API instead.
- Image optimization via `next/image` (built-in), not Cloudflare Images.
- Routing is file-based App Router, not TanStack Router.
- `next.config.ts` for all Next.js configuration.
