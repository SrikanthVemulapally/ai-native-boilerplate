# Tauri Rules — Desktop Agent (Variant B)
> Loaded when `config.variant === "agent-web"` or `config.stack` includes `tauri`.
> Desktop development has unique requirements: IPC security, code signing, auto-update, offline-first.

---

## Tauri Architecture

```
┌─────────────────────────────────────────┐
│  WebView (React / TanStack)              │  ← UI layer
│  ─────────────────────────────────────  │
│  Tauri JS API + invoke()                 │  ← IPC bridge
│  ─────────────────────────────────────  │
│  Rust commands (#[tauri::command])       │  ← Business logic
│  ─────────────────────────────────────  │
│  SQLite (rusqlite / sqlx)               │  ← Local data store
│  ─────────────────────────────────────  │
│  Cloudflare ingest / sync               │  ← Remote sync (outbox)
└─────────────────────────────────────────┘
```

---

## IPC Security — Critical

### The Golden Rule
**Never trust data arriving via `invoke()` from the frontend.** The WebView is an untrusted surface.

```rust
// ✅ CORRECT — validate every parameter in the command
#[tauri::command]
async fn create_segment(
    db: State<'_, Database>,
    segment: SegmentInput,  // Deserialize + validate in SegmentInput's impl
) -> Result<Segment, AppError> {
    // SegmentInput implements validation in its deserialize
    segment.validate()?;
    db.insert_segment(&segment).await
}

// ❌ WRONG — trusting raw string input
#[tauri::command]
async fn execute_query(query: String) -> String {
    db.execute(&query)  // SQL injection waiting to happen
}
```

### IPC Validation Rules
- Every `#[tauri::command]` parameter must be typed (no raw `serde_json::Value` unless unavoidable).
- Use a validated newtype or struct with `impl TryFrom<RawInput>` that enforces business rules.
- Never expose a command that runs arbitrary SQL, file reads outside app dir, or shell commands.
- Log all IPC calls at `debug` level. Log failures at `warn` level.

### Capability-Based Access Control (Tauri 2.0)
Configure least-privilege in `src-tauri/capabilities/`:

```json
{
  "identifier": "app-capability",
  "description": "App core permissions",
  "windows": ["main"],
  "permissions": [
    "app:default",
    "window:default",
    "fs:allow-appdata-read-recursive",
    "fs:allow-appdata-write-recursive"
  ]
}
```

**Never grant more permissions than required.** `fs:allow-home-read-recursive` for reading app data is overkill — scope to `appdata` only.

---

## Local SQLite — Offline-First Data

### Schema Management (rusqlite/sqlx)
```rust
// ✅ Run migrations at startup
pub async fn run_migrations(db: &SqlitePool) -> Result<(), Error> {
    sqlx::migrate!("./migrations").run(db).await?;
    Ok(())
}
```

- Migrations live in `src-tauri/migrations/`.
- Never edit existing migrations — only add new ones.
- Version format: `YYYYMMDDHHMMSS_description.sql`
- Every migration must be reversible (include `-- Down:` comment).

### Schema Rules
- UUIDv7 for all primary keys (time-ordered, compatible with remote sync).
- `created_at`, `updated_at` on every table (RFC 3339 format, stored as TEXT).
- `synced_at` column on tables that sync to cloud — null = not yet synced.
- Boolean columns: stored as INTEGER (0/1). Named with `is_` prefix.

### Outbox Pattern (Offline Sync)
```rust
// Every write that needs to sync goes to outbox first
pub async fn record_segment(db: &SqlitePool, segment: &Segment) -> Result<()> {
    let mut tx = db.begin().await?;
    // 1. Insert the record
    insert_segment(&mut tx, segment).await?;
    // 2. Insert into outbox
    insert_outbox_event(&mut tx, "segment.created", &segment.id, &segment).await?;
    tx.commit().await?;
    Ok(())
}

// Sync worker flushes outbox periodically
pub async fn flush_outbox(db: &SqlitePool, client: &IngestClient) -> Result<()> {
    let events = get_pending_outbox_events(db, 100).await?;
    // Send in batches. On success: mark sent. On failure: increment retry count.
    client.send_batch(&events).await?;
    mark_outbox_events_sent(db, &event_ids).await?;
}
```

### Outbox Rules
- Max 3 retry attempts per event. After 3: move to dead-letter table, alert user.
- Flush interval: 30 seconds (configurable).
- Flush on app focus (in case long background gap).
- Events are idempotent — sending twice is safe (use event `id` as idempotency key).
- Never block the UI on outbox flush — it runs in background.

---

## Auto-Update (Mandatory for All Agent Apps)

### Update Check Flow
```rust
// Check on startup, and every 4 hours
pub async fn check_update(app: &AppHandle) -> Result<()> {
    let update = app.updater().check().await?;
    if let Some(update) = update {
        // Show update dialog to user (never silent force-update)
        emit_update_available(&app, &update.version, &update.body)?;
    }
    Ok(())
}
```

