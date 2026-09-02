# UX Patterns & Mental Models

> The behavioral layer. These are the patterns that make users convert, stay, and succeed.
> Apply the relevant section to every page you build.

---

## Onboarding UX

### First-Run Experience
- **Progressive, not exhaustive.** Never show a 12-step wizard. 3 steps max, each completing a real action.
- **Activation event.** Define ONE action that means the user is "activated" (e.g., created first project, invited first team member). Guide everything toward that.
- **Time-to-value < 60 seconds.** From signup to first meaningful action. Remove every wall between them and value.
- **Empty states as onboarding.** First-time empty states should teach, not just say "nothing here." Include a CTA to create the first item.
- **Progressive disclosure.** Show 3 features on first visit. Reveal more as they use the app. Never overwhelm.

### Trial-to-Paid Conversion
- **Show value before asking for payment.** Let them use the product first. Gate only when they hit a meaningful limit.
- **Soft limits > hard walls.** "You've used 5 of 5 free projects. Upgrade for unlimited." Not "Access denied."
- **Upgrade CTA placement.** Contextual, not banner-spammed. At the moment of hitting the limit, not before.
- **Trial countdown.** Show remaining trial days in a subtle, non-annoying way. "3 days left in your trial" in account menu, not a full-screen modal.

### Activation Patterns
- **Checklist onboarding.** Small, dismissible checklist (3-5 items) that tracks setup progress. Each item links to the action.
- **Sample data.** Pre-populate with demo data so the app isn't empty on first visit. Let them clear it with one click.
- **Interactive coachmarks.** Highlight one element at a time. Dismissible. Never force completion.
- **Skip onboarding.** Always allow skipping. Users who skip can still succeed — don't gate them.

---

## Conversion UX

### Pricing Page Psychology
- **3-tier max.** Good/Better/Best. More than 3 causes choice paralysis.
- **Anchor pricing.** Show the most expensive plan first (left) to anchor perception. Or highlight the middle plan as "Most Popular."
- **Annual/monthly toggle.** Default to annual (show savings). "Save 20%" badge on annual.
- **Feature comparison table.** Side-by-side, scannable. Checkmarks for included, dashes for not. No paragraphs.
- **Free tier if applicable.** "Free forever" not "Free trial." Remove credit card requirement for signup.
- **CTA per plan.** Each plan has its own button. Button text matches the action: "Start Free," "Choose Pro," "Contact Sales."

### Friction Reduction
- **Social login.** Google + GitHub minimum. Reduces signup to 2 clicks.
- **No credit card for free tier.** Only ask at upgrade moment.
- **Progressive signup.** Email → use product → password/profile later. Never front-load forms.
- **Autofill.** Browser autofill works. Don't disable it. `autocomplete` attributes on every field.
- **One-column forms.** Multi-column forms have lower completion rates. Exception: inline fields (first/last name).

### CTA Design
- **One primary CTA per view.** If everything is highlighted, nothing is.
- **Contrast > size.** A small high-contrast button beats a large low-contrast one.
- **Action-oriented copy.** "Create Project" not "Submit." "Start Free" not "Sign Up."
- **Above the fold.** The primary CTA is visible without scrolling on landing pages.
- **Repeat at bottom.** On long pages, repeat the CTA at the bottom for users who read everything.

---

## Forms UX

### Validation
- **Inline validation.** Validate on blur, not on every keystroke (causes anxiety). Show success (green check) or error (red text + icon).
- **Never validate on type.** Typing "abc" in an email field and seeing "invalid" after 3 chars is hostile.
- **Error messages.** Say what's wrong AND how to fix it. "Enter a valid email like name@example.com" not "Invalid input."
- **Submit button.** Disabled until form is valid OR enabled with validation on submit. Pick one, be consistent.
- **Server errors.** If server returns error, show it inline near the relevant field, not in a generic toast.

### Multi-Step Forms
- **Progress indicator.** Show "Step 2 of 4" with a visual bar.
- **Back button.** Always works. Preserves entered data.
- **One concept per step.** Don't mix "Your profile" and "Billing info" on the same step.
- **Save progress.** Autosave or allow resuming. Never make them re-enter everything.

