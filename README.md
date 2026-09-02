<!-- markdownlint-disable MD033 MD041 -->

<p align="center">
  <img src="assets/banner.png" alt="AI-Native Boilerplate" width="100%" />
</p>

<h1 align="center">AI-Native Boilerplate</h1>

<p align="center">
  <strong>Discipline for AI agents building serious software.<br>Stop AI drift. Enforce architecture. Save millions of tokens.</strong>
</p>

<p align="center">
  <a href="https://github.com/SrikanthVemulapally/ai-native-boilerplate/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/SrikanthVemulapally/ai-native-boilerplate?style=for-the-badge&color=6366f1" /></a>
  <a href="https://github.com/SrikanthVemulapally/ai-native-boilerplate/forks"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/SrikanthVemulapally/ai-native-boilerplate?style=for-the-badge&color=6366f1" /></a>
  <a href="https://github.com/SrikanthVemulapally/ai-native-boilerplate/blob/main/LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-6366f1?style=for-the-badge" /></a>
  <a href="https://github.com/SrikanthVemulapally/ai-native-boilerplate/issues"><img alt="Issues" src="https://img.shields.io/github/issues/SrikanthVemulapally/ai-native-boilerplate?style=for-the-badge&color=6366f1" /></a>
</p>

<p align="center">
  <a href="#getting-started">Quick Start</a> ·
  <a href="#the-architecture">Architecture</a> ·
  <a href="#whats-inside">What's Inside</a> ·
  <a href="#design-system">Design System</a> ·
  <a href="#compliance">Compliance</a> ·
  <a href="EXTENDING.md">Extending</a> ·
  <a href="CHEATSHEET.md">Cheatsheet</a>
</p>

---

## The Problem

You start coding with Claude. It's fast. It's fun. Then the codebase grows.

- AI writes code that contradicts your architecture — every session
- Requirements drift from implementation silently
- Every session re-explains the same context, burning tokens
- Patterns diverge across files with no enforcement
- Decisions get re-litigated because nobody wrote them down
- Features ship without tests because nothing enforced it
- UI looks different on every page — no design discipline
- Security, compliance, accessibility — afterthoughts

**This boilerplate is the discipline layer that prevents all of that.**

---

## What It Is

A **configurable, token-efficient boilerplate** that gives AI coding agents (Claude Code, Cursor, Windsurf, Copilot, Cline) the rules, context, and enforcement they need to build production-grade software without drifting.

**160+ files of discipline** across 6 layers, loaded surgically — only what your project needs.

### Why you'll save millions of tokens

| Mode | Rules Loaded | ~Tokens | Use When |
|------|-------------|---------|----------|
| Minimal | 7 | ~2K | Prototypes, hackathons |
| Web-only | ~20 | ~9K | Standard SaaS web app |
| Agent+Web | ~24 | ~10.5K | Desktop agent + web admin |
| Full-stack | ~30 | ~13K | Everything enabled, large team |

The generator **concatenates** content into a single `CLAUDE.md` — one read, zero import overhead, zero wasted context on irrelevant rules.

---

