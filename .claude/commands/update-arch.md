---
name: update-arch
description: Update docs/ARCHITECTURE.md to reflect actual current state of the codebase
user-invocable: true
---

Update the architecture docs: $ARGUMENTS

## Workflow

### Step 1: Scan Current State
Explore the codebase to understand current structure:
- Directory layout and key files
- Data flow (request → route → service → db)
- Authentication/authorization pattern
- External integrations
- Background job / queue structure

### Step 2: Compare with Existing Docs
Read `docs/ARCHITECTURE.md` and identify what's outdated or missing.

### Step 3: Update
Rewrite or update the relevant sections. Preserve history in `docs/DECISIONS.md`
if any architectural decisions are being formalized.

### Step 4: Generate Architecture Diagram
If the project has a `diagrams/` folder, generate a text-based flow diagram:
```
[User] → [TanStack Router] → [Route Handler] → [Service] → [Drizzle ORM] → [D1]
                                              ↘ [Stripe]
                                              ↘ [Queue] → [Worker]
```

### Step 5: Commit
```
docs(architecture): [what changed and why]
```

## ARCHITECTURE.md Sections to Maintain

- **Overview** — what this system does in 2-3 sentences
- **Stack** — every technology with version and purpose
- **Directory Structure** — key dirs and what lives there
- **Data Flow** — request lifecycle, top to bottom
- **Auth Model** — how users authenticate and are authorized
- **Database** — schema overview, migration strategy
- **Background Jobs** — queues, workers, cron jobs
- **External Integrations** — Stripe, email, storage, etc.
- **Agent (if applicable)** — desktop agent architecture, update mechanism
- **Deployment** — environments, CI/CD pipeline
- **Known Constraints** — hard limits, platform restrictions, tech debt
