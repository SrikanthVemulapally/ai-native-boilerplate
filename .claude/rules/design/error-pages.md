# Error Pages — Design Patterns

> Error pages are brand moments. A good 404 keeps users. A bad 500 loses them forever.
> Every project must have all 5 error pages designed and implemented before launch.

---

## Required Error Pages

| Page | Route | Trigger |
|---|---|---|
| **404 Not Found** | `/*` catch-all | Page doesn't exist, broken link |
| **500 Server Error** | Error boundary | Unhandled exception, API failure |
| **403 Forbidden** | Auth check | User lacks permission |
| **Offline** | Service worker | No network connection |
| **Maintenance** | Feature flag | Planned downtime |

---

## 404 — Not Found

**Goal:** Keep the user in the app. Never dead-end them.

### Structure
```
┌─────────────────────────────────────┐
│  [Subtle illustration or number]    │
│                                     │
│  Page not found                     │
│  The page you're looking for        │
│  doesn't exist or was moved.        │
│                                     │
│  [Search bar — optional]            │
│                                     │
│  [← Go back]  [Go to Dashboard →]  │
│                                     │
│  Popular pages:                     │
│  • Dashboard  • Projects  • Settings│
└─────────────────────────────────────┘
```

### Rules
- **Headline:** "Page not found" — clear, no jargon. NOT "404 Error."
- **Don't blame the user.** "The page you're looking for doesn't exist" not "You entered a wrong URL."
- **Two escape routes:** Back button + primary destination (dashboard/home).
- **Helpful suggestions:** Link to 3-5 popular/useful pages.
- **Optional search:** If your app has search, put it here.
- **No apology.** "Sorry for the inconvenience" is filler — skip it.
- **Subtle humor is OK** — a small illustration or playful text maintains brand. Don't overdo it.
- **Always include full navigation.** User should be able to navigate from here.

```tsx
// TanStack Router — catch-all 404
export const Route = createFileRoute('/*')({
  component: NotFoundPage,
})

function NotFoundPage() {
  const navigate = useNavigate()
  const router = useRouter()

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-4">
      <div className="text-center max-w-md">
        <p className="text-sm font-medium text-muted-foreground mb-2">404</p>
        <h1 className="text-3xl font-bold tracking-tight mb-4">Page not found</h1>
        <p className="text-muted-foreground mb-8">
          The page you're looking for doesn't exist or has been moved.
        </p>
        <div className="flex gap-3 justify-center">
          <Button variant="outline" onClick={() => router.history.back()}>
            ← Go back
          </Button>
          <Button onClick={() => navigate({ to: '/dashboard' })}>
            Go to Dashboard
          </Button>
        </div>
      </div>
    </div>
  )
}
```

---

## 500 — Server Error

**Goal:** Maintain trust. Communicate clearly. Give a recovery path.

### Structure
```
┌─────────────────────────────────────┐
│  [Simple error illustration]        │
│                                     │
│  Something went wrong               │
│  We're having trouble loading       │
│  this page right now.               │
│                                     │
│  [Try again]  [Go to Dashboard]     │
│                                     │
│  If this keeps happening,           │
│  contact support →                  │
│                                     │
│  Error ID: abc123 (copy)            │
└─────────────────────────────────────┘
```

### Rules
- **Headline:** "Something went wrong" — honest and human.
- **Take responsibility.** "We're having trouble" not "An error occurred" (passive).
- **Always show "Try again."** Most 500s are transient. One retry often works.
- **Error ID.** Auto-generate a trace ID, show it, let users copy it. Support team can look it up in Sentry.
- **Support link.** For B2B apps — link directly to support chat or email.
- **Don't show stack traces.** Ever. To anyone. Security risk.
- **Log to Sentry** from the error boundary before rendering this page.

```tsx
// React error boundary — catches rendering errors
import * as Sentry from '@sentry/react'

export function ErrorBoundaryFallback({ error, resetErrorBoundary }: FallbackProps) {
  const eventId = Sentry.captureException(error)

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-4">
      <div className="text-center max-w-md">
        <h1 className="text-3xl font-bold tracking-tight mb-4">Something went wrong</h1>
        <p className="text-muted-foreground mb-8">
          We're having trouble loading this page. This has been reported automatically.
        </p>
        <div className="flex gap-3 justify-center mb-6">
          <Button onClick={resetErrorBoundary}>Try again</Button>
          <Button variant="outline" asChild>
            <Link to="/dashboard">Go to Dashboard</Link>
          </Button>
        </div>
        {eventId && (
          <p className="text-xs text-muted-foreground">
            Error ID: <code className="font-mono">{eventId}</code>
            <button onClick={() => navigator.clipboard.writeText(eventId)}
                    className="ml-2 underline">Copy</button>
          </p>
        )}
      </div>
    </div>
  )
}

// Wrap your router with Sentry's error boundary
<Sentry.ErrorBoundary fallback={ErrorBoundaryFallback}>
  <RouterProvider router={router} />
</Sentry.ErrorBoundary>
```

---

## 403 — Forbidden / Unauthorized

**Goal:** Explain clearly what the user can't do and why, then direct them.

### Two Variants

**Variant A: Not logged in (redirect to login)**
```
┌──────────────────────────────────────┐
│  Sign in to continue                 │
│  You need to be signed in to         │
│  access this page.                   │
│                                      │
│  [Sign in →]  [Create account]       │
└──────────────────────────────────────┘
```

**Variant B: Logged in but wrong plan/role**
```
┌──────────────────────────────────────┐
│  You don't have access to this       │
│                                      │
│  This feature requires the           │
│  [Pro / Team / Enterprise] plan.     │
│                                      │
│  [Upgrade now →]  [Learn more]       │
│                                      │
│  Or contact your admin to            │
│  request access.                     │
└──────────────────────────────────────┘
```

