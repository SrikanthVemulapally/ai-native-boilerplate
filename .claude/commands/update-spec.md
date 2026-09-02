---
name: update-spec
description: Update docs/SPEC.md with a change — tracked, versioned, and impact-assessed
user-invocable: true
---

Update the spec: $ARGUMENTS

## Workflow

This command is for intentional spec changes. It is NOT for bug fixes.

### Step 1: Current State
Read `docs/SPEC.md` and show the section being changed.

### Step 2: Impact Analysis
- What code currently implements the part of the spec you're changing?
- What tests cover it?
- What MDD feature docs reference it?

List all affected areas before making any change.

### Step 3: Propose the Change
Show exactly what will change in SPEC.md (before → after).
Get explicit user confirmation before writing.

### Step 4: Update SPEC.md
Make the change. Be surgical — only the intended section.

### Step 5: Record the Decision
Add to `docs/DECISIONS.md`:
```
## YYYY-MM-DD — [spec change title]
**Changed:** [what section changed]
**Why:** [reason for the change]
**Impact:** [what needs to be updated in the code]
**Status:** [pending / in-progress / done]
```

### Step 6: Plan Code Updates
List everything that needs to change in the code to align with the updated spec.
Do not make those changes now — create a task or proceed with `/implement` per change.
