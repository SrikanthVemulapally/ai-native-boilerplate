# AI Agent Discipline — Lifecycle & Protocols
> Always loaded. These rules govern how AI agents work from project start to completion to maintenance.
> They exist because AI coding without discipline produces unmaintainable codebases.

---

## The Lifecycle

```
START → PLAN → IMPLEMENT → VERIFY → SYNC → SHIP → MONITOR → MAINTAIN
  ↑                                                              |
  └─────────────────── FEEDBACK LOOP ────────────────────────────┘
```

Every feature, every bugfix, every change follows this cycle. No skipping steps.

---

## Phase 1: START — Context Recovery

**Every new session begins here. Before any work.**

### Context Recovery Protocol
1. Read `docs/SPEC.md` — what does this product do?
2. Read `docs/ARCHITECTURE.md` — how is it built?
3. Read `docs/DECISIONS.md` (last 5 entries) — what was recently decided?
4. Read `docs/CHANGELOG.md` (last 10 entries) — what recently changed?
5. Check `.mdd/docs/` — are there in-progress features?
6. `git log --oneline -20` — recent commit history
7. `git status` — what's dirty?
8. `git diff --stat` — what's staged/unstaged?

**Only after completing all 8 steps may you proceed to PLAN.**

### Session Boundary Protocol
When ending a session:
1. Update `.mdd/docs/<feature>.md` status field.
2. Log progress in `docs/CHANGELOG.md` if significant.
3. Commit or stash all changes. Never leave dirty working tree.
4. Note in `.mdd/docs/<feature>.md` under "Notes": what's left to do.

---

## Phase 2: PLAN — Before Writing Code

### Pre-Flight Checklist (mandatory before ANY implementation)
- [ ] Feature exists in `docs/SPEC.md`? If not → add it first.
- [ ] `.mdd/docs/<feature>.md` exists? If not → create it first.
- [ ] Architecture documented for this feature? If not → update `docs/ARCHITECTURE.md`.
- [ ] Affected files identified and listed in feature doc?
- [ ] Risks identified? What could break?
- [ ] Test cases written in feature doc?
- [ ] Estimated number of files to change? If > 5 → reconsider scope.

**If any checkbox is unchecked, do NOT proceed to implementation.**

### Planning Rules
- Minimum 3 steps in any plan. Fewer = you haven't thought enough.
- List every file that will change. No surprises.
- Identify dependencies between steps. What must happen before what?
- Note which steps are reversible and which are not.
- For non-reversible steps (migrations, data transforms) → write a rollback plan.

---

## Phase 3: IMPLEMENT — Writing Code

### Coding Rules (in priority order)
1. **Read before write.** Read the file you're about to change. Read related files. Understand context.
2. **Match existing patterns.** Look at 2-3 similar files. Follow the established pattern. Do not introduce a new pattern.
3. **One change at a time.** Complete one logical change, test it, then move to the next.
4. **No scope creep.** If you notice something unrelated that could be improved → log in `docs/DECISIONS.md` as "Tech Debt: ...". Do not fix it now.
5. **No silent refactors.** If a refactor is needed to implement the feature → it's part of the feature. Document it. If not → it's tech debt. Log it.
6. **Explain non-obvious code.** Comments explain WHY, not WHAT. If you wrote it and it needs a WHAT comment → it's too complex.

### Anti-Patterns Catalog (never do these)

