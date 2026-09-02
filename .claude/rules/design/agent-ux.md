# Agent / Desktop UX Patterns

> UX patterns specific to local agent applications (Tauri, Electron).
> These apply when the app runs on the user's machine, not just in a browser.

---

## System Tray / Menu Bar

### Tray Icon
- **Always present.** When the app is running, the tray icon is visible. This is the primary navigation point.
- **Status indicators.** Icon changes based on state:
  - Default: app icon
  - Active/syncing: subtle pulse or badge
  - Error: red dot overlay
  - Paused: grayed out or paused icon
- **Tooltip.** Hover shows current status: "Pulse — Tracking time" or "Pulse — Paused."
- **Context menu.** Right-click shows: Open, Pause/Resume, Settings, Quit. In that order.

### Window Behavior
- **Close to tray.** Closing the window minimizes to tray, doesn't quit. Users expect the agent to keep running.
- **Single instance.** Opening a second instance focuses the existing window.
- **Start on login.** Optional setting (default off, prompt after first week of use).
- **Restore window position.** Remember last position and size. Users have spatial memory.

---

## Auto-Update UX

### Update Flow
1. **Check silently.** App checks for updates on launch and every 4 hours. Never block the UI for checking.
2. **Notify, don't force.** Show a subtle banner: "Version 2.1.0 available. Restart to update." Not a modal.
3. **Download in background.** Download the update without user action. Show progress in tray menu: "Downloading update... 45%."
4. **Install on restart.** "Restart to update" button in banner and tray menu. Apply on next launch.
5. **Force update for security.** Only for critical security patches. Show modal: "A security update is required. This will restart the app now."
6. **Rollback.** If update fails to launch, automatically roll back to previous version on next start.

### Update Notification Patterns
| Severity | Pattern | Example |
|---|---|---|
| Regular update | Subtle banner, dismissible | "v2.1.0 ready. Restart to update." |
| Feature update | Banner + "What's new" link | "v2.1.0 ready. See what's new →" |
| Security update | Modal, not dismissible | "Security update required. Restart now." |
| Failed update | Toast error + retry | "Update failed. Check connection and retry." |

### Changelog
- **In-app changelog.** After update, show a "What's New" dialog with the changelog. Dismissible.
- **Readable format.** Features (green), Fixes (blue), Breaking (red). Not a git log dump.
- **Link to full changelog.** "View full changelog" opens browser to GitHub releases or docs.

---

## Background Operation UX

### Status Visibility
- **Always know what's happening.** The user should never wonder "is this thing running?"
- **Status bar.** Bottom of window: "● Tracking — 2h 15m today" or "● Paused — Last active 10 min ago."
- **Tray tooltip.** Summarized status when window is hidden.
- **Notification on state change.** System notification when transitioning between active/paused/error. Only for user-relevant changes.

### Resource Usage
- **Show resource impact.** Settings page: "CPU: 0.3%, Memory: 45MB, Network: 2KB/min." Users care about what's running on their machine.
- **Low-resource mode.** "Battery saver" toggle — reduces check frequency, pauses non-essential features.
- **No surprise resource usage.** Never spike CPU without user action. Background work is throttled.

### Offline Behavior
- **Seamless offline.** App works fully offline. Queues changes. Syncs when connection returns.
- **Offline indicator.** Subtle banner: "You're offline. Changes will sync when you reconnect."
- **Conflict resolution UI.** If offline changes conflict with server: "This was changed on another device. Keep yours or theirs?" with diff preview.
- **No data loss.** Local SQLite/Outbox. Never lose user data due to connectivity.

---

## Permissions & Trust

### First-Run Permissions
- **Explain before asking.** "Pulse needs to track active window time. This allows it to record which app you're using." Then show OS permission dialog.
- **One permission at a time.** Don't dump 4 permission requests on first launch. Sequence them as the feature is needed.
- **Permission denied state.** "Time tracking is paused because accessibility permission was revoked. Grant access in System Settings → Privacy."
- **Deep link to settings.** "Open System Settings →" button that takes user directly to the relevant OS settings pane.

### Privacy Indicators
- **What's being collected.** Settings → Privacy: "Data collected: active window title, duration, app name. Data NOT collected: file contents, keystrokes, browser history."
- **Local-first messaging.** "Your data stays on your device. Sync is optional and encrypted."
- **Export everything.** "Export all your data" button. JSON or CSV. One click.
- **Delete everything.** "Delete all local data" with typed confirmation. Irreversible.

