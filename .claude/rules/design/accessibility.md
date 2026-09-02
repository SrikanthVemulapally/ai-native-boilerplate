# Accessibility — WCAG 2.2 AA Checklist

> Accessibility is not optional. It's a legal requirement in most jurisdictions and a moral obligation. WCAG 2.2 AA is the minimum standard.

## The POUR Principles

WCAG is built on four principles. All content must be:

1. **Perceivable** — Users can perceive all information (see, hear)
2. **Operable** — Users can interact with all components (keyboard, mouse, touch)
3. **Understandable** — Users can understand content and operations
4. **Robust** — Content works with assistive technologies

## Pre-Flight Checklist (AI Agent Must Verify)

### Perceivable

- [ ] All images have `alt` text (or `alt=""` for decorative images)
- [ ] Color contrast meets AA: 4.5:1 for body text, 3:1 for large text and UI components
- [ ] Color is not the sole indicator of meaning (add icons, text, or shape)
- [ ] Form inputs have associated `<Label>` (not just placeholder text)
- [ ] Error messages are text, not just red borders
- [ ] Captions/transcripts exist for audio/video content

### Operable

- [ ] All interactive elements are keyboard accessible (`Tab` to move, `Enter`/`Space` to activate)
- [ ] Focus order is logical (left-to-right, top-to-bottom)
- [ ] Focus indicator is visible (`focus-visible:ring-2 focus-visible:ring-ring`)
- [ ] No keyboard traps (user can always `Esc` out of modals, menus)
- [ ] Skip-to-content link exists on multi-section pages
- [ ] Touch targets are ≥44x44px on mobile
- [ ] No content that flashes more than 3 times per second

### Understandable

- [ ] Language is set: `<html lang="en">`
- [ ] Form validation is inline and on-blur (not only on submit)
- [ ] Error messages are in plain language with suggested solutions
- [ ] Navigation is consistent across pages
- [ ] Component behavior is predictable (same action = same result)

### Robust

- [ ] HTML is semantic (`<nav>`, `<main>`, `<article>`, `<section>`, `<aside>`)
- [ ] ARIA attributes are used correctly (see below)
- [ ] Works with screen readers (test with VoiceOver/NVDA)
- [ ] Works with browser zoom at 200%
- [ ] Works in high contrast mode
- [ ] No dependencies on a single input method

## Semantic HTML — Use This, Not That

| Use | Don't Use |
|---|---|
| `<button>` | `<div onClick>` |
| `<a href>` | `<span onClick>` for navigation |
| `<nav>` | `<div className="nav">` |
| `<main>` | `<div id="main">` |
| `<header>` | `<div className="header">` |
| `<footer>` | `<div className="footer">` |
| `<section>` | `<div className="section">` |
| `<article>` | `<div className="card">` for content |
| `<aside>` | `<div className="sidebar">` for non-main content |
| `<label htmlFor>` | `<span>` as label |
| `<fieldset>` + `<legend>` | `<div>` wrapping radio groups |

**shadcn/ui components already use semantic HTML and Radix primitives.** Don't override the underlying element.

## ARIA — When and How

### Golden Rule: No ARIA is better than bad ARIA.

If you can use semantic HTML instead of ARIA, do it. ARIA is a patch, not a solution.

### When ARIA IS Needed

| Situation | ARIA | Example |
|---|---|---|
| Dynamic content update | `aria-live="polite"` | Toast notifications, search results |
| Loading state | `aria-busy="true"` + `aria-live="polite"` | Data region fetching |
| Custom widget (no native equivalent) | `role`, `aria-expanded`, `aria-controls` | Custom combobox, accordion |
| Form validation | `aria-invalid="true"` + `aria-describedby` | Invalid input linking to error |
| Icon-only button | `aria-label="Close"` | `<Button size="icon" aria-label="Close">` |
| Current page in nav | `aria-current="page"` | Active sidebar item |
| Modal dialog | `role="dialog"` + `aria-modal="true"` | (shadcn Dialog handles this) |
| Tabs | `role="tablist"`, `role="tab"`, `aria-selected` | (shadcn Tabs handles this) |

### aria-live Regions

