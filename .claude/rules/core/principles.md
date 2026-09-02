# Core Principles
> Non-negotiable. These 10 principles govern every decision in this codebase.
> When in doubt about ANY choice — consult these first.
> Full detail: see PRINCIPLES.md at project root.

---

## 1. Single Source of Truth
**Spec → Architecture → Code. Never the reverse.**
- `docs/SPEC.md` is the law. Code follows spec. Spec never follows code.
- `docs/ARCHITECTURE.md` is the blueprint. Update it when reality changes.
- `docs/DECISIONS.md` is the memory. Log every significant decision.
- `.mdd/docs/<feature>.md` exists before any feature code is written.

## 2. Think Before You Code
**Planning is the first deliverable.**
- Read existing code before writing. Understand context.
- List every file that will change before touching any.
- If your plan has fewer than 3 steps — think harder.

## 3. Simplicity First
**Simple code is correct code. Complex code is a liability.**
- Simplest solution that works is always preferred.
- No abstraction without 3 concrete use cases.
- Complexity test: can a competent engineer understand this in 60 seconds?

## 4. Surgical Changes Only
**Change only what is required. Nothing more.**
- Never refactor while implementing a feature.
- Never clean up unrelated code in the same commit.
- Blast radius: if touching > 5 files for one feature → reconsider architecture.

## 5. Tests Are Not Optional
**Untested code is not done. It is a liability waiting to fail.**
- Tests before or alongside implementation.
- Every public API: happy path + error case.
- Every bug fix: regression test.

## 6. Git Discipline
**Your commit history is the project's autobiography.**
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- Every commit: complete, working, tested, reviewed.
- No direct pushes to main. PRs required.

## 7. Security Is Non-Negotiable
**Never sacrifice security for speed. Ever.**
- Secrets in env vars. Never in code, comments, or logs.
- All user input validated (Zod). No exceptions.
- Auth + authorization verified on EVERY request.

## 8. Document Decisions, Not Just Code
**Future you needs to know WHY, not just WHAT.**
- Every architectural decision → ADR in `docs/DECISIONS.md`.
- Non-obvious code choices → comment explaining WHY (not WHAT).

## 9. AI Agent Discipline
**AI writes code. Humans own the system.**
- Read the spec. Not training data. Not assumptions.
- When uncertain — ask. Do not hallucinate solutions.
- Document decisions made. Update architecture when changed.
- Token efficiency: read only what you need. One goal per session.

## 10. Definition of Done
A task is DONE only when ALL are true:
- [ ] Feature works as described in `docs/SPEC.md`
- [ ] Tests pass: `pnpm test`
- [ ] Types pass: `pnpm typecheck`
- [ ] Lint passes: `pnpm lint`
- [ ] `docs/ARCHITECTURE.md` reflects current reality
- [ ] Decisions logged in `docs/DECISIONS.md`
- [ ] MDD feature doc updated
- [ ] Commit is clean and conventional
