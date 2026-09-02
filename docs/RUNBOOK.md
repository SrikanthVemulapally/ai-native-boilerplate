# Runbook — [App Name]

> For on-call engineers and AI agents responding to production incidents.
> Last updated: YYYY-MM-DD

---

## Quick Reference

| What | Where | How |
|---|---|---|
| Logs | Cloudflare Dashboard → Workers → Logs | Filter by Worker name |
| Errors | Sentry → [project] | Filter by environment=production |
| DB | Cloudflare Dashboard → D1 → [db-name] | Query console |
| Deployments | GitHub Actions → deploy workflow | Check last deploy |
| Stripe | dashboard.stripe.com → [account] | Check webhooks, events |
| Uptime | [status page URL] | External monitor |

---

## Severity Levels

| Level | Response Time | Example |
|---|---|---|
| **SEV-1** | Immediate (< 15 min) | Full outage, data loss, security breach |
| **SEV-2** | < 1 hour | Partial outage, payments failing, auth broken |
| **SEV-3** | < 4 hours | Feature degraded, non-critical errors spiking |
| **SEV-4** | Next business day | Minor UI bugs, slow endpoints, isolated failures |

---

## Incident Response Protocol

### Step 1: Assess (2 min)
```
1. What is the user impact? (nothing works / feature broken / slow / cosmetic)
2. How many users affected? (all / some / one)
3. When did it start? (git log --oneline -10 → correlate with deploy time)
4. Is it getting worse? (check Sentry error rate trend)
```

### Step 2: Communicate
- Post in #incidents Slack channel: `SEV-N: [description] — investigating`
- If SEV-1/SEV-2: notify team lead immediately

### Step 3: Investigate
Follow the relevant runbook section below.

### Step 4: Fix or Rollback
- If a bad deploy caused it: **rollback first**, investigate second
- If data issue: fix data in DB, then fix code

### Step 5: Resolve
- Confirm fix in production
- Update #incidents: `RESOLVED: [what was wrong, what was fixed]`
- Log in `docs/DECISIONS.md` with INCIDENT tag
- Schedule post-mortem for SEV-1/SEV-2

---

## Runbook: Full API Outage

**Symptoms:** All API calls returning 5xx, Worker not responding

```bash
# 1. Check Worker health
curl -I https://api.yourdomain.com/health

# 2. Check Cloudflare status
open https://www.cloudflarestatus.com

# 3. Check Worker logs in Cloudflare Dashboard
# Workers → [worker-name] → Logs → filter last 30 min

# 4. Check last deployment
# GitHub → Actions → last successful deploy job

# 5. If bad deploy: rollback
# GitHub → Actions → deploy workflow → re-run previous successful run
# OR: git revert [bad commit] && git push origin main
```

---

## Runbook: Database Issues

**Symptoms:** Queries failing, data not saving, migration errors

```bash
# Check D1 status
wrangler d1 execute [DB_NAME] --command="SELECT 1" --remote

# Check migration status
wrangler d1 execute [DB_NAME] --command="SELECT * FROM drizzle_migrations ORDER BY created_at DESC LIMIT 10" --remote

# Run a specific query for debugging
wrangler d1 execute [DB_NAME] --command="SELECT COUNT(*) FROM users" --remote

# Check for locked tables (SQLite)
wrangler d1 execute [DB_NAME] --command="PRAGMA database_list" --remote
```

**If migration failed:**
1. Check which migration failed (Sentry + Worker logs)
2. Run the rollback SQL manually:
   ```bash
   wrangler d1 execute [DB_NAME] --file=drizzle/migrations/[rollback].sql --remote
   ```
3. Fix the migration file
4. Re-deploy

---

## Runbook: Payments / Stripe Issues

**Symptoms:** Payments failing, webhooks not firing, subscriptions stuck

