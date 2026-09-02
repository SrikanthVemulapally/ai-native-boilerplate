# Release

Prepare and execute a release. This command guides the full release process.

## Instructions

You are preparing a release. Follow these steps in order:

### Step 1: Determine Version
- Read `docs/CHANGELOG.md` — what's in "Unreleased"?
- Read current version from `package.json` (and `tauri.conf.json` if agent app)
- Determine bump type:
  - **MAJOR**: Breaking API change, breaking DB schema, removed feature
  - **MINOR**: New feature, new endpoint, new UI page
  - **PATCH**: Bug fix, perf improvement, dependency update
- Present the proposed version to the human for approval

### Step 2: Update Version
- Bump version in `package.json`
- Bump version in `tauri.conf.json` (if agent app)
- Bump version in any other config files that track version

### Step 3: Finalize Changelog
- Move "Unreleased" section to `[VERSION] — YYYY-MM-DD`
- Ensure all entries are categorized: Added, Changed, Fixed, Security, Breaking
- Add link to compare: `[1.2.3]: https://github.com/<org>/<repo>/compare/v1.2.2...v1.2.3`

### Step 4: Pre-Release Checks
Run and verify ALL pass:
```
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```
- If any fail → STOP. Fix before release. Do not release with failing checks.

### Step 5: Create Release Commit
```bash
git add -A
git commit -m "chore: release v<VERSION>"
```

### Step 6: Create Git Tag
```bash
git tag -a v<VERSION> -m "Release v<VERSION>

See CHANGELOG.md for details."
```

### Step 7: Push
```bash
git push origin main
git push origin v<VERSION>
```
This triggers the release CI pipeline.

### Step 8: Post-Release
- Monitor health check: `curl https://app.com/api/health`
- Monitor error rate for 15 minutes
- If error rate > 1% → rollback immediately
- For major release: create ADR in `docs/DECISIONS.md`

### Output
Report the release status, version, what's included, and monitoring status.
