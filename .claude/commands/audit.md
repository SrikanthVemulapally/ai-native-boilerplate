# Spec Drift Audit

Check if documentation has drifted from actual codebase reality. Run periodically (monthly) or when suspecting drift.

## Instructions

You are performing a spec drift audit. Compare documentation against the actual codebase.

### Step 1: SPEC.md vs Codebase
- Read `docs/SPEC.md` — list all features documented
- Search the codebase for each feature:
  - Does the route exist?
  - Does the component exist?
  - Does the API endpoint exist?
- Flag any feature in SPEC that has NO code implementation
- Flag any code feature/route that is NOT in SPEC

### Step 2: ARCHITECTURE.md vs Codebase
- Read `docs/ARCHITECTURE.md` — list all systems, services, data flows
- Check:
  - Does each described system exist in the codebase?
  - Is the file structure accurate?
  - Are the data flows still correct?
  - Are external services still used?
- Flag any architecture described that doesn't match reality

### Step 3: .mdd/docs/ vs Codebase
- List all feature docs in `.mdd/docs/`
- For each:
  - Status "done" → does the feature actually work? Spot-check the code.
  - Status "in-progress" → is there actually code for it? Or is it abandoned?
  - Status "draft" → is it still relevant? Or should it be deprecated?

### Step 4: CHANGELOG.md vs Git History
- Read `docs/CHANGELOG.md` last 20 entries
- Check `git log --oneline -50`
- Flag any significant commits not reflected in the changelog

### Step 5: DECISIONS.md Check
- Read `docs/DECISIONS.md`
- Are there any decisions that have been reversed in practice?
- Are there any "TECH DEBT" entries that have been resolved?

### Output Format
```
## Spec Drift Audit Report
**Date:** YYYY-MM-DD

### SPEC Drift
- ✅ Feature X: matches
- ⚠️ Feature Y: in SPEC but no implementation
- ⚠️ Route /api/v1/foo: exists in code but not in SPEC

### Architecture Drift
- ✅ Auth system: matches
- ⚠️ Queue system: described as SQS but actually using Cloudflare Queues

### Feature Doc Drift
- ⚠️ .mdd/docs/payments.md: status "in-progress" but code is complete
- ⚠️ .mdd/docs/legacy-export.md: status "draft", last touched 6 months ago

### Changelog Drift
- ⚠️ Commit abc123 "feat: add export" not in changelog

### Recommendations
1. (list of actions to fix drift, prioritized)
```

Present findings to human. Recommend fixes. Get approval before making changes.
