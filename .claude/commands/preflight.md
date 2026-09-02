# Pre-Flight Check

Before starting ANY implementation task, run this command to verify all prerequisites are met.

## Instructions

You are about to start implementation work. Before writing a single line of code, verify ALL of the following:

### Step 1: Context Recovery
Read these files and summarize the current state:
- `docs/SPEC.md` — what does this product do?
- `docs/ARCHITECTURE.md` — how is it built?
- `docs/DECISIONS.md` — read last 5 entries
- `docs/CHANGELOG.md` — read last 10 entries
- `.mdd/docs/` — list all feature docs and their status

### Step 2: Git State
Run:
```
git log --oneline -20
git status
git diff --stat
```

### Step 3: Feature Doc Check
- Does a feature doc exist in `.mdd/docs/` for what you're about to work on?
- If NO → create one using the template at `.mdd/docs/_template.md` first. Do not proceed without it.
- If YES → read it. Is the status "in-progress"? Check the "Notes" section for context from last session.

### Step 4: Spec Alignment
- Does this feature exist in `docs/SPEC.md`?
- If NO → add it to the spec first. Get human approval.
- If YES → read the relevant section. Does the spec match what you're about to build?

### Step 5: Architecture Check
- Does `docs/ARCHITECTURE.md` describe the systems you'll touch?
- Are there any architecture decisions in `docs/DECISIONS.md` that affect this work?
- Will this work CHANGE the architecture? If yes → update `ARCHITECTURE.md` first.

### Step 6: Impact Assessment
List every file that will change:
- Files to modify: (list them)
- Files to create: (list them)
- Files at risk: (list them)

Count the total. If > 5 files → flag to human for scope review.

### Step 7: Risk Assessment
- What could break?
- What has dependencies on this work?
- Is this change reversible?
- If a database migration is needed → is there a rollback plan?

### Output Format
```
## Pre-Flight Check Report

**Feature:** <name>
**Spec section:** <link>
**Feature doc:** .mdd/docs/<name>.md (status: <status>)

### Files to Change
- (list)

### Files to Create
- (list)

### Risks
- (list)

### Migrations Needed
- (list or "none")

### Verdict
✅ CLEARED FOR IMPLEMENTATION
⚠️ NEEDS HUMAN APPROVAL: <reason>
```

If any check fails, do NOT proceed to implementation. Report the failure and what's needed.
