# Frontend Rules (TanStack Start + React)

Loaded when working on UI components, routes, or SSR code.

## Component Architecture
- **No logic in UI components.** Components render and emit events only.
- **No data fetching in components.** Use TanStack Query hooks in loader or dedicated hooks.
- **No direct API calls from components.** All data access goes through query hooks or loaders.
- **Server components for public pages.** Client components only when interactivity requires it.

## File Structure
```
src/routes/
  _layout.tsx          # Root layout
  _auth/               # Authenticated routes (middleware guards)
  _public/             # Public routes (no auth required)

src/components/
  ui/                  # Primitive components (buttons, inputs, etc.)
  features/            # Feature-specific composed components
  layouts/             # Page layout shells

src/hooks/             # Custom React hooks
src/lib/               # Pure utilities, no React
```

## TanStack Router Rules
- Use file-based routing — filenames define routes.
- Use `loaderFn` for data that must be present before render (SSR).
- Use TanStack Query for client-side data that can load after render.
- Route guards via `beforeLoad` — redirect unauthorized users to login.
- Always define `validateSearch` with Zod for any route with search params.

## Forms (TanStack Form + Zod)
```typescript
// ✅ CORRECT — validated form with error display
const form = useForm({
  defaultValues: { email: '', password: '' },
  onSubmit: async ({ value }) => {
    // value is typed and validated
    await loginMutation.mutateAsync(value);
  },
  validators: {
    onChange: LoginSchema, // Zod schema
  },
});
```

## SEO (for public routes)
Every public route must export a `head` function:
```typescript
export const Route = createFileRoute('/')({
  head: () => ({
    meta: [
      { title: 'AppName — Primary Keyword' },
      { name: 'description', content: 'Compelling 150-char description' },
      { property: 'og:title', content: 'AppName — Primary Keyword' },
      { property: 'og:image', content: 'https://...' },
    ],
    links: [{ rel: 'canonical', href: 'https://...' }],
  }),
});
```

## Accessibility
- All interactive elements are keyboard accessible.
- All images have `alt` text (empty string `""` for decorative images).
- All form inputs have `<label>` elements.
- Color contrast ratio ≥ 4.5:1 for normal text.
- Focus indicators visible and not removed (no `outline: none` without replacement).

## Design System
- ONLY use tokens from `design_system.html` and `docs/DESIGN.md`.
- Never hardcode color hex values, font sizes, or spacing values in components.
- Add every new component to `design_system.html`.
