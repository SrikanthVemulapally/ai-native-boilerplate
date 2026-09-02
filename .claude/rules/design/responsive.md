# Responsive Design — Authoritative Rules

> Responsive is not "add some breakpoints." It's a system. Every layout decision must work at every viewport.
> Mobile-first always. Design at 375px first, enhance up. Never the reverse.

---

## Fluid Typography (clamp-based)

Never use fixed font sizes. Use `clamp()` so text scales fluidly between viewport sizes — no media query jumps.

```css
/* ✅ Fluid type scale — scales between mobile min and desktop max */
:root {
  --text-xs:   clamp(0.694rem, 0.67vw + 0.57rem,  0.8rem);
  --text-sm:   clamp(0.833rem, 0.8vw + 0.69rem,   0.9rem);
  --text-base: clamp(1rem,     1vw + 0.75rem,      1.125rem);
  --text-lg:   clamp(1.2rem,   1.2vw + 0.9rem,     1.375rem);
  --text-xl:   clamp(1.44rem,  1.5vw + 1rem,       1.75rem);
  --text-2xl:  clamp(1.728rem, 2vw + 1.1rem,       2.25rem);
  --text-3xl:  clamp(2.074rem, 2.5vw + 1.2rem,     3rem);
  --text-4xl:  clamp(2.488rem, 3vw + 1.3rem,       3.75rem);
  --text-5xl:  clamp(2.986rem, 4vw + 1.4rem,       4.5rem);
  --text-6xl:  clamp(3.583rem, 5vw + 1.5rem,       6rem);
}
```

**Rules:**
- Never write `text-4xl` without verifying it doesn't overflow on mobile
- Hero headings: always fluid — `clamp()` directly or via Tailwind's responsive prefixes
- Line-height tightens as font size grows: use `leading-tight` for headings, `leading-relaxed` for body

---

## Fluid Spacing

Spacing should also scale fluidly for larger sections:

```css
/* Section padding — tight on mobile, generous on desktop */
.section {
  padding-block: clamp(3rem, 6vw, 6rem);   /* 48px → 96px */
  padding-inline: clamp(1rem, 5vw, 8rem);  /* 16px → 128px */
}
```

Tailwind utility:
```html
<!-- ✅ Responsive section padding -->
<section class="py-12 sm:py-16 lg:py-24 px-4 sm:px-6 lg:px-8">
```

---

## Container System

Use a consistent container system — never raw `width`:

```html
<!-- ✅ Standard container -->
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

<!-- ✅ Narrow content (prose, auth forms) -->
<div class="max-w-2xl mx-auto px-4 sm:px-6">

<!-- ✅ Full bleed with contained content -->
<section class="w-full bg-muted">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
```

**Container max-widths:**
| Name | Max Width | Use |
|---|---|---|
| `xs` | 20rem (320px) | Cards, small modals |
| `sm` | 24rem (384px) | Auth forms |
| `md` | 28rem (448px) | Medium modals |
| `lg` | 32rem (512px) | Wide forms |
| `xl` | 36rem (576px) | Content sections |
| `2xl` | 42rem (672px) | Blog posts, prose |
| `4xl` | 56rem (896px) | Dashboard content |
| `6xl` | 72rem (1152px) | Wide dashboards |
| `7xl` | 80rem (1280px) | Full-width layouts |

---

## CSS Grid — Responsive Patterns

### Auto-responsive grid (no media queries needed)
```css
/* ✅ Cards that auto-wrap at minimum 280px */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
}

/* ✅ Fixed columns with responsive breakpoints */
.feature-grid {
  display: grid;
  grid-template-columns: 1fr;                    /* mobile: 1 col */
}
@media (min-width: 768px) {
  .feature-grid { grid-template-columns: 1fr 1fr; }      /* tablet: 2 cols */
}
@media (min-width: 1024px) {
  .feature-grid { grid-template-columns: 1fr 1fr 1fr; }  /* desktop: 3 cols */
}
```

Tailwind:
```html
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
```

### Dashboard grid
```html
<!-- ✅ KPI cards — 2 on mobile, 4 on desktop -->
<div class="grid grid-cols-2 lg:grid-cols-4 gap-4">

<!-- ✅ Main + sidebar — stacked mobile, side-by-side desktop -->
<div class="grid grid-cols-1 lg:grid-cols-[1fr_320px] gap-6">
```

### Subgrid (modern — use for aligned nested content)
```css
.card-grid > .card {
  display: grid;
  grid-template-rows: subgrid;
  grid-row: span 3; /* header, content, footer always aligned */
}
```

---

## Container Queries — Component-Level Responsive Design

Container queries let components respond to their *container* size, not the viewport. This is how you build truly reusable responsive components.