```tsx
// Toast region — polite (announces when screen reader is idle)
<div aria-live="polite" aria-atomic="true">
  <Sonner />
</div>

// Loading region — polite
<div aria-live="polite" aria-busy={isLoading}>
  {isLoading ? <Skeleton /> : <Content />}
</div>

// Error alerts — assertive (announces immediately)
<div role="alert" aria-live="assertive">
  {error && <p>{error.message}</p>}
</div>
```

### Common ARIA Mistakes

- ❌ `aria-label` on an element that already has visible text — redundant
- ❌ `aria-hidden="true"` on a focusable element — hides from AT but still in tab order
- ❌ `role="button"` on a `<button>` — native role already set
- ❌ Using ARIA to make a `<div>` act like a `<select>` — use `<Select>` instead
- ❌ Forgetting `aria-controls` when `aria-expanded` is used — screen reader can't find target

## Keyboard Navigation

### Key Bindings Every App Must Support

| Key | Action |
|---|---|
| `Tab` | Move to next focusable element |
| `Shift + Tab` | Move to previous focusable element |
| `Enter` | Activate button/link |
| `Space` | Activate button / toggle checkbox |
| `Escape` | Close modal, menu, popover, dropdown |
| `Cmd/Ctrl + K` | Open command palette |
| `Cmd/Ctrl + S` | Save (in editors/forms) |

### Focus Management

- **Modal opens:** Move focus to first interactive element inside modal
- **Modal closes:** Return focus to the element that triggered it
- **Route change:** Move focus to page `<h1>` or main content
- **List add/remove:** Focus the new item or maintain position
- **Toast appears:** Do NOT steal focus (use `aria-live` instead)

```tsx
// Focus trap for modals (Radix Dialog handles this automatically)
// For custom modals:
import { focusFirst } from "@/lib/focus-utils";

useEffect(() => {
  if (isOpen) focusFirst(modalRef.current);
}, [isOpen]);
```

## Color Contrast Quick Test

| Element | Foreground | Background | Min Ratio | Check |
|---|---|---|---|---|
| Body text | `text-foreground` | `bg-background` | 4.5:1 | ✅ (default theme) |
| Muted text | `text-muted-foreground` | `bg-background` | 4.5:1 | ⚠️ Verify per theme |
| Button text | `text-primary-foreground` | `bg-primary` | 4.5:1 | ✅ (default) |
| Destructive | `text-destructive` | `bg-background` | 3:1 (large) | ⚠️ Verify |
| Border | `border-border` | `bg-background` | 3:1 | ✅ (default) |
| Focus ring | `ring-ring` | `bg-background` | 3:1 | ✅ (default) |

**If you customize the primary color, you MUST re-verify all primary-related contrast ratios.**

## Testing Accessibility

### Automated (CI/CD)

```bash
# axe-core in Vitest
npx vitest --config vitest.a11y.config.ts

# Lighthouse CI
npx lhci autorun --collect.url=http://localhost:3000
```

### Manual Testing Checklist

1. **Keyboard-only test:** Unplug mouse. Can you complete all primary tasks?
2. **Screen reader test:** Run VoiceOver (Mac) or NVDA (Windows). Navigate your app.
3. **Zoom test:** Zoom to 200%. Does layout still work?
4. **High contrast test:** Enable Windows High Contrast mode. Does content still read?
5. **Reduced motion test:** Enable "Reduce Motion" in OS settings. Do animations respect it?

## AI Agent Accessibility Checklist

Before marking any UI complete:

- [ ] Semantic HTML used (no `<div onClick>` for buttons)
- [ ] All images have appropriate `alt` text
- [ ] All inputs have `<Label>` (not just placeholders)
- [ ] Focus states visible on all interactive elements
- [ ] Keyboard can reach and operate everything
- [ ] Color contrast meets AA (especially custom colors)
- [ ] `aria-live` regions set for dynamic content
- [ ] `prefers-reduced-motion` respected for animations
- [ ] Error messages are text, linked via `aria-describedby`
- [ ] Icon-only buttons have `aria-label`
- [ ] Page has logical heading hierarchy (one `<h1>`, then `<h2>`, etc.)
- [ ] Skip link exists on pages with nav