| Anti-Pattern | Why It's Bad | Do Instead |
|--------------|-------------|------------|
| **God files** (>500 lines) | Unmaintainable, hard to review, merge conflicts | Split by responsibility, ≤200 lines ideal |
| **Premature abstraction** | Wrong abstraction is worse than duplication | Wait for 3 concrete use cases before abstracting |
| **Defensive coding for impossible states** | Noise, dead code, false safety | Use TypeScript types to make states impossible |
| **Copy-paste without understanding** | Bugs propagate, fixes don't | Read what you copy. Adapt to this context. |
| **Chasing the latest library** | Dependency churn, bundle bloat, breaking changes | Use what's installed. Justify any new dep in DECISIONS.md |
| **Mocking everything in tests** | Tests pass but app is broken | Test against real boundaries (real DB, real API) for integration tests |
| **Commenting out code instead of deleting** | Dead code, confusion, git archaeology needed | Delete it. Git remembers. Need it back? `git revert`. |
| **`any` type escape hatch** | Type safety is the whole point of TypeScript | Use `unknown` + narrow, or define the type properly |
| **Catch-all error swallowing** | `catch (e) {}` hides bugs forever | Log the error. Let it surface. Handle specifically. |
| **Committing commented-out console.logs** | Noise in codebase | Use a logger. Remove debug code before commit. |
| **Reimplementing stdlib/library functions** | Reinventing the wheel, probably worse | Use the library. Read its docs. |
| **Deeply nested conditionals** | Unreadable, untestable | Early returns, guard clauses, extract functions |
| **Long parameter lists** | Wrong abstraction, hard to call | Group into an options object with a type |
| **Magic numbers** | What does `86400` mean? | Named constant: `SECONDS_PER_DAY = 86400` |
| **Inconsistent naming** | Cognitive load, search difficulty | Follow naming conventions (see conventions.md) |

### Self-Correction Protocol
When you realize you made a mistake mid-implementation:

1. **STOP.** Do not "fix it forward". Stop the current approach.
2. **ASSESS.** How bad is it? Is it already committed? Is it deployed?
3. **REVERT if needed.** `git checkout -- <file>` for uncommitted. `git revert <commit>` for committed.
4. **DOCUMENT.** Log what went wrong in `.mdd/docs/<feature>.md` under "Notes".
5. **REPLAN.** Update the plan with the correct approach.
6. **REIMPLEMENT.** Start fresh with the correct approach.

**Never paper over a mistake. Never "make it work" with a hack. Fix the root cause.**

### Escalation Matrix — When to Ask the Human

| Situation | Action |
|-----------|--------|
| Spec is ambiguous or contradictory | STOP. Ask human. Do not guess. |
| Multiple valid approaches with different trade-offs | Present options to human with pros/cons. Let them choose. |
| Change affects > 5 files | Confirm scope with human before proceeding. |
| Database migration that could lose data | STOP. Present migration plan to human. Get explicit approval. |
| Security-sensitive change (auth, crypto, payments) | Always have human review the diff before commit. |
| Breaking API change | Present deprecation plan to human. Get approval. |
| Need to add a new dependency | Justify in `docs/DECISIONS.md`. If > 50KB gzipped → ask human. |
| Feature seems to require architecture change | Update `ARCHITECTURE.md` first. Have human review. |
| Tests are failing and you don't understand why | Investigate for 15 min. If still stuck → ask human with details. |
| You're about to delete files | Always confirm with human before deleting. |

**Default: when uncertain, ask. Do not hallucinate. Do not guess. Do not "probably".**

---

## Phase 4: VERIFY — Testing & Quality

### Testing Strategy

| Test Type | What It Covers | Tool | Run When |
|-----------|---------------|------|----------|
| Unit | Pure functions, utilities, service layer | Vitest | Every commit |
| Component | UI components in isolation | Vitest + Testing Library | Every commit |
| Integration | API routes + DB + external services | Vitest + D1 local | Every PR |
| E2E | Full user flows in browser | Playwright | Every PR (smoke) |
| Eval (AI) | AI output quality, accuracy, safety | Custom eval runner | On AI feature change |

### Test Rules
- **Arrange-Act-Assert** structure. Always. No exceptions.
- **One assertion per test** when possible. Group related assertions only if testing the same behavior.
- **Test behavior, not implementation.** Tests should survive a refactor of the implementation.
- **Descriptive test names:** `it('returns 401 when user is not authenticated')` not `it('test auth')`.
- **No `expect(true).toBe(true)`** — that's not a test, that's a lie.
- **Coverage threshold: 80%** on changed files. Enforced in CI.
- **Every bug fix includes a regression test** that would have caught the original bug.

