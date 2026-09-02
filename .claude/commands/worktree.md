# /worktree [task-name]

Create an isolated branch + git worktree for a task. **ALWAYS use this instead of `git checkout` for feature work.** Never work directly on main.

**Usage:** `/worktree add-user-auth`

---

## Why Worktrees

- Isolated working directory — no branch switching, no stash juggling
- Parallel agents can work simultaneously without conflict
- Main branch stays clean and always runnable
- Easy to abandon: delete worktree, delete branch, zero impact

---

## Phase 1 — Check Current State

```bash
git branch --show-current    # where are we?
git worktree list            # what worktrees exist?
git status                   # any uncommitted changes?
```

If uncommitted changes exist: commit or stash them first. Never create a worktree with dirty state.

---

## Phase 2 — Determine Branch Type

Check the task type:

| Task Type | Branch Prefix |
|-----------|--------------|
| New feature | `feat/<name>` |
| Bug fix | `fix/<name>` |
| Experiment (uncertain approach) | `exp/<name>` |
| Refactor | `refactor/<name>` |
| Docs | `docs/<name>` |
| Chore / tooling | `chore/<name>` |

Name should be kebab-case, ≤30 chars. Ask user to confirm if unclear.

---

## Phase 3 — Create the Worktree

```bash
# Create branch from current main
git fetch origin main
git branch feat/<task-name> origin/main

# Create worktree at standard location
git worktree add ../$(basename $(pwd))-<task-name> feat/<task-name>

# Enter the worktree
cd ../$(basename $(pwd))-<task-name>

# Install dependencies
pnpm install
```

Set port offset if running dev server (to avoid conflicts):
- Main: 3000 / Worktree 1: 3010 / Worktree 2: 3020 / etc.

Report to user:
```
✅ Worktree created
   Branch: feat/<task-name>
   Path: ../<project>-<task-name>/
   Dev port: 3010 (set PORT=3010 before pnpm dev)
   
Now working in the worktree. Main branch is unaffected.
```

---

## Phase 4 — Work

Do the work. Commit in logical blocks (see Git discipline rules):
- Checkpoint commits every 30 min or major milestone
- Conventional commit format: `feat: <what>`
- Run tests before each commit

---

## Phase 5 — Merge (when task complete)

```bash
# From worktree
pnpm test          # all tests pass
pnpm typecheck     # types clean

# Push branch
git push origin feat/<task-name>

# Create PR (GitHub CLI)
gh pr create --title "feat: <task-name>" --body "Closes #<issue>"
```

After PR merged:
```bash
# Back in main repo
git worktree remove ../<project>-<task-name>
git branch -d feat/<task-name>
git fetch --prune
```

---

## /worktree list

Show all active worktrees with their branches and status:
```bash
git worktree list
```

## /worktree clean

Remove a completed worktree:
```bash
git worktree remove ../<project>-<task-name>
git branch -d feat/<task-name>
```
