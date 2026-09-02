# Promotion Copy — All Platforms

> Ready-to-paste copy for every channel. Post in the order listed for maximum impact.
> Repo: https://github.com/SrikanthVemulapally/ai-native-boilerplate
> Landing: https://srikanthvemulapally.github.io/ai-native-boilerplate

---

## 📅 Posting Schedule

| Day | Platform | Est. Impact |
|-----|----------|-------------|
| Day 1 | Reddit r/ClaudeAI | Medium — warm audience |
| Day 2 | Reddit r/ChatGPTCoding + r/webdev | Medium |
| Day 3 | X/Twitter thread | High if it catches |
| Day 4 | Hacker News Show HN | 🔥 Highest — do this at 8am EST Tuesday/Wednesday |
| Day 5 | dev.to article live | SEO long-tail |
| Week 2 | Product Hunt | Credibility + backlink |
| Ongoing | Discord servers + Awesome list PRs | Permanent backlinks |

---

## 1. REDDIT

### r/ClaudeAI

**Title:**
> I built a boilerplate that stops Claude from drifting — 170+ rules, 6 enforcement layers, open source

**Body:**
```
After months of Claude ignoring my architecture rules mid-session, I built this.

The problem: every time you start a new Claude session, it forgets your patterns, rewrites things its own way, and slowly turns your codebase into a mess. You spend more time correcting drift than actually building.

So I built AI-Native Boilerplate — a discipline layer for AI coding agents.

**What it is:**
- 160+ files of rules across 6 layers (core, stack, features, compliance, custom)
- Token-efficient: loads only what your project needs (~2K–13K tokens depending on config)
- Works with Claude Code, Cursor, Windsurf, Copilot, Cline
- Covers architecture enforcement, design systems, security, GDPR/HIPAA/SOC2 compliance, testing, and more
- One command setup: generates a single CLAUDE.md tailored to your stack

**The layers:**
1. Core rules — always loaded (architecture, git, testing, security)
2. Stack rules — loaded by your stack (React, Node, Rust, Python...)
3. Feature rules — loaded by feature flag (payments, auth, SEO, i18n...)
4. Design system — tokens, components, spacing
5. Custom rules — your overrides, loaded last, always win
6. Compliance — GDPR, HIPAA, SOC2, PCI, EU AI Act

**Token savings:** Instead of re-explaining your architecture every session, the boilerplate handles it. Teams report saving millions of tokens per month.

GitHub: https://github.com/SrikanthVemulapally/ai-native-boilerplate
Landing page: https://srikanthvemulapally.github.io/ai-native-boilerplate

MIT licensed. Would love feedback from this community — you're exactly who this was built for.
```

---

### r/ChatGPTCoding

**Title:**
> Open source boilerplate that gives AI coding assistants 170+ rules to follow — stops drift, saves tokens

**Body:**
```
If you've ever had an AI coding assistant ignore your architecture, rewrite things its own way, or forget context between sessions — this is for you.

AI-Native Boilerplate is an open source discipline layer for AI agents.

**The core idea:**
Instead of hoping your AI follows your rules, you encode them once in a structured boilerplate. The generator builds a single CLAUDE.md (or equivalent) that your agent reads at session start — covering architecture, patterns, security, testing, and compliance.

**Works with:** ChatGPT (via Codex/API), Claude Code, Cursor, Windsurf, GitHub Copilot, Cline

**What's inside:**
- 160+ rule files across 6 layers
- Stack configs for React, Next.js, Node, Python, Rust, Go, and more
- Feature flags: payments (Stripe), auth, SEO, i18n, analytics, real-time, file uploads
- Compliance packs: GDPR, HIPAA, SOC2, PCI DSS, EU AI Act
- Design system enforcement (colors, spacing, typography tokens)
- Token-efficient: minimal config loads ~2K tokens, full stack ~13K

One command generates your tailored config. MIT licensed.

https://github.com/SrikanthVemulapally/ai-native-boilerplate

Happy to answer questions — been using this in production for a few months now.
```

---

### r/webdev

**Title:**
> I got tired of AI rewriting my architecture every session, so I built a structured boilerplate to enforce it — open source

**Body:**
```
Every developer I know has hit this wall: you set up a clean architecture, start using an AI coding assistant, and slowly the patterns diverge. The AI writes things its own way, ignores your conventions, and you spend half your time correcting it.

I built AI-Native Boilerplate to solve this.

It's a configurable rule system for AI coding agents — 160+ files covering architecture, stack conventions, design systems, security, testing, and compliance. You run a generator, it builds a single context file tuned to your stack, and your AI agent actually follows your rules.

**Stack support:** React, Next.js, Remix, Vue, Svelte, Node, Python, Go, Rust, and more
**Feature flags:** Stripe payments, OAuth, SEO, i18n, analytics, real-time, file uploads
**Compliance:** GDPR, HIPAA, SOC2, PCI DSS, EU AI Act — pre-written rules, not afterthoughts
**Design system:** Typography, color, spacing, and component rules your AI actually follows

It's MIT licensed and I'm actively maintaining it.

https://github.com/SrikanthVemulapally/ai-native-boilerplate

Would genuinely love feedback from experienced web devs — what rules would you add?
```

