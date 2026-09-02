# Git Discipline — AI-Native Workflow
> Always loaded. Non-negotiable. Your git history is your project's autobiography — write it well.
> AI agents touch more files faster than humans. Git discipline contains that risk without slowing down.

---

## Branch Strategy — Configurable

Set in `boilerplate.config.json` → `"gitStrategy": "trunk" | "gitflow"`. Default: `trunk`.

### Trunk-Based Development (default — recommended for web/SaaS)

```
main ─────────────────────────────────────────────── production
  ├── add-user-export ──── short-lived feature branch
  ├── fix-stripe-webhook ── short-lived fix branch
  └── exp/auth-jwt ──────── experiment (may be discarded)
```

- **Branch from `main`, merge to `main` via PR, delete after merge.**
- No `develop` branch. No `release` branches.
- Branch lifetime: **under 2 days**. Longer features → use feature flags.
- Every merge to `main` is potentially deployable (CI auto-deploys).
- Incomplete features: behind feature flags, NOT long-lived branches.

### GitFlow (for scheduled releases, mobile apps, enterprise)

```
main ─────────────────────────────── production only
  └── develop ────────────────────── integration for next release
        ├── feature/user-export ──── branched from develop
        └── feature/billing-v2 ───── branched from develop
release/v1.2.0 ← branched from develop → merged to main AND develop
hotfix/critical-fix ← branched from main → merged to main AND develop
```

- Feature: branch from `develop`, merge to `develop`. Name: `feature/description`.
- Release: branch from `develop`, merge to `main` AND `develop`. Name: `release/vX.Y.Z`.
- Hotfix: branch from `main`, merge to `main` AND `develop`. Name: `hotfix/description`.
- `main`: production only. Never commit directly.

### Branch Naming (all strategies)

```
<type>/<short-description>      ← trunk-based (no feature/ prefix needed for short branches)
feature/<description>           ← gitflow only
fix/<description>               ← bug fix
exp/<description>               ← experiment (may be discarded — zero guilt)
refactor/<description>          ← no new behavior, structural only
chore/<description>             ← config, deps, tooling
release/vX.Y.Z                  ← gitflow only
hotfix/<description>            ← gitflow only
```

- lowercase, hyphens only — no underscores, no spaces
- max 50 characters
- always branched from the correct base (main for trunk, develop for gitflow features)

---

## The Experiment Branch Pattern

**The most underused pattern in AI-native development.**

When you're not sure Claude's approach will work — uncertain architecture, unclear abstraction, refactoring a complex system — use an experiment branch.

### When to Use
- Refactoring where multiple approaches are viable
- Feature where the right abstraction isn't clear
- Trying an AI-suggested approach when you have doubts

### Workflow

```bash
# Start from your feature branch (NOT main)
git checkout feat/notification-system

# Create experiment branch
git checkout -b exp/notifications-websocket

# Let Claude implement the approach fully
# Test it — does it actually work?

# If YES: merge back
git checkout feat/notification-system
git merge exp/notifications-websocket

# If NO: delete it. Zero cost.
git checkout feat/notification-system
git branch -D exp/notifications-websocket
# Start again with a different approach.
```

**The psychological value:** you can let Claude try something ambitious without polluting your feature branch. The experiment is isolated by design.

---

## Checkpoint Commits — During Long Sessions

Long AI sessions (30+ minutes, 10+ files changed) should NOT wait until the end to commit. Stage and commit at natural checkpoints.

### Commit When
- A logical unit of work is complete (component built, API route working, migration done)
- TypeScript passes at this point, even if more work remains
- You've reviewed the changes and they're correct
- Before starting a significantly different part of the task

### Don't Commit When
- Files are half-changed (migration applied, but code using it not updated yet)
- TypeScript is failing
- You haven't reviewed the diff

### Pattern

```bash
# After Claude builds the UserStats component:
git diff --staged          # review
tsc --noEmit               # verify TypeScript
git add components/dashboard/StatsCard.tsx
git commit -m "feat(dashboard): add StatsCard component with API integration"

# Continue — Claude builds ActivityFeed
# After review and TypeScript passes:
git add components/dashboard/ActivityFeed.tsx app/api/user/activity/route.ts
git commit -m "feat(dashboard): add ActivityFeed with paginated activity API"
```

Checkpoint commits mean if Claude breaks something in the next step, you have a clean recovery point.

---

## Scope-Creep Check — Before Every Commit

Before any commit, the AI must self-audit:

1. **Summarize what changed and why in 2-3 sentences**
2. **Flag anything in the diff that wasn't explicitly requested**
3. If unrelated changes are found → separate them into a different commit, or revert them

This catches:
- Files changed that weren't supposed to be in scope
- "Clean up" of unrelated code while fixing a bug
- Accidental `console.log` or debug code
- Config files touched while working on a feature

---

## Commit Format (Conventional Commits — Mandatory)

