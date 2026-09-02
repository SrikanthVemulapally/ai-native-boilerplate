# Cross-Platform Rules
> Loaded when: `config.stack` includes `tauri` OR `config.features.pwa === true`
> Cross-platform support is not an afterthought — it's a first-class requirement.

---

## The Golden Rule

**Never write platform-specific code without a rule for what happens on other platforms.**
If it works on macOS and you haven't tested Windows — it's broken on Windows.

---

## Platform Matrix

| Platform | Targets | Build Runner | Installer |
|---|---|---|---|
| macOS Apple Silicon | `aarch64-apple-darwin` | `macos-latest` | `.dmg` |
| macOS Intel | `x86_64-apple-darwin` | `macos-latest` | `.dmg` |
| Windows 10/11 | `x86_64-pc-windows-msvc` | `windows-latest` | `.msi` (WiX) |
| Linux (most distros) | `x86_64-unknown-linux-gnu` | `ubuntu-22.04` | `.AppImage` |
| Linux (Debian/Ubuntu) | `x86_64-unknown-linux-gnu` | `ubuntu-22.04` | `.deb` |
| Linux (RedHat/Fedora) | `x86_64-unknown-linux-gnu` | `ubuntu-22.04` | `.rpm` |

**Universal binaries:** macOS requires BOTH targets — never ship Intel-only or M1-only.
Build `aarch64` and `x86_64` separately, then use `lipo` to create a universal binary OR ship both and let the user download the right one.

---

## File Paths — The #1 Source of Platform Bugs

### The Problem
```typescript
// ❌ WRONG — breaks on Windows (backslash separator)
const configPath = `${appDir}/config/settings.json`

// ❌ WRONG — hardcoded Unix path
const logDir = '/var/log/myapp'

// ✅ CORRECT — use Tauri path APIs
import { appDataDir, join } from '@tauri-apps/api/path'
const configPath = await join(await appDataDir(), 'config', 'settings.json')
```

### Rules
- **Never concatenate paths with `/` or `\`** — always use `path.join()` in Node.js or Tauri path APIs in the frontend.
- **Never hardcode Unix paths** (`/home/user`, `/tmp`, `/etc`).
- **Never hardcode Windows paths** (`C:\Users`, `%APPDATA%`).
- **Use Tauri path APIs** for all app-relative paths: `appDataDir()`, `appConfigDir()`, `appLogDir()`, `tempDir()`.
- **In Rust:** use `tauri::Manager::path()` — never `std::env::home_dir()` (deprecated, buggy on Windows).

### Platform App Data Directories (reference)
| Platform | App Data | Config | Logs |
|---|---|---|---|
| Windows | `%APPDATA%\<BundleId>\` | same | `%APPDATA%\<BundleId>\logs\` |
| macOS | `~/Library/Application Support/<BundleId>/` | `~/Library/Preferences/` | `~/Library/Logs/<BundleId>/` |
| Linux | `~/.local/share/<BundleId>/` | `~/.config/<BundleId>/` | `~/.local/share/<BundleId>/logs/` |

---

## Keyboard Shortcuts — Cmd vs Ctrl

### The Problem
Hardcoding `Ctrl+S` works on Windows/Linux but is wrong on macOS (should be `⌘S`).
Showing `⌘` on Windows is confusing.

### The Rule
```typescript
// ✅ Platform-aware shortcut detection
const isMac = navigator.platform.toUpperCase().includes('MAC')
const modKey = isMac ? '⌘' : 'Ctrl'

// Display
<kbd>{modKey}+S</kbd>  // Shows ⌘S on Mac, Ctrl+S on Windows/Linux

// Keyboard handler
if ((e.metaKey || e.ctrlKey) && e.key === 's') {
  // Works on both: metaKey = ⌘ on Mac, ctrlKey = Ctrl on Win/Linux
  handleSave()
}
```

### Shortcut Mapping Table
| Action | macOS | Windows/Linux |
|---|---|---|
| Save | `⌘S` | `Ctrl+S` |
| Copy | `⌘C` | `Ctrl+C` |
| Paste | `⌘V` | `Ctrl+V` |
| Undo | `⌘Z` | `Ctrl+Z` |
| Find | `⌘F` | `Ctrl+F` |
| New | `⌘N` | `Ctrl+N` |
| Settings | `⌘,` | — (no standard) |
| Quit | `⌘Q` | `Alt+F4` |
| Close window | `⌘W` | `Ctrl+W` |

### Tauri Global Shortcuts
```rust
// Register platform-aware global shortcut
use tauri_plugin_global_shortcut::{Code, Modifiers, ShortcutState};

