# Page Types — Structural Patterns

> Every page in a SaaS product follows one of these patterns. AI agents must identify the page type before building.

## 1. Landing Page (Marketing)

**Purpose:** Convert visitors to sign-ups. First impression in 5 seconds.

### Structure (Top to Bottom)

```
┌─────────────────────────────────────────────┐
│ NAVBAR: Logo | Links | CTA                   │
├─────────────────────────────────────────────┤
│ HERO: H1 + Subtitle + CTA + Visual           │  ← Above the fold
├─────────────────────────────────────────────┤
│ SOCIAL PROOF: Logo cloud or testimonial      │
├─────────────────────────────────────────────┤
│ FEATURES: 3-column grid with icons           │
├─────────────────────────────────────────────┤
│ FEATURE DETAIL: Alternating image+text       │
├─────────────────────────────────────────────┤
│ TESTIMONIALS: Carousel or grid               │
├─────────────────────────────────────────────┤
│ PRICING: 3-tier table                        │
├─────────────────────────────────────────────┤
│ FAQ: Accordion                               │
├─────────────────────────────────────────────┤
│ CTA SECTION: Final conversion push           │
├─────────────────────────────────────────────┤
│ FOOTER: Links, social, legal                 │
└─────────────────────────────────────────────┘
```

### Hero Section Rules

- **H1:** 6-12 words. Clear value proposition, NOT your tagline.
- **Subtitle:** 1-2 sentences. What it does, who it's for.
- **CTA:** Primary button (`Get Started` / `Start Free`) + secondary (`Book Demo` / `Watch Video`)
- **Visual:** Product screenshot, animated demo, or abstract visual (Magic UI components)
- **Background:** Subtle gradient, dot grid, or animated pattern. Never busy.
- **Above the fold:** ALL critical content visible without scrolling on 1080p.

### Section Spacing

- **Desktop:** `py-24` (96px) between major sections
- **Mobile:** `py-16` (64px) between major sections
- **Container:** `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`

### Conversion Principles

1. **One CTA per section.** Don't compete for attention.
2. **Show the product.** Screenshots > illustrations > abstract.
3. **Social proof early.** Logos or testimonial within first scroll.
4. **Pricing visible.** Don't hide pricing — it increases trust.
5. **Reduce friction.** "Start Free" > "Sign Up" > "Create Account"

### Landing Page Components

- **Magic UI:** `AnimatedGridPattern`, `Marquee`, `BorderBeam`, `NumberTicker`
- **shadcn blocks:** `hero-1` through `hero-8`, `pricing-1`, `faq-1`, `testimonial-1`
- **Aceternity UI:** `BackgroundGradient`, `Spotlight`, `TextGenerateEffect`

## 2. Admin Dashboard

**Purpose:** Data overview + action center. The "home" of the app.

### Structure

```
┌────────┬────────────────────────────────────┐
│        │ TOPBAR: Search | Notifications | User │
│ SIDEBAR├────────────────────────────────────┤
│        │ PAGE HEADER: Title + Description + Actions │
│ - Nav  ├────────────────────────────────────┤
│ - Nav  │ KPI ROW: 3-4 metric cards           │
│ - Nav  ├────────────────────────────────────┤
│ - Nav  │ MAIN CHART: Primary visualization   │
│        ├────────────────────────────────────┤
│        │ SECONDARY: Table | List | Calendar  │
└────────┴────────────────────────────────────┘
```

### Dashboard Anatomy

1. **Sidebar** — Primary navigation. Collapsible. Icons + labels. Active state.
2. **Topbar** — Global search (Cmd+K), notifications, user menu. Sticky.
3. **Page Header** — Title, description, primary action button. Consistent across all pages.
4. **KPI Cards** — 3-4 metrics. Number + label + trend indicator (+12% vs last period).
5. **Primary Chart** — Line/area/bar. Time-series. Theme-aware colors (`chart-1` through `chart-5`).
6. **Secondary Content** — Data table, activity feed, or task list.

### Dashboard UX Rules

- **Default state matters.** Choose sensible defaults for date range, filters, and visible columns.
- **Prioritize warnings.** Surface alerts and anomalies above routine data.
- **Group related data.** Charts about revenue go together, charts about users go separately.
- **Drill-down pattern.** Overview → click → drawer or detail page.
- **Loading state:** Skeleton the entire dashboard structure, not just a spinner.
- **Empty state:** Show onboarding CTA when no data exists yet.

### Data Table Rules (from Pencil & Paper research)