```
<type>(<scope>): <short description>

[optional body — WHAT changed and WHY. Not how (code shows how).]

[optional footer — Closes #123, BREAKING CHANGE: ...]
```

### Types
| Type | When |
|------|------|
| `feat` | New feature visible to users |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code restructure, no behaviour change |
| `test` | Adding or fixing tests |
| `chore` | Build, deps, tooling — no production code |
| `perf` | Performance improvement |
| `security` | Security fix |
| `ci` | CI/CD config changes |

### Rules
- **Scope:** the feature or module name (`auth`, `billing`, `dashboard`)
- **Description:** present tense, lowercase, no period — `add user export endpoint`
- **Body:** explain *why*, not just *what* (the diff already shows what)
- **Footer:** breaking changes, issue refs

### ✅ Good commits
```
feat(auth): add Google OAuth provider
fix(billing): handle Stripe webhook duplicate events
refactor(services): extract email logic into dedicated service
```

### ❌ Bad commits (blocked by commit-msg hook)
```
fix stuff
wip
update
misc
working version
```

### AI-Generated Commit Messages
- Let Claude read the actual `git diff` and generate the message from it — not from memory of the conversation
- Claude is better at this than most humans: it's not attached to the code it just wrote
- Always focus on WHY, not WHAT. If the message could be inferred by reading the diff, it's not adding value.

---

## The Work-Free Review Workflow

This is the ideal AI-native loop. The human reviews, the AI does everything else.

```
1. Human: "Implement user export feature"
2. AI: Creates branch feat/user-export (from main)
3. AI: Writes MDD feature doc
4. AI: Implements with checkpoint commits
5. AI: Runs tests, lint, typecheck
6. AI: Self-reviews diff, flags scope creep
7. AI: Pushes branch, creates PR with description from diff
8. AI: Reports to human: "PR ready for review"
9. Human: Reviews diff, tests in dev environment
10. Human: Approves and merges (or requests changes)
11. AI: Deletes branch, updates docs, updates CHANGELOG
```

**The human never writes code, never writes commit messages, never writes PR descriptions.** The human reviews and decides. That's the work-free approach.

---

## Feature Flags > Long-Lived Branches

For features that take more than 1 day to complete:

```typescript
const ENABLE_NEW_SETTINGS = process.env.FEATURE_NEW_SETTINGS === 'true';

// Code is merged to main but hidden behind the flag
if (ENABLE_NEW_SETTINGS) {
  // new feature code
}
```

- Code merges to `main` daily (behind the flag)
- No branch alive for weeks accumulating merge conflicts
- Flag enables the feature when ready
- Flag is removed (and dead code cleaned up) after the feature is stable

**This is the trunk-based answer to "the feature is too big for one PR."** Use it instead of keeping a branch alive.

---

## Pull Requests

### PR Description (Generated From Diff, Not Memory)

```markdown
## Summary
2-3 bullet points of what changed. Generated from `git diff main...branch`.

## Why
Why this change was needed. Link to spec section or decision.

## How
Key implementation decisions. Any trade-offs.

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual test: [specific steps]
- [ ] Edge case: [specific case]

## Scope Check
- [ ] No files changed outside stated scope
- [ ] No console.log / debug code left
- [ ] No TODO/FIXME introduced
```

### PR Rules
- PRs target `main` (trunk) or `develop` (gitflow features)
- PR scope: one feature, one bug, one refactor. Never mix.
- PR size: max 400 lines changed. Larger = split it.
- No self-merge without review.
- AI code-reviewer subagent can review if human is unavailable for low-risk changes.

---

## Layered Commits — 3-5 Per Feature

**Target 3-5 commits per feature. Not 1 (review-hostile). Not 20 (noise).**

Each commit should represent a coherent layer — reviewable, bisectable, revertable independently.

### Good layering for a full-stack feature:
```
feat: add user schema + migration          ← data layer
feat: add user tRPC router + validation    ← API layer
feat: add UserProfile component            ← UI layer
feat: wire auth guard + loading state      ← integration
test: add user router + E2E tests          ← verification
```

### Bad commits:
```
feat: add user stuff                       ← too broad, review-hostile
fix: oops forgot migration                 ← should have been in first commit
fix: actually fix migration               ← noisy, losing trust
...17 more commits...
```

### Rules:
- Commit after each **logical group** passes typecheck + lint
- Don't push to remote until the user asks — local commits are cheap
- Don't accumulate everything for one giant commit at session end
- Each commit must build and pass tests independently

## Rebase vs Merge

| Situation | Use |
|-----------|-----|
| Your branch is behind main by a few commits | `git rebase main` — linear history, clean |
| Your branch has diverged significantly | `git merge main` — preserves history, avoids conflict complexity |
| Before creating a PR | `git rebase main` first — clean diff for reviewer |
| After PR review feedback | `git rebase -i HEAD~N` to squash fixup commits (only on unshared branches) |
| Multi-agent parallel branches | `git merge` — rebase causes conflicts for other agents |

