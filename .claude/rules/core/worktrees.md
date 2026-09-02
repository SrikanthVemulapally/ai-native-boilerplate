# Git Worktrees — Parallel Agent Isolation
> Loaded when `config.multi_agent.enabled: true` and `config.multi_agent.worktrees: true`.
> Git worktrees give each parallel AI agent its own working directory sharing one `.git` object store.

---

## Why Worktrees

When multiple AI agents work in the same repo simultaneously:
- Two agents editing the same working directory = file overwrites, stale context, git lock contention
- Separate clones = massive disk usage, no shared object store
- **Worktrees** = each agent gets an isolated checkout, shared `.git`, independent branches

```
project/
├── .git/                    ← shared object store (one copy)
├── main/                    ← main worktree (your primary checkout)
├── worktrees/
│   ├── agent-a/             ← Agent A's isolated workspace (branch: feat/auth)
│   ├── agent-b/             ← Agent B's isolated workspace (branch: feat/export)
│   └── agent-c/             ← Agent C's isolated workspace (branch: feat/dashboard)
```

---

## Worktree Lifecycle

### Creating a Worktree

```bash
# Create a worktree for Agent A on a new branch
git worktree add worktrees/agent-a -b feat/auth

# Create a worktree for Agent B on an existing branch
git worktree add worktrees/agent-b feat/export

# Each worktree is its own working directory
cd worktrees/agent-a
# Agent A works here — has full file access, own branch, own staging area
```

### Rules
- **One branch per worktree.** Git enforces this — a branch checked out in one worktree cannot be checked out in another.
- **Never check out `main` in a worktree.** Main belongs to the primary checkout.
- **Worktree path:** always `worktrees/<agent-name>/` — predictable, easy to clean up.
- **Agent naming:** `agent-a`, `agent-b`, etc. or `agent-<feature>` like `agent-auth`.

### Removing a Worktree

```bash
# After Agent A's work is merged:
cd /project/main              # must be outside the worktree being removed
git worktree remove worktrees/agent-a
git branch -d feat/auth       # delete the branch too

# If worktree is stale or stuck:
git worktree prune            # clean up orphaned worktree metadata
```

**Always remove worktrees after the branch is merged.** Dead worktrees waste disk and cause confusion.

---

## Multi-Agent Worktree Protocol

### Starting Parallel Work

```bash
# From main worktree:
git checkout main
git pull

# Create worktrees for each agent's feature
git worktree add worktrees/agent-auth -b feat/auth
git worktree add worktrees/agent-export -b feat/export
git worktree add worktrees/agent-dashboard -b feat/dashboard
```

### Agent Assignment

Each agent is told its worktree path:

```
"You are Agent A. Work in: /project/worktrees/agent-auth/
 Your branch: feat/auth
 Your feature: User authentication with Google OAuth
 Your MDD doc: .mdd/docs/auth.md"
```

### Synchronization

Agents working in separate worktrees share the same `.git` object store. This means:

| Operation | Works Across Worktrees? |
|-----------|------------------------|
| See other branches' commits | ✅ Yes — `git log feat/export` works from any worktree |
| Cherry-pick from another branch | ✅ Yes |
| Merge another branch | ✅ Yes — `git merge feat/export` from your worktree |
| See another worktree's uncommitted changes | ❌ No — uncommitted changes are local to each worktree |
| Create the same branch in two worktrees | ❌ No — Git prevents this by design |

### Getting Latest Main Into Your Worktree

```bash
cd worktrees/agent-auth
git rebase main    # or git merge main
# Your worktree now has the latest main + your feature changes
```

**After any agent merges to main, all other agents should rebase:**
```bash
# In each active worktree:
git rebase main
```

---

## Shared File Protocol Under Worktrees

Even with isolated worktrees, shared files can cause merge conflicts when branches are merged.

### CRITICAL Shared Files (coordinate before touching)