### AI Eval Rules (when `features.ai` is enabled)
- Define eval criteria in `.mdd/docs/<feature>.md` under "Tests" section.
- Eval runner: input → AI output → judge (LLM or rubric) → score.
- Minimum 20 test cases per AI feature.
- Threshold: > 80% pass rate to deploy. < 60% = block deploy.
- Version eval prompts and model configs alongside code.

### Quality Gate (before commit)
- [ ] `pnpm lint` — zero errors, zero warnings
- [ ] `pnpm typecheck` — zero errors
- [ ] `pnpm test` — all pass, ≥80% coverage on changed files
- [ ] No `console.log` in committed code (use logger)
- [ ] No `any` types (use `unknown` or proper types)
- [ ] No commented-out code
- [ ] No `TODO` without a ticket reference (`TODO(TICKET-123): ...`)

---

## Phase 5: SYNC — Documentation Update

**After implementation, before commit. No exceptions.**

- [ ] Does `docs/ARCHITECTURE.md` still match reality? → Update if not.
- [ ] Does `docs/SPEC.md` reflect this feature? → Update if not.
- [ ] Was a significant decision made? → Log in `docs/DECISIONS.md`.
- [ ] Is `.mdd/docs/<feature>.md` status updated? → Update to `done` or `in-progress`.
- [ ] Is `docs/CHANGELOG.md` updated? → Add entry under "Unreleased".
- [ ] Any new env vars? → Add to `.env.example` with comment.

**If any of these are skipped, the commit hook will block you.**

---

## Phase 6: SHIP — Release

### Release Checklist
- [ ] All CI checks pass on `main`
- [ ] `docs/CHANGELOG.md` updated with version + date
- [ ] D1 migrations tested on staging
- [ ] Health check endpoint verified on staging
- [ ] Rollback plan documented and tested
- [ ] Feature flags set (if using staged rollout)
- [ ] Post-deploy monitoring active
- [ ] `docs/DECISIONS.md` has release ADR (for major versions)

### Versioning
- Semantic versioning: `MAJOR.MINOR.PATCH`
- MAJOR: breaking changes (API, DB schema, UX flows)
- MINOR: new features, backward-compatible
- PATCH: bug fixes, performance improvements, docs
- Pre-release: `1.0.0-beta.1`, `1.0.0-rc.1`
- Agent apps: version in `tauri.conf.json` must match git tag

---

## Phase 7: MONITOR — Post-Release

### First 15 Minutes
- Watch error rate. > 1% = rollback.
- Watch p99 latency. > 5s = rollback.
- Watch health check. Any failure = rollback.
- Check user-facing pages manually (smoke test production).

### First 24 Hours
- Monitor error tracking for new error types.
- Monitor support tickets / user feedback.
- Monitor Stripe webhook processing (if payment-related).
- Monitor queue depth (if queue-based).

### First Week
- Review Core Web Vitals (if frontend change).
- Review D1 query performance (if DB change).
- Review cost impact (if architecture change).
- Schedule post-mortem if any incidents occurred.

---

## Phase 8: MAINTAIN — Long-Term Health

### Technical Debt Management
- All tech debt logged in `docs/DECISIONS.md` with prefix `TECH DEBT:`.
- Format: `TECH DEBT: <description> — Impact: <low/medium/high> — Estimated fix: <hours>`
- Review tech debt list every sprint planning.
- Allocate 20% of sprint capacity to debt reduction.
- High-impact debt → fix immediately, don't wait for sprint.

### Dependency Management
- `pnpm audit` weekly. Critical vulnerabilities → fix same day.
- Major version bumps → test on branch first, review changelog, check for breaking changes.
- Lockfile committed. Never run `pnpm install` without `--frozen-lockfile` in CI.
- Review dependency list quarterly. Remove unused packages: `pnpm depcheck`.

### Spec Drift Audit (monthly)
1. Compare `docs/SPEC.md` feature list against actual codebase routes/components.
2. Compare `docs/ARCHITECTURE.md` diagrams against actual file structure.
3. Compare `.mdd/docs/` status fields against actual implementation state.
4. Log discrepancies in `docs/DECISIONS.md` as `SPEC DRIFT: ...`.
5. Fix drift: either update docs to match reality, or fix code to match docs. Prefer the former unless code is wrong.