### Input Types
- **Use native input types.** `type="email"`, `type="tel"`, `type="date"` — gives mobile users the right keyboard.
- **Input masks for formatted fields.** Phone: (555) 123-4567. Credit card: 4242 4242 4242 4242.
- **Character counts for limited fields.** "42/280" — show when approaching limit, turn red at limit.
- **Textarea auto-resize.** Don't show a scrollbar for 3 lines of text.

### Autosave
- **Autosave form drafts.** For long forms (settings, profiles). Show "Saved" indicator, not "Saving..." (implies it might fail).
- **Dirty state warning.** "You have unsaved changes" when navigating away. `beforeunload` for browser-level.
- **Conflict resolution.** If two users edit the same resource, show "This was edited by someone else. Reload?"

---

## Search & Filter UX

### Command Palette (⌘K)
- **Trigger.** ⌘K (Mac) / Ctrl+K (Windows). Show hint in UI: "Press ⌘K to search."
- **Fuzzy search.** Match partial queries. "proj" finds "Projects."
- **Keyboard navigation.** Arrow keys + Enter. Esc to close.
- **Recent items.** Show recently accessed items above search results.
- **Actions, not just navigation.** "Create new project," "Change theme," "Invite user" — not just page links.
- **Grouped results.** Pages, Actions, People — grouped by category with headers.

### Filters
- **Faceted filters.** Checkbox groups by category (Status, Date, Type). Sidebar or dropdown.
- **Active filter chips.** Show applied filters as removable chips above results.
- **Clear all.** One button to reset all filters.
- **Filter count.** Show result count after filtering: "Showing 12 of 47."
- **URL-synced filters.** Filters update the URL. Shareable links, back button works.
- **Save filter presets.** For power users who repeatedly apply the same filter combo.

### Empty Search Results
- **Helpful, not empty.** "No results for 'xyz'. Try a different search term or clear filters."
- **Suggestions.** Show popular items or recently viewed when search is empty.

---

## Data Visualization UX

### Chart Selection
| Data Story | Chart Type |
|---|---|
| Trend over time | Line or Area |
| Comparison between categories | Bar (vertical) or Column |
| Part of a whole | Donut or Stacked Bar |
| Distribution | Histogram or Box Plot |
| Correlation | Scatter |
| Single key metric | KPI card with sparkline |
| Funnel / conversion stages | Funnel chart |
| Geographic | Choropleth map |

### Chart UX Rules
- **Start axis at zero.** For bar charts. Always. Non-zero baselines mislead.
- **No 3D charts.** Ever. They distort perception.
- **Max 5 series per chart.** More = unreadable. Fold extras into "Other."
- **Tooltips on hover.** Show exact values. Don't rely on axis reading.
- **Legend placement.** Top or right. Never bottom (requires scrolling down to understand the chart).
- **Color-blind safe.** Use shape + color, not color alone. Avoid red/green pairs.
- **Responsive.** Charts resize on smaller screens. Hide legend on mobile, use direct labels.
- **Loading state.** Skeleton chart outline while data loads. Not a spinner.
- **Empty state.** "No data yet. Data will appear here once you have activity."

### Drill-Down
- **Click to drill.** Click a bar → see breakdown for that category.
- **Breadcrumb.** "All > Q3 2026 > September" so users can navigate back up.
- **Export.** Allow CSV/PNG export of chart data for reporting.

---

## Notification UX

### Toast Hierarchy
| Priority | Duration | Style | Example |
|---|---|---|---|
| Success | 3s | Green, bottom-right | "Project created" |
| Info | 4s | Blue, bottom-right | "Export ready" |
| Warning | 5s | Amber, bottom-right | "Trial expires in 3 days" |
| Error | Sticky | Red, bottom-right, manual dismiss | "Failed to save: network error" |

### Toast Rules
- **One at a time.** Queue multiple, don't stack 5 toasts.
- **No toast for expected actions.** Don't toast "Page loaded." Only unexpected or user-initiated outcomes.
- **Action button in toast.** "Undo" for destructive actions. "View" for created items.
- **No auto-dismiss for errors.** Errors stay until dismissed or resolved.
- **Position.** Bottom-right on desktop. Top-center on mobile.

### Notification Center
- **Bell icon with badge.** Unread count badge in navbar.
- **Grouped by day.** "Today," "Yesterday," "Earlier this week."
- **Mark as read.** Individual + "Mark all as read."
- **Categories.** Mentions, System, Updates. Filterable.
- **Persistence.** Notifications survive page refresh. Stored server-side for cross-device.

