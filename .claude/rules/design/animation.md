# Animation — Micro-Interactions & Motion Principles

> Animation is not decoration. It communicates hierarchy, relationship, and feedback. Bad animation distracts. Good animation feels invisible — it makes the interface feel alive.

## When to Animate

| Animate | Don't Animate |
|---|---|
| State changes (open/close, expand/collapse) | Page loads (use skeletons instead) |
| Hover/focus feedback on interactive elements | Every scroll position (exhausting) |
| Transitions between views or tabs | Text content changes |
| Data updates (number tickers, chart morphs) | Static content display |
| Drag-and-drop reordering | Page layout shifts on data load |
| Notification entrance/exit | Loading spinners (just rotate) |

## Duration & Easing

### Duration Scale

| Token | Duration | When |
|---|---|---|
| `instant` | 100ms | Hover states, color changes |
| `fast` | 150ms | Small UI toggles, icon rotations |
| `normal` | 250ms | Default — most transitions |
| `slow` | 400ms | Page transitions, large panel slides |
| `deliberate` | 600ms | Hero animations, onboarding sequences |

**Never exceed 600ms** for UI transitions. Users perceive >600ms as lag, not animation.

### Easing Curves

| Curve | When | Framer Motion |
|---|---|---|
| `ease-out` | Elements entering (appear, slide in) | `{ ease: "easeOut" }` |
| `ease-in` | Elements leaving (dismiss, fade out) | `{ ease: "easeIn" }` |
| `ease-in-out` | Position transitions (move, resize) | `{ ease: "easeInOut" }` |
| `spring` | Physical interactions (drag, swipe) | `{ type: "spring", stiffness: 300, damping: 30 }` |
| `linear` | Continuous animations (progress, rotation) | `{ ease: "linear" }` |

**Never use `ease` (the default cubic-bezier).** It feels robotic. Always specify.

### Spring Physics

For natural, tactile interactions — drag, swipe, reorder:

```tsx
import { motion } from "framer-motion";

// Card with spring hover
<motion.div
  whileHover={{ y: -4 }}
  transition={{ type: "spring", stiffness: 400, damping: 25 }}
>

// Drawer slide
<motion.div
  initial={{ x: "-100%" }}
  animate={{ x: 0 }}
  exit={{ x: "-100%" }}
  transition={{ type: "spring", stiffness: 300, damping: 30 }}
>
```

### Spring Tuning Guide

| Stiffness | Damping | Feel |
|---|---|---|
| 100 | 10 | Bouncy, playful (consumer apps) |
| 300 | 30 | Responsive, natural (default) |
| 500 | 40 | Snappy, precise (pro tools) |
| 800 | 50 | Very fast, mechanical (games) |

## Framer Motion Patterns

### 1. Page Transition

```tsx
// Route-level transition
<motion.div
  initial={{ opacity: 0, y: 8 }}
  animate={{ opacity: 1, y: 0 }}
  exit={{ opacity: 0, y: -8 }}
  transition={{ duration: 0.25, ease: "easeOut" }}
>
  {children}
</motion.div>
```

### 2. List Stagger

```tsx
const container = {
  hidden: { opacity: 0 },
  show: { opacity: 1, transition: { staggerChildren: 0.05 } }
};

const item = {
  hidden: { opacity: 0, y: 12 },
  show: { opacity: 1, y: 0, transition: { duration: 0.25, ease: "easeOut" } }
};

<motion.ul variants={container} initial="hidden" animate="show">
  {items.map(i => <motion.li key={i.id} variants={item}>{i.name}</motion.li>)}
</motion.ul>
```

### 3. Number Ticker

```tsx
// Animated counter for dashboard metrics
<motion.span
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
>
  <CountUp end={value} duration={0.6} />
</motion.span>
```

### 4. Hover Lift

```tsx
<motion.div
  whileHover={{ y: -4 }}
  whileTap={{ y: 0 }}
  transition={{ type: "spring", stiffness: 400, damping: 25 }}
>
```

### 5. Expand/Collapse

```tsx
<motion.div
  initial={false}
  animate={{ height: isOpen ? "auto" : 0, opacity: isOpen ? 1 : 0 }}
  transition={{ duration: 0.25, ease: "easeInOut" }}
  style={{ overflow: "hidden" }}
>
```

## shadcn/ui Built-in Animations

shadcn components already include proper animations via Tailwind:

- `Dialog` / `Sheet` / `Drawer` — slide + fade (Radix handles this)
- `Popover` / `Tooltip` — scale + fade
- `DropdownMenu` — slide + fade
- `Accordion` — height animation
- `Toast` / `Sonner` — slide + fade

**Don't add custom animations to shadcn components.** They're already animated. Only add motion to custom components.

## Accessibility & Animation

### `prefers-reduced-motion`

**Mandatory:** Respect user's OS setting to reduce motion.

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

In Framer Motion:

```tsx
import { useReducedMotion } from "framer-motion";

const shouldReduceMotion = useReducedMotion();

<motion.div
  initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 8 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: shouldReduceMotion ? 0 : 0.25 }}
>
```

### Animation Rules for Accessibility

1. **No auto-playing motion** that lasts >5s (distracting, vestibular issues)
2. **No parallax** on scroll (vestibular triggers) unless `prefers-reduced-motion` is respected
3. **No flashing** >3 times per second (seizure risk)
4. **Status changes** must be communicated without animation (animation is enhancement, not the signal)
5. **Animation is never the only feedback.** Always pair with text, color, or icon change.

## Performance Rules

1. **Only animate transform and opacity.** These are GPU-accelerated. Animating `width`, `height`, `top`, `left` causes layout reflow → jank.
2. **`will-change` sparingly.** Add to elements about to animate, remove after. Don't leave it permanently.
3. **Limit animated elements.** Max 10-15 simultaneously animating elements on screen.
4. **Defer below-the-fold animation.** Use `whileInView` instead of `animate` for off-screen elements.

```tsx
// ✅ Only animate when in viewport
<motion.div
  initial={{ opacity: 0, y: 20 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true }}
  transition={{ duration: 0.4 }}
>
```

## Anti-Patterns

- ❌ Animating `display: none → block` — doesn't work, use opacity + height
- ❌ Spring on every element — chaos, reserve for physical interactions
- ❌ Duration >600ms for UI — feels laggy
- ❌ Bounce on serious actions (delete, error) — tonally wrong
- ❌ Animation without `prefers-reduced-motion` — accessibility failure
- ❌ Custom CSS keyframes when Framer Motion handles it — inconsistency
- ❌ Animating layout properties (margin, padding) — causes reflow