### Architecture Review (quarterly)
1. Is the architecture still serving the product? Or has the product outgrown it?
2. Are there any bottlenecks? (D1 query limits, Worker CPU, bundle size)
3. Are there any new Cloudflare features that would simplify the architecture?
4. Log findings in `docs/DECISIONS.md` as `ARCH REVIEW Q<N>: ...`.
5. Major architecture changes → new ADR + spec update + migration plan.

### Security Audit (quarterly)
1. `pnpm audit` — all vulnerabilities addressed or documented as accepted risk.
2. Review all auth middleware — any bypass paths?
3. Review all API routes — any missing auth/authorization checks?
4. Review all Stripe webhook handlers — signature verification still working?
5. Review environment variables — any leaked? Any unused?
6. Review D1 schema — any missing RLS or userId filters?
7. Log findings in `docs/DECISIONS.md` as `SEC AUDIT Q<N>: ...`.

---

## Session Close Protocol

Before ending ANY session, complete these steps in order:

```
SESSION CLOSE CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━
□ 1. All tests pass (pnpm test)
□ 2. Types clean (pnpm typecheck)
□ 3. Lint clean (pnpm lint)
□ 4. Checkpoint commit made (nothing uncommitted)
□ 5. ARCHITECTURE.md updated if structure changed
□ 6. MDD doc updated if feature doc exists for this work
□ 7. DECISIONS.md updated if a key decision was made
□ 8. .env.example updated if new env vars added
□ 9. Run /compound to extract session learnings
□ 10. Announce: branch, what was done, what's next
```

Never end a session with uncommitted changes, failing tests, type errors, or docs out of sync with code.

If the session was interrupted (context compaction): read `.claude/handoffs/latest.md` to understand where things were left before continuing.

---

## Multi-Agent Coordination

When multiple AI agents work on the same codebase:

| Rule | Why |
|------|-----|
| One feature per agent | No merge conflicts, clear ownership |
| Agents communicate via `.mdd/docs/` | Shared state, no hidden context |
| Architecture changes require human approval | Prevents divergent architectures |
| No agent touches another agent's feature files | Prevents conflicts |
| Merge to `main` only via PR | Human reviews all cross-agent changes |
| Shared types/interfaces updated via dedicated PR | Prevents type drift |

---

## Refactoring Discipline

### When to Refactor
- When the code is actively being changed for a feature (opportunistic refactoring).
- When tech debt is blocking a feature (necessity refactoring).
- When the architecture no longer fits the product (structural refactoring — requires ADR).
- **Never** "because it looks ugly". Aesthetics are not a reason for change.

### How to Refactor
1. **Write tests first.** If there are no tests, write characterization tests that capture current behavior.
2. **One refactor at a time.** One type of change per commit. No mixing refactors with features.
3. **Verify tests pass after each step.** If tests break → you changed behavior. Revert or update tests deliberately.
4. **Commit after each step.** Small, reviewable commits. Easy to bisect if something breaks.
5. **Document the refactor** in `docs/DECISIONS.md`: what changed, why, what's the impact.

### Refactoring Anti-Patterns
- "Big bang" refactors (rewrite everything at once) → always fail.
- Refactoring without tests → you will break things and not know it.
- Refactoring while implementing a feature → mixed concerns, hard to review.
- Refactoring without documenting → future you doesn't know why it changed.

---

## Context Budget Management

AI agents have limited context. Manage it like a resource.

- **Read only what you need.** Targeted file reads, not full-codebase scans.
- **One goal per session.** Do not scope-creep mid-task.
- **Close loops.** Finish a feature before starting the next one.
- **Use the spec.** The spec is compressed context. Read it instead of reading 50 source files.
- **Stop when done.** Do not "improve" things that weren't in scope.
- **Delegate when possible.** Use subagents for independent tasks.
- **Summarize at boundaries.** When switching tasks, summarize what was done to reduce context carry.
