# Feature Rules: Auto-Update
> Loaded when: features.auto-update=true OR variants.agent.enabled=true
> ⚠️ MANDATORY when profile=agent-web. This is not optional.

## Why This Exists

Desktop agents that cannot update themselves become a maintenance nightmare:
- Users run outdated, insecure versions indefinitely
- Bug fixes never reach the field
- You cannot deprecate old API versions safely
- Support burden multiplies across version fragmentation

**An agent without auto-update is incomplete. Full stop.**

## Required Components

### 1. Update Server Endpoint (Cloudflare Worker)

```typescript
// workers/api/src/routes/updates/index.ts
// Pattern: GET /updates/:target/:arch/:current_version
// Returns: { version, url, signature, body } or 204 if up to date

export async function checkUpdate(c: Context) {
  const { target, arch, current_version } = c.req.param()
  
  const latest = await getLatestRelease(c.env.GITHUB_TOKEN)
  
  if (semver.lte(latest.version, current_version)) {
    return new Response(null, { status: 204 }) // Up to date
  }

  const asset = findAsset(latest.assets, target, arch)
  
  return c.json({
    version: latest.version,
    notes: latest.body,
    pub_date: latest.published_at,
    platforms: {
      [`${target}-${arch}`]: {
        signature: asset.signature,
        url: asset.url,
      }
    }
  })
}
```

### 2. Tauri Updater Config

```json
// src-tauri/tauri.conf.json
{
  "plugins": {
    "updater": {
      "active": true,
      "endpoints": [
        "https://api.yourapp.com/updates/{{target}}/{{arch}}/{{current_version}}"
      ],
      "dialog": true,
      "pubkey": "YOUR_BASE64_PUBLIC_KEY_HERE"
    }
  }
}
```

### 3. Update Check Logic (Rust)

```rust
// src-tauri/src/auto_update.rs
use tauri_plugin_updater::UpdaterExt;
use tauri_plugin_notification::NotificationExt;

pub async fn check_and_notify(app: tauri::AppHandle) {
    match app.updater().unwrap().check().await {
        Ok(Some(update)) => {
            // Always notify user — never silent-install
            app.notification()
                .builder()
                .title("Update Available")
                .body(&format!("Version {} is ready to install.", update.version))
                .show()
                .unwrap();

            // Trigger from system tray or user action
        }
        Ok(None) => {} // Up to date
        Err(e) => {
            eprintln!("Update check failed: {}", e);
            // Non-fatal — log, don't crash
        }
    }
}
```

### 4. GitHub Actions Release Workflow

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  build:
    strategy:
      matrix:
        include:
          - platform: macos-latest
            args: '--target aarch64-apple-darwin'
          - platform: macos-latest
            args: '--target x86_64-apple-darwin'
          - platform: windows-latest
            args: ''
          - platform: ubuntu-22.04
            args: ''
    
    steps:
      - uses: actions/checkout@v4
      - uses: tauri-apps/tauri-action@v0
        env:
          TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY }}
          TAURI_SIGNING_PRIVATE_KEY_PASSWORD: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY_PASSWORD }}
        with:
          tagName: v__VERSION__
          releaseName: 'Release v__VERSION__'
          releaseBody: 'See CHANGELOG.md for details.'
          releaseDraft: false
```

## Key Signing (One-Time Setup)

```bash
# Generate signing keypair (do this ONCE, store private key securely)
pnpm tauri signer generate -w ~/.tauri/myapp.key

# Add to GitHub Actions secrets:
# TAURI_SIGNING_PRIVATE_KEY = contents of ~/.tauri/myapp.key
# Add public key to tauri.conf.json > plugins > updater > pubkey
```

## Rules

- **Check for updates on app start.** Not blocking — background check.
- **Check again every 4 hours for long-running agents.**
- **Never auto-install without user consent** (for apps handling sensitive data).
- **Always show what changed** (release notes / CHANGELOG entry).
- **Update must not interrupt active user sessions.** Queue for next restart.
- **Rollback capability** — keep previous version installer in case of emergency.
- **Version must follow semver strictly.** `pnpm version patch|minor|major` to bump.
- **CHANGELOG.md updated on every release.** Automated from conventional commits.