app.global_shortcut().on_shortcut(
    #[cfg(target_os = "macos")]
    "Super+Shift+P",  // ⌘⇧P on macOS
    #[cfg(not(target_os = "macos"))]
    "Ctrl+Shift+P",   // Ctrl+Shift+P on Windows/Linux
    |_app, _shortcut, event| {
        if event.state == ShortcutState::Pressed {
            toggle_window();
        }
    }
)?;
```

---

## Font Rendering Differences

### The Reality
- **macOS** — subpixel antialiasing, fonts look heavier/bolder
- **Windows** — ClearType antialiasing, fonts look thinner/lighter
- **Linux** — varies by distro, often grayscale antialiasing

### Rules
- **Test font weights on all platforms.** `font-weight: 400` on macOS ≠ `font-weight: 400` on Windows.
- **Never rely on system fonts.** Always specify a web font with `font-family` fallback chain.
- **Self-host fonts.** System font availability varies — `Inter` is not preinstalled on Windows.
- **Font smoothing:**
```css
/* Apply globally — improves rendering on macOS */
body {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  /* Note: this can make text too thin on Windows — test both */
}
```
- **Inter on Windows** — use `font-weight: 450` or `500` where you'd use `400` on macOS. The visual weight difference is significant.
- **Test at 100% zoom.** Windows defaults to 125% DPI scaling — always test at both 100% and 125%.

---

## Scrollbar Differences

### The Problem
- **macOS** — scrollbars hidden by default, appear on scroll (overlay, no layout impact)
- **Windows** — scrollbars always visible (take up layout space, ~17px wide)
- **Linux** — varies

This means a layout that looks clean on macOS may have a horizontal overflow or jank on Windows because the scrollbar suddenly takes 17px.

### Rules
```css
/* ✅ Style scrollbars consistently — thin + branded */
* {
  scrollbar-width: thin;                          /* Firefox */
  scrollbar-color: hsl(var(--border)) transparent; /* Firefox */
}

/* Chrome/Safari/Edge */
*::-webkit-scrollbar { width: 6px; height: 6px; }
*::-webkit-scrollbar-track { background: transparent; }
*::-webkit-scrollbar-thumb {
  background: hsl(var(--border));
  border-radius: 3px;
}
*::-webkit-scrollbar-thumb:hover {
  background: hsl(var(--muted-foreground));
}
```

- **Never assume scrollbar is invisible.** Calculate layouts with scrollbar width in mind.
- **Test with `overflow: scroll` forced.** Use browser DevTools to force scrollbar visibility.
- **Overlay scrollbars only with care.** Don't use `overflow: overlay` (non-standard, removed from Chromium).

---

## Windows Installer & SmartScreen

### SmartScreen Reputation Problem
New `.msi` installers from unknown publishers show a blue "Windows protected your PC" warning.
This kills user trust and conversion. The solution:

1. **Extended Validation (EV) Certificate** — required for instant reputation, costs ~$400/yr
   - Buy from: DigiCert, Sectigo, GlobalSign
   - EV certs require identity verification (2-5 business days)
   - Store in GitHub Actions secrets — never on developer machines
2. **OV Certificate** (Organization Validation) — cheaper, but still shows SmartScreen for new apps
3. **Reputation building** — alternative: enough installs + no malware reports builds reputation over time (~months)

### WiX Installer Config (Tauri default)
```json
// src-tauri/tauri.conf.json
{
  "bundle": {
    "windows": {
      "wix": {
        "template": null,
        "language": "en-US"
      },
      "nsis": {
        "installMode": "perUser"  // ← never perMachine (requires admin)
      }
    }
  }
}
```

**Rules:**
- **Always `perUser` install.** Never require admin/UAC elevation for install.
- **Store data in `%APPDATA%`.** Never `Program Files`.
- **Test on Windows 10 AND 11.** UI differences in title bars, window chrome.
- **Test with Windows Defender enabled.** Ensure no false-positive detection.

---

## macOS Code Signing & Notarization

### Required for Distribution Outside App Store
Without notarization, Gatekeeper shows "Apple could not verify..." — users can't open the app.

### Step-by-Step (CI)
```yaml
# GitHub Actions secrets required:
# APPLE_CERTIFICATE — base64-encoded .p12 file
# APPLE_CERTIFICATE_PASSWORD — .p12 password
# APPLE_SIGNING_IDENTITY — "Developer ID Application: Your Name (TEAM_ID)"
# APPLE_ID — your Apple ID email
# APPLE_PASSWORD — app-specific password (not your Apple ID password)
# APPLE_TEAM_ID — 10-character team ID

- name: Import Apple certificate
  run: |
    echo $APPLE_CERTIFICATE | base64 --decode > certificate.p12
    security create-keychain -p "" build.keychain
    security import certificate.p12 -k build.keychain -P $APPLE_CERTIFICATE_PASSWORD -A
    security list-keychains -s build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p "" build.keychain