---

## Collaboration UX

### Presence
- **Avatars in navbar.** Show who's online with colored ring (green=active, gray=offline).
- **Cursors (real-time editors).** Show other users' cursors with their name label in their avatar color.
- **Typing indicators.** "Srikanth is typing..." in comment boxes and shared editors.

### Comments & Activity
- **Threaded comments.** Reply to a specific comment, not a flat list.
- **@mentions.** Type @ to mention. Notified user gets bell notification.
- **Activity feed.** "Srikanth created Project X" — audit trail of who did what.
- **Revision history.** Show changes with author and timestamp. Allow reverting.

---

## Settings UX

### Progressive Disclosure
- **Tabs or sidebar.** Group settings: Profile, Notifications, Billing, Team, Integrations, Advanced.
- **Search settings.** If more than 20 settings, add a search bar.
- **Save patterns.**
  - Auto-save with "Saved" indicator (for toggles, preferences).
  - Explicit "Save Changes" button (for profile, billing — things with consequences).
  - Never mix the two on the same page.

### Reset
- **Reset to defaults.** Per-section, not global. "Reset notifications to defaults" not "Reset everything."
- **Confirm destructive settings.** "Delete account" requires typed confirmation: type "DELETE" to confirm.

---

## Mobile & Touch UX

### Touch Targets
- **44×44px minimum.** Apple HIG. 48×48px for Google Material. Never smaller.
- **Spacing between targets.** 8px minimum between clickable elements to prevent mis-taps.

### Mobile Patterns
- **Bottom sheets, not modals.** On mobile, modals feel like new pages. Bottom sheets feel contextual.
- **Swipe to reveal actions.** Swipe left on a list item to reveal Delete/Archive.
- **Sticky bottom bar.** Primary CTA sticks to bottom on mobile. Always reachable.
- **Pull to refresh.** Native-feeling. Don't add a refresh button.
- **No hover-dependent UI.** Touch devices don't hover. Every hover action has a tap equivalent.

### Responsive Breakpoints (shadcn/Tailwind)
| Breakpoint | Width | Layout |
|---|---|---|
| `sm` | 640px | Mobile landscape, small tablet |
| `md` | 768px | Tablet |
| `lg` | 1024px | Small desktop, large tablet |
| `xl` | 1280px | Desktop |
| `2xl` | 1536px | Large desktop |

- **Mobile-first.** Write styles for mobile, enhance for larger. Not the reverse.
- **One column on mobile.** Stack everything. Side-by-side only at `lg` and up.

---

## Trust & Credibility UX

### Social Proof
- **Logos.** "Trusted by teams at [Company]." 5-6 logos, grayscale, hover for color.
- **Testimonials.** Real quote + name + title + photo. Not generic "Great product!" — specific outcomes.
- **Stats.** "10,000+ users," "99.9% uptime," "2M+ API calls/day." Specific numbers, not vague claims.
- **Reviews.** Star rating + link to public review (G2, Capterra). Only if you have 4+ stars.

### Security Signals
- **SSL/TLS badge.** Lock icon in footer. "Secured with 256-bit SSL."
- **Compliance badges.** SOC 2, GDPR, HIPAA — if applicable. Link to details.
- **Privacy policy link.** In footer. One click away. Not buried.
- **Data ownership.** "Your data is yours. Export anytime." Reduces lock-in fear.
- **2FA prompt.** After signup, not during. "Secure your account: enable 2FA."

---

## UX Writing & Microcopy

### Voice
- **Clear, not clever.** "Delete project" not "Send to the void."
- **Short, not terse.** "Enter your email to get started" not "Email required."
- **Active, not passive.** "We'll send you a link" not "A link will be sent to you."
- **Positive, not negative.** "Password must be 8+ characters" not "Password too short."

### Error Messages
- **What happened.** "We couldn't save your changes."
- **Why.** "Your session expired."
- **What to do.** "Log in again and try saving."
- **Never blame the user.** "Invalid email" → "Enter a valid email address."

### Empty States
- **Explain the empty state.** "No projects yet."
- **Provide a reason.** "Projects you create will appear here."
- **CTA to act.** "Create your first project" (button).

### Button Copy
- **Describe the action.** "Create Project" not "OK" or "Submit."
- **Use verbs.** "Save," "Delete," "Export," "Invite."
- **Match consequence.** "Delete" for destructive. "Archive" for reversible. Don't use "Delete" for reversible actions.