- **Text:** Left-align. Headers match column alignment.
- **Numbers:** Right-align. Use `tabular-nums`. Decimal alignment.
- **Dates:** Left-align (qualitative, not quantitative).
- **Row division:** Hairline borders (1px, `border-border`). Avoid zebra stripes — conflicts with hover/selected states.
- **Vertical alignment:** Center for ≤3 lines. Top for >3 lines.
- **Column management:** Freeze first column on horizontal scroll. Allow hide/reorder.
- **Density toggle:** Let users switch comfortable/compact.
- **Row actions:** Use a dropdown menu on hover or a dedicated actions column.
- **Multi-select:** Checkbox column + bulk action bar that appears when >1 selected.
- **Pagination:** Show "Showing 1-10 of 234" + page controls. Infinite scroll for feeds, pagination for tables.
- **Empty table:** "No results" message + CTA to add or adjust filters.
- **Loading table:** Skeleton rows matching column structure.

## 3. Authentication Pages

**Purpose:** Frictionless entry. Every field here is a conversion barrier.

### Login

```
┌───────────────────────────┐
│ LOGO                      │
│                           │
│ Welcome back              │
│ Enter your credentials    │
│                           │
│ [Email input]             │
│ [Password input]    [Forgot?] │
│ [Sign in →]               │
│                           │
│ ── or ──                  │
│ [Continue with Google]    │
│ [Continue with GitHub]    │
│                           │
│ Don't have an account?    │
│ Sign up                   │
└───────────────────────────┘
```

### Auth UX Rules

- **Center the form.** `max-w-sm mx-auto` on a centered card.
- **Social login first** (if available) — reduces friction. OAuth > email/password.
- **Show password toggle** — eye icon to reveal.
- **Inline validation** — validate on blur, not on every keystroke.
- **Clear error messages** — "Email not found" not "Error 404".
- **No unnecessary fields** — name, company, etc. can come later.
- **2FA:** Code input with auto-advance (`InputOTP`).
- **Post-login:** Redirect to intended page, not generic dashboard.
- **Loading state:** Button shows spinner, disable all inputs.

## 4. Settings Pages

**Purpose:** Configuration. Users come here with a specific goal.

### Structure

```
┌────────┬────────────────────────────────────┐
│        │ SETTINGS: Profile                   │
│ SETTINGS├────────────────────────────────────┤
│ SIDEBAR│ [Avatar]                            │
│        │ [Name input]                        │
│ - Prof │ [Email input]                       │
│ - Team │ [Bio textarea]                      │
│ - Bill │                                     │
│ - Notif│ [Save changes]                      │
│ - API  │                                     │
└────────┴────────────────────────────────────┘
```

### Settings UX Rules

- **Settings sidebar** — Section navigation (Profile, Team, Billing, Notifications, API).
- **One section at a time** — Don't cram everything on one page.
- **Save pattern:** Sticky save bar at bottom OR auto-save with toast confirmation.
- **Danger zone** — Destructive actions (delete account, transfer ownership) in a clearly marked `AlertDialog`.
- **Toggle labels** — Always show what the toggle does, not just the switch.
- **Form grouping** — Group related fields with section headers.
- **Unsaved changes** — Warn before navigation away from unsaved form.

## 5. List/Collection Pages

**Purpose:** Browse, search, filter, and act on multiple items.

### Structure

```
┌────────────────────────────────────┐
│ PAGE HEADER: Title + [Create]       │
├────────────────────────────────────┤
│ SEARCH BAR + FILTERS                │
├────────────────────────────────────┤
│ TABLE / CARD GRID / LIST            │
│  - Sortable columns                  │
│  - Row actions                       │
│  - Pagination                        │
├────────────────────────────────────┤
│ "Showing 1-10 of 234"               │
└────────────────────────────────────┘
```

## 6. Detail Pages

**Purpose:** Deep view of a single entity.

### Structure

```
┌────────────────────────────────────┐
│ BREADCRUMB: Home > Items > Item #42 │
├────────────────────────────────────┤
│ HEADER: Title + Status badge + Actions │
├────────────────────────────────────┤
│ TABS: Overview | Activity | Settings │
├────────────────────────────────────┤
│ TAB CONTENT                         │
│  - Key-value pairs                  │
│  - Related entities                 │
│  - Activity timeline                │
└────────────────────────────────────┘
```

## Responsive Breakpoints

| Breakpoint | Width | Target |
|---|---|---|
| `sm` | 640px | Large phones, small tablets |
| `md` | 768px | Tablets |
| `lg` | 1024px | Small laptops |
| `xl` | 1280px | Desktops |
| `2xl` | 1536px | Large monitors |

### Mobile-First Rules

1. **Start at mobile.** Design for 375px first, then enhance.
2. **Sidebar → Drawer.** On mobile, sidebar becomes a slide-in drawer.
3. **Data table → Cards.** On mobile, tables become stacked cards.
4. **Topbar collapses.** Menu icon appears, links hide.
5. **Forms stack.** Side-by-side inputs become stacked on mobile.
6. **Touch targets.** Minimum 44x44px for all interactive elements.
