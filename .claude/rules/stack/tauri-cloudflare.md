# Stack Rules: Tauri (Desktop Agent) + Cloudflare (Web/API)
> Loaded when: variants.agent.framework=tauri
> Extends: tanstack-cloudflare.md

## Monorepo Structure (Agent + Web)

```
apps/
  agent/                  ← Tauri desktop app
    src-tauri/
      src/
        main.rs           ← Entry point
        commands/         ← Tauri commands (IPC bridge)
        services/         ← Business logic (pure Rust)
        state/            ← App state management
        auto_update.rs    ← Update logic (MANDATORY)
      Cargo.toml
      tauri.conf.json
    src/                  ← Agent frontend (React/TS)
      components/
      lib/
        ipc.ts            ← Type-safe Tauri command wrappers
        store.ts          ← Zustand store
      main.tsx
  web/                    ← Web admin/dashboard (TanStack Start)
  
workers/                  ← Cloudflare Workers (shared API)

packages/
  shared/                 ← Types shared: agent + web + workers
  agent-sdk/              ← Typed API client for agent↔API communication
```

## ⚠️ AUTO-UPDATE IS MANDATORY

**The agent MUST implement auto-update. No exceptions. No workarounds.**

Why: A desktop agent without auto-update creates a fragmented fleet of versions that is impossible to maintain, debug, or deprecate safely.

```rust
// src-tauri/src/auto_update.rs — required file
use tauri_plugin_updater::UpdaterExt;

pub async fn check_for_updates(app: tauri::AppHandle) -> Result<(), Box<dyn std::error::Error>> {
    let update = app.updater()?.check().await?;
    
    if let Some(update) = update {
        // Notify user via system tray / notification
        // Download in background
        // Install on next restart
        update.download_and_install(|_chunk_length, _content_length| {}, || {}).await?;
    }
    
    Ok(())
}
```

**Auto-update requirements:**
- `tauri-plugin-updater` installed and configured
- `tauri.conf.json` has `updater` section with endpoint
- Updates signed with private key (public key in config)
- Update server endpoint exists in Cloudflare Worker
- Version bumped via `pnpm version` (auto-tags git)
- GitHub Actions workflow builds + signs + uploads to releases
- User is ALWAYS notified before installation (never silent install without consent on data-sensitive apps)

```json
// tauri.conf.json updater section
{
  "plugins": {
    "updater": {
      "active": true,
      "endpoints": ["https://api.yourapp.com/updates/{{target}}/{{arch}}/{{current_version}}"],
      "dialog": true,
      "pubkey": "YOUR_UPDATER_PUBLIC_KEY"
    }
  }
}
```

## Tauri IPC Rules

- **All Tauri commands are typed end-to-end.** Rust return type maps to TypeScript type in `packages/shared`.
- **No direct `invoke` calls in components.** Wrap in `lib/ipc.ts` functions.
- **All sensitive operations in Rust, not JS.** JS side is UI only.
- **Capability-based permissions.** Only allow what the app explicitly needs in `capabilities/`.

```typescript
// ✅ Correct — typed IPC wrapper in lib/ipc.ts
export async function captureActivity(): Promise<ActivitySegment> {
  return invoke<ActivitySegment>('capture_activity')
}

// ❌ Wrong — raw invoke in component
const data = await invoke('capture_activity') // untyped
```

## Agent State Management

- **Zustand for UI state.** No Redux, no Context for global state.
- **Persistent state via Tauri Store plugin.** `@tauri-apps/plugin-store` for settings/config.
- **Outbox pattern for API sync.** Agent queues events locally, flushes on network availability.

```typescript
// Outbox pattern — required for any agent→API sync
export class OutboxQueue {
  private queue: PendingEvent[] = []
  
  async add(event: AgentEvent): Promise<void> {
    await store.set(`outbox:${uuidv7()}`, event) // Persist first
    this.queue.push(event)
  }
  
  async flush(): Promise<void> {
    // Send in batches, mark as sent, clean up
  }
}
```

## System Tray Rules

- **All long-running agents MUST have a system tray icon.**
- **Tray shows status** (running, error, syncing, offline).
- **Tray has: Open, Pause/Resume, Settings, Check for Updates, Quit.**
- **App window can be hidden but agent never stops on window close.**

## Security Rules (Agent-Specific)

- **No secrets stored in plain text.** Use OS keychain via `tauri-plugin-keystore`.
- **API tokens stored in keychain, not Tauri Store.**
- **All network calls to your API only.** No third-party calls from Rust without explicit review.
- **Code signing is mandatory for distribution.** macOS notarization + Windows Authenticode.
- **CSP configured in tauri.conf.json.** No `unsafe-inline` or `unsafe-eval`.

## Build & Distribution

- **GitHub Actions builds all 3 platforms** (macOS arm64 + x64, Windows x64, Linux x64).
- **Artifacts uploaded to GitHub Releases** (used by auto-updater).
- **Version follows semver strictly.** Bump via `pnpm version patch|minor|major`.
- **Release notes are mandatory.** `CHANGELOG.md` updated on every release.
