# Design System — Master Rules

> **This file is loaded when `config.features.designSystem: true` (default).**
> It @-imports the full design rule set. AI agents MUST follow these rules for ALL UI work.

## Core Philosophy

**UI/UX is everything.** A product that works but looks amateur will lose to a product that looks premium but works slightly less. First impressions are decided in 5 seconds. Every pixel matters.

## Mandatory Stack

| Layer | Technology | Why |
|---|---|---|
| **Styling** | Tailwind CSS v4 | Utility-first, token-mapped, AI-native |
| **Components** | shadcn/ui (Radix + Tailwind) | Open code, AI-ready, accessible, composable |
| **Animations** | Framer Motion (Motion) | Declarative, spring physics, 60fps |
| **Icons** | Lucide React | Tree-shakeable, consistent, pairs with shadcn |
| **Fonts** | Inter (body) + variable heading | See typography.md |
| **Charts** | Recharts (via shadcn chart) | Theme-aware, composable |

**Do NOT use:** Material UI, Chakra, Ant Design, Bootstrap, or any black-box component library. These fight Tailwind, bloat bundles, and AI tools don't natively generate them.

## The 10 Nielsen Heuristics — Non-Negotiable

Every UI decision must satisfy these. They've held for 30+ years unchanged.

1. **Visibility of system status** — Always show what's happening. Loading states, progress, toasts, optimistic UI.
2. **Match between system and real world** — Use user's language, not internal jargon. Follow real-world conventions.
3. **User control and freedom** — Undo, cancel, escape. Users need emergency exits.
4. **Consistency and standards** — Same action = same component. Follow platform conventions.
5. **Error prevention** — Prevent before it happens. Confirm destructive actions. Validate inline.
6. **Recognition over recall** — Make options visible. Don't force users to remember.
7. **Flexibility and efficiency** — Keyboard shortcuts, command palettes, power-user paths.
8. **Aesthetic and minimalist design** — Remove irrelevant information. Every element competes for attention.
9. **Help users recognize, diagnose, recover from errors** — Plain language, suggest solutions, no error codes.
10. **Help and documentation** — Easy to search, focused on task, concrete steps. Best if unneeded.

## Design Process for AI Agents

When building any UI, follow this sequence:

1. **Identify page type** → Check `page-types.md` for the right pattern
2. **Identify state** → Check `states.md` — every page needs loading, empty, error, success states
3. **Select components** → Check `components.md` — use shadcn/ui, never reinvent
4. **Apply tokens** → Check `tokens.md` — never hardcode colors, spacing, or fonts
5. **Verify accessibility** → Check `accessibility.md` — WCAG 2.2 AA minimum
6. **Add motion** → Check `animation.md` — purposeful, not decorative
7. **Review against heuristics** → Self-check all 10 before marking complete

## Rules That Cannot Be Overridden

- **No hardcoded color values.** Use `bg-background`, `text-foreground`, `border-border`, etc.
- **No hardcoded spacing.** Use Tailwind's scale (`gap-4`, `p-6`), never `style="margin: 13px"`.
- **No inline font styles.** Use font tokens or Tailwind classes.
- **No custom components when shadcn/ui has one.** Check first, build only if gap.
- **Every interactive element needs a focus state.** `focus-visible:ring-2 focus-visible:ring-ring`.
- **Every form needs validation.** Inline, real-time, plain-language error messages.
- **Every page needs all 4 states.** Loading, empty, error, success — no exceptions.
- **Dark mode is not optional.** Every page must work in both light and dark themes.

## Sub-Rules

The following files are loaded alongside this one:

- `tokens.md` — Three-tier design token architecture (primitive → semantic → component)
- `typography.md` — Font system, type scale, pairing rules
- `color.md` — Color palette, psychology, dark mode, contrast requirements
- `components.md` — shadcn/ui component catalog, usage rules, composition patterns
- `page-types.md` — Landing page, admin dashboard, auth, settings — structural patterns
- `states.md` — Loading, empty, error, success state patterns
- `animation.md` — Micro-interaction principles, Framer Motion patterns
- `accessibility.md` — WCAG 2.2 checklist, ARIA, keyboard navigation
