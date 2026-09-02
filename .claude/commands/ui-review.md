# /ui-review [component-or-page]

Run a comprehensive design review checklist on a UI component or page before marking it done.
This command is MANDATORY before completing any UI implementation task.

## When to Run
- After implementing any new page or component
- After making significant UI changes
- Before creating a PR that touches UI code
- After a design review request

## Review Process

### 1. Responsiveness Check
- [ ] Renders correctly at 375px (iPhone SE — minimum)
- [ ] Renders correctly at 768px (tablet)
- [ ] Renders correctly at 1280px (desktop)
- [ ] No horizontal scroll at any width ≥ 375px
- [ ] No text overflow or truncation issues
- [ ] Images have `width` + `height` attributes (CLS prevention)
- [ ] Fluid typography used for headings (clamp or responsive classes)
- [ ] Container queries used where component appears in variable-width contexts

### 2. Dark Mode Check
- [ ] All colors use semantic tokens (`text-foreground`, `bg-background`, etc.)
- [ ] No hardcoded hex values in className or style
- [ ] Works in both light and dark themes
- [ ] No pure white or pure black (`#fff` / `#000`) — use tokens
- [ ] Images don't look washed out or blinding in dark mode

### 3. States Check (all 4 mandatory)
- [ ] **Loading state** — skeleton matches content shape, no layout shift
- [ ] **Empty state** — helpful message + CTA, not just "No data"
- [ ] **Error state** — plain language, recovery action
- [ ] **Success state** — confirmation feedback (toast or inline)

### 4. Accessibility Check
- [ ] All interactive elements have visible focus styles
- [ ] Keyboard navigation works (Tab, Enter, Escape, Arrow keys)
- [ ] Color contrast ≥ 4.5:1 for normal text, ≥ 3:1 for large text
- [ ] No color-only information (always pair color with icon or text)
- [ ] Images have meaningful alt text (not empty, not "image of...")
- [ ] Form fields have associated `<label>` elements
- [ ] Modals/dialogs trap focus and restore on close
- [ ] Error messages linked to inputs via `aria-describedby`

### 5. Component Usage Check
- [ ] Uses shadcn/ui components (no custom alternatives to existing components)
- [ ] No hardcoded spacing values (`style="margin: 13px"` etc.)
- [ ] No hardcoded font sizes
- [ ] Button variants follow decision tree (default/secondary/outline/ghost/destructive)
- [ ] Icons from Lucide React only

### 6. Performance Check
- [ ] No unvirtualized lists with >50 items
- [ ] Heavy components (charts, editors) are lazy-loaded
- [ ] LCP image (if any) has `loading="eager"` + `fetchpriority="high"`
- [ ] All other images have `loading="lazy"` + `decoding="async"`
- [ ] No layout-triggering animations (only `transform` and `opacity`)

### 7. Animation Check
- [ ] `prefers-reduced-motion` respected via `useReducedMotion()`
- [ ] No animation exceeds 600ms duration
- [ ] Entrance animations use `ease-out`, exit uses `ease-in`
- [ ] Spring physics only for physical interactions (drag, swipe)
- [ ] No animation that causes layout shift

### 8. Copy & Microcopy Check
- [ ] All button labels are action verbs ("Create Project", not "OK")
- [ ] Error messages say what happened + what to do
- [ ] Empty states have a headline + CTA
- [ ] Loading states have specific copy ("Generating report...", not "Loading...")
- [ ] No Lorem ipsum or placeholder text remaining

### 9. Mobile UX Check
- [ ] All touch targets ≥ 44×44px
- [ ] No hover-only interactions (touch equivalent exists)
- [ ] Safe area insets applied if using fixed/sticky elements
- [ ] Forms don't trigger zoom (input font-size ≥ 16px)
- [ ] Bottom fixed elements account for home indicator (safe-area-inset-bottom)

### 10. Page-Type Specific

#### Landing Page
- [ ] Hero above the fold on 1080p
- [ ] Primary CTA visible without scrolling
- [ ] Social proof within first scroll
- [ ] Pricing visible on page

#### Admin Dashboard
- [ ] KPI cards show trend indicators
- [ ] Data table has column alignment (numbers right, text left)
- [ ] Sidebar collapses to icon-only at appropriate breakpoint
- [ ] Page header has title + primary action

#### Forms
- [ ] Inline validation on blur (not on type)
- [ ] Server errors shown near relevant fields
- [ ] Submit button has loading state
- [ ] Unsaved changes warning on navigation

## Output Format

Report findings as:
- ✅ PASS — item is correct
- ⚠️ WARN — minor issue, acceptable but should note
- ❌ FAIL — must fix before marking done

**Only mark UI work done when zero ❌ FAIL items remain.**

List all ❌ and ⚠️ items with specific file + line number where the issue is.