### Loading Copy
- **Specific, not generic.** "Generating report..." not "Loading..."
- **Time estimates for long ops.** "This usually takes 30 seconds."
- **Progress for >3s operations.** Progress bar with percentage.

---

## Cognitive Load Management

### Progressive Disclosure
- **Show essential first.** Hide advanced settings behind "Show advanced options."
- **Chunk information.** Don't show 50 form fields. Group into 3 steps of ~15.
- **Default to closed.** Accordions collapsed by default. Expand only what the user needs.

### Decision Fatigue
- **Smart defaults.** Pre-select the most common option. Don't make users choose everything.
- **Limit choices.** 3 pricing tiers, not 7. 5 notification preferences, not 25 checkboxes.
- **Recommended badges.** "Recommended for you" on one option in a list reduces decision time.

### Information Hierarchy
- **F-pattern on content pages.** Users scan in an F-pattern. Put important info top-left.
- **Z-pattern on landing pages.** Eye flows top-left → top-right → bottom-left → bottom-right. Place CTA at bottom-right.
- **Above the fold.** The most important action is visible without scrolling. Always.

### Scannability
- **Headings every 2-3 paragraphs.** Break long content into sections.
- **Bulleted lists for features.** Not paragraphs. Users scan, don't read.
- **Bold key terms.** But don't bold everything. Bold = "read this if you skim."
- **Short paragraphs.** 2-3 sentences max. Long walls of text = bounce.

---

## Dark Mode (Beyond Color)

- **Shadows, not borders.** In dark mode, borders add visual noise. Use elevation shadows + slightly lighter backgrounds for separation.
- **Images.** Add `opacity: 0.8` to images in dark mode, or use CSS `filter: brightness(0.9)`. Prevents white-image glare.
- **No pure black.** Use `oklch(0.145 0 0)` (#1a1a1a area), not `#000000`. Pure black causes eye strain.
- **Contrast ratios.** Recalculate for dark mode. What passes in light may fail in dark.
- **Color saturation.** Reduce saturation by ~10% in dark mode. Colors appear more saturated on dark backgrounds.
- **Glow effects.** Subtle shadows with color tint (e.g., `shadow-blue-500/20`) work well in dark mode. Don't overdo.
- **System preference.** Default to `prefers-color-scheme`. Manual toggle persists in localStorage.
- **No flash.** Inline critical CSS in `<head>` to set theme before paint. Prevents flash of wrong theme (FOUC).
- **Email templates.** Dark mode email clients invert colors. Test with `prefers-color-scheme: dark` media query in email CSS.
- **Code blocks.** Use a dark code theme even in light mode (like GitHub does). Reduces eye strain for code.
- **Diagrams/charts.** Ensure chart colors have dark-mode variants. Don't just invert — some colors become invisible.
- **Form fields.** Slightly lighter background than page background. `bg-muted` not `bg-background` for inputs in dark mode.

---

## Summary: UX Checklist Per Page Type

### Landing Page
- [ ] Hero with one clear value prop + CTA above fold
- [ ] Social proof within first scroll
- [ ] Feature section: 3 features, icon + headline + 1-line description
- [ ] Pricing with 3 tiers, annual/monthly toggle
- [ ] FAQ accordion
- [ ] Final CTA section
- [ ] Footer with links, legal, security signals

### Admin Dashboard
- [ ] KPI cards (3-5 max) with trend indicators
- [ ] Primary chart (line or bar) showing main metric over time
- [ ] Data table with search, sort, filter, pagination
- [ ] Quick action button (top-right)
- [ ] Recent activity feed
- [ ] Responsive: KPIs stack, table becomes cards on mobile

### Settings
- [ ] Sidebar or tab navigation
- [ ] Progressive disclosure for advanced options
- [ ] Save indicator or explicit save button
- [ ] Destructive actions behind confirmation

### Auth
- [ ] Social login options first
- [ ] Minimal fields (email + password, or just email for magic link)
- [ ] Show/hide password toggle
- [ ] "Forgot password" link
- [ ] No session timeout on the login page itself

### Onboarding
- [ ] 3 steps max, each completing a real action
- [ ] Progress indicator
- [ ] Skip option
- [ ] Activation event defined and tracked
- [ ] Sample data pre-populated