```css
/* Define a containment context */
.card-container {
  container-type: inline-size;
  container-name: card;
}

/* Component responds to its container, not the viewport */
@container card (min-width: 400px) {
  .card {
    display: grid;
    grid-template-columns: 120px 1fr;
  }
}

@container card (min-width: 600px) {
  .card-actions {
    flex-direction: row;
  }
}
```

Tailwind v4 (built-in):
```html
<!-- @container class makes the element a container -->
<div class="@container">
  <div class="flex-col @md:flex-row">
```

**When to use container queries:**
- Components used in sidebars AND main content (size differs)
- Card components (appear in 1, 2, 3 column grids)
- Widgets that embed in different contexts
- Any component where breakpoints don't match the component's actual size

---

## Responsive Navigation Patterns

### Decision tree for navigation type

```
How many top-level nav items?
  → ≤5 items AND no subitems
    → Mobile: bottom tab bar (iOS/Android native feel)
    → Desktop: horizontal top nav

  → ≤5 items WITH subitems OR 6-10 items
    → Mobile: hamburger → full-screen or slide-in drawer
    → Desktop: horizontal nav with dropdowns (NavigationMenu)

  → 10+ items OR complex hierarchy
    → Mobile: hamburger → full-screen drawer with accordion groups
    → Desktop: sidebar (collapsible to icon-only)
    → This is your admin app pattern
```

### Top navigation (marketing/landing)
```html
<!-- Mobile: hamburger + full-width drawer -->
<nav class="sticky top-0 z-50 bg-background/95 backdrop-blur border-b border-border">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
    <!-- Logo always visible -->
    <Logo />
    
    <!-- Desktop links -->
    <div class="hidden md:flex items-center gap-6">
      <NavLinks />
      <CTAButton />
    </div>
    
    <!-- Mobile: hamburger only -->
    <Sheet>
      <SheetTrigger class="md:hidden"><Menu /></SheetTrigger>
      <SheetContent side="right">
        <MobileNavLinks />
      </SheetContent>
    </Sheet>
  </div>
</nav>
```

### Bottom tab bar (mobile-first app)
```html
<!-- Only on mobile, hidden on desktop -->
<nav class="fixed bottom-0 left-0 right-0 z-50 md:hidden
            bg-background border-t border-border
            pb-[env(safe-area-inset-bottom)]">
  <div class="grid grid-cols-5 h-16">
    <TabItem icon={Home} label="Home" />
    <TabItem icon={Search} label="Search" />
    <TabItem icon={Plus} label="Create" primary />
    <TabItem icon={Bell} label="Alerts" />
    <TabItem icon={User} label="Profile" />
  </div>
</nav>

<!-- Compensate for bottom nav height on mobile -->
<main class="pb-16 md:pb-0">
```

### Sidebar (admin app)
```
Mobile (<1024px):
  → Hidden by default
  → Hamburger in topbar opens Sheet (slide-in from left)
  → Full-height, full-width on mobile
  → Overlay backdrop

Desktop (≥1024px):
  → Always visible, fixed left
  → Collapsible to icon-only (saves space on laptops)
  → Collapse state persisted in localStorage
```

---

## Responsive Tables

Tables are the hardest responsive pattern. Choose a strategy per use case:

### Strategy 1: Horizontal scroll (complex data tables)
```html
<div class="overflow-x-auto -mx-4 sm:mx-0">
  <table class="min-w-full">
    <!-- Full table, scrollable on mobile -->
  </table>
</div>
```
Use when: Many columns with numeric data, all columns equally important

### Strategy 2: Card transform (record lists)
```html
<!-- Desktop: table rows -->
<div class="hidden md:block">
  <DataTable columns={columns} data={data} />
</div>

<!-- Mobile: card list -->
<div class="md:hidden space-y-3">
  {data.map(row => <RecordCard key={row.id} record={row} />)}
</div>
```
Use when: Each row is a distinct entity (user, project, order)

### Strategy 3: Priority columns (medium complexity)
```html
<!-- Hide less important columns on mobile via Tailwind -->
<th class="hidden sm:table-cell">Created At</th>
<th class="hidden lg:table-cell">Last Modified</th>
<!-- Always show: Name, Status, Actions -->
```
Use when: 5-8 columns, 2-3 are always needed, rest are supplementary

---

## Cumulative Layout Shift (CLS) Prevention

CLS is the #1 AI-generated UI bug. Claude builds UIs that shift on load because it forgets to reserve space.

**Rule: Always reserve space for async-loaded content.**

### Images — always specify dimensions
```html
<!-- ❌ NO — causes layout shift as image loads -->
<img src="/hero.jpg" alt="Hero" />

<!-- ✅ YES — height reserved before image loads -->
<img src="/hero.jpg" alt="Hero" width="1200" height="630"
     class="w-full h-auto aspect-video object-cover" />
```

