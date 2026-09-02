# Deployment & Release Process
> Always loaded. Deploying is not the end — it's the start of monitoring.

---

## Environments

| Env | Purpose | Branch | Auto-Deploy | Data |
|-----|---------|--------|-------------|------|
| `local` | Development | — | — | Seed data |
| `preview` | PR review | `pr-*` | On PR open/update | Seeded subset |
| `staging` | Pre-prod | `staging` | On push to staging | Anonymized prod copy |
| `production` | Live | `main` | On merge to main (after approval) | Real data |

### Environment Parity Rules
- Same runtime (Cloudflare Workers) across staging and production.
- Same dependencies (same lockfile, same versions).
- Same schema (migrations applied to all environments in order).
- Different secrets (each env has its own API keys, Stripe keys, etc.).
- Staging uses Stripe test mode. Production uses Stripe live mode.

---

## CI/CD Pipeline

### Pipeline Stages (every PR)
```
lint → typecheck → unit → integration → e2e:smoke → build → security:scan → bundle:check
```

| Stage | Command | Fail Condition | Fix |
|-------|---------|----------------|-----|
| Lint | `pnpm lint` | Any error or warning | Fix lint issues |
| Type check | `pnpm typecheck` | Any `tsc` error | Fix type errors |
| Unit tests | `pnpm test:unit --coverage` | Test fail or coverage < 80% | Fix test or add tests |
| Integration | `pnpm test:integration` | Any test fails | Fix failing test |
| E2E smoke | `pnpm test:e2e --smoke` | Any smoke test fails | Fix failing flow |
| Build | `pnpm build` | Build fails or warns | Fix build issues |
| Security | `pnpm audit --audit-level=moderate` | Moderate+ vulnerability | Update dependency |
| Bundle | `pnpm bundle:check` | > 10% regression from baseline | Reduce bundle size |

### Branch Protection Rules
- `main`: requires PR, requires CI pass, requires 1 review, no direct push
- `staging`: requires PR, requires CI pass
- No force-push to any protected branch
- No delete `main` or `staging`

---

## Deployment Process

### Web App (Cloudflare Workers)
```bash
# 1. Merge PR to main (triggers deploy)
# 2. CI runs full pipeline
# 3. If all pass:
wrangler deploy --env production

# 4. Health check
curl https://app.com/api/health
# Expected: { "status": "ok", "version": "1.2.3" }

# 5. Monitor for 5 minutes
# - Error rate < 1%
# - p99 latency < 5s
# - No new error types in error tracking
```

### Agent App (Tauri)
```bash
# 1. Bump version in tauri.conf.json
# 2. Update CHANGELOG.md
# 3. Create git tag: v1.2.3
# 4. Push tag → triggers release CI
# 5. CI builds for all platforms:
#    - Windows: .msi + .exe (NSIS)
#    - macOS: .dmg (universal)
#    - Linux: .AppImage + .deb
# 6. Upload to GitHub Releases
# 7. Update auto-update feed (latest.json)
# 8. Staged rollout: 10% → 50% → 100%
```

### Database Migrations
```bash
# 1. Test migration locally
pnpm db:generate
pnpm db:migrate

# 2. Apply to staging
wrangler d1 migrations apply --env staging <DB_NAME>

# 3. Verify staging works
# - Run integration tests against staging
# - Manual smoke test

# 4. Apply to production (after PR merge)
wrangler d1 migrations apply --env production <DB_NAME>

# 5. Verify production
curl https://app.com/api/health/deep
```

### Migration Safety Rules
- Never run a migration that hasn't been tested on staging.
- Never run a destructive migration (DROP, ALTER with data loss) without a backup.
- Always have a rollback migration prepared.
- Migrations are idempotent where possible (CREATE TABLE IF NOT EXISTS, etc.).
- Large data migrations: do in batches, not one transaction. Update in chunks of 1000.

---

## Rollback Process

### Cloudflare Workers
```bash
# Instant rollback to previous version
wrangler rollback

# Verify
curl https://app.com/api/health
```