---

## Desktop-Specific Patterns

### Keyboard Shortcuts
- **Global hotkey.** Register a system-wide shortcut (e.g., ⌘⇧P) to show/hide the app. Configurable.
- **In-app shortcuts.** ⌘N for new, ⌘W to close window, ⌘, for settings. Follow OS conventions.
- **Shortcut discovery.** Show shortcuts in tooltips and menu items. ⌘? for full shortcut list.

### Window Management
- **Minimum size.** Set a minimum window size so the UI never breaks. 400×600 for most agent apps.
- **Maximize/fullscreen.** Support native maximize. Don't do custom fullscreen.
- **Multiple windows.** Only if the app genuinely benefits (e.g., floating timer window + main dashboard). Otherwise single window.

### Native Integration
- **Dock badge.** macOS: badge count on dock icon for pending items.
- **Jump lists.** Windows: right-click taskbar → quick actions.
- **Notifications.** Use native OS notifications, not in-app toasts for background events. In-app toasts only when window is focused.

### File System
- **Default save location.** Use OS-standard directories: Documents, Downloads. Never save to app data dir for user-visible files.
- **File picker.** Use native OS file picker. Never custom file browser.
- **Drag and drop.** Support dragging files onto the window to import.

---

## Agent-Specific UI Components

### Activity Timeline
- **Chronological list.** Reverse chronological (newest first). Group by day.
- **Time labels.** "2:15 PM — 3:42 PM (1h 27m)." Human-readable durations.
- **Icons per activity type.** Different icon for coding, browsing, meeting, idle.
- **Color coding.** By project or category. Consistent with web admin colors.
- **Editable.** Click an entry to edit time, project, or delete.

### Mini Dashboard
- **Today summary.** Total active time, breakdown by project, current status.
- **Weekly chart.** Bar chart, 7 days, shows trend. Compact (120px height).
- **Quick actions.** Start/pause timer, switch project, add manual entry.

### Tray Quick Actions
- **One-click toggle.** Click tray icon to start/pause the primary action.
- **Project switcher.** Tray menu dropdown to switch active project.
- **Status display.** Tray menu header shows: "● Active — Project X — 1h 23m"

---

## Sync Status UX

### Sync States
| State | Indicator | UI |
|---|---|---|
| Synced | Green check (subtle) | "All changes synced" in status bar |
| Syncing | Spinning indicator | "Syncing 3 items..." |
| Pending | Yellow dot | "3 changes pending sync" |
| Error | Red dot + retry | "Sync failed — Retry" |
| Offline | Gray dot | "Offline — will sync when connected" |

### Sync Rules
- **Automatic.** Sync happens in background. No "Sync Now" button needed unless there's an error.
- **Non-blocking.** UI never freezes during sync. User can continue working.
- **Retry with backoff.** Failed syncs retry automatically: 5s, 10s, 30s, 1m, 5m. After 5 attempts, show error.
- **Manual retry.** After auto-retry exhausts, show "Retry" button in status bar.
- **Sync history.** Settings → Sync: show last sync time, items synced, any conflicts resolved.

---

## Error Handling (Desktop-Specific)

### Crash Recovery
- **Auto-restart.** If the agent crashes, it restarts automatically. Silently if in background.
- **Crash report.** After crash recovery, show: "Pulse encountered an error and restarted. Send crash report?" (opt-in).
- **State preservation.** All state is persisted to local DB. Crash doesn't lose data.
- **Graceful degradation.** If a subsystem fails (e.g., window tracking), disable that feature, show notice, keep running.

### Permission Revocation
- **Detect immediately.** Poll or listen for permission changes. Don't wait for the user to notice it's broken.
- **Clear messaging.** "Screen recording permission was revoked. Time tracking is paused. Regrant in System Settings."
- **Deep link.** Button to open the exact OS settings pane.

### Database Corruption
- **Auto-repair.** On startup, run integrity check. If corrupt, attempt repair.
- **Backup before repair.** Copy the corrupt DB before attempting repair. User can manually recover.
- **Worst case.** If unrecoverable, show: "Local data was corrupted. Your synced data is safe. Reset local data?" with confirmation.
