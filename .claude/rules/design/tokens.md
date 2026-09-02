# Design Tokens — Three-Tier Architecture

> **Token system based on W3C Design Token Community Group format.**
> shadcn/ui uses CSS custom properties (variables) for theming. This is the single source of truth.

## The Three Tiers

### Tier 1: Primitive Tokens (Raw Values)

The raw material — colors, sizes, durations. These are the only place raw values appear.

```css
/* colors — use OKLCH for perceptual uniformity */
--blue-500: oklch(0.623 0.214 259);
--gray-100: oklch(0.968 0.001 286);
--gray-900: oklch(0.210 0.006 285);

/* spacing — 4px base unit */
--space-1: 0.25rem;  /* 4px */
--space-2: 0.5rem;   /* 8px */
--space-3: 0.75rem;  /* 12px */
--space-4: 1rem;     /* 16px */
--space-6: 1.5rem;   /* 24px */
--space-8: 2rem;     /* 32px */
--space-12: 3rem;    /* 48px */
--space-16: 4rem;    /* 64px */

/* radius — single source of truth */
--radius: 0.625rem;  /* 10px — shadcn default */

/* durations */
--duration-fast: 150ms;
--duration-normal: 250ms;
--duration-slow: 400ms;
```

**AI agents NEVER reference primitive tokens directly in components.** They exist only to define semantic tokens.

### Tier 2: Semantic Tokens (Meaning)

These map primitives to meaning. This is what components reference.

```css
:root {
  /* surfaces */
  --background: oklch(1 0 0);           /* page background */
  --foreground: oklch(0.145 0 0);       /* default text */
  --card: oklch(1 0 0);                 /* elevated surface */
  --card-foreground: oklch(0.145 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.145 0 0);

  /* actions */
  --primary: oklch(0.205 0 0);          /* main CTA */
  --primary-foreground: oklch(0.985 0 0);
  --secondary: oklch(0.97 0 0);         /* secondary action */
  --secondary-foreground: oklch(0.205 0 0);
  --accent: oklch(0.97 0 0);            /* hover/focus surface */
  --accent-foreground: oklch(0.205 0 0);
  --destructive: oklch(0.577 0.245 27); /* danger */
  --destructive-foreground: oklch(0.985 0 0);

  /* subtle */
  --muted: oklch(0.97 0 0);             /* subdued surface */
  --muted-foreground: oklch(0.556 0 0); /* helper text */
  --border: oklch(0.922 0 0);           /* dividers */
  --input: oklch(0.922 0 0);            /* form borders */
  --ring: oklch(0.708 0 0);             /* focus rings */

  /* charts */
  --chart-1: oklch(0.646 0.222 41);
  --chart-2: oklch(0.6 0.118 184);
  --chart-3: oklch(0.398 0.07 227);
  --chart-4: oklch(0.828 0.189 84);
  --chart-5: oklch(0.769 0.188 70);

  /* sidebar */
  --sidebar: oklch(0.985 0 0);
  --sidebar-foreground: oklch(0.145 0 0);
  --sidebar-primary: oklch(0.205 0 0);
  --sidebar-primary-foreground: oklch(0.985 0 0);
  --sidebar-accent: oklch(0.97 0 0);
  --sidebar-accent-foreground: oklch(0.205 0 0);
  --sidebar-border: oklch(0.922 0 0);
  --sidebar-ring: oklch(0.708 0 0);
}

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  --card: oklch(0.205 0 0);
  --card-foreground: oklch(0.985 0 0);
  --popover: oklch(0.205 0 0);
  --popover-foreground: oklch(0.985 0 0);
  --primary: oklch(0.922 0 0);
  --primary-foreground: oklch(0.205 0 0);
  --secondary: oklch(0.269 0 0);
  --secondary-foreground: oklch(0.985 0 0);
  --accent: oklch(0.269 0 0);
  --accent-foreground: oklch(0.985 0 0);
  --destructive: oklch(0.704 0.191 22);
  --border: oklch(1 0 0 / 10%);
  --input: oklch(1 0 0 / 15%);
  --ring: oklch(0.556 0 0);
  /* chart + sidebar tokens similarly inverted */
}
```

### Tier 3: Component Tokens (Overrides)

Optional per-component overrides. Only created when a component needs a value that differs from its semantic default.

```css
/* Only create these if the default doesn't work */
--button-primary-bg: var(--primary);
--button-primary-hover: var(--primary); /* with brightness filter */
--badge-success-bg: oklch(0.86 0.15 150);
```

## Tailwind Integration

shadcn/ui maps semantic tokens to Tailwind utilities via `@theme inline`:

```css
@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
  --color-border: var(--border);
  /* ... all tokens mapped ... */
  
  --radius-sm: calc(var(--radius) * 0.6);
  --radius-md: calc(var(--radius) * 0.8);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) * 1.4);
  --radius-2xl: calc(var(--radius) * 1.8);
  --radius-3xl: calc(var(--radius) * 2.2);
}
```

**This means AI agents use:**
```jsx
// ✅ CORRECT — semantic tokens
<div className="bg-background text-foreground border-border">
<Card className="bg-card text-card-foreground">
<Button variant="primary">

// ❌ WRONG — hardcoded values
<div style={{ background: "#fff", color: "#000" }}>
<div className="bg-white text-black">
<Card className="bg-[#f8f9fa]">
```

## Theme Switching

Dark mode works by overriding the same tokens inside `.dark`:

```tsx
// ThemeProvider wraps the app
<html className={theme === 'dark' ? 'dark' : ''}>
```

**Rules:**
- Every token must have a `:root` and `.dark` variant
- Never use `dark:` Tailwind prefix for semantic colors — the token already handles it
- Use `dark:` only for one-off adjustments that don't warrant a token

## Adding Custom Tokens

To add a new semantic token (e.g., `warning`):

1. Define in `:root` and `.dark`
2. Map in `@theme inline`
3. Use in components: `bg-warning text-warning-foreground`

```css
:root {
  --warning: oklch(0.84 0.16 84);
  --warning-foreground: oklch(0.28 0.07 46);
}
.dark {
  --warning: oklch(0.41 0.11 46);
  --warning-foreground: oklch(0.99 0.02 95);
}
@theme inline {
  --color-warning: var(--warning);
  --color-warning-foreground: var(--warning-foreground);
}
```

## OKLCH — Why and How

shadcn/ui v4 uses OKLCH color space. Why:

- **Perceptual uniformity** — a 0.1 lightness change looks the same across hues
- **Better dark mode** — inverting lightness preserves perceived contrast
- **Wider gamut** — can express P3 colors that sRGB hex cannot

**AI agents should use OKLCH for any custom color.** Format: `oklch(L C H)` where:
- L = lightness (0-1)
- C = chroma (0-0.4 typically)
- H = hue (0-360 degrees)

## Token Naming Convention

```
<category>-<variant>[-<state>]

--primary              → surface
--primary-foreground   → text on that surface
--primary-hover        → hover state (if needed)
--sidebar-primary      → scoped to sidebar
--chart-1              → indexed series
```

**Never invent inconsistent names.** Follow the `surface` / `surface-foreground` pairing pattern.
