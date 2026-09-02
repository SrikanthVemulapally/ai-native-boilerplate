# Web Performance — Core Web Vitals & Budgets

> Performance is a feature. Slow = lost users. Google uses Core Web Vitals as a ranking signal.
> Every AI-generated UI must be measured against these budgets before shipping.

---

## Core Web Vitals (2025)

The three metrics Google uses for ranking. All three must pass to avoid SEO penalty.

| Metric | Good | Needs Work | Poor | What It Measures |
|---|---|---|---|---|
| **LCP** (Largest Contentful Paint) | < 2.5s | 2.5–4s | > 4s | Load speed — when main content is visible |
| **INP** (Interaction to Next Paint) | < 200ms | 200–500ms | > 500ms | Responsiveness — delay from interaction to visual response |
| **CLS** (Cumulative Layout Shift) | < 0.1 | 0.1–0.25 | > 0.25 | Visual stability — unexpected layout shifts |

**INP replaced FID (First Input Delay) in March 2024.** FID is dead. Test INP.

---

## LCP — Largest Contentful Paint

The LCP element is almost always one of:
- Hero image
- Hero heading text
- Above-the-fold video thumbnail

### LCP Rules

```html
<!-- ✅ LCP image — must load immediately -->
<img
  src="/hero.webp"
  alt="Hero"
  width="1200" height="630"
  loading="eager"           <!-- never lazy for LCP element -->
  fetchpriority="high"      <!-- browser hint: load this first -->
  decoding="sync"           <!-- don't defer decoding -->
/>

<!-- ✅ Preload LCP image in <head> -->
<link rel="preload" as="image" href="/hero.webp"
      imagesrcset="/hero-400.webp 400w, /hero-800.webp 800w, /hero-1200.webp 1200w"
      imagesizes="100vw" />
```

**LCP anti-patterns:**
- `loading="lazy"` on the hero image — adds 100-300ms delay
- LCP image loaded via CSS `background-image` — browser can't preload it
- LCP image behind JavaScript — React renders AFTER HTML parse
- No `width`/`height` on LCP image — CLS penalty stacks with LCP penalty
- Font blocking LCP text — use `font-display: optional` or `swap`

### LCP Cloudflare Edge Rules
```typescript
// ✅ Use Cache-Control for hero images — cache at edge, instant repeat visits
// workers/ingest/index.ts
response.headers.set('Cache-Control', 'public, max-age=31536000, immutable') // hashed assets
response.headers.set('Cache-Control', 'public, max-age=3600, stale-while-revalidate=86400') // content
```

---

## INP — Interaction to Next Paint

INP measures time from user interaction (click, keypress, tap) to the next frame painted.
The #1 cause: long tasks on the main thread blocking rendering.

### INP Rules

```typescript
// ❌ BAD — heavy computation on main thread blocks interaction response
function handleClick() {
  const result = expensiveComputation(data) // blocks for 500ms
  setResult(result)
}

// ✅ GOOD — defer heavy work, respond immediately
function handleClick() {
  setLoading(true)           // immediate visual feedback
  setTimeout(() => {         // yield to browser, then compute
    const result = expensiveComputation(data)
    setResult(result)
    setLoading(false)
  }, 0)
}

// ✅ BETTER — use Web Worker for CPU-intensive work
const worker = new Worker('/workers/compute.js')
function handleClick() {
  setLoading(true)
  worker.postMessage({ data })
  worker.onmessage = (e) => {
    setResult(e.data.result)
    setLoading(false)
  }
}
```

**INP anti-patterns:**
- Synchronous `fetch()` equivalents (blocking)
- Large React re-renders on every keystroke — use `useDeferredValue`
- Heavy `useEffect` on component mount
- Unvirtualized lists (rendering 1000+ DOM nodes)
- Synchronous `localStorage` in event handlers

### React INP Optimizations
```tsx
import { useDeferredValue, startTransition } from 'react'

// ✅ Defer non-urgent updates
const [query, setQuery] = useState('')
const deferredQuery = useDeferredValue(query)

// ✅ Mark state updates as non-urgent transitions
function handleSearch(value: string) {
  setQuery(value)                                    // immediate
  startTransition(() => setSearchResults(filter(value))) // deferred
}

// ✅ Virtualize long lists — react-virtual or @tanstack/virtual
import { useVirtualizer } from '@tanstack/react-virtual'
// Never render more than ~50 DOM nodes in a list
```

---

## CLS — Cumulative Layout Shift

