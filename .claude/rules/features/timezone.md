# Feature Rules: Timezone & Locale Handling
> Always loaded when features.i18n=true. Also loaded standalone if config.timezone=true.

## The Golden Rule
**Store UTC everywhere. Convert to local time only at the point of display.**

This single rule prevents 90% of timezone bugs. Apply it without exception.

---

## Rule 1 — Database: Always UTC

```typescript
// schema.ts — Drizzle
import { timestamp } from 'drizzle-orm/d1'

export const events = sqliteTable('events', {
  id: text('id').primaryKey(),

  // ✅ Always store as UTC timestamp
  created_at: integer('created_at', { mode: 'timestamp' }).notNull()
    .$defaultFn(() => new Date()),
  updated_at: integer('updated_at', { mode: 'timestamp' }).notNull()
    .$defaultFn(() => new Date()),
  deleted_at: integer('deleted_at', { mode: 'timestamp' }),

  // ✅ For user-facing events: store UTC + store user's timezone IANA string
  scheduled_at_utc: integer('scheduled_at_utc', { mode: 'timestamp' }).notNull(),
  user_timezone: text('user_timezone').notNull(), // 'Asia/Dubai', 'America/New_York'

  // ❌ Never store timezone offsets (+04:00) — they change with DST
  // ❌ Never store local time strings ('2026-09-02 14:00')
  // ❌ Never store Unix timestamps as text
})

// users table — always store timezone preference
export const users = sqliteTable('users', {
  id: text('id').primaryKey(),
  timezone: text('timezone').notNull().default('UTC'), // IANA string
  locale: text('locale').notNull().default('en'),
  // ...
})
```

---

## Rule 2 — API: Always Transmit UTC ISO 8601

```typescript
// ✅ API responses always use UTC ISO 8601
{
  "created_at": "2026-09-02T10:00:00.000Z",  // Z suffix = UTC
  "scheduled_at": "2026-09-02T14:00:00.000Z"
}

// ❌ Never send local time strings in API responses
{
  "created_at": "Sep 2, 2026 2:00 PM",       // No timezone context
  "created_at": "2026-09-02T18:00:00+04:00"  // Offset can mislead clients
}

// API input — accept ISO 8601, convert to UTC immediately on receipt
export async function handleCreateEvent(req: Request) {
  const { scheduled_at, timezone } = await req.json()

  // Convert user's local time to UTC using their timezone
  const utcDate = toUTC(scheduled_at, timezone)

  await db.insert(events).values({
    scheduled_at_utc: utcDate,
    user_timezone: timezone,
  })
}
```

---

## Rule 3 — Cloudflare: Free Timezone Detection

```typescript
// workers/ingest/src/middleware/timezone.ts
export function detectTimezone(request: Request): string {
  // Cloudflare provides timezone for free — use it
  const cf = (request as any).cf
  if (cf?.timezone) {
    return cf.timezone // 'Asia/Dubai', 'Europe/Berlin', etc.
  }

  // Fallback: parse from Accept-Language or stored preference
  return 'UTC'
}

// Use in session creation — auto-populate user timezone on signup
export async function createSession(request: Request, userId: string) {
  const detectedTimezone = detectTimezone(request)
  await db.update(users)
    .set({ timezone: detectedTimezone })
    .where(eq(users.id, userId))
    // User can always override in settings
}
```

---

## Rule 4 — Display: Convert at Render Time Only

```typescript
// packages/i18n/formatter.ts

// ✅ Convert UTC → user's timezone only when displaying
export function formatDateTime(
  utcDate: Date | string,
  userTimezone: string,   // IANA string from user profile
  locale: string,
  options?: Intl.DateTimeFormatOptions
): string {
  return new Intl.DateTimeFormat(locale, {
    timeZone: userTimezone,
    dateStyle: 'medium',
    timeStyle: 'short',
    ...options,
  }).format(new Date(utcDate))
}

// Results for same UTC time "2026-09-02T10:00:00Z":
// Asia/Dubai (UTC+4):      "Sep 2, 2026, 2:00 PM"
// America/New_York (UTC-4): "Sep 2, 2026, 6:00 AM"
// Europe/Berlin (UTC+2):   "Sep 2, 2026, 12:00 PM"
// Asia/Tokyo (UTC+9):      "Sep 2, 2026, 7:00 PM"

// ✅ Relative time (e.g. "3 hours ago") — use Intl.RelativeTimeFormat
export function formatRelativeTime(
  utcDate: Date | string,
  locale: string
): string {
  const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' })
  const diffMs = new Date(utcDate).getTime() - Date.now()
  const diffMins = Math.round(diffMs / 60000)

  if (Math.abs(diffMins) < 60) return rtf.format(diffMins, 'minute')
  if (Math.abs(diffMins) < 1440) return rtf.format(Math.round(diffMins / 60), 'hour')
  return rtf.format(Math.round(diffMins / 1440), 'day')
}

// ✅ Show timezone name to user (always make it explicit)
export function formatWithTimezone(
  utcDate: Date | string,
  userTimezone: string,
  locale: string
): string {
  return new Intl.DateTimeFormat(locale, {
    timeZone: userTimezone,
    dateStyle: 'medium',
    timeStyle: 'short',
    timeZoneName: 'short', // "Sep 2, 2026, 2:00 PM GST"
  }).format(new Date(utcDate))
}
```

