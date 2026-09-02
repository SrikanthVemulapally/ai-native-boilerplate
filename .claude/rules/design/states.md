# States — Loading, Empty, Error, Success

> Every page and every component has 4 states. "It works with data" is not a complete implementation. All 4 states are mandatory.

## The 4 States Framework

```
┌────────────────────────────────────────────────┐
│ WHAT STATE AM I IN?                             │
│                                                │
│  No data yet?     → LOADING (skeleton)         │
│  Data loaded,     → SUCCESS (populated)        │
│   content exists?                               │
│  Data loaded,     → EMPTY (zero-state)         │
│   no content?                                   │
│  Something broke? → ERROR (recoverable)        │
└────────────────────────────────────────────────┘
```

## 1. Loading States

### When to Use Each Pattern

| Pattern | When | Duration Expectation |
|---|---|---|
| **Skeleton** | Content area loading | >200ms |
| **Spinner** | Button action, inline | <2s |
| **Progress bar** | Known progress (upload, install) | Variable |
| **Optimistic UI** | Like-delete, toggle | Instant revert on error |

### Skeleton Rules

- **Match the layout exactly.** Skeleton must mirror the final content — same height, same width, same shape. A wrong-sized skeleton causes CLS when real content loads.
- **Animate subtly.** Use `animate-pulse` (Tailwind) for a soft fade pulse. For premium feel, use a shimmer sweep:
- **No text.** Never show "Loading..." text with a skeleton. The skeleton IS the loading indicator.
- **Skeleton the structure, not a spinner.** A spinner in an empty area feels broken. A skeleton feels like progress.
- **Stagger skeletons.** If loading a list, stagger opacity of skeleton items for a more natural feel.
- **Identical count.** Render the expected number of skeleton items (e.g. if page shows 6 cards, render 6 skeleton cards).

```css
/* Shimmer skeleton — more premium than pulse */
@keyframes shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

.skeleton-shimmer {
  background: linear-gradient(
    90deg,
    hsl(var(--muted)) 25%,
    hsl(var(--muted-foreground) / 0.15) 50%,
    hsl(var(--muted)) 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}
```

```tsx
// ✅ Staggered skeleton list
{Array.from({ length: 6 }).map((_, i) => (
  <motion.div
    key={i}
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
    transition={{ delay: i * 0.05 }}
  >
    <CardSkeleton />
  </motion.div>
))}
```

```tsx
// ✅ Correct — skeletons match card structure
<div className="grid grid-cols-3 gap-4">
  {Array.from({ length: 6 }).map((_, i) => (
    <Card key={i}>
      <CardHeader>
        <Skeleton className="h-4 w-3/4" />
        <Skeleton className="h-3 w-1/2" />
      </CardHeader>
      <CardContent>
        <Skeleton className="h-32 w-full" />
      </CardContent>
    </Card>
  ))}
</div>

// ❌ Wrong — spinner in empty space
<div className="flex items-center justify-center min-h-[400px]">
  <Spinner />
</div>
```

### Spinner Rules

- Use `Loader2` from Lucide with `animate-spin`.
- Button loading: replace text with spinner, keep button width stable.
- Inline loading: small spinner next to the triggering element.
- **Never use a full-page spinner.** It blocks and disorients.

### Optimistic UI

Use for actions that almost always succeed:
- Like / unlike / bookmark
- Toggle settings
- Mark as read
- Delete (with undo toast)

```tsx
// Pattern: update UI immediately, revert on error
const onToggle = async () => {
  const prev = isEnabled;
  setIsEnabled(!prev); // optimistic
  try {
    await api.toggle();
  } catch {
    setIsEnabled(prev); // revert
    toast.error("Failed to update. Please try again.");
  }
};
```

### Timing Thresholds (Nielsen)

| Duration | What Users Feel | What to Do |
|---|---|---|
| <100ms | Instant | No indicator needed |
| 100ms-1s | Slight delay | Skeleton or subtle animation |
| 1-3s | Short wait | Skeleton + maybe progress |
| 3-10s | Long wait | Progress bar with context |
| >10s | Very long | Progress + allow background tasks |

## 2. Empty States

Empty states are NOT errors. They are opportunities to guide users.

### Empty State Anatomy

```
┌───────────────────────────┐
│                           │
│       [Illustration]       │  ← Simple icon or illustration
│                           │
│   No projects yet          │  ← Clear title (what's empty)
│                           │
│   Create your first        │  ← Helpful description
│   project to get started.  │
│                           │
│   [+ Create Project]       │  ← Primary CTA
│                           │
│   Or import from CSV       │  ← Secondary action (optional)
│                           │
└───────────────────────────┘
```

### Types of Empty States

| Type | When | What to Show |
|---|---|---|
| **First-time** | New user, no data | Onboarding CTA, tutorial link |
| **Search no results** | Filter returned nothing | "No results for X" + clear filters button |
| **Cleared** | User deleted everything | "Nothing here yet" + create button |
| **Permission** | User lacks access | Explain why + request access CTA |