Every unexpected visual shift adds to CLS. Common causes and fixes:

| Cause | Score Impact | Fix |
|---|---|---|
| Images without dimensions | High | Always `width` + `height` |
| Ads/embeds without reserved space | High | Fixed height container before load |
| Dynamic content insertion above existing | High | Insert below, or reserve space |
| Web fonts causing FOUT | Medium | `font-display: optional` + size-adjust |
| Animations that move layout | Medium | Use `transform`, never `top`/`left`/`margin` |
| Late-loading images in feed | Medium | Fixed-height skeleton cards |

```tsx
// ✅ Skeleton matches exact dimensions of loaded content
function ArticleCardSkeleton() {
  return (
    <div className="rounded-lg border p-4 space-y-3">
      <Skeleton className="h-48 w-full rounded-md" />  {/* image placeholder */}
      <Skeleton className="h-5 w-3/4" />               {/* title */}
      <Skeleton className="h-4 w-1/2" />               {/* meta */}
      <div className="space-y-2">
        <Skeleton className="h-3 w-full" />            {/* body lines */}
        <Skeleton className="h-3 w-5/6" />
      </div>
    </div>
  )
}
```

---

## Bundle Size Budgets

| Bundle | Budget | Tool |
|---|---|---|
| Initial JS (gzipped) | **< 150KB** | `bundlesize` or `size-limit` |
| Per-route JS chunk | **< 50KB** | Vite bundle analysis |
| CSS total | **< 50KB** | `tailwind --minify` |
| Total page weight (3G) | **< 500KB** | Lighthouse |
| Fonts total | **< 100KB** | `font-display: optional` |
| Images (single page) | **< 500KB** | WebP + responsive srcset |

### Bundle Analysis
```bash
# Vite bundle visualization
pnpm add -D rollup-plugin-visualizer
# Add to vite.config.ts, run build, open stats.html

# Size limit CI check
pnpm add -D size-limit @size-limit/preset-app
# .size-limit.json: [{ "path": "dist/**/*.js", "limit": "150 KB" }]
# CI: pnpm size-limit
```

### Code Splitting Rules
```typescript
// ✅ Route-level code splitting (TanStack Router auto-splits)
// Each route = one chunk loaded on demand

// ✅ Heavy component splitting
const Chart = lazy(() => import('./Chart'))           // recharts is large
const DataTable = lazy(() => import('./DataTable'))   // data grids are large
const MDEditor = lazy(() => import('./MDEditor'))     // editors are very large

// ✅ Feature splitting
const AdminPanel = lazy(() => import('./admin/Panel'))

// ❌ NEVER lazy-load above-the-fold content (adds latency to LCP)
```

### Tree Shaking Rules
```typescript
// ❌ BAD — imports entire lodash (~70KB)
import _ from 'lodash'
const result = _.groupBy(data, 'category')

// ✅ GOOD — imports only groupBy (~3KB)
import groupBy from 'lodash/groupBy'

// ✅ BEST — use native where possible (zero KB)
const result = Object.groupBy(data, item => item.category)

// ❌ BAD — imports all of date-fns
import * as dateFns from 'date-fns'

// ✅ GOOD — named imports, tree-shaken
import { format, parseISO, differenceInDays } from 'date-fns'
```

---

## Resource Hints

Add these in `<head>` to speed up critical resources:

```html
<!-- ✅ Preconnect to critical third-party origins (DNS + TLS) -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="preconnect" href="https://api.yourapp.com" />

<!-- ✅ Preload critical resources (fonts, LCP image, critical CSS) -->
<link rel="preload" as="font" href="/fonts/inter-var.woff2"
      type="font/woff2" crossorigin />
<link rel="preload" as="image" href="/hero.webp" />

<!-- ✅ Prefetch next likely navigation (after user signs in) -->
<link rel="prefetch" href="/dashboard" />
<link rel="prefetch" href="/dashboard/projects" />

<!-- ✅ DNS prefetch for origins you'll connect to (lower priority than preconnect) -->
<link rel="dns-prefetch" href="https://cdn.yourapp.com" />
```

**Rules:**
- `preconnect` — only use for origins you'll definitely use in <1s. Max 3-4.
- `preload` — only for resources used by the current page. Wrong preloads waste bandwidth.
- `prefetch` — guess the user's next navigation. Use after login to prefetch dashboard.
- Never preload resources not used on the current page — wastes bandwidth, hurts mobile users.

---

## Font Performance