## The Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 6: Compliance (GDPR · HIPAA · SOC2 · PCI · EU AI Act) │  ← Configurable per regulation
├─────────────────────────────────────────────────────────────┤
│  Layer 5: Custom Rules (.claude/rules/custom/)               │  ← Your overrides. Load last. Win.
├─────────────────────────────────────────────────────────────┤
│  Layer 4: Feature Rules (.claude/rules/features/)            │  ← Loaded by feature flag only
│  payments · seo · auth · auto-update · ai · i18n · realtime  │
│  email · analytics · file-uploads · error-tracking · openapi │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: Design System (.claude/rules/design/)              │  ← UI/UX discipline (default: on)
│  tokens · typography · color · components · page-types       │
│  states · animation · accessibility · ux-patterns ·          │
│  agent-ux · responsive · performance · error-pages ·         │
│  email-templates                                             │
├─────────────────────────────────────────────────────────────┤
│  Layer 2: Stack Rules (.claude/rules/stack/)                 │  ← Loaded by config.stack
│  tanstack · tauri · nextjs · cloudflare · monorepo ·         │
│  cross-platform · mobile-web                                 │
├─────────────────────────────────────────────────────────────┤
│  Layer 1: Core (PRINCIPLES.md + core/ rules)                 │  ← Always loaded. Non-negotiable.
│  principles · security · git · mdd · discipline ·            │
│  conventions · nfr · testing · deployment · worktrees ·      │
│  multi-agent                                                 │
└─────────────────────────────────────────────────────────────┘
```

**The key insight:** Claude loads ONLY what is relevant to your project. A web-only app doesn't load auto-update rules. An API-only app doesn't load SEO rules. Zero token waste.

---

## What's Inside

### Discipline & Enforcement

| Component | Count | What It Does |
|-----------|-------|-------------|
| **Core rules** | 12 | Principles, security, git, MDD, discipline lifecycle, conventions, NFRs, testing, deployment, worktrees, multi-agent |
| **Slash commands** | 27 | `/implement` `/review` `/commit` `/scaffold` `/debug` `/test` `/diagnose` `/preflight` `/release` `/audit` `/migrate` `/refactor` `/simplify` and more |
| **Lifecycle hooks** | 16 | Block dangerous commands, auto-format, spec alignment, quality gate, eval compliance, file length guard, context handoff, env var docs |
| **Git hooks** | 3 | Pre-commit (secrets, lint, types), commit-msg (conventional), pre-push (protect main, tests) |
| **Specialist agents** | 4 | code-reviewer, security-auditor, test-writer, fullstack-builder |
| **Doc templates** | 8 | SPEC, ARCHITECTURE, DESIGN, DECISIONS, CHANGELOG, RUNBOOK, ROADMAP, API |

### Design System (15 rule files)

| Rule | Covers |
|------|--------|
| `design-system.md` | Mandatory stack (Tailwind + shadcn/ui + Framer Motion), Nielsen's 10 heuristics, 7-step design process |
| `tokens.md` | Three-tier token architecture (primitive → semantic → component), OKLCH color |
| `typography.md` | Inter default, type scale, font pairing, self-hosted loading, tabular numbers |
| `color.md` | Color psychology by industry, 7 base palettes, custom primary, dark mode, WCAG contrast |
| `components.md` | Full shadcn/ui catalog, CVA variant pattern, button decision tree, composition rules |
| `page-types.md` | Landing page (hero→CTA→pricing), admin dashboard, auth, settings, list/detail |
| `states.md` | All 4 states mandatory (skeleton with shimmer, empty with CTA, error hierarchy, success) |
| `animation.md` | Duration scale, spring physics, Framer Motion patterns, `prefers-reduced-motion` |
| `accessibility.md` | WCAG 2.2 AA checklist, semantic HTML, ARIA, keyboard nav, focus management |
| `ux-patterns.md` | Onboarding, conversion, forms, search, data viz, notifications, mobile, trust, UX writing |
| `agent-ux.md` | System tray, auto-update flow, background operations, permissions, desktop patterns |
| `responsive.md` | Fluid typography, container queries, responsive nav, tables, CLS prevention |
| `performance.md` | Core Web Vitals (LCP/INP/CLS), bundle budgets, code splitting, font performance |
| `error-pages.md` | 404, 500, 403, offline, maintenance — with escape routes and Sentry IDs |
| `email-templates.md` | react-email + Resend, 10 required transactional emails, dark mode, bulletproof CTA |

### Compliance (configurable)

| Regulation | When to Enable |
|------------|---------------|
| **GDPR + DPDPA** | EU/UK/India users |
| **PCI DSS** | Payments (auto-loaded if `payments: true`) |
| **SOC 2 Type II** | Enterprise sales |
| **HIPAA** | Healthcare / PHI |
| **EU AI Act** | AI features to EU |

### Cross-Platform

- **Desktop:** macOS (Intel + Apple Silicon), Windows, Linux (AppImage + .deb + .rpm)
- **Web:** Chrome, Firefox, Safari (WebKit), mobile Chrome, iPhone 13
- **Mobile web:** viewport, touch targets, iOS keyboard, PWA, offline UX
- **CI:** cross-browser E2E matrix on every PR

### AI-Native Git Discipline

- **Trunk-based or GitFlow** — configurable
- **Experiment branches** (`exp/`) — try uncertain approaches, delete without guilt
- **Checkpoint commits** — logical units, not one giant commit
- **Scope-creep check** — flag anything in the diff that wasn't requested
- **Work-free review loop** — AI branches → implements → PRs. Human just reviews.
- **Git worktrees** — parallel agents get isolated working directories
- **Feature flags > long branches** — merge behind a flag, not a weeks-old branch

### Testing & Auto-Eval Compliance

- **Red Gate / Green Gate** — tests must fail before implementation, pass after
- **Minimum 3 assertions** per test (URL + visibility + data)
- **Test co-location** — `Component.test.tsx` next to `Component.tsx`
- **File length guard** — warns at 300 lines, blocks at 500
- **Eval compliance gate** — AI features without evals can't ship
- **Eval regression detection** — score drop = blocked merge
- **Eval runner template** — TypeScript runner with LLM-as-judge hook

---

## Getting Started

### New project from this boilerplate

```bash
# Clone
git clone https://github.com/SrikanthVemulapally/ai-native-boilerplate.git my-project
cd my-project

