# Changelog

All notable changes to this project will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

> **AI Agents:** Update this file with every feature merge.
> Use the `/commit` command — it appends to `[Unreleased]` automatically.
> Use the `/release` command — it promotes `[Unreleased]` to a versioned entry.
> **NEVER modify released entries.** Append only.

---

## [Unreleased]

### Added
- (new features go here)

### Changed
- (changes to existing features go here)

### Fixed
- (bug fixes go here)

### Deprecated
- (features that will be removed in a future release)

### Removed
- (features removed in this release)

### Security
- (security fixes — always mention CVE if applicable)

---

<!-- Example entry — delete this before first real release -->
<!--
## [1.2.0] — 2025-03-15

### Added
- User profile page with avatar upload
- Dark mode toggle with system preference detection
- Email notifications for subscription events

### Changed
- Improved dashboard load time by 40% (lazy-loaded charts)
- Upgraded Stripe SDK to v14 (webhook signature verification improved)

### Fixed
- Fixed CLS issue on landing page hero image (added explicit dimensions)
- Fixed N+1 query in /api/posts endpoint

### Security
- Rotated JWT signing key after audit recommendation
- Added rate limiting to /api/auth/login (5 req/15min per IP)

## [1.1.0] — 2025-02-01

### Added
- Stripe subscription billing (monthly + annual)
- Customer portal for self-service plan management
- Trial period (14 days)

## [1.0.0] — 2025-01-15

### Added
- Initial release
- User authentication (email + password)
- Core dashboard
- Basic CRUD operations
-->

---

## Versioning Rules

```
MAJOR (1.0.0 → 2.0.0): Breaking changes — API contract change, DB migration that drops columns,
                         removal of supported features. Requires migration guide.

MINOR (1.0.0 → 1.1.0): New features that are backward-compatible.
                         New API endpoints, new UI features, new config options.

PATCH (1.0.0 → 1.0.1): Bug fixes, performance improvements, security patches.
                         No new features, no breaking changes.
```

**Pre-release tags:** `1.0.0-beta.1`, `1.0.0-rc.1`
**Agent releases:** Desktop agent follows the same versioning — agent version must match or exceed API version.