```css
/* ✅ Self-host all fonts — never load from Google Fonts in production */
/* Use fontsource or download manually, host under /public/fonts/ */

@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-var.woff2') format('woff2');
  font-weight: 100 900;          /* Variable font — one file for all weights */
  font-display: optional;         /* No FOUT, no layout shift */
  font-style: normal;
  unicode-range: U+0000-00FF;    /* Subset to Latin — smaller file */
}
```

**`font-display` values:**
| Value | Behavior | Use When |
|---|---|---|
| `optional` | Instant fallback, font loaded for next visit | Best for CLS |
| `swap` | Brief invisible text, then font swap | Acceptable FOUT |
| `block` | 3s invisible, then swap | Only for icon fonts |
| `fallback` | 100ms block, 3s swap window | Compromise |

**Font rules:**
- Use variable fonts (one file: `inter-var.woff2`) — not separate files per weight
- Subset to required unicode ranges — Latin-only saves 40-60% file size
- Preload the main font file with `<link rel="preload">`
- `font-display: optional` everywhere — eliminates FOUT and CLS

---

## Script Loading Strategy

```html
<!-- ✅ Critical inline scripts (theme detection — prevents FOUC) -->
<script>
  // Inline only: ≤300 bytes, critical path
  const theme = localStorage.getItem('theme') ?? 'system'
  document.documentElement.classList.add(theme)
</script>

<!-- ✅ Module scripts — deferred by default, non-blocking -->
<script type="module" src="/main.js"></script>

<!-- ✅ Third-party scripts — always defer -->
<script defer src="https://analytics.example.com/script.js"></script>

<!-- ✅ Non-critical third-party — load after page interactive -->
<script>
  window.addEventListener('load', () => {
    const script = document.createElement('script')
    script.src = 'https://widget.intercom.io/widget/xxx'
    document.head.appendChild(script)
  })
</script>

<!-- ❌ NEVER — render-blocking scripts in <head> -->
<script src="/app.js"></script>
```

---

## Image Optimization Pipeline

```typescript
// vite.config.ts — automatic image optimization
import { imagetools } from 'vite-imagetools'

export default {
  plugins: [
    imagetools({
      defaultDirectives: new URLSearchParams({
        format: 'webp',
        quality: '85',
        as: 'picture',
      })
    })
  ]
}

// Usage in component
import heroSrc from './hero.jpg?w=400;800;1200&format=webp&as=picture'
```

**Image format priority:** AVIF > WebP > JPEG/PNG
**Quality settings:** Hero images: 85%, thumbnails: 70%, icons: PNG/SVG

---

## Cloudflare-Specific Performance

```typescript
// ✅ Use Cloudflare Image Resizing
// Automatic format conversion + resize at edge
const imageUrl = `https://yourapp.com/cdn-cgi/image/width=800,format=auto,quality=85/${originalUrl}`

// ✅ Use KV for edge caching of API responses
// workers/api/index.ts
const cached = await env.CACHE_KV.get(cacheKey)
if (cached) return new Response(cached, { headers: { 'X-Cache': 'HIT' } })

const data = await db.query(...)
await env.CACHE_KV.put(cacheKey, JSON.stringify(data), { expirationTtl: 300 })

// ✅ Use Workers Cache API
const cache = caches.default
const cachedResponse = await cache.match(request)
if (cachedResponse) return cachedResponse
```

---

## Performance Testing

```bash
# Lighthouse CI — run on every PR
pnpm add -D @lhci/cli
# .lighthouserc.js: assert LCP < 2500, INP < 200, CLS < 0.1

# Core Web Vitals in browser
import { onLCP, onINP, onCLS } from 'web-vitals'
onLCP(metric => console.log('LCP:', metric.value))
onINP(metric => console.log('INP:', metric.value))
onCLS(metric => console.log('CLS:', metric.value))

# Bundle analysis
pnpm build --mode analyze  # generates stats.html
```

**Performance checklist:**
- [ ] LCP < 2.5s (Lighthouse mobile throttled)
- [ ] INP < 200ms (measured with web-vitals library)
- [ ] CLS < 0.1 (all images have dimensions, no font flash)
- [ ] Bundle < 150KB gzipped (size-limit CI check)
- [ ] No render-blocking scripts in `<head>`
- [ ] LCP image has `fetchpriority="high"` and `loading="eager"`
- [ ] All other images have `loading="lazy"` and `decoding="async"`
- [ ] Fonts self-hosted with `font-display: optional`
- [ ] Resource hints for critical third-party origins
- [ ] Code-split at route level (no single large bundle)