# Install & setup
pnpm install
pnpm setup    # guided setup — fills config, generates CLAUDE.md, installs hooks

# Open in Claude Code
claude .
```

Then type `/setup` in Claude Code. That's it.

### Manual setup

```bash
cp boilerplate.config.json.example boilerplate.config.json
# Edit boilerplate.config.json for your project
node scripts/generate-claude-md.js
git config core.hooksPath .githooks
chmod +x .githooks/* .claude/hooks/*.sh
```

### One config file controls everything

```json
{
  "profile": "web-only",
  "stack": { "frontend": "tanstack-start", "backend": "cloudflare-workers" },
  "features": {
    "payments": true,
    "auth": true,
    "seo": true,
    "i18n": true,
    "ai": false
  },
  "compliance": {
    "gdpr": true,
    "dpdpa": true,
    "pci": true,
    "hipaa": false,
    "soc2": false,
    "eu_ai_act": false
  },
  "designSystem": {
    "headingFont": "inter",
    "baseColor": "neutral",
    "darkMode": "system"
  },
  "gitStrategy": "trunk"
}
```

Run `node scripts/generate-claude-md.js` → Claude gets exactly the rules it needs. Nothing more.

---

## Profiles

| Profile | What it is | Rules |
|---------|-----------|-------|
| `web-only` | Web SaaS only | ~20 |
| `agent-web` | Desktop agent + web admin | ~24 |
| `api-only` | Headless API / microservice | ~14 |
| `full-stack` | Everything | ~30 |
| `minimal` | Prototype / hackathon | 7 |

> **`agent-web` enforces auto-update as mandatory.** An agent without auto-update is not shippable.

---

## Extensibility

See **[EXTENDING.md](EXTENDING.md)** for the full guide. Quick version:

- **New stack?** One `.md` file + one line in generator
- **New feature?** One `.md` file + one line in generator
- **Override anything?** Drop `.md` in `rules/custom/` — loads last, always wins
- **New profile?** One `.json` file
- **New command?** Drop `.md` in `.claude/commands/` — immediately available

Works with: **Claude Code** (native) · **Cursor** (`.cursorrules`) · **Windsurf** (`.windsurfrules`) · **Copilot** (`.github/copilot-instructions.md`) · **Cline** (`.clinerules`)

---

## Quick Reference

See **[CHEATSHEET.md](CHEATSHEET.md)** for the one-page scannable reference of all commands, hooks, and rules.

---

## Contributing

Contributions are welcome! See **[CONTRIBUTING.md](CONTRIBUTING.md)** for guidelines.

---

## License

MIT — use it, fork it, sell it, build your empire with it.

---

<p align="center">
  <strong>If this saved you tokens, give it a ⭐</strong>
</p>

<p align="center">
  Built by <a href="https://srikanthvemulapally.com">Srikanth Vemulapally</a> · for builders who take AI-native coding seriously.
</p>