```

Tauri handles the actual signing and notarization via `tauri-action` when these env vars are set.

### Rules
- **Certificate expires.** Set a calendar reminder 60 days before expiry. Expired cert = broken updates.
- **Notarization takes 2-10 minutes.** Factor into release CI time.
- **Staple the notarization ticket.** `xcrun stapler staple` — users can install offline.
- **Hardened runtime required.** Set `"hardenedRuntime": true` in tauri.conf.json for notarization.
- **Entitlements.** Declare all entitlements (network, camera, microphone) — undeclared = revoked on use.

---

## Linux Distribution Formats

### AppImage (default, recommended)
- No install required — executable runs anywhere
- Works on all major distros (Ubuntu, Fedora, Arch, openSUSE)
- User just `chmod +x` and run

### .deb (Debian/Ubuntu — 60%+ of Linux desktop market)
```yaml
# Tauri builds .deb automatically
# tauri.conf.json
{
  "bundle": {
    "linux": {
      "deb": { "depends": ["libwebkit2gtk-4.1-0", "libappindicator3-1"] }
    }
  }
}
```

### .rpm (Fedora/RHEL/openSUSE)
```yaml
# Tauri builds .rpm automatically
{
  "bundle": {
    "linux": {
      "rpm": { "depends": ["webkit2gtk4.1", "libappindicator-gtk3"] }
    }
  }
}
```

### Rules
- **Ship all three: AppImage + .deb + .rpm** when targeting Linux.
- **Test on Ubuntu LTS** (22.04, 24.04) — largest Linux desktop audience.
- **No snap/flatpak required** unless targeting a store specifically.
- **AppImage auto-update works.** Use AppImageUpdate or Tauri's built-in updater.
- **Linux system tray** — requires `libappindicator3` dep. Always declare it.

---

## Web: Cross-Browser Testing

### Browser Matrix (Required)
| Browser | Engine | Market Share | Platform |
|---|---|---|---|
| Chrome | Blink/V8 | ~65% | Win/Mac/Linux/Android |
| Safari | WebKit/JSC | ~20% | macOS/iOS |
| Firefox | Gecko/SpiderMonkey | ~3% | Win/Mac/Linux |
| Edge | Blink/V8 | ~5% | Win/Mac |
| Samsung Internet | Blink | ~3% | Android |

**Minimum test matrix:** Chrome + Safari + Firefox. Always.

### Safari-Specific Gotchas
```css
/* ❌ Gap in flex — broken Safari < 14.1 */
.container { display: flex; gap: 16px; }

/* ✅ Safe for older Safari */
.container { display: flex; }
.container > * + * { margin-left: 16px; }

/* ❌ aspect-ratio — broken Safari < 15 */
.box { aspect-ratio: 16 / 9; }

/* ✅ Safe fallback */
.box { aspect-ratio: 16 / 9; }
@supports not (aspect-ratio: 1) {
  .box { padding-bottom: 56.25%; height: 0; }
}
```

### Safari Rules
- **100vh bug.** On iOS Safari, `100vh` includes the address bar. Use `100dvh` (dynamic viewport height) — available Safari 15.4+.
- **Position: fixed with keyboard.** iOS Safari shifts fixed elements when the keyboard appears. Use `position: sticky` where possible.
- **Scroll momentum.** `-webkit-overflow-scrolling: touch` is deprecated. Use `overscroll-behavior` instead.
- **Date input.** `<input type="date">` renders differently on Safari — consider a custom picker for consistency.
- **localStorage quota.** iOS Safari limits to 5MB in private mode. Handle `QuotaExceededError`.
- **IndexedDB in private mode.** Throws errors in Safari private mode. Always wrap in try/catch with fallback.
- **Custom fonts in WebKit.** Font display may differ — always test.

### Playwright Cross-Browser Config
```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
    { name: 'mobile-safari', use: { ...devices['iPhone 13'] } },
  ],
})
```

---

## Tauri vs Electron — Decision Guide

| Factor | Tauri | Electron |
|---|---|---|
| Bundle size | ~5MB | ~80-150MB |
| Memory | ~50MB | ~150-300MB |
| Language | Rust + JS | Node.js + JS |
| System WebView | ✅ (OS default) | ❌ (bundled Chromium) |
| Cross-browser consistency | ⚠️ (WebView varies) | ✅ (always Chromium) |
| Community/ecosystem | Growing | Mature |
| Code signing | Same | Same |
| Native APIs | Via Tauri plugins | Via Node.js |
| When to choose | New projects, performance critical | Large team, max ecosystem, existing Node.js |

**Our default: Tauri.** Override only when: team is full Node.js, or you need guaranteed rendering consistency across all Windows versions (older Win10 has Edge 18 WebView2 issues).

---

## Cross-Platform Testing Checklist

Before any release:
- [ ] Built and launched on macOS (M1/M2 native)
- [ ] Built and launched on macOS Intel (or tested via Rosetta)
- [ ] Built and launched on Windows 10 (at 100% AND 125% DPI)
- [ ] Built and launched on Windows 11
- [ ] Built and launched on Ubuntu 22.04 LTS
- [ ] Web tested on Chrome + Safari + Firefox
- [ ] Web tested on iOS Safari (real device, not simulator)
- [ ] Web tested on Android Chrome
- [ ] Keyboard shortcuts correct on each platform
- [ ] Fonts render acceptably on Windows (check weight)
- [ ] Scrollbars styled consistently
- [ ] File paths work on Windows (no forward-slash concat)
- [ ] Auto-update works end-to-end on each platform
- [ ] Installer signed (Windows EV cert, macOS notarized)
- [ ] System tray works correctly on each OS
