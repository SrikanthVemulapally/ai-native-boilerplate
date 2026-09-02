# /clean-branches

Prune stale local branches that have been merged and deleted from remote. Safe, non-destructive, shows you what it will delete before deleting.

---

## Phase 1 — Fetch and Find

```bash
# Sync remote state
git fetch --all --prune

# Find local branches whose remote tracking branch is gone
git branch -vv | grep '\[origin/.*: gone\]'
```

Present the list to the user:
```
Branches to delete (merged and removed from remote):
  feat/user-auth          (merged 3 days ago)
  fix/login-redirect      (merged 1 week ago)
  exp/new-dashboard       (never merged — abandoned?)
  
Branches to KEEP (still active on remote):
  feat/payment-flow       (PR open)
  main                    (always kept)
```

**Flag any unmerged branches** with a `⚠️` and ask separately about each one.

---

## Phase 2 — Confirm

Ask: "Delete the [N] merged branches? Unmerged branches will be skipped unless you confirm each."

---

## Phase 3 — Delete

```bash
# Delete merged branches
git branch -d feat/user-auth fix/login-redirect

# If unmerged branch confirmed: force delete
git branch -D exp/new-dashboard
```

---

## Phase 4 — Clean Worktrees

```bash
# List worktrees
git worktree list

# Remove any worktrees whose branch was just deleted
git worktree prune
```

---

## Phase 5 — Report

```
✅ Branch cleanup complete
   Deleted: 3 branches
   Kept: 2 branches (active PRs)
   Worktrees pruned: 1
   
   Your local branch list is now in sync with remote.
```
