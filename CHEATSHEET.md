# AI-Native Boilerplate — Cheat Sheet

Quick reference for every command, hook, rule, and workflow. Bookmark this.

---

## Slash Commands

### Development Workflow
| Command | What It Does |
|---------|-------------|
| `/project-inject` | Inject full project context into session — run at session start |
| `/catchup` | Brief on current project state (branch, recent commits, open MDD docs) |
| `/preflight` | 7-point check before implementing anything |
| `/implement <feature>` | Full MDD workflow: doc → test skeletons → plan → build → verify |
| `/scaffold <feature>` | Generate full feature scaffold (schema, worker, route, component) |
| `/build` | Continue from an approved plan |

### Code Quality
| Command | What It Does |
|---------|-------------|
| `/review` | Code review against 9-point checklist |
| `/refactor <file>` | Full audit + refactor against ALL project rules |
| `/simplify <target>` | Reduce complexity without changing behavior |
| `/security-check` | Security audit — OWASP, auth, secrets, injection |
| `/performance` | Lighthouse, bundle analysis, N+1 detection |

### Testing
| Command | What It Does |
|---------|-------------|
| `/test-plan <feature>` | Comprehensive test strategy with matrix + effort |
| `/test <target>` | Write or run tests with Red Gate enforcement |
| `/add-eval <feature>` | Add LLM-as-judge evals for AI features |
| `/diagnose <issue>` | Investigate only — compare solutions, no code changes |
| `/debug <issue>` | Systematic root-cause + fix |

### Git Workflow
| Command | What It Does |
|---------|-------------|
| `/worktree <name>` | Create isolated branch + worktree for a task |
| `/clean-branches` | Prune stale merged branches from remote |
| `/commit` | Auto-generate conventional commit message from diff |
| `/push` | Push + create PR with description |
| `/release` | Full release process with monitoring checklist |

### Documentation
| Command | What It Does |
|---------|-------------|
| `/update-spec <area>` | Update SPEC.md after requirements change |
| `/update-arch` | Update ARCHITECTURE.md after structural change |
| `/diagram [type]` | Generate diagrams from actual code (arch/api/db/dataflow) |
| `/audit` | Spec drift detection — docs vs codebase |

### Maintenance
| Command | What It Does |
|---------|-------------|
| `/debt` | Tech debt review and prioritization |
| `/compound` | Extract session learnings into CLAUDE.md |
| `/migrate <description>` | Database migration workflow (safe, with rollback) |
| `/create-skill <name>` | Create a new reusable skill |
| `/setup` | Interactive project setup / config |

---

## Lifecycle Hooks (Auto-Run)

| Event | Hook | What It Does |
|-------|------|-------------|
| Session start | `session-start-checklist.sh` | Doc status, branch, CHANGELOG |
| Every prompt | `inject-git-context.sh` | Branch, recent commits, dirty files |
| PreToolUse Write | `protect-sensitive-files.sh` | Block writes to .env, migrations, generated files |
| PreToolUse Bash | `block-dangerous-commands.sh` | Block rm -rf, force push, DROP TABLE, etc. |
| PostToolUse Write | `auto-format.sh` | Format every file Claude touches |
| PostToolUse Write | `schema-migration-reminder.sh` | Remind to migrate after schema changes |
| PostToolUse Write | `post-write-arch-reminder.sh` | Remind to update ARCHITECTURE.md after structural changes |
| PostToolUse Write | `env-var-doc-check.sh` | Block if new env var not in .env.example |
| PostToolUse Write | `track-changed-files.sh` | Count changed files for quality gate |
| PostToolUse Write | `file-length-guard.sh` | Warn at 300 lines, block at 500 |
| PostToolUse Write | `test-co-location-check.sh` | Remind to add test file for new source file |
| Stop | `stop-quality-gate.sh` | 10-point quality gate before finishing |
| Stop | `eval-compliance-gate.sh` | Block if AI features missing evals |
| PreCompact | `pre-compact-save-state.sh` | Save state before context compaction |
| PreCompact | `context-handoff.sh` | Write handoff doc for resumed sessions |
| PostCompact | `post-compact-reinject.sh` | Reinject critical context after compaction |