### Update Rules
- **Check on startup.** Always.
- **Check every 4 hours** while running. Use background timer.
- **Never silent-update without user consent** (except security patches — prompt prominently).
- **Show release notes** — always show what's changing before user approves.
- **Staged rollout**: update feed supports `percentage` field — use it.
- **Signature verification**: Tauri v2 verifies update signatures automatically. Never disable.
- **Rollback**: if update fails validation → keep current version. Never leave user with broken install.

### Update Feed Format (`latest.json`)
```json
{
  "version": "1.2.3",
  "notes": "## What's New\n- Feature A\n- Bug fix B",
  "pub_date": "2026-09-01T00:00:00Z",
  "platforms": {
    "windows-x86_64": {
      "signature": "...",
      "url": "https://releases.example.com/app-1.2.3-x64.msi"
    },
    "darwin-aarch64": {
      "signature": "...",
      "url": "https://releases.example.com/app-1.2.3-aarch64.dmg"
    },
    "linux-x86_64": {
      "signature": "...",
      "url": "https://releases.example.com/app-1.2.3-amd64.AppImage"
    }
  }
}
```

### Code Signing (Required for Distribution)
- **Windows**: sign with EV certificate. Without signing → SmartScreen blocks install.
- **macOS**: notarize with Apple Developer account. Without notarization → Gatekeeper blocks.
- **Linux**: AppImage format is signed via update key. No OS-level signing required.
- Signing keys in CI secrets. Never on developer machines.

---

## React in Tauri

The frontend is identical to a web app except:
- `fetch()` goes to the Cloudflare API (not localhost).
- `tauri.invoke()` calls local Rust commands.
- Use `@tauri-apps/api` imports, not window globals.

```typescript
// ✅ Correct IPC call
import { invoke } from '@tauri-apps/api/core';

const segment = await invoke<Segment>('create_segment', {
  segment: { ...segmentData }
});

// ✅ Correct event listener
import { listen } from '@tauri-apps/api/event';

const unlisten = await listen<UpdatePayload>('update-available', (event) => {
  showUpdateDialog(event.payload);
});
// Always call unlisten() on component unmount
```

### React + Tauri Rules
- Handle the case where `invoke()` fails — network, permissions, Rust panic.
- Never block the UI thread waiting for Rust — all `invoke()` calls are async.
- Use `useEffect` cleanup to `unlisten()` from Tauri events.
- Tauri windows are persistent — use `useLayoutEffect` carefully.

---

## Platform-Specific Considerations

### Windows
- App data: `%APPDATA%\<BundleId>\`
- Auto-start: `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`
- System tray: always provide a tray icon for background agents.
- UAC: never require admin privileges. Store data in AppData, not Program Files.

### macOS
- App data: `~/Library/Application Support/<BundleId>/`
- Login items: use `SMLoginItemSetEnabled` (deprecated) or `LaunchAgent` plist.
- System tray: MenuBar icon for background agents.
- Sandboxed: if distributing via App Store, additional restrictions apply.

### Linux
- App data: `~/.local/share/<BundleId>/`
- Autostart: `.config/autostart/<name>.desktop`
- System tray: StatusNotifierItem / libappindicator.
- AppImage is preferred format — no install required.

---

## Build Pipeline for Agent Apps

```yaml
# CI matrix build
strategy:
  matrix:
    include:
      - os: windows-latest
        target: x86_64-pc-windows-msvc
        artifact: .msi
      - os: macos-latest
        target: aarch64-apple-darwin
        artifact: .dmg
      - os: macos-latest
        target: x86_64-apple-darwin
        artifact: .dmg (Intel)
      - os: ubuntu-latest
        target: x86_64-unknown-linux-gnu
        artifact: .AppImage

steps:
  - pnpm install
  - pnpm tauri build --target ${{ matrix.target }}
  - Upload artifact to GitHub Releases
  - Update latest.json in Cloudflare R2
```

### Version Sync Rule
`package.json` version MUST match `src-tauri/tauri.conf.json` version MUST match git tag.
If any of the three diverge → build fails. This is enforced in CI.

---

## Security Checklist for Agent Apps

Before any agent app release:
- [ ] All `#[tauri::command]` inputs validated
- [ ] No shell commands exposed via IPC
- [ ] File system access scoped to `appdata` only
- [ ] Update signatures verified in config
- [ ] Code signing certificates valid and not expiring within 30 days
- [ ] Notarization successful (macOS)
- [ ] SmartScreen warning tested (Windows)
- [ ] SQLite WAL mode enabled (prevents corruption on crash)
- [ ] Outbox DLQ implemented (no silent data loss)
- [ ] Crash reporter configured (Sentry or equivalent)
