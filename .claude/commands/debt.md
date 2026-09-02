# Tech Debt Review

Review and prioritize technical debt. Run during sprint planning or when debt feels overwhelming.

## Instructions

You are performing a technical debt review.

### Step 1: Gather Debt
- Read `docs/DECISIONS.md` — find all entries prefixed with "TECH DEBT:"
- Search codebase for `TODO`, `FIXME`, `HACK`, `WORKAROUND` comments
- Check for:
  - Files > 500 lines (god files)
  - Functions > 100 lines
  - Components > 300 lines
  - Any `any` types in the codebase
  - Any disabled ESLint rules
  - Any skipped tests
  - Any `@ts-ignore` or `@ts-expect-error` without explanation

### Step 2: Assess Each Debt Item
For each item, assess:
- **Impact:** How much does this hurt? (low/medium/high)
- **Effort:** How long to fix? (hours/days/weeks)
- **Risk:** What happens if we don't fix it? (what breaks, what slows down)
- **Dependencies:** Is anything blocked by this? Is this blocked by anything?

### Step 3: Prioritize
Sort by: Impact × Risk ÷ Effort (highest first)

### Step 4: Recommend
- What should be fixed this sprint? (20% capacity)
- What should be fixed next sprint?
- What can be accepted as permanent? (document why)

### Output Format
```
## Tech Debt Review
**Date:** YYYY-MM-DD

### High Priority (fix this sprint)
| Item | Impact | Effort | Location |
|------|--------|--------|----------|
| ... | high | 4h | src/services/user-service.ts:234 |

### Medium Priority (next sprint)
| Item | Impact | Effort | Location |
|------|--------|--------|----------|
| ... | medium | 1d | src/components/Dashboard.tsx |

### Low Priority (accept or defer)
| Item | Impact | Effort | Location |
|------|--------|--------|----------|
| ... | low | 2h | src/utils/legacy.ts |

### Code Smells Found
- (list of structural issues)

### Recommendations
1. (prioritized action list)

### Accepted Debt
- (debt we're choosing to keep, with reason)
```

Present to human. Get approval on what to fix this sprint.