### Aspect ratio containers
```html
<!-- ✅ Reserve space for video/iframe before it loads -->
<div class="aspect-video w-full">
  <iframe class="w-full h-full" src="..." />
</div>

<!-- ✅ Square product images -->
<div class="aspect-square overflow-hidden rounded-lg">
  <img class="w-full h-full object-cover" src="..." />
</div>
```

### Fonts — prevent FOUT/FOIT
```css
/* ✅ font-display: optional — no layout shift, instant fallback */
@font-face {
  font-family: 'Inter';
  font-display: optional; /* Best for CLS */
  src: url('/fonts/inter.woff2') format('woff2');
}

/* ✅ Size-adjust to match fallback metrics exactly */
@font-face {
  font-family: 'InterFallback';
  src: local('Arial');
  size-adjust: 107%;  /* Matches Inter's metrics */
  ascent-override: 90%;
}
```

### Dynamic content — always set min-height
```html
<!-- ❌ NO — toast/banner appearing causes shift -->
<div>
  {showBanner && <Banner />}
  <main>...</main>
</div>

<!-- ✅ YES — reserve space, use AnimatePresence for entry -->
<div class="min-h-[48px]">
  <AnimatePresence>{showBanner && <Banner />}</AnimatePresence>
</div>
```

### Skeleton loaders — match exact dimensions
```tsx
// ❌ WRONG — generic skeleton doesn't match content height
<Skeleton className="h-4 w-full" />

// ✅ CORRECT — skeleton matches the actual content shape
function UserCardSkeleton() {
  return (
    <div className="flex items-center gap-3 p-4">
      <Skeleton className="h-10 w-10 rounded-full" />   {/* avatar */}
      <div className="space-y-2">
        <Skeleton className="h-4 w-32" />                 {/* name */}
        <Skeleton className="h-3 w-24" />                 {/* email */}
      </div>
    </div>
  )
}
```

---

## Responsive Images

```html
<!-- ✅ Art direction — different image for mobile vs desktop -->
<picture>
  <source media="(min-width: 1024px)" srcset="/hero-desktop.webp" />
  <source media="(min-width: 640px)"  srcset="/hero-tablet.webp" />
  <img src="/hero-mobile.webp" alt="Hero"
       width="390" height="844"
       class="w-full h-auto"
       loading="eager"
       fetchpriority="high" />  <!-- LCP image: eager + high priority -->
</picture>

<!-- ✅ Responsive srcset (same image, different sizes) -->
<img
  src="/product-800.webp"
  srcset="/product-400.webp 400w,
          /product-800.webp 800w,
          /product-1200.webp 1200w"
  sizes="(max-width: 640px) 100vw,
         (max-width: 1024px) 50vw,
         400px"
  alt="Product"
  width="800" height="600"
  loading="lazy"
/>
```

**Image rules:**
- LCP image (hero): `loading="eager"` + `fetchpriority="high"`
- All other images: `loading="lazy"` + `decoding="async"`
- Always `width` + `height` attributes — prevents CLS
- Always WebP with fallback JPEG/PNG
- Use `object-fit: cover` in containers, never stretch

---

## Responsive Design Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `height: 100vh` | Breaks on iOS Safari with address bar | Use `100dvh` |
| Fixed pixel widths | Overflow on small screens | Use max-width + percentages |
| Absolute font sizes | Doesn't scale with user settings | Use rem/em/clamp |
| `overflow: hidden` on body | Breaks iOS scroll | Use on specific containers |
| Hover-only interactions | Touch devices can't hover | Always provide tap equivalent |
| `!important` to override Tailwind | Specificity war | Fix the class order or use a variant |
| Desktop-first breakpoints | Mobile is an afterthought | Mobile-first always |
| Fixed navbar without safe area | Hidden under notch on iPhone | `padding-top: env(safe-area-inset-top)` |
| Images without dimensions | CLS on every page load | Always specify width + height |
| JS-calculated responsive layout | Causes reflow, slow | Use CSS Grid/Flexbox + container queries |
| `word-break: break-all` | Breaks words mid-syllable | Use `overflow-wrap: break-word` |

---

## Responsive Testing Checklist

Before marking any page done:
- [ ] Viewport tested: 375px (iPhone SE), 390px (iPhone 14), 768px (iPad), 1280px (desktop), 1920px (wide)
- [ ] No horizontal scroll at any width ≥ 320px
- [ ] No text overflow at any width
- [ ] All touch targets ≥ 44×44px
- [ ] Images don't shift on load (CLS = 0)
- [ ] Navigation works at every breakpoint
- [ ] Data tables have a mobile strategy (scroll/card/priority)
- [ ] Forms are single-column on mobile
- [ ] Fluid typography — no text too large or too small at extremes
- [ ] Container queries used for components in variable-width contexts
- [ ] Safe area insets applied (top, bottom)