| File | Protocol |
|------|----------|
| `packages/shared/types.ts` | Only one agent modifies at a time. Declare in DECISIONS.md. |
| `src/db/schema.ts` | Migrations serialize. Never two agents migrating simultaneously. |
| `package.json` | Add deps only. Separate commits. Human merges. |
| `wrangler.toml` | One agent at a time. |
| `tailwind.config.ts` | Additive changes only. Never rename tokens. |

### Safe Files (each agent owns their own)

| Pattern | Safe Because |
|---------|-------------|
| `src/features/<feature>/` | Feature-scoped, no overlap |
| `src/routes/api/v1/<feature>/` | Route-scoped |
| `src/components/<feature>/` | Component-scoped |
| `.mdd/docs/<feature>.md` | Doc-scoped |
| `tests/<feature>/` | Test-scoped |

---

## Worktree Setup Script

```bash
#!/usr/bin/env bash
# scripts/setup-worktrees.sh
# Sets up parallel worktrees for multi-agent development

set -e

FEATURES=("$@")
BASE=$(pwd)

if [ ${#FEATURES[@]} -eq 0 ]; then
  echo "Usage: ./setup-worktrees.sh auth export dashboard"
  exit 1
fi

git checkout main
git pull

for feature in "${FEATURES[@]}"; do
  echo "Creating worktree for: $feature"
  git worktree add "worktrees/agent-$feature" -b "feat/$feature"
  echo "  → worktrees/agent-$feature (branch: feat/$feature)"
done

echo ""
echo "✅ Worktrees ready. Assign agents:"
for feature in "${FEATURES[@]}"; do
  echo "  Agent → worktrees/agent-$feature (feat/$feature)"
done
```

---

## Cleanup Script

```bash
#!/usr/bin/env bash
# scripts/cleanup-worktrees.sh
# Removes all worktrees and their branches after merge

set -e

WORKTREES=$(git worktree list --porcelain | grep "^worktree " | sed 's/^worktree //')

for wt in $WORKTREES; do
  BRANCH=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  echo "Removing worktree: $wt (branch: $BRANCH)"
  git worktree remove "$wt" --force 2>/dev/null || true
  if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ]; then
    git branch -D "$BRANCH" 2>/dev/null || true
  fi
done

git worktree prune
echo "✅ All worktrees cleaned up."
```

---

## Port Namespacing (for dev servers)

When multiple agents run dev servers simultaneously, port collisions occur.

| Agent | Port Offset | Dev Server Port |
|-------|-------------|-----------------|
| Main | 0 | 3000 |
| Agent A | +1 | 3001 |
| Agent B | +2 | 3002 |
| Agent C | +3 | 3003 |

Each worktree's dev server should use a unique port:
```bash
# In worktrees/agent-auth:
PORT=3001 pnpm dev

# In worktrees/agent-export:
PORT=3002 pnpm dev
```

For databases (local SQLite/D1):
```bash
# Each worktree gets its own local DB
wrangler d1 create --local agent-auth-db
wrangler d1 create --local agent-export-db
```

---

## When to Use Worktrees vs Not

| Scenario | Use Worktrees? |
|----------|---------------|
| 1 AI agent, sequential work | ❌ No — unnecessary complexity |
| 2+ AI agents, parallel features | ✅ Yes — prevents file conflicts |
| 1 AI agent + human coding simultaneously | ✅ Yes — prevents stomping |
| Quick experiment (single agent) | ❌ No — use exp/ branch instead |
| Long-running parallel development | ✅ Yes — clean isolation |
| CI/CD pipeline | ❌ No — use fresh clone |

---

## Human Responsibilities in Worktree Workflows

1. **Create worktrees** — agents don't create their own worktrees (coordination risk)
2. **Assign agents** — tell each agent its worktree path and feature
3. **Monitor progress** — check `.mdd/docs/` in each worktree for status
4. **Merge in order** — foundation → services → routes → UI
5. **Clean up** — run cleanup script after all branches are merged
6. **Resolve cross-worktree conflicts** — human arbitrates when two branches conflict

**Agents never merge each other's worktrees.** The human merges.