**Rules:**
- Never rebase shared branches (branches other people have checked out)
- Never rebase after pushing (forces others to reset)
- Squash commits only on your own unshared branch
- After rebasing: `git push --force-with-lease` (never `--force`)

---

## Commit Discipline

### Every commit must be:
- **Complete** — the repo works after this commit. Never commit broken code.
- **Atomic** — one logical change. Not "fix bug and add feature".
- **Tested** — tests pass at this commit. `git bisect` should always find a working state.
- **Reviewed** — self-reviewed before committing. Read your own diff.

### Commit checklist (run mentally before every commit)
- [ ] `pnpm lint` passes?
- [ ] `pnpm typecheck` passes?
- [ ] `pnpm test` passes?
- [ ] No `console.log` left in production code?
- [ ] No commented-out code?
- [ ] No `.env` files staged?
- [ ] No secrets staged? (`git diff --staged | grep -i 'secret\|key\|password\|token'`)
- [ ] Commit message follows conventional format?
- [ ] Only changed files related to the stated purpose?
- [ ] Scope-creep check done? (flag anything unexpected)

---

## Git Operations — Safe vs Dangerous

### Always Safe
```bash
git status
git log --oneline -20
git diff
git diff --staged
git branch -a
git stash list
```

### Safe with Caution
```bash
git stash              # safe, but don't forget to pop
git reset HEAD <file>  # unstage only
git checkout -- <file> # discard unstaged changes (irreversible locally)
```

### DANGEROUS — Ask human first (blocked by hook)
```bash
git reset --hard           # destroys uncommitted work permanently
git push --force            # rewrites remote history, breaks teammates
git push -f                 # same as above
git rebase -i               # rewrites history — only on unshared branches
git clean -fd               # deletes untracked files permanently
git branch -D               # deletes branch permanently
git commit --no-verify      # skips hooks — NEVER
```

**Never run dangerous commands without explicit human approval.** These are blocked by the `block-dangerous-commands.sh` hook.

---

## Branch Lifecycle

| State | Action |
|-------|--------|
| Created | `git checkout -b <type>/<description>` from correct base |
| Active | Committing checkpoint commits, updating MDD doc |
| Ready for review | Push, create PR, update MDD doc status to "review" |
| Merged | Delete local + remote branch: `git branch -d <name> && git push origin --delete <name>` |
| Abandoned (experiment failed) | `git checkout <base> && git branch -D <exp/name>` — no guilt |
| Stale (> 7 days old) | Human decides: merge, rebase, or delete |

**Never leave dead branches.** Merged or abandoned branches are deleted immediately.

---

## Release Tagging

### Semantic Versioning
```
vMAJOR.MINOR.PATCH

v1.0.0  — initial release
v1.0.1  — bug fix
v1.1.0  — new feature, backward compatible
v2.0.0  — breaking change
```

### Tagging Process
```bash
# On main, after merge:
git tag -a v1.2.0 -m "Release v1.2.0: User export feature, billing fixes"
git push origin v1.2.0

# For agent/desktop apps with auto-update:
# Tag triggers the build pipeline → signed binary → update manifest
```

Tags are immutable. Never delete or move a tag that has been pushed.

---

## Gitignore Hygiene

Keep `.gitignore` organized by category:
```gitignore
# Dependencies
node_modules/
.pnpm-store/

# Build outputs
dist/
.output/
.vinxi/

# Environment & secrets
.env
.env.*
!.env.example
*.pem
*.key

# OS
.DS_Store
Thumbs.db

# IDE
.idea/
*.swp

# Testing
coverage/
playwright-report/

# Cloudflare
.wrangler/

# Tauri (agent apps)
src-tauri/target/
```

---

## Emergency Procedures

### Committed a secret?
1. **Revoke the secret immediately** (before anything else)
2. `git rebase -i HEAD~N` to remove the commit (if not pushed)
3. If pushed: BFG Repo-Cleaner to scrub history
4. Force-push (with team notification) — use `--force-with-lease`
5. Rotate ALL secrets that may have been exposed
6. Log the incident in `docs/DECISIONS.md`

### Accidentally pushed to main?
1. Do NOT panic
2. `git revert <commit>` — create a new commit that undoes it (preferred)
3. Only `git push --force` if the push was seconds ago and no one has pulled
4. Notify team immediately

### Merge conflict?
1. `git status` — identify conflicting files
2. Open each conflicted file, resolve manually
3. Test after resolving — conflicts are the most common source of regression
4. `git add <resolved-files>`
5. `git commit` — git generates the merge commit message

### AI created a bad commit (wrong files, broken code)?
1. `git log --oneline -5` — identify the bad commit
2. `git revert <commit>` — safest, creates undo commit
3. If the commit is the most recent and not pushed: `git reset --soft HEAD~1` — undo but keep changes staged
4. Never `git reset --hard` to undo AI work without checking for uncommitted changes first
