---
name: catchup
description: Instantly get full context on a project — use at the start of any session or after a long break
user-invocable: true
---

Generate a comprehensive project status briefing. This command is for:
- Starting a new session after a break
- A new AI agent joining a project mid-development
- After context compaction when prior context was lost
- A human asking "where are we?"

## Instructions

Gather and present a complete project status report by executing these steps:

### Step 1: Identity
Read `boilerplate.config.json` and present:
- Project name and profile
- Stack
- Active features

### Step 2: Spec Summary
Read `docs/SPEC.md` and present:
- What is this product (1-2 sentences)?
- Features marked DONE vs IN PROGRESS vs NOT STARTED
- Open questions still unresolved

### Step 3: Architecture Snapshot
Read `docs/ARCHITECTURE.md` and present:
- Stack overview (1 paragraph)
- Directory structure summary
- Key layer boundaries
- Known constraints

### Step 4: Recent Activity
Run and summarize:
```bash
git log --oneline -20
git status
git diff --stat
```
- What were the last 20 commits about?
- What's currently dirty or staged?

### Step 5: Recent Decisions
Read `docs/DECISIONS.md` — show the last 5 entries:
- What was decided recently?
- Any open decisions still pending?
- Any tech debt items logged?

### Step 6: Recent Changes
Read `docs/CHANGELOG.md` — show the Unreleased section + last release:
- What's shipped?
- What's in progress for next release?

### Step 7: Active Features
List all files in `.mdd/docs/` and for each:
- Feature name
- Status (draft / in-progress / done / deprecated)
- Last synced date
- Blocked on? (if any)

### Step 8: Codebase Health
Run:
```bash
pnpm typecheck 2>&1 | tail -5
pnpm lint 2>&1 | tail -10
```
- Any type errors?
- Any lint errors?

### Step 9: Git State
```bash
git branch -a | head -20
git stash list
```
- What branches exist?
- Any stashed work?

### Step 10: What's Next

Based on everything above, identify and present:
1. **Immediate next task** — what should be worked on right now based on spec, changelog, and feature doc status?
2. **Blockers** — anything that needs resolution before work can proceed?
3. **Risks** — any tech debt, spec drift, or architectural concerns?

---

## Output Format

```
## Project Catch-Up Report
**Generated:** YYYY-MM-DD HH:MM
**Project:** [name]

### 🎯 What This Is
[1-2 sentence product description]

### 📋 Spec Status
- ✅ Done: Feature A, Feature B
- 🔄 In Progress: Feature C (see .mdd/docs/feature-c.md)
- ⏳ Not Started: Feature D, Feature E
- ❓ Open Questions: [list]

### 🏗️ Architecture
[Stack + key decisions summary]

### 📅 Last 20 Commits
[formatted list]

### 🧠 Recent Decisions (last 5)
[formatted list]

### 📦 Unreleased Changes
[from CHANGELOG.md]

### 🔄 Active Feature Docs
| Feature | Status | Blocked? |
|---|---|---|

### 🏥 Codebase Health
- TypeScript: ✅ Clean / ❌ N errors
- Lint: ✅ Clean / ❌ N warnings

### ⚡ What To Do Next
1. **Immediate:** [specific next task]
2. **Blockers:** [list or "none"]
3. **Risks:** [list or "none"]
```

Present this report, then ask: "What would you like to work on?"
