---
name: seo-audit
description: Audit and fix SEO — meta tags, OG, structured data, Core Web Vitals, sitemap
user-invocable: true
---

SEO audit: $ARGUMENTS

## Checklist Per Public Page

### Meta Tags
- [ ] `<title>` unique per page, 50-60 chars, includes primary keyword
- [ ] `<meta name="description">` unique per page, 150-160 chars, compelling
- [ ] `<link rel="canonical">` pointing to the correct URL

### Open Graph
- [ ] `og:title`
- [ ] `og:description`
- [ ] `og:image` (1200×630px, < 1MB)
- [ ] `og:url`
- [ ] `og:type` (website / article / product)

### Twitter Cards
- [ ] `twitter:card` (summary_large_image)
- [ ] `twitter:title`
- [ ] `twitter:description`
- [ ] `twitter:image`

### Structured Data (JSON-LD)
Required pages:
- [ ] Home → Organization schema
- [ ] Product/Pricing → Product + Offer schema
- [ ] Blog posts → Article schema
- [ ] FAQ page → FAQPage schema

### Technical
- [ ] `robots.txt` exists and is correct
- [ ] `sitemap.xml` exists and includes all public pages
- [ ] All public pages use SSR (not client-only rendering)
- [ ] `<html lang="...">` set
- [ ] Heading hierarchy: exactly one `<h1>` per page
- [ ] Images have `alt` text
- [ ] No broken links (`<a href="">`, missing `href`)

### Core Web Vitals Checks
- [ ] LCP < 2.5s (largest content paints fast — usually hero image/text)
- [ ] CLS < 0.1 (no layout shift — images have width/height)
- [ ] FID < 100ms (no blocking JS on the critical path)

## Fixes

For any item failing above:
1. Show the current state (code snippet or output)
2. Show the fix
3. Apply it surgically — don't rewrite the whole page

## Output Format

```
## SEO Audit — [page or area]

### Pages Audited
- /home — [PASS/ISSUES]
- /pricing — [PASS/ISSUES]
- ...

### Issues Found
| Priority | Page | Issue | Fix |
|---|---|---|---|
| HIGH | /pricing | Missing og:image | Add <meta property="og:image" ...> |

### Structured Data Status
[list per page]

### Sitemap Status
[current state and any missing pages]
```
