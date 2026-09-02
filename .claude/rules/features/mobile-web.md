# Mobile Web & PWA Rules
> Loaded when: `config.features.pwa === true` OR always for web variants (mobile IS a platform)
> Mobile is not a breakpoint — it's a different usage context with different physics, constraints, and expectations.

---

## Mobile-First Is Non-Negotiable

Design for the smallest screen first, then expand. Never "make it work on mobile" as a last step.

**Target devices:**
- iOS Safari (iPhone SE — 375px wide — worst case)
- Android Chrome (Pixel 5 — 393px wide)
- Tablet (768px — iPad, Android)

---

## Viewport & Layout Rules

```html
<!-- Required in every HTML document -->
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
```

- `viewport-fit=cover` — required for iPhone notch/Dynamic Island safe areas
- Never set `user-scalable=no` — accessibility violation, users need to zoom

### Safe Area Insets (iPhone Notch/Dynamic Island)
```css
/* ✅ Always account for safe areas */
.bottom-nav {
  padding-bottom: max(env(safe-area-inset-bottom), 16px);
}

.top-header {
  padding-top: max(env(safe-area-inset-top), 16px);
}

/* Tailwind equivalent */
.pb-safe { padding-bottom: env(safe-area-inset-bottom); }
```

### 100vh Problem (iOS Safari)
```css
/* ❌ WRONG — 100vh includes browser chrome on iOS Safari */
.full-screen { height: 100vh; }

/* ✅ CORRECT — use dynamic viewport height */
.full-screen { height: 100dvh; } /* Safari 15.4+, Chrome 108+ */

/* ✅ Fallback for older browsers */
.full-screen {
  height: 100vh;
  height: 100dvh; /* overrides if supported */
}
```

---

## Touch Targets

- **Minimum touch target: 44×44px** (Apple HIG) / **48×48dp** (Material Design)
- **Visual size can be smaller** — use padding to expand the touch area
- **Spacing between targets: minimum 8px**

```css
/* ✅ Small icon with large touch target */
.icon-button {
  width: 24px;
  height: 24px;
  padding: 10px; /* expands touch target to 44×44 */
}
```

---

## iOS Safari Specific Rules

### Keyboard Behavior
- `position: fixed` elements shift when the software keyboard appears on iOS
- Use `position: sticky` for elements that must stay visible with keyboard open
- Listen for `visualViewport` resize to detect keyboard appearance:

```typescript
window.visualViewport?.addEventListener('resize', () => {
  const keyboardHeight = window.innerHeight - window.visualViewport!.height
  document.documentElement.style.setProperty(
    '--keyboard-height',
    `${keyboardHeight}px`
  )
})
```

### Form Inputs
- `<input type="text">` on iOS triggers zoom if `font-size < 16px` — always use `font-size: 16px` minimum on inputs
- `autocomplete="off"` doesn't fully work on iOS — Safari ignores it for password managers
- `inputmode` attribute controls soft keyboard type:

```html
<input inputmode="numeric" />    <!-- Number pad -->
<input inputmode="email" />      <!-- Email keyboard -->
<input inputmode="tel" />        <!-- Phone keyboard -->
<input inputmode="url" />        <!-- URL keyboard -->
```

### Scroll Behavior
```css
/* ✅ Momentum scrolling on iOS */
.scrollable {
  overflow-y: scroll;
  -webkit-overflow-scrolling: touch; /* deprecated but still needed for older iOS */
  overscroll-behavior: contain;       /* prevent scroll chaining */
}
```

### Storage Limits
```typescript
// ❌ Don't assume localStorage works in private mode
try {
  localStorage.setItem('key', 'value')
} catch (e) {
  // iOS Safari private mode throws QuotaExceededError
  // Fall back to in-memory storage or sessionStorage
  console.warn('localStorage unavailable, using memory fallback')
}
```

### Other iOS Gotchas
- **`Date()` parsing** — `new Date('2026-01-01')` returns Invalid Date on some iOS versions. Always use explicit ISO 8601 with time: `new Date('2026-01-01T00:00:00Z')`
- **`<select>` element** — renders as native iOS picker — cannot be styled. Use a custom dropdown component for consistent UX
- **Tap delay** — removed in iOS 13+, but add `touch-action: manipulation` to interactive elements to eliminate 300ms delay on older iOS
- **Audio autoplay** — blocked until user interaction. Never autoplay audio without user gesture
- **WebGL** — limited on older iOS devices. Check `WebGLRenderingContext` availability

---

## Responsive Breakpoints

```typescript
// Tailwind config — standard breakpoints
// sm: 640px   → landscape phone
// md: 768px   → tablet
// lg: 1024px  → laptop
// xl: 1280px  → desktop
// 2xl: 1536px → large desktop

// Custom breakpoints for specific needs
screens: {
  'xs': '375px',    // iPhone SE (absolute minimum)
  'sm': '640px',
  'md': '768px',
  'lg': '1024px',
  'xl': '1280px',
  '2xl': '1536px',
  '3xl': '1920px',  // Wide desktop / TV
}
```

### Layout Rules Per Breakpoint

| Component | Mobile (<768px) | Tablet (768-1024px) | Desktop (>1024px) |
|---|---|---|---|
| Navigation | Bottom tab bar or hamburger | Sidebar (collapsible) | Sidebar (fixed) |
| Data table | Card list | Horizontal scroll table | Full table |
| Forms | Single column | Single column | Two column |
| Dashboard | Single column KPIs + charts | 2-column grid | Full grid |
| Modals | Full screen | Centered (80% width) | Centered (600px max) |
| Sidebar | Off-canvas drawer | Collapsible | Always visible |