---

## Rule 5 — IANA Timezone Strings (Not Offsets)

```typescript
// ✅ Always IANA timezone identifiers
const VALID_TIMEZONES = [
  'Asia/Dubai',
  'Asia/Kolkata',
  'America/New_York',
  'America/Los_Angeles',
  'Europe/London',
  'Europe/Berlin',
  'Asia/Tokyo',
  'Australia/Sydney',
  'UTC',
]

// ✅ Validate on input
export function isValidTimezone(tz: string): boolean {
  try {
    Intl.DateTimeFormat(undefined, { timeZone: tz })
    return true
  } catch {
    return false
  }
}

// ❌ Never store or accept raw offsets
'+04:00'    // breaks at DST transitions
'GMT+4'     // ambiguous
'EST'       // ambiguous (3 countries use 'EST')
'+05:30'    // India never has DST but others at +05:30 might
```

---

## Rule 6 — DST Handling

```typescript
// DST transitions are automatic with IANA + Intl API
// DO NOT manually calculate timezone offsets

// ✅ Safe — Intl handles DST automatically
new Intl.DateTimeFormat('en-US', {
  timeZone: 'America/New_York',
  timeStyle: 'short',
}).format(new Date('2026-03-08T07:00:00Z')) // Spring forward — handled

// ❌ Dangerous — manual offset calculation
const offset = -5 // EST — wrong for EDT (summer: -4)
const local = new Date(utcMs + offset * 3600000)

// Edge cases to test explicitly:
// - Spring forward: clock jumps from 2:00 AM to 3:00 AM (1 hour doesn't exist)
// - Fall back: clock repeats from 1:00 AM to 2:00 AM (1 hour runs twice)
// - Some countries change DST dates yearly
// - Some regions have half-hour offsets (India +05:30, Nepal +05:45)
// - Some regions have 15-minute offsets (New Zealand Chatham +12:45)
// All handled correctly by Intl API when using IANA strings
```

---

## Rule 7 — Scheduled Tasks & Crons

```typescript
// ✅ All cron schedules in UTC
// wrangler.toml
[triggers]
crons = ["0 9 * * 1-5"]  // 9:00 AM UTC — add comment with user-visible time

// ✅ For user-scheduled tasks: store user's intent (local time + timezone)
// then compute next UTC trigger
export function computeNextRun(
  cronExpression: string,  // "0 9 * * 1-5" — in user's local time
  userTimezone: string
): Date {
  // Use a cron library that supports timezones
  // e.g. croner: new Cron("0 9 * * 1-5", { timezone: userTimezone }).nextRun()
}

// ❌ Never schedule tasks in local time without timezone context
// A "9:00 AM daily" job stored as UTC 05:00 breaks when user's region enters DST
```

---

## Rule 8 — Timezone Settings UX

```typescript
// Settings page — timezone selector
// ✅ Group by region, show UTC offset + city name
// ✅ Auto-detect on signup (from Cloudflare cf.timezone)
// ✅ Show current time preview as user selects timezone
// ✅ Store as IANA string, display as human-readable

const TIMEZONE_DISPLAY = {
  'Asia/Dubai':          'Gulf Standard Time (Dubai, UTC+4)',
  'America/New_York':    'Eastern Time (New York, UTC-5/-4)',
  'Europe/London':       'Greenwich Mean Time (London, UTC+0/+1)',
  'Asia/Kolkata':        'India Standard Time (Mumbai, UTC+5:30)',
}

// ✅ Always show timestamps with timezone context in admin views
// "Created: Sep 2, 2026, 2:00 PM GST (your timezone)"
// Never show raw UTC to end users — confusing and unprofessional
```

---

## Rule 9 — Tauri Agent: System Timezone

```typescript
// For desktop agent — use system timezone, sync to API
// src-tauri/src/timezone.rs
use chrono::Local;

pub fn get_system_timezone() -> String {
    // Use iana-time-zone crate
    iana_time_zone::get_timezone()
        .unwrap_or_else(|_| "UTC".to_string())
}

// On agent startup — report system timezone to API
// Update user.timezone if changed (user may travel)
```

---

## Testing Checklist

- [ ] All DB timestamps store as UTC integers (mode: 'timestamp')
- [ ] API responses contain `Z` suffix on all datetime strings
- [ ] UI displays times in user's IANA timezone (not UTC)
- [ ] Relative time ("3 hours ago") is locale-aware
- [ ] Timezone selector shows IANA strings, not offsets
- [ ] Cron jobs comment their UTC schedule + user-visible local equivalent
- [ ] Scheduled tasks recompute when user changes timezone
- [ ] DST transition dates tested (March/November for US, March/October for EU)
- [ ] Half-hour offset timezones tested (India, Iran, Afghanistan, Nepal)
- [ ] Admin views show timezone identifier alongside timestamps
