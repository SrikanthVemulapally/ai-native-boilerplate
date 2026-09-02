# /project-inject

Record project-specific context into the session — domain constraints, quality standards, directory conventions, external schemas, API contracts, and anything Claude needs to understand THIS project specifically.

Run this at the start of any session where Claude needs deep project context. Unlike `/catchup` (which reads the current state), `/project-inject` reads the permanent facts about the project.

---

## What Gets Injected

### 1. Project Identity
Read `docs/SPEC.md` and summarise:
- What this product does (1 sentence)
- Who it's for (user type)
- Current phase (alpha / beta / production)
- Active milestone

### 2. Architecture Facts
Read `docs/ARCHITECTURE.md`:
- Package structure (monorepo packages and their roles)
- Data flow (how data moves through the system)
- External dependencies (third-party services, their purpose)
- Critical constraints ("never call X from Y", "always use queue for Z")

### 3. Stack-Specific Conventions
Read `CLAUDE.md` @imports for active stack rules:
- Framework-specific patterns
- Library version pitfalls (e.g., Zod 4 vs v3 differences)
- Anti-patterns specific to this stack
- Code examples for common patterns

### 4. Quality Standards
Read `docs/SPEC.md` NFR section and `.claude/rules/core/nfr.md`:
- Performance budgets (LCP, bundle size, API latency targets)
- Test coverage thresholds
- Security requirements
- Compliance obligations

### 5. Current Work Context
Read `.mdd/.startup.md` and recent `.mdd/docs/`:
- Active feature docs (what's being built)
- In-progress decisions
- Known blockers

### 6. Key Files Map
Read `docs/ARCHITECTURE.md` directory conventions section:
- Where routes live
- Where DB schema lives
- Where workers live
- Where shared types live

---

## Output Format

Present a structured session briefing:

```
📋 PROJECT CONTEXT INJECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Product: [name] — [one sentence description]
Phase: [phase] | Milestone: [milestone]

Architecture:
  [key structural facts]

Active Constraints:
  ⚠️  [constraint 1]
  ⚠️  [constraint 2]

Current Work:
  [active MDD features]

Quality Targets:
  LCP: <2.5s | Bundle: <150KB | Coverage: >80%

I'm ready. What are we working on?
```

---

## When to Run

- Start of any new session working on this project
- After `/catchup` when you need deeper technical context
- When switching from one part of the codebase to another
- When Claude seems to have lost project context mid-session

---

## Auto-Injection

This can also be wired as a `SessionStart` hook to run automatically. See `.claude/hooks/session-start-checklist.sh`.