### Rules
- **Variant A:** Automatically redirect to login with `returnTo` param. On success, redirect back.
- **Variant B:** Show exactly what plan or role is required. Make upgrade easy.
- **Never say "You are not authorized"** — say what they need to do instead.
- **Admin notification.** For team apps — offer to notify the admin to grant access.

```tsx
// TanStack Router — route-level auth guard
export const Route = createFileRoute('/admin')({
  beforeLoad: ({ context }) => {
    if (!context.auth.user) {
      throw redirect({ to: '/login', search: { returnTo: '/admin' } })
    }
    if (context.auth.user.role !== 'admin') {
      throw redirect({ to: '/403' })
    }
  },
})

// /403 page
function ForbiddenPage() {
  const { user } = useAuth()
  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className="text-center max-w-md">
        <h1 className="text-3xl font-bold mb-4">Access restricted</h1>
        <p className="text-muted-foreground mb-8">
          {user ? "You don't have permission to view this page." : "Sign in to continue."}
        </p>
        {user ? (
          <Button asChild><Link to="/dashboard">Go to Dashboard</Link></Button>
        ) : (
          <Button asChild><Link to="/login">Sign in</Link></Button>
        )}
      </div>
    </div>
  )
}
```

---

## Offline Page

**Goal:** Acknowledge reality. Show cached content if available. Queue actions.

### Structure
```
┌──────────────────────────────────────┐
│  You're offline                      │
│                                      │
│  Check your internet connection.     │
│  We'll reconnect automatically.      │
│                                      │
│  [Try reconnecting]                  │
│                                      │
│  ● 3 changes saved locally           │
│    They'll sync when you're back.    │
└──────────────────────────────────────┘
```

### Rules
- **Detect offline state.** `navigator.onLine` + `window.addEventListener('offline')`.
- **Non-blocking for minor features.** Not everything needs a full offline page — minor features show an inline banner.
- **Full offline page only** when the entire app is unavailable.
- **Show pending mutations.** "3 changes saved locally" gives users confidence their work is safe.
- **Auto-reconnect.** When `online` event fires, silently retry and dismiss the page.
- **Service worker required.** App shell must be cached for offline page to render at all.

```tsx
// Offline detection hook
function useOnlineStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine)
  useEffect(() => {
    const on = () => setIsOnline(true)
    const off = () => setIsOnline(false)
    window.addEventListener('online', on)
    window.addEventListener('offline', off)
    return () => { window.removeEventListener('online', on); window.removeEventListener('offline', off) }
  }, [])
  return isOnline
}

// Non-blocking offline banner (preferred over full page)
function OfflineBanner() {
  const isOnline = useOnlineStatus()
  if (isOnline) return null
  return (
    <div className="fixed top-0 left-0 right-0 z-50 bg-amber-500 text-amber-950
                    text-sm text-center py-2 px-4">
      You're offline — changes will sync when reconnected
    </div>
  )
}
```

---

## Maintenance Page

**Goal:** Set expectations. Communicate timeline. Don't leave users in the dark.

### Structure
```
┌──────────────────────────────────────┐
│  [Logo]                              │
│                                      │
│  We'll be right back                 │
│  We're performing scheduled          │
│  maintenance. Expected completion:   │
│  [time and timezone]                 │
│                                      │
│  Follow @yourapp for updates         │
│  [Twitter/X] [Status page]           │
└──────────────────────────────────────┘
```

### Rules
- **Static HTML file** — deploy before maintenance starts, works without your app running
- **Include estimated time.** Vague "back soon" = frustrated users. Give a real time.
- **Status page link.** statuspage.io, betteruptime.com — users can subscribe to updates
- **Social link.** Twitter/X for real-time updates
- **CDN/edge serving.** Cloudflare Page Rule or Workers route to serve maintenance.html directly

```typescript
// Cloudflare Worker — serve maintenance page for all routes
// wrangler.toml: [[routes]] pattern = "*.yourapp.com/*"
export default {
  async fetch(request: Request, env: Env) {
    const maintenanceMode = await env.FEATURE_FLAGS.get('maintenance_mode')
    if (maintenanceMode === 'true') {
      const html = await env.ASSETS.fetch('/maintenance.html')
      return new Response(html.body, {
        status: 503,
        headers: {
          'Content-Type': 'text/html',
          'Retry-After': '3600',
        }
      })
    }
    return env.ASSETS.fetch(request)
  }
}
```

---

## Error Page Design Tokens

All error pages share these design rules:
- **Centered layout.** `min-h-screen flex items-center justify-center`
- **Max width:** `max-w-md` for the content block
- **Hierarchy:** Large headline → short description → primary action → secondary action
- **No navigation chrome.** Error pages are standalone — no sidebar, topbar, or footer (except for 404)
- **Brand consistent.** Same fonts, same colors, same button styles as the rest of the app
- **Responsive.** Centered on all screen sizes, no horizontal overflow

---

## Error Page Checklist

- [ ] 404 page exists with navigation suggestions
- [ ] 500 error boundary catches all React rendering errors
- [ ] 500 page shows Sentry error ID (copyable)
- [ ] 403 handles both "not logged in" and "wrong role/plan" variants
- [ ] Offline handling — at minimum a non-blocking banner
- [ ] Maintenance page is a static HTML file (no JS dependency)
- [ ] All error pages tested in dark mode
- [ ] All error pages tested on mobile (375px)
- [ ] Error pages render without navigation (app shell down)