### D1 Database
```bash
# Apply reverse migration
wrangler d1 migrations apply --env production <DB_NAME> --reverse <MIGRATION_ID>

# If no reverse migration exists:
# 1. Write one immediately
# 2. Test on staging first
# 3. Apply to production
# 4. Log incident in DECISIONS.md
```

### Agent App
```bash
# Update auto-update feed to point to previous version
# Users on newer version will get downgraded on next check
# OR: mark current version as broken in update feed
```

### Frontend (CDN)
```bash
# Deploy previous commit
git checkout <previous-commit>
pnpm build
wrangler deploy --env production

# Purge CDN cache
wrangler r2 bucket cache purge  # or Cloudflare dashboard
```

---

## Release Versioning

### Semantic Versioning
```
MAJOR.MINOR.PATCH
  1   . 2  . 3
```

| When to Bump | Example |
|---------------|---------|
| MAJOR | Breaking API change, DB schema change requiring migration, removed feature |
| MINOR | New feature, new endpoint, new UI page — all backward-compatible |
| PATCH | Bug fix, performance improvement, dependency update, doc update |

### Pre-release
- `1.0.0-beta.1` — internal testing
- `1.0.0-rc.1` — release candidate (staging, final review)
- `1.0.0` — production release

### Release Process
1. Update version in `package.json` (and `tauri.conf.json` for agent apps)
2. Update `docs/CHANGELOG.md` — move "Unreleased" to version + date
3. Create git tag: `git tag -a v1.2.3 -m "Release 1.2.3"`
4. Push tag: `git push origin v1.2.3`
5. CI triggers release build
6. Post-release monitoring (see below)
7. For major releases: create ADR in `docs/DECISIONS.md`

### Changelog Format
```markdown
## [1.2.3] — 2026-09-15

### Added
- User export feature (SPEC.md §4.2)
- Dark mode toggle

### Changed
- Improved dashboard loading time by 40%
- Updated Stripe webhook handling

### Fixed
- Fixed race condition in queue processing
- Fixed empty state not showing on filtered lists

### Security
- Patched lodash vulnerability (CVE-2026-1234)

### Breaking
- Removed deprecated `/api/v1/users` endpoint (use `/api/v1/profiles`)
```

---

## Post-Release Monitoring

### Immediate (0-15 min)
- [ ] Health check returns 200
- [ ] Error rate < 1% of requests
- [ ] p99 latency < 5s
- [ ] No new error types in error tracking
- [ ] Key user flows work (smoke test production manually)
- [ ] Stripe webhooks processing (if payment-related)

### Short-term (15 min - 24 hr)
- [ ] Error rate stable
- [ ] No user-reported issues
- [ ] Queue depth normal (no backlog)
- [ ] D1 query performance normal
- [ ] No cost anomalies

### Medium-term (1-7 days)
- [ ] Core Web Vitals stable (if frontend change)
- [ ] No regression in eval scores (if AI change)
- [ ] Support ticket volume normal
- [ ] User engagement metrics normal
- [ ] Schedule post-mortem if any incidents

### If Something Goes Wrong
1. **Rollback immediately.** Don't try to fix-forward unless rollback is impossible.
2. **Log incident.** Timeline, impact, root cause, resolution → `docs/DECISIONS.md`.
3. **Communicate.** Status page, user email if user-facing.
4. **Post-mortem within 48 hours.** Blameless. Focus on system improvement, not individual.
5. **Action items.** Preventive measures assigned to specific people with deadlines.

---

## Feature Flags

### When to Use
- Gradual rollout (10% → 50% → 100%)
- A/B testing
- Kill switch for risky features
- Beta access for specific users

### Implementation
- Use Cloudflare KV for flag storage (low latency, edge-distributed).
- Flag shape: `{ feature: string, enabled: boolean, percentage: number, allowList: string[] }`
- Check flags early in the request lifecycle.
- Log flag evaluation: which flag, which user, which variant.
- Dead code elimination: remove feature flag checks once feature is 100% enabled.

### Rules
- No more than 5 active flags at a time. More = complexity debt.
- Every flag has an owner and an expiry date. Expired flags → remove.
- Flag states documented in `docs/DECISIONS.md`.
- Never use flags for environment-specific config (use env vars).