---

## Progressive Web App (PWA)

Enable when `config.features.pwa === true`.

### Required Files
```
public/
  manifest.json         ← Web App Manifest
  sw.js                 ← Service Worker (or use Workbox)
  icons/
    icon-192.png        ← Android / home screen
    icon-512.png        ← Android splash / maskable
    apple-touch-icon.png ← iOS home screen (180×180)
    favicon.ico         ← Browser tab
    favicon.svg         ← Modern browsers (scalable)
```

### Web App Manifest
```json
{
  "name": "My App",
  "short_name": "App",
  "description": "App description",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#09090b",
  "theme_color": "#18181b",
  "orientation": "portrait-primary",
  "icons": [
    { "src": "/icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/icon-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" },
    { "src": "/icons/apple-touch-icon.png", "sizes": "180x180", "type": "image/png" }
  ],
  "screenshots": [
    { "src": "/screenshots/desktop.png", "sizes": "1280x720", "form_factor": "wide" },
    { "src": "/screenshots/mobile.png", "sizes": "390x844", "form_factor": "narrow" }
  ]
}
```

### Service Worker (Workbox)
```typescript
// Use Workbox via vite-plugin-pwa — don't write service worker from scratch
// vite.config.ts
import { VitePWA } from 'vite-plugin-pwa'

VitePWA({
  registerType: 'autoUpdate',
  workbox: {
    globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
    runtimeCaching: [
      {
        urlPattern: /^https:\/\/api\./,
        handler: 'NetworkFirst',   // API: try network, fall back to cache
        options: { cacheName: 'api-cache', expiration: { maxAgeSeconds: 300 } }
      }
    ]
  }
})
```

### Caching Strategy Rules
| Resource | Strategy | Why |
|---|---|---|
| HTML shell | `NetworkFirst` | Always fresh |
| JS/CSS bundles | `CacheFirst` (hashed names) | Immutable — hash changes on update |
| API responses | `NetworkFirst` | Fresh data preferred |
| Images | `CacheFirst` | Slow to load, rarely change |
| Fonts | `CacheFirst` (1 year) | Self-hosted, versioned |

### Install Prompt
```typescript
// ✅ Custom install prompt — better UX than browser default
let deferredPrompt: BeforeInstallPromptEvent | null = null

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault()
  deferredPrompt = e as BeforeInstallPromptEvent
  showInstallButton()  // Show your custom "Install App" button
})

async function promptInstall() {
  if (!deferredPrompt) return
  deferredPrompt.prompt()
  const { outcome } = await deferredPrompt.userChoice
  if (outcome === 'accepted') trackEvent('pwa_installed')
  deferredPrompt = null
}
```

**Install prompt rules:**
- Never show on first visit — wait until user has visited 2+ times or after a meaningful action
- Don't use the browser's default prompt — it's confusing. Always use `beforeinstallprompt`
- Show the prompt contextually: after signup completion, after a "save" action, in settings

### Offline UX
```typescript
// Detect online/offline state
const [isOnline, setIsOnline] = useState(navigator.onLine)

useEffect(() => {
  const handleOnline = () => setIsOnline(true)
  const handleOffline = () => setIsOnline(false)
  window.addEventListener('online', handleOnline)
  window.addEventListener('offline', handleOffline)
  return () => {
    window.removeEventListener('online', handleOnline)
    window.removeEventListener('offline', handleOffline)
  }
}, [])
```

**Offline rules:**
- Show a non-blocking banner when offline: "You're offline. Some features may be limited."
- Cache critical app shell — the UI must render even without network
- Queue mutations (POST/PUT/DELETE) when offline, sync when reconnected
- Never show an error when offline — show the offline state gracefully

---

## Mobile Performance Budgets

| Metric | Budget | Why |
|---|---|---|
| First Contentful Paint | < 1.8s on 4G | Users leave after 3s |
| LCP (Largest Contentful Paint) | < 2.5s on 4G | Core Web Vital |
| Total Blocking Time | < 200ms | Interaction responsiveness |
| JS bundle (initial) | < 100KB gzipped | Mobile CPUs are slow to parse JS |
| Image sizes | WebP, lazy loaded | Mobile data is expensive |
| Fonts | Self-hosted, `font-display: swap` | No FOIT on slow connections |

### Image Optimization
```html
<!-- ✅ Responsive images with WebP -->
<picture>
  <source srcset="/hero.webp" type="image/webp" />
  <img src="/hero.jpg" alt="Hero" loading="lazy" decoding="async"
       width="1200" height="630" />
</picture>

<!-- ✅ Above-fold images: no lazy loading -->
<img src="/logo.svg" alt="Logo" loading="eager" />
```

---

## Mobile Testing Checklist

- [ ] Tested on real iPhone (not just simulator) — iOS Safari behaves differently
- [ ] Tested on real Android device — Chrome on Android differs from desktop Chrome  
- [ ] No horizontal scroll on any screen width ≥ 375px
- [ ] All touch targets ≥ 44×44px
- [ ] Forms don't trigger zoom (font-size ≥ 16px on inputs)
- [ ] No fixed elements broken by software keyboard
- [ ] Safe area insets applied (notch/Dynamic Island)
- [ ] Offline state handled gracefully
- [ ] PWA installable (if enabled) — Lighthouse PWA audit passes
- [ ] Performance: LCP < 2.5s on throttled 4G in Lighthouse
- [ ] No content behind bottom navigation bar