---

## Git Workflow

### Branch Naming
```
feat/<name>      New features
fix/<name>       Bug fixes  
exp/<name>       Experiments (uncertain — delete if fails)
refactor/<name>  Refactoring
docs/<name>      Documentation
chore/<name>     Tooling, deps
```

### Commit Discipline
```
feat: add user authentication
fix: prevent session expiry on mobile
chore: upgrade Zod to v4
docs: update API endpoint list

Rules:
- 3-5 commits per feature (not 1, not 20)
- Commit at logical units, not at end of session
- Each commit must pass typecheck + tests
- Run /commit to auto-generate message from diff
```

### The Work-Free Review Loop
```
Claude: branches → implements → commits → opens PR
Human: reviews → merges (or requests changes)
```

---

## 8-Phase AI Lifecycle

```
START     → Read docs, /project-inject, /catchup
PLAN      → /preflight, create MDD doc, /test-plan
IMPLEMENT → /worktree, Red Gate, build, Green Gate
VERIFY    → /test, /review, /security-check
SYNC      → /update-arch, /diagram, /audit
SHIP      → /release, /push, PR, merge
MONITOR   → check errors, performance, evals
MAINTAIN  → /debt, /compound, /refactor
```

---

## Testing Rules

```
Pyramid:        Unit 60% / Integration 20% / E2E 15% / Eval 5%
Coverage:       ≥80% on changed files
Assertions:     ≥3 per test (URL + visibility + data)
Co-location:    test.ts next to source.ts
Red Gate:       Tests MUST fail before implementation
Green Gate:     Tests MUST pass after (≤5 fix iterations)
E2E ports:      Dev: 3000  Test: 4000/4010  (never overlap)
```

---

## NFR Budgets

```
Web Performance:
  LCP: <2.5s     FID: <100ms     CLS: <0.1
  Bundle: <150KB  TTI: <3.5s      TTFB: <200ms

API:
  p50: <100ms    p99: <2s        Error rate: <0.1%

Agent (Tauri):
  Launch: <2s    Memory: <200MB  CPU idle: <2%
```

---

## Data Classification

```
T1 PUBLIC       — Expose freely (product names, public prices)
T2 INTERNAL     — Auth users only (usage stats, feature flags)
T3 CONFIDENTIAL — PII, log carefully (email, IP, preferences)
T4 RESTRICTED   — Encrypt at rest + transit (passwords, tokens, PHI)
```

---

## File Structure

```
docs/
  SPEC.md          Requirements (single source of truth)
  ARCHITECTURE.md  System design + data map
  DESIGN.md        Visual decisions + brand
  DECISIONS.md     ADRs (why things are the way they are)
  CHANGELOG.md     Version history
  ROADMAP.md       Phased plan
  RUNBOOK.md       Production incident playbooks
  API.md           API reference

.mdd/
  .startup.md      Session context (auto-updated)
  docs/            MDD feature docs (one per feature)

.claude/
  commands/        Slash commands (25+)
  agents/          Specialist subagents (4)
  hooks/           Lifecycle hooks (16)
  rules/           Loaded context rules (50+)
```

---

## Quick Diagnostics

Something wrong? Check in this order:

1. `git status` — are you on the right branch?
2. `pnpm typecheck` — type errors?
3. `pnpm test` — failing tests?
4. `pnpm lint` — lint errors?
5. `/diagnose <issue>` — systematic investigation
6. `/audit` — spec drift?
7. `/security-check` — security issues?

---

## Key Rules (Never Break)

```
❌ NEVER commit to main directly
❌ NEVER hardcode secrets or credentials
❌ NEVER write code before reading docs
❌ NEVER skip the Red Gate (tests must fail first)
❌ NEVER ship without updating ARCHITECTURE.md
❌ NEVER use any (TypeScript)
❌ NEVER let files exceed 500 lines
❌ NEVER use sequential awaits for independent operations
❌ NEVER store T4 data without encryption
❌ NEVER auto-deploy without human approval
```
