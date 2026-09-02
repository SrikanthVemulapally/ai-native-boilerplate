# Design System — [App Name]

> This document captures all project-specific design decisions.
> AI agents must read this before building ANY UI.
> Update it when design decisions change. Never let it drift from reality.
> Full design rules live in `.claude/rules/design/` — this file is the PROJECT LAYER on top.

**Last updated:** YYYY-MM-DD

---

## 1. Brand Identity

### Product Name
[App Name]

### Tagline
[1-line value proposition]

### Personality
Choose 3 adjectives that describe how the product should FEEL:
- [ ] Professional / Trustworthy
- [ ] Playful / Friendly
- [ ] Minimal / Focused
- [ ] Bold / Confident
- [ ] Warm / Approachable
- [ ] Technical / Precise

Chosen: _______________, _______________, _______________

---

## 2. Color Decisions

### Base Palette
From `boilerplate.config.json → designSystem.baseColor`:

| Token | Value | Usage |
|---|---|---|
| `--background` | (auto from base) | Page backgrounds |
| `--foreground` | (auto from base) | Default text |
| `--primary` | **[YOUR COLOR HERE]** | CTAs, active states, brand accent |
| `--primary-foreground` | **[YOUR COLOR HERE]** | Text on primary |

### Primary Color Rationale
**Color chosen:** _______________
**Why:** [Why does this color fit the brand? What emotion does it convey?]
**OKLCH value:** `oklch(_ _ _)`

### Status Colors
| Status | Token | Light Mode OKLCH | Dark Mode OKLCH |
|---|---|---|---|
| Success | `--success` | `oklch(0.65 0.15 150)` | `oklch(0.45 0.12 150)` |
| Warning | `--warning` | `oklch(0.84 0.16 84)` | `oklch(0.55 0.14 84)` |
| Info | `--info` | `oklch(0.65 0.15 240)` | `oklch(0.55 0.14 240)` |

*Override if brand requires different status colors.*

---

## 3. Typography Decisions

### Fonts
| Role | Font | Weight(s) | Source |
|---|---|---|---|
| Heading | [Font name] | 600, 700 | [@fontsource/...] |
| Body | Inter | 400, 500 | [@fontsource/inter] |
| Mono | JetBrains Mono | 400 | [@fontsource/jetbrains-mono] |

### Font Rationale
**Heading font:** _______________
**Why this pairing:** [Why does this font complement the brand?]

---

## 4. Radius & Spacing

| Token | Value | Feel |
|---|---|---|
| `--radius` | **[0.5rem / 0.625rem / 0.75rem]** | [Sharp / Default / Rounded] |

**Chosen radius:** _______________ rem
**Why:** [Sharp = professional/technical, Rounded = friendly/consumer]

---

## 5. Component Decisions

### Custom Components Built
Track every component built beyond the shadcn/ui defaults:

| Component | Location | Why Built (not in shadcn) | Status |
|---|---|---|---|
| (example) PricingCard | `src/components/features/PricingCard.tsx` | Needs animated gradient border | ✅ Done |
| | | | |

### shadcn Components Customized
Track every shadcn component that was modified beyond tokens:

| Component | What Changed | Why |
|---|---|---|
| (example) Button | Added loading spinner variant | Need consistent loading state |
| | | |

---

## 6. Page-Specific Decisions

### Landing Page
- **Hero background:** [gradient / pattern / image / video]
- **Hero heading font size:** [text-5xl / text-6xl on desktop]
- **Primary CTA text:** "_______________"
- **Secondary CTA text:** "_______________"
- **Social proof type:** [logo cloud / testimonials / stats]
- **Feature section layout:** [3-column grid / alternating / cards]

### Dashboard
- **Sidebar width:** [240px / 256px / 280px]
- **Sidebar style:** [solid / ghost / inset]
- **Topbar height:** [56px / 64px]
- **Default date range:** [last 7 days / last 30 days / this month]
- **KPI card count:** [3 / 4]
- **Primary chart type:** [line / area / bar]

### Authentication
- **Auth provider shown first:** [email / Google / GitHub]
- **Show password strength meter:** [yes / no]
- **2FA enabled:** [yes / no — which type: TOTP / SMS]

---

## 7. Motion & Animation Decisions

### Animation Profile
- **Speed:** [Fast (tech tools) / Normal (default) / Relaxed (consumer)]
- **Easing preference:** [Spring / Ease-out / Custom]
- **Page transitions:** [Fade only / Fade + slide up / None]
- **Stagger on lists:** [Yes / No]

---

## 8. Dark Mode

- **Default theme:** [light / dark / system]
- **Toggle visible:** [Yes — in navbar / Yes — in settings only / No (system only)]
- **Dark mode tested:** [ ] Light mode tested: [ ]

---

## 9. Icon Set

**Primary:** Lucide React (all projects — do not mix sets)
**Additional allowed:** [Heroicons for specific patterns / None]
**Custom icons:** stored in `src/components/icons/`

---

## 10. Design Decisions Log

Record every significant design decision here. Same format as DECISIONS.md.

```
## YYYY-MM-DD — [Design Decision Title]
**Context:** Why was this decision needed?
**Decision:** What was decided?
**Alternatives considered:** What else was evaluated?
**Consequences:** What does this enable / constrain going forward?
```

---

## 11. Known Design Debt

| Issue | Impact | Priority |
|---|---|---|
| (example) Mobile nav not implemented | Mobile users can't navigate | HIGH |
| | | |

---

*Update this file when ANY design decision changes.*
*AI agents: read this file before building any UI. The decisions here override general guidelines.*
