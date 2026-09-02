# Typography — Font System, Scale, Pairings

> Typography is 60% of a SaaS UI. It affects readability, personality, trust, and performance.

## Font Stack

### Body Font (Mandatory)

**Inter** — the SaaS industry standard. Proven at 14px across all devices, optimized for screen rendering, tabular figures for data.

```css
font-family: 'Inter', system-ui, -apple-system, sans-serif;
font-feature-settings: 'cv11', 'ss01';  /* alternate styles */
font-variant-numeric: tabular-nums;      /* aligned numbers in tables */
```

### Heading Font (Configurable)

Choose based on brand personality:

| Personality | Font | Pair With | Best For |
|---|---|---|---|
| Modern/Clean | Inter (same) | Inter body | Default — zero-config |
| Modern SaaS | Plus Jakarta Sans | Inter body | Most SaaS products |
| Techy/Geometric | Space Grotesk | DM Sans body | Developer tools, AI products |
| Friendly | Outfit | Inter body | Consumer-facing, onboarding |
| Premium/Editorial | Fraunces | Source Sans body | High-end, editorial, luxury |
| Bold/Geometric | DM Sans (same) | DM Sans body | Clean, confident brands |

**Default if unspecified:** Inter for everything. This is a valid, production-grade choice.

### Monospace Font

**JetBrains Mono** or **Geist Mono** — for code blocks, terminal output, technical data.

```css
font-family: 'JetBrains Mono', 'Fira Code', monospace;
```

### Font Loading Rules

1. **Self-host fonts** — use `next/font`, `@fontsource`, or `@vitejs/plugin-fonts`. Never load from Google Fonts CDN (external request, privacy, performance).
2. **`font-display: swap`** — always. Prevents FOIT (flash of invisible text).
3. **Limit weights** — max 3 weights per font:
   - Regular (400) — body text
   - Medium (500) — UI labels, buttons
   - Semibold (600) — headings (Bold/700 optional for marketing)
4. **Subset to latin** — unless targeting CJK/Arabic, don't load full character sets.

## Type Scale

Use a consistent modular scale. Ratio: 1.2x (minor third) or 1.25x (major third).

| Token | Size | Line Height | Weight | Usage |
|---|---|---|---|---|
| `text-xs` | 12px | 16px | 400 | Captions, timestamps, badges |
| `text-sm` | 14px | 20px | 400 | Secondary text, table cells, form labels |
| `text-base` | 16px | 24px | 400 | Body text, default |
| `text-lg` | 18px | 28px | 400 | Subheadings, card titles |
| `text-xl` | 20px | 28px | 600 | Section titles, dialog headers |
| `text-2xl` | 24px | 32px | 600 | Page titles |
| `text-3xl` | 30px | 36px | 700 | Hero headings (app) |
| `text-4xl` | 36px | 40px | 700 | Marketing headings |
| `text-5xl` | 48px | 1.1 | 700 | Landing page hero |
| `text-6xl` | 60px | 1.1 | 700 | Landing page mega hero |

**Tailwind classes already implement this scale.** Use `text-sm`, `text-base`, `text-lg`, etc. Never use arbitrary `text-[15px]`.

## Line Height

| Context | Ratio | Tailwind |
|---|---|---|
| Body text | 1.5 | `leading-normal` |
| Headings | 1.2-1.3 | `leading-tight` |
| Display/hero | 1.1 | `leading-none` or `leading-[1.1]` |
| UI labels | 1.4 | `leading-snug` |

## Letter Spacing (Tracking)

| Context | Value | Tailwind |
|---|---|---|
| Body text | -0.01em | `tracking-tight` |
| Headings | -0.02em | `tracking-tighter` |
| Uppercase labels | 0.05em | `tracking-wide` |
| Display/hero | -0.03em | `tracking-tighter` |

## Font Pairing Rules

1. **Contrast, not conflict.** Pair fonts that are visually different (serif + sans, geometric + humanist). Two similar sans-serifs look like a mistake.
2. **Match x-heights.** Fonts appearing near each other should look the same size at the same `font-size`.
3. **Share an era.** Fonts from the same design era pair naturally.
4. **One font is fine.** Inter alone is a production-grade choice. Don't force two fonts if one works.

## Number Formatting

- **Tables and data:** `tabular-nums` (Tailwind: `tabular-nums`) — aligns columns
- **Currency:** Use `Intl.NumberFormat` — never manually format
- **Large numbers:** Compact notation for dashboards (`1.2K`, `3.4M`)

```tsx
// ✅ Correct
new Intl.NumberFormat('en', { notation: 'compact' }).format(1200000) // "1.2M"
new Intl.NumberFormat('en', { style: 'currency', currency: 'USD' }).format(99.99) // "$99.99"

// ❌ Wrong
`${(1200000 / 1000000).toFixed(1)}M`  // manual = bugs
`$${price}`                            // no localization
```

## Content Width (Measure)

**Optimal reading line length: 45-75 characters.**

| Context | Max Width | Tailwind |
|---|---|---|
| Body text | 65ch | `max-w-prose` or `max-w-[65ch]` |
| Article/blog | 70ch | `max-w-[70ch]` |
| Dashboard content | none | full width |
| Forms | 480px | `max-w-md` |
| Dialogs | 512px | `max-w-lg` |

## Anti-Patterns

- ❌ Loading >3 font weights — performance killer
- ❌ Using Google Fonts CDN link — use self-hosted
- ❌ Hardcoding `font-size` in inline styles — use Tailwind scale
- ❌ Mixing >2 font families — visual chaos
- ❌ Using `text-center` for body text — reduces readability
- ❌ Low contrast text (gray-400 on white) — fails WCAG
- ❌ Using non-tabular numbers in data tables — misaligned columns