### Empty State Rules

1. **Never just say "No data."** Explain what will be here and how to create it.
2. **Always provide a CTA.** The empty state should push the user to the next action.
3. **Use illustrations sparingly.** A Lucide icon in a muted circle is enough. Don't over-design.
4. **Keep it in context.** Empty state should appear where the data would be — not a separate page.
5. **Match the layout.** Empty state fills the same container as the populated state would.

```tsx
// ✅ Good empty state
<Card className="flex flex-col items-center justify-center py-16">
  <div className="rounded-full bg-muted p-4 mb-4">
    <FolderOpen className="h-8 w-8 text-muted-foreground" />
  </div>
  <h3 className="text-lg font-semibold">No projects yet</h3>
  <p className="text-sm text-muted-foreground mt-1 mb-4">
    Create your first project to start tracking time.
  </p>
  <Button>
    <Plus className="mr-2 h-4 w-4" />
    Create Project
  </Button>
</Card>
```

## 3. Error States

### Error Hierarchy

| Level | Where | Component | Example |
|---|---|---|---|
| **Field error** | Inline, next to input | Form field message | "Email is required" |
| **Section error** | In content area | Alert banner | "Failed to load chart data" |
| **Page error** | Full page | Error page | 404, 500, offline |
| **Global error** | Toast / Sonner | Toast notification | "Auto-save failed" |

### Error Message Rules

1. **Plain language.** "We couldn't save your changes" not "Error: ECONNREFTECTED".
2. **Explain what happened.** "The server took too long to respond."
3. **Suggest a solution.** "Try again in a moment, or check your connection."
4. **Offer a retry.** Always provide a "Try again" button for recoverable errors.
5. **No blame.** Don't say "You entered wrong" — say "This email doesn't look right."

### Error Page Pattern

```
┌───────────────────────────┐
│                           │
│       [Error icon]         │
│                           │
│   Something went wrong     │
│                           │
│   We're not sure what      │
│   happened, but we've      │
│   been notified.           │
│                           │
│   [Try again] [Go home]    │
│                           │
└───────────────────────────┘
```

### Error Boundary (React)

Every route should have an error boundary:

```tsx
<ErrorBoundary fallback={<ErrorPage onRetry={reset} />}>
  <DashboardContent />
</ErrorBoundary>
```

### Form Validation Errors

- **When:** Validate on blur, not on every keystroke (too aggressive)
- **Where:** Below the field, in `text-destructive` color
- **What:** Specific, actionable message
- **How:** `aria-describedby` linking input to error message

```tsx
<FormField
  name="email"
  render={({ field, fieldState }) => (
    <FormItem>
      <FormLabel>Email</FormLabel>
      <FormControl>
        <Input
          {...field}
          aria-invalid={!!fieldState.error}
          aria-describedby={fieldState.error ? "email-error" : undefined}
        />
      </FormControl>
      {fieldState.error && (
        <p id="email-error" className="text-sm text-destructive">
          {fieldState.error.message}
        </p>
      )}
    </FormItem>
  )}
/>
```

## 4. Success States

### Success Feedback Hierarchy

| Action Scope | Feedback | Duration |
|---|---|---|
| **Minor** (toggle, save) | Toast | 3s |
| **Moderate** (create, update) | Toast + inline highlight | 4s |
| **Major** (import, migration) | Success page or banner | Until dismissed |
| **Destructive** (delete) | Undo toast | 5s with undo action |

### Toast Rules (Sonner)

- **Position:** Bottom-right (desktop), bottom-center (mobile)
- **Duration:** 4s default, 7s for errors (more reading time)
- **One at a time** for same action. Don't stack identical toasts.
- **Action toast:** Include "Undo" button for destructive actions.

```tsx
// Success
toast.success("Project created", { description: "You can start adding tasks now." });

// Destructive with undo
toast("Project deleted", {
  description: "Your project has been removed.",
  action: { label: "Undo", onClick: undoDelete },
});

// Error
toast.error("Failed to save", { description: "Check your connection and try again." });
```

### Success State Anti-Patterns

- ❌ Full-page success screen for minor actions — overkill
- ❌ Modal dialog for "Saved!" — just use a toast
- ❌ No feedback at all — user doesn't know if it worked
- ❌ Success message stays forever — should auto-dismiss
- ❌ Confetti animation — distracting, not professional (unless consumer app)

## State Decision Tree for AI Agents

```
Building a page/component? 
→ Does it fetch data?
  → YES → Implement ALL 4 states: loading, empty, error, success
  → NO → Does it have a form?
    → YES → Implement: idle, validating, success, error states
    → NO → Does it have a button action?
      → YES → Implement: idle, loading, success, error states
      → NO → Static content — no states needed
```
