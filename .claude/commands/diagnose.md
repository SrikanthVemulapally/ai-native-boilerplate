---
name: diagnose
description: Investigate a problem and compare solutions — without changing any code
user-invocable: true
---

Diagnose: $ARGUMENTS

## Purpose

Understand the problem completely BEFORE writing any fix. This command produces a diagnosis document only. No code changes. No fixes. Pure investigation.

## Workflow

### Phase 1: Reproduce & Describe
- What is the exact symptom? (error message, wrong output, unexpected behavior)
- What are the exact steps to reproduce?
- Is it deterministic or intermittent?
- When did it start? (`git log --oneline -20` — find the change)
- What environment? (local, staging, production, which browser/OS)

### Phase 2: Trace the Data Flow
Follow the data from input to output:
- Where does the input enter the system?
- What transformations happen at each step?
- Where does it diverge from expected behavior?
- What is the LAST correct state before the bug?

Write findings to `.mdd/diagnostics/<issue-slug>.md` incrementally — this survives context compaction.

### Phase 3: Root Cause Analysis
State the root cause precisely:
- **Root cause:** [one specific sentence — not "there's a bug," but "the timezone is not converted before comparison at line 47 of time.service.ts"]
- **Why it exists:** [missing validation, wrong assumption, race condition, etc.]
- **Why it wasn't caught:** [no test for this case, test mocks the wrong layer, etc.]
- **Blast radius:** [what other features/callsites might be affected?]

### Phase 4: Solution Options
List 2-3 possible fixes. For each:
```markdown
### Option A: [short name]
- **What:** [what change]
- **Where:** [which files]
- **Risk:** [what could break]
- **Effort:** [S/M/L]
- **Tests needed:** [what new tests]
- **Pros:** ...
- **Cons:** ...
```

### Phase 5: Recommendation
```markdown
## Recommended: Option [X]
**Why:** [1-2 sentences]
**Confidence:** [High/Medium/Low]
**Next step:** Run `/debug [same issue]` to implement the fix, or `/implement [fix description]`
```

## Output
Save full diagnosis to `.mdd/diagnostics/<issue-slug>.md`.
Print the summary (root cause + recommendation) to chat.

## Rules
- **No code changes.** Not even "small fixes." Not even "while I'm here."
- **No speculation.** Every claim must cite a file, line, or test result.
- **Read the actual code.** Don't guess from memory. Read the file.
- **Check git blame.** When was this line introduced? Why?
- **Test the reproduction.** Actually run the reproduction steps.
