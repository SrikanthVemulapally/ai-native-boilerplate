# Feature Rules: SEO
> Loaded when: features.seo=true

## Every Page Must Have

```typescript
// TanStack Start — route meta
export const Route = createFileRoute('/blog/$slug')({
  head: ({ loaderData }) => ({
    title: `${loaderData.post.title} | MyApp`,
    meta: [
      { name: 'description', content: loaderData.post.excerpt },
      { property: 'og:title', content: loaderData.post.title },
      { property: 'og:description', content: loaderData.post.excerpt },
      { property: 'og:image', content: loaderData.post.og_image },
      { property: 'og:type', content: 'article' },
      { name: 'twitter:card', content: 'summary_large_image' },
    ],
  }),
})
```

## Required Files

```
apps/web/app/
  components/
    seo/
      MetaTags.tsx      ← Reusable meta tag component
      JsonLd.tsx        ← Structured data component
  lib/
    seo.ts             ← Title/description generators, OG image helpers
  routes/
    sitemap.xml.ts     ← Dynamic sitemap generation
    robots.txt.ts      ← Robots.txt route
```

## Structured Data (JSON-LD)

Required on: home page, blog posts, product pages, pricing page.

```typescript
// Minimal — Organization schema (home page)
const orgSchema = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: 'Your Company',
  url: 'https://yourapp.com',
  logo: 'https://yourapp.com/logo.png',
}

// SaaS product — SoftwareApplication schema
const appSchema = {
  '@context': 'https://schema.org',
  '@type': 'SoftwareApplication',
  name: 'Your App',
  operatingSystem: 'Web',
  applicationCategory: 'BusinessApplication',
  offers: { '@type': 'Offer', price: '29', priceCurrency: 'USD' },
}
```

## Performance = SEO

- **Core Web Vitals targets:** LCP < 2.5s, FID < 100ms, CLS < 0.1
- **Images:** always have `width` + `height`. Lazy load below fold. WebP format.
- **No render-blocking resources.** CSS inlined for critical path. JS deferred.
- **Server-side rendering mandatory for all public pages.** No CSR-only public routes.

## Sitemap

```typescript
// routes/sitemap.xml.ts
export const Route = createFileRoute('/sitemap.xml')({
  loader: async () => getAllPublicPages(),
  component: () => null,
  headers: () => ({ 'Content-Type': 'application/xml' }),
})
```

## Rules

- **Every page has a unique `<title>` and `<meta description>`.**
- **Title format:** `Page Name | Brand` (50-60 chars). Never truncate brand.
- **Description:** 120-158 chars. Action-oriented. Includes primary keyword.
- **Canonical tags on all pages.** Prevents duplicate content.
- **`robots.txt` disallows `/admin`, `/api`, `/internal`.**
- **Sitemap submitted to Google Search Console** on first deploy.
- **No SEO on auth-gated pages.** `noindex` for `/dashboard`, `/settings`, etc.
- **OG images are 1200×630px.** Generated dynamically for content pages.