```bash
# 1. Check Stripe Dashboard → Developers → Webhooks → [endpoint]
#    - Are webhooks being delivered?
#    - What's the failure response?

# 2. Check Stripe webhook logs in your API logs
grep "stripe.webhook" [logs]

# 3. Test webhook delivery manually
stripe trigger checkout.session.completed  # requires Stripe CLI

# 4. Check webhook secret
# The STRIPE_WEBHOOK_SECRET env var must match the one in Stripe Dashboard
# Mismatch = signature verification fails = all webhooks rejected

# 5. Replay a failed webhook
# Stripe Dashboard → Developers → Webhooks → [endpoint] → [failed event] → Resend
```

**Subscription stuck in wrong state:**
```bash
# Check Stripe's record vs your DB
wrangler d1 execute [DB_NAME] --command="SELECT * FROM subscriptions WHERE user_id='[userId]'" --remote
# Compare with: stripe customers retrieve [stripeCustomerId] --expand subscriptions

# Fix DB if webhook was missed
wrangler d1 execute [DB_NAME] --command="UPDATE subscriptions SET status='active', plan='pro' WHERE user_id='[userId]'" --remote
# Then log this manual fix in DECISIONS.md
```

---

## Runbook: Authentication Issues

**Symptoms:** Users can't log in, tokens invalid, session errors

```bash
# Check auth errors in Sentry
# Filter: tags.error_code = AUTH_ERROR | FORBIDDEN_ERROR

# Verify JWT secret hasn't changed
# A changed JWT_SECRET invalidates ALL existing sessions
# Only change during a planned maintenance window with session invalidation

# Check refresh token table
wrangler d1 execute [DB_NAME] --command="SELECT COUNT(*) FROM sessions WHERE expires_at > unixepoch()" --remote
```

**If JWT_SECRET was rotated unexpectedly:**
1. All users will be logged out (expected)
2. Announce via email/status page
3. Document in DECISIONS.md

---

## Runbook: Desktop Agent Issues (Tauri variant)

**Symptoms:** Agent not syncing, update failing, crash on startup

```bash
# Check agent logs
# macOS: ~/Library/Logs/[app-name]/
# Windows: %APPDATA%/[app-name]/logs/
# Linux: ~/.local/share/[app-name]/logs/

# Check update server
curl https://releases.yourdomain.com/[app-name]/latest.json

# Force update check
# App menu → Help → Check for Updates

# Roll back to previous version
# Download previous release from GitHub Releases
# Uninstall current → install previous
```

---

## Runbook: Rollback a Deployment

```bash
# Find the last good commit
git log --oneline -20

# Option A: Revert the bad commit(s)
git revert [bad-commit-sha]
git push origin main  # triggers re-deploy via CI

# Option B: Roll back to a specific tag
git checkout [last-good-tag]
git checkout -b hotfix/rollback-[date]
# Push and deploy this branch

# Option C: Re-run a previous GitHub Actions deploy
# GitHub → Actions → [deploy workflow] → find last successful run → Re-run jobs
```

---

## Regular Maintenance Tasks

| Task | Frequency | How |
|---|---|---|
| Review Sentry error inbox | Daily | Sentry → Issues → Inbox |
| Check Worker P95 latency | Weekly | Cloudflare Dashboard → Workers → Metrics |
| Review D1 query performance | Monthly | Cloudflare Dashboard → D1 → Insights |
| Rotate API keys (non-critical) | Quarterly | Per service dashboard |
| Run `/security-check` | Monthly | Claude Code slash command |
| Review `pnpm audit` | Monthly | `pnpm audit --fix` |
| Archive old logs from R2 | Monthly | `wrangler r2 object list logs/ --prefix=old/` |
| Review Stripe disputed charges | Weekly | Stripe Dashboard → Disputes |

---

## Contacts

| Role | Name | Contact |
|---|---|---|
| On-call engineer | [name] | [contact] |
| Team lead | [name] | [contact] |
| Stripe support | — | support.stripe.com |
| Cloudflare support | — | dash.cloudflare.com/support |

---

*Keep this doc updated. Stale runbooks cause longer incidents.*
*After every incident: update the relevant runbook section with what you learned.*
