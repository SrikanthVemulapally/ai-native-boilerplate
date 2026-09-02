# Color — Palette, Psychology, Dark Mode, Contrast

> Color is the fastest communication medium in UI. It signals brand, hierarchy, status, and emotion before a single word is read.

## Color Psychology for SaaS

| Color | Psychology | Best For | Examples |
|---|---|---|---|
| **Blue** | Trust, stability, competence | Enterprise, finance, B2B | Stripe, Linear, LinkedIn |
| **Indigo/Violet** | Creativity, innovation, premium | AI tools, dev tools, design | Linear, Vercel, Framer |
| **Green** | Growth, success, health | Analytics, health, productivity | GitHub, Spotify, Notion |
| **Orange** | Energy, enthusiasm, affordability | Marketing, consumer, SMB | HubSpot, SoundCloud |
| **Red** | Urgency, passion, danger (context) | Alerts, destructive actions | — |
| **Teal** | Balance, clarity, modernity | SaaS dashboards, data tools | — |
| **Neutral/Black** | Sophistication, minimalism | Premium, developer-focused | Vercel, shadcn, Linear |

**Choose your primary based on:**
1. **Industry expectation** — finance = blue, health = green, AI = violet/indigo
2. **Brand personality** — playful = orange, serious = blue, premium = black
3. **Competitor differentiation** — if everyone in your space is blue, be violet

## The shadcn/ui Color System

shadcn uses **semantic token pairs**: every surface has a `-foreground` companion for text/icons on it.

| Token Pair | Controls | Used In |
|---|---|---|
| `background` / `foreground` | Page background + default text | App shell, page sections |
| `card` / `card-foreground` | Elevated surfaces | Cards, panels, settings |
| `popover` / `popover-foreground` | Floating surfaces | Dropdowns, popovers, menus |
| `primary` / `primary-foreground` | Brand color, main CTAs | Buttons, active states, badges |
| `secondary` / `secondary-foreground` | Lower-emphasis actions | Secondary buttons |
| `muted` / `muted-foreground` | Subtle surfaces + helper text | Descriptions, empty states |
| `accent` / `accent-foreground` | Interactive hover/focus | Ghost buttons, hovered rows |
| `destructive` / `destructive-foreground` | Danger actions | Delete buttons, errors |
| `border` | All dividers/separators | Cards, tables, layout dividers |
| `input` | Form control borders | Inputs, selects, textareas |
| `ring` | Focus rings | All focusable controls |

## Base Color Palettes

shadcn/ui provides 7 base color schemes. Choose one in `components.json`:

| Base | Vibe | Light Mode | Dark Mode |
|---|---|---|---|
| **Neutral** | Default, clean, versatile | Pure grays | Deep grays |
| **Stone** | Warm, organic | Warm grays | Warm dark |
| **Zinc** | Cool, modern | Cool grays | Cool dark |
| **Mauve** | Soft, feminine | Purple-tinted gray | Purple-tinted dark |
| **Olive** | Natural, earthy | Green-tinted gray | Green-tinted dark |
| **Mist** | Airy, calm | Blue-tinted gray | Blue-tinted dark |
| **Taupe** | Refined, editorial | Brown-tinted gray | Brown-tinted dark |

**Default: Neutral.** Change only if the brand demands warmth or a specific tint.

## Customizing Primary Color

To set a brand color (e.g., indigo), override `--primary` and `--primary-foreground`:

```css
:root {
  --primary: oklch(0.488 0.243 264);       /* indigo */
  --primary-foreground: oklch(0.985 0 0);  /* white */
}
.dark {
  --primary: oklch(0.6 0.2 264);           /* lighter indigo for dark */
  --primary-foreground: oklch(0.145 0 0);  /* dark text on light primary */
}
```

**Rules for brand color:**
- Light mode: primary should have lightness 0.3-0.6 for sufficient contrast with white text
- Dark mode: primary should have lightness 0.6-0.8 for visibility on dark surfaces
- Always test with a contrast checker — minimum 4.5:1 for normal text, 3:1 for large text

## Status Colors

Beyond the core tokens, define status colors for semantic meaning:

```css
:root {
  --success: oklch(0.65 0.15 150);
  --success-foreground: oklch(0.985 0 0);
  --warning: oklch(0.84 0.16 84);
  --warning-foreground: oklch(0.28 0.07 46);
  --info: oklch(0.65 0.15 240);
  --info-foreground: oklch(0.985 0 0);
  --destructive: oklch(0.577 0.245 27);
  --destructive-foreground: oklch(0.985 0 0);
}
```

| Status | When to Use | Component |
|---|---|---|
| Success | Action completed, positive state | Toast, badge, inline confirmation |
| Warning | Non-blocking issue, caution | Banner, badge, tooltip |
| Info | Neutral information | Tooltip, banner, badge |
| Destructive | Permanent/irreversible action | Delete dialog, danger zone |

## Dark Mode — Mandatory

**Every page must work in both light and dark themes.** No exceptions.

### Implementation

```tsx
// 1. ThemeProvider at app root
import { ThemeProvider } from '@/components/theme-provider'

<ThemeProvider defaultTheme="system" enableSystem>
  <App />
</ThemeProvider>

// 2. Toggling — save preference to localStorage
// 3. CSS — override tokens in .dark selector
```

### Dark Mode Rules

1. **Don't just invert.** Dark mode is NOT white-on-black. Surfaces are layered grays:
   - Background: `oklch(0.145 0 0)` — deep, not pure black
   - Card: `oklch(0.205 0 0)` — slightly lighter
   - Popover: `oklch(0.205 0 0)` — matches card

2. **Reduce chroma in dark mode.** Saturated colors vibrate on dark backgrounds. Reduce chroma by ~30%.

3. **Borders become translucent.** Use `oklch(1 0 0 / 10%)` instead of solid grays.

4. **Shadows are less effective.** Rely on surface elevation (lightness difference) more than shadows.

5. **Test both themes.** Switch and review every component in both modes.

## Contrast Requirements (WCAG 2.2 AA — Minimum)

| Element | Ratio | Standard |
|---|---|---|
| Body text (< 18px) | 4.5:1 | AA |
| Large text (≥ 18px or 14px bold) | 3:1 | AA |
| UI components (borders, icons) | 3:1 | AA |
| Disabled text | Exempt | — |
| Focus indicator | 3:1 against adjacent | AA |

**For AAA compliance:** 7:1 for body text, 4.5:1 for large text.

### Common Contrast Failures

- `text-muted-foreground` on `bg-background` — verify it passes 4.5:1
- `placeholder` text — often too light, use `text-muted-foreground`
- White text on light primary — check primary isn't too light
- Status badges with insufficient contrast between badge and text

## Color Usage Rules for AI Agents

1. **Never use raw hex/rgb values.** Always use semantic tokens.
2. **Never use Tailwind's color palette directly** (`bg-blue-500`, `text-red-600`). Use semantic tokens (`bg-primary`, `text-destructive`).
3. **Status colors need tokens.** Define `--success`, `--warning`, `--info` and use `bg-success`, `text-warning`, etc.
4. **One primary color.** Don't use multiple brand colors as primary. Pick one.
5. **Color is not the only signal.** Never rely on color alone — always add icon, text, or shape for status.
6. **Test dark mode.** Every component, every time. If it looks wrong in dark mode, fix the token, not the component.