---

### r/nextjs

**Title:**
> Built a boilerplate that gives AI agents strict Next.js rules — stops them from using Pages Router, wrong patterns, etc.

**Body:**
```
Quick one for the Next.js community.

If you use AI coding assistants with Next.js, you know the pain: it uses Pages Router when you want App Router, puts logic in the wrong place, ignores your file structure, or writes client components when server components would be better.

I built AI-Native Boilerplate with a dedicated Next.js rule layer that enforces:
- App Router only (or Pages Router if you're still there — configurable)
- Server vs client component boundaries
- File/folder conventions
- Data fetching patterns (Server Actions, Route Handlers)
- Image optimization rules
- Metadata API usage
- Turbopack vs Webpack config
- Deployment target rules (Vercel, Cloudflare, self-hosted)

Plus layers for TypeScript, Tailwind, testing (Vitest/Playwright), Stripe, auth, and more.

One command generates a CLAUDE.md tailored to your exact Next.js setup.

https://github.com/SrikanthVemulapally/ai-native-boilerplate

MIT. Feedback welcome — especially from folks running large Next.js codebases with AI agents.
```

---

## 2. HACKER NEWS — Show HN

**Title:**
> Show HN: AI-Native Boilerplate – 170+ rules that stop LLMs from drifting in your codebase

**Body (first comment — post immediately after submission):**
```
Hi HN,

I've been building production software with AI coding agents (Claude Code, Cursor, Copilot) for the past year. The biggest problem isn't the AI's capability — it's drift. Every session, the AI subtly deviates from your architecture. Over weeks, the codebase diverges from its own conventions.

I built AI-Native Boilerplate to solve this structurally.

**How it works:**
A generator reads your project config (stack, features, compliance needs) and concatenates the relevant rule files into a single CLAUDE.md. Your agent loads this at session start — one read, zero overhead, full context.

**The architecture has 6 layers:**
1. Core — always loaded (git discipline, testing, security, architecture)
2. Stack — loaded by your stack (React, Next.js, Node, Python, Rust, Go...)
3. Features — loaded by flag (Stripe, auth, SEO, i18n, analytics, real-time...)
4. Design system — typography, color, spacing tokens your agent follows
5. Custom — your project-specific overrides, loaded last, always win
6. Compliance — GDPR, HIPAA, SOC2, PCI DSS, EU AI Act

**Token efficiency:**
Minimal config: ~2K tokens | Full-stack: ~13K tokens. The concatenation approach means one file read vs. dozens of imports — significant savings at scale.

**What's NOT in this repo:**
- No framework code (it's a rule layer, not a starter template)
- No vendor lock-in (works with any AI coding agent)
- No magic (just well-structured Markdown that agents actually follow)

GitHub: https://github.com/SrikanthVemulapally/ai-native-boilerplate
Landing: https://srikanthvemulapally.github.io/ai-native-boilerplate

Happy to answer questions about the architecture decisions, why certain rules are structured the way they are, or what I've learned about what agents actually follow vs. ignore.
```

---

## 3. X / TWITTER THREAD

**Tweet 1 (hook):**
```
AI coding assistants are powerful.

But they drift.

Every session, your AI subtly ignores your architecture — until your codebase is a mess.

I built a fix. Open source. 170+ rules. Thread 🧵
```

**Tweet 2:**
```
The problem isn't the AI's capability.

It's that every new session starts with zero context about YOUR architecture, YOUR patterns, YOUR rules.

So it writes things its own way. And you spend more time correcting than building.
```

**Tweet 3:**
```
AI-Native Boilerplate is a discipline layer for AI coding agents.

160+ rule files across 6 layers:
→ Core (always loaded)
→ Stack (React, Next, Node, Python, Rust...)
→ Features (Stripe, auth, SEO, i18n...)
→ Design system
→ Custom overrides
→ Compliance (GDPR, HIPAA, SOC2)
```

**Tweet 4:**
```
The token math matters.

Instead of re-explaining your architecture every session, the generator builds ONE file your agent reads at start.

Minimal config: ~2K tokens
Full-stack: ~13K tokens

Teams using this save millions of tokens per month.
```

**Tweet 5:**
```
Works with every major AI coding agent:

→ Claude Code ✅
→ Cursor ✅
→ Windsurf ✅
→ GitHub Copilot ✅
→ Cline ✅
→ Codex ✅

One boilerplate. Any agent.
```

