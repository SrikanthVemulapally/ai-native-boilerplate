# PRINCIPLES.md — Immutable Core
> These rules apply to EVERY project, regardless of profile, stack, or features.
> They cannot be disabled, overridden, or argued against.
> If in doubt about ANY decision — consult these first.

---

## 1. Single Source of Truth (SSoT)

**The spec is always right. The code follows the spec. Never the other way.**

- `docs/SPEC.md` — what the product does. Every feature, every behaviour.
- `docs/ARCHITECTURE.md` — how it's built. Every system boundary, every data flow.
- `docs/DESIGN.md` — how it looks. Tokens, components, patterns.
- `docs/DECISIONS.md` — why decisions were made. ADRs for every significant choice.
- `.mdd/docs/<feature>.md` — per-feature detailed spec before any code is written.

**Before writing a single line of code:**
1. Does this feature exist in `SPEC.md`? If not — add it first.
2. Does the architecture support it? If not — update `ARCHITECTURE.md` first.
3. Is there a feature doc in `.mdd/docs/`? If not — create it first.

**After writing code:**
1. Does `ARCHITECTURE.md` still reflect reality? If not — update it now.
2. Did you make a significant decision? Log it in `DECISIONS.md` now.

---

## 2. Think Before You Code

**Planning is not optional. It is the first deliverable.**

Before touching any file:
1. Identify the goal precisely — what behaviour changes?
2. Identify affected files — list every file that will change.
3. Identify risks — what could break? What has dependencies?
4. Write the plan — minimum one sentence per step.

**Estimation rule:** If your plan has fewer than 3 steps, you haven't thought hard enough.

**The 5-minute rule:** Spend at least 5 minutes reading existing code before writing new code. Discover what already exists. Reuse ruthlessly.

---

## 3. Simplicity First, Always

**Simple code is correct code. Complex code is a liability.**

- The simplest solution that correctly solves the problem is ALWAYS preferred.
- No abstraction without at least 3 concrete use cases.
- No pattern without an existing precedent in this codebase.
- No dependency without reading its source and understanding its cost.
- No generalization before you have the specific case working.

**The complexity test:** Can a competent engineer who has never seen this codebase understand what this code does in 60 seconds? If not — simplify.

---

## 4. Surgical Changes Only

**Change only what is required. Nothing more. Nothing less.**

- Never refactor while implementing a feature.
- Never "clean up" unrelated code in the same commit.
- Never change APIs, interfaces, or schemas beyond what the task requires.
- If you discover a problem while working — log it in `DECISIONS.md`, finish the task, fix separately.

**The blast radius rule:** Every change should touch the minimum number of files possible. If you're touching more than 5 files for a single feature — reconsider the architecture.

---

## 5. Tests Are Not Optional

**Untested code is not done. It is a liability waiting to fail.**

- Write tests BEFORE writing implementation (TDD) or ALONGSIDE implementation.
- Every public API must have at least one happy path test and one error case test.
- Every bug fix must have a regression test.
- Tests live next to what they test. No separate `__tests__` directories buried elsewhere.

**The confidence test:** Before saying "done", ask: "Could I deploy this right now with zero fear?" If no — write more tests.

---

## 6. Git Discipline

**Your git history is your project's autobiography. Write it well.**

- Every commit is a complete, working, deployable unit.
- Conventional commits are mandatory: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- No commit message like "fix stuff", "wip", "misc", "update".
- PRs are required for all changes to `main`. No direct pushes.
- Every PR has a description explaining WHY, not just WHAT.

---

## 7. Security Is Non-Negotiable

**Never sacrifice security for speed. Ever.**

- Secrets go in environment variables. Never in code. Never in comments. Never in logs.
- All user input is validated before use. No exceptions.
- All database queries are parameterized. No string concatenation with user data.
- All external data is treated as hostile until proven otherwise.
- Authentication and authorization are verified on EVERY request. Not just the first one.

---

## 8. Document Decisions, Not Just Code

**Future engineers (including you in 3 months) need to know WHY.**

- Every architectural decision gets an ADR in `docs/DECISIONS.md`.
- Format: Context → Decision → Consequences.
- Every non-obvious code choice gets a comment explaining WHY, not WHAT.
- "Obvious" is not obvious to someone who wasn't in the room.

---

## 9. AI Agent Discipline

**AI writes code. Humans own the system. Never forget which is which.**

**For Claude and all AI agents:**
- You are operating inside a real production codebase. Treat it accordingly.
- Read the existing code before writing new code. Understand before changing.
- The spec is your source of truth. Not your training data. Not your assumptions.
- When uncertain — ask. Do not hallucinate solutions.
- When you make a significant decision — document it in `DECISIONS.md`.
- When your change affects architecture — update `ARCHITECTURE.md` immediately.
- When your change adds a feature — update `SPEC.md` to reflect it.
- Never generate code that you cannot explain line by line.
- Never generate a pattern you have not seen in THIS codebase.

**Token efficiency mandate:**
- Read only what you need. Use targeted file reads, not full-codebase scans.
- One goal per session. Do not scope-creep mid-task.
- Stop when done. Do not "improve" things that weren't in scope.

---

## 10. The Definition of Done

A task is DONE when:
- [ ] The feature works as described in `SPEC.md`
- [ ] Tests pass (`vitest run` / equivalent)
- [ ] Types check (`tsc --noEmit`)
- [ ] Linter passes (`eslint` / equivalent)
- [ ] `ARCHITECTURE.md` reflects the current state
- [ ] Any new decision is logged in `DECISIONS.md`
- [ ] The MDD feature doc is updated
- [ ] The commit is clean and conventional

If any of these are false — it is NOT done.

---

*These principles are not guidelines. They are the contract between you and this codebase.*
*Version: 1.0 — Only updated via explicit team decision logged in DECISIONS.md.*