**Tweet 6:**
```
Compliance isn't an afterthought here.

Pre-written rule packs for:
→ GDPR
→ HIPAA
→ SOC2
→ PCI DSS
→ EU AI Act

Your AI agent follows them from day one. Not after the audit.
```

**Tweet 7:**
```
Design system enforcement too.

Typography, color tokens, spacing, component rules — all encoded.

No more AI writing inline styles when you have a design system. No more hardcoded hex values. No more inconsistent spacing.
```

**Tweet 8:**
```
It's MIT licensed. Actively maintained.

One command to generate your tailored config:

npx ai-native-boilerplate init

GitHub ⭐: https://github.com/SrikanthVemulapally/ai-native-boilerplate

If this helped you — share it. This problem affects every team building with AI agents.
```

---

## 4. DEV.TO / HASHNODE ARTICLE

**Title:** How I Stopped AI Coding Assistants From Drifting — And Saved Millions of Tokens Doing It

**Tags:** ai, claudeai, cursor, webdev, opensource

**Cover image:** Use the repo banner (assets/banner.png)

---

**Article:**

```markdown
# How I Stopped AI Coding Assistants From Drifting — And Saved Millions of Tokens Doing It

If you've been building with AI coding assistants — Claude Code, Cursor, Copilot, Windsurf — you've hit this wall.

You start a new session. The AI doesn't know your architecture. It doesn't know your patterns. It doesn't know the decisions you made three weeks ago when you chose server components over client components, or why you're using Drizzle instead of Prisma.

So it guesses. And it drifts.

Over sessions, your codebase slowly diverges from its own conventions. Files get inconsistent. Patterns split. You spend more time correcting the AI than actually building.

I got tired of it. So I built a structural fix.

## The Problem Is Context, Not Capability

The AI isn't bad at coding. It's bad at *remembering your specific context* across sessions.

Every session is a blank slate. You can paste in context manually — but that burns tokens, takes time, and you'll inevitably forget something. And as your codebase grows, "explain your architecture to the AI" becomes a 10-minute ritual before every session.

There had to be a better way.

## The Solution: A Structured Rule Layer

I built [AI-Native Boilerplate](https://github.com/SrikanthVemulapally/ai-native-boilerplate) — a configurable, token-efficient discipline layer for AI coding agents.

The idea is simple: encode your architecture, patterns, and conventions once, in a structured format your AI agent actually reads and follows. Then generate a single context file from that structure, tuned to your exact stack and features.

No more re-explaining. No more drift.

## The Architecture

The boilerplate has 6 layers:

### Layer 1: Core Rules (always loaded)
The fundamentals that apply to every project:
- Git discipline (commit message format, branch naming, PR conventions)
- Testing requirements (coverage thresholds, test file structure)
- Security baseline (no secrets in code, input validation, auth patterns)
- Architecture invariants (folder structure, import rules, naming conventions)

### Layer 2: Stack Rules (loaded by your stack)
Specific rules for your technology choices:
- React, Next.js (App Router vs Pages Router), Vue, Svelte, Remix
- Node.js, Python, Go, Rust
- TypeScript strictness rules
- Database patterns (Drizzle, Prisma, Mongoose)
- Styling (Tailwind, CSS Modules, styled-components)

### Layer 3: Feature Rules (loaded by flag)
Only loaded when you enable the feature:
- Stripe payments (webhook handling, idempotency, error handling)
- Authentication (session management, OAuth, JWT patterns)
- SEO (metadata API, structured data, sitemap)
- Internationalization (i18n patterns, locale routing)
- Analytics, real-time, file uploads, email, error tracking

### Layer 4: Design System
Typography tokens, color scales, spacing values, component conventions — all encoded. Your AI agent references these instead of inventing its own values.

### Layer 5: Custom Rules (your overrides)
Your project-specific rules, loaded last. They always win over base layers. This is where you encode decisions that are specific to your codebase.

### Layer 6: Compliance
Pre-written rule packs for GDPR, HIPAA, SOC2, PCI DSS, and EU AI Act. Your AI agent follows them from day one — not after the audit flags something.

## The Token Math

This is where it gets interesting.

The generator concatenates all relevant rule files into a single `CLAUDE.md`. Your agent loads this once at session start.

| Config | Rules Loaded | ~Tokens |
|--------|-------------|---------|
| Minimal | 7 | ~2K |
| Web-only | ~20 | ~9K |
| Agent+Web | ~24 | ~10.5K |
| Full-stack | ~30 | ~13K |

Compare this to manually pasting context every session. At 10 sessions a day, across a team of 5, the savings compound fast. Teams report saving **millions of tokens per month**.

## Getting Started

```bash
npx ai-native-boilerplate init
```

The CLI asks about your stack, features, and compliance needs — then generates your tailored `CLAUDE.md` in seconds.

## What I Learned Building This

A few things that surprised me:

**1. Agents follow structure, not prose.** Rules written as bullet points with clear verbs ("always use", "never use", "prefer X over Y") are followed far more reliably than paragraph-style explanations.

**2. Ordering matters.** Rules loaded later override earlier ones. The custom layer wins by design — this is the single most important architectural decision in the boilerplate.

**3. Token efficiency compounds.** The difference between 2K and 13K tokens per session is significant at scale. Being selective about which rules to load (feature flags, stack specificity) is worth the upfront config work.

**4. Compliance rules change agent behaviour significantly.** When GDPR rules are loaded, the agent genuinely handles PII differently — logging decisions, data retention comments, consent patterns. It's not magic, but it's real.

## Try It

The project is MIT licensed and actively maintained.

→ [GitHub](https://github.com/SrikanthVemulapally/ai-native-boilerplate)  
→ [Landing page](https://srikanthvemulapally.github.io/ai-native-boilerplate)  
→ [Built by Srikanth Vemulapally](https://srikanthvemulapally.com)

If you're building serious software with AI agents and drift is a problem — this is for you. Star it, fork it, or open an issue. I'm actively responding to feedback.
```

---

## 5. PRODUCT HUNT

**Name:** AI-Native Boilerplate

**Tagline:** 170+ rules that stop AI coding agents from drifting in your codebase

**Description:**
```
AI coding assistants drift. Every new session starts with zero context — and slowly, your architecture diverges from its own conventions.

AI-Native Boilerplate is a structured discipline layer for AI agents (Claude Code, Cursor, Copilot, Windsurf, Cline). A generator builds a single token-efficient context file tailored to your stack, so your agent follows your rules from session one.

6 layers: Core → Stack → Features → Design System → Custom → Compliance (GDPR, HIPAA, SOC2, PCI)

Supports: React, Next.js, Vue, Svelte, Node, Python, Go, Rust, and more.

MIT licensed. One command to start.
```

**First comment (post immediately):**
```
Hey Product Hunt! 👋

I'm Srikanth, the maker of AI-Native Boilerplate.

This started as a personal frustration — I was building production apps with Claude Code and Cursor, and no matter how carefully I set up my architecture, the AI would slowly drift from my conventions. New session = blank slate = drift.

The fix was structural: encode your rules once, generate a single context file, and your agent follows them consistently across every session.

The project is MIT licensed and I'm actively maintaining it. Would love your honest feedback — especially from teams already using AI coding agents in production.

GitHub: https://github.com/SrikanthVemulapally/ai-native-boilerplate
```

**Topics:** Developer Tools, Artificial Intelligence, Open Source, Productivity

---

## 6. DISCORD SERVERS

### Anthropic Discord (#projects or #showcase)
```
Just open-sourced something I've been building for a few months — AI-Native Boilerplate.

It's a discipline layer for Claude Code (and other agents) — 170+ rules across 6 layers that stop LLMs from drifting in your codebase. Token-efficient, configurable by stack and feature.

https://github.com/SrikanthVemulapally/ai-native-boilerplate

Would love feedback from folks who use Claude Code heavily — you know the drift problem better than anyone.
```

### Cursor Discord (#showcase)
```
Built something for Cursor users dealing with AI drift — AI-Native Boilerplate.

Generates a single tailored context file for your agent, covering architecture, stack conventions, design system, and compliance. Works with Cursor's rules system.

https://github.com/SrikanthVemulapally/ai-native-boilerplate

MIT licensed. Feedback welcome.
```

---

## 7. AWESOME LIST PRs

Submit PRs to these repos adding the boilerplate:

### awesome-cursorrules
```markdown
- [AI-Native Boilerplate](https://github.com/SrikanthVemulapally/ai-native-boilerplate) - 170+ rules across 6 layers for Claude Code, Cursor, Copilot, Windsurf and more. Token-efficient, stack-configurable, compliance-ready.
```

### awesome-claude
```markdown
- [AI-Native Boilerplate](https://github.com/SrikanthVemulapally/ai-native-boilerplate) - Structured rule boilerplate for Claude Code. 170+ rules, 6 enforcement layers, compliance packs (GDPR/HIPAA/SOC2). MIT.
```

### awesome-ai-tools
```markdown
- [AI-Native Boilerplate](https://github.com/SrikanthVemulapally/ai-native-boilerplate) - Discipline layer for AI coding agents. Stops LLM drift, enforces architecture, saves tokens. MIT licensed.
```

---

*Generated by Qawl — srikanthvemulapally.com*
