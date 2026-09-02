# Multi-Agent Coordination
> Loaded when multiple AI agents work on the same codebase simultaneously.
> Parallel AI development without coordination = merge conflicts, architecture drift, and duplicated work.

---

## The Core Problem

Multiple AI agents working in parallel on the same codebase WILL conflict without explicit coordination:
- Two agents solve the same problem differently → merge conflict
- One agent changes a shared type → breaks the other agent's work
- Two agents add the same feature independently → duplication
- One agent refactors while another is building on the old structure → disaster

**Solution: Explicit ownership, shared state via MDD docs, human arbitration for conflicts.**

---

## Ownership Model

### One Agent, One Feature
- Each agent is assigned exactly ONE feature or task at a time.
- No agent touches files owned by another agent's active feature.
- Ownership is declared in `.mdd/docs/<feature>.md` → `agent:` field.

### File Ownership Declaration
When starting work, declare ownership in the feature doc:

```markdown
# Feature: User Export
**Status:** in-progress
**Agent:** claude-code-session-A  <!-- ← claim ownership -->
**Branch:** feat/user-export
**Started:** YYYY-MM-DD
**Touches:** src/services/export-service.ts, src/routes/api/v1/exports.ts
```

### Conflict Check Before Starting
Before creating or modifying ANY file:
1. `grep -r "agent:" .mdd/docs/` — find all active agent claims.
2. Check if your target file appears in any other agent's "Touches:" list.
3. If YES → do NOT touch that file. Report conflict to human.

---

## Shared Communication Protocol

All inter-agent communication happens through files — not through assumptions.

### Status Updates (mandatory)
Every 30 minutes of work or after each commit, update your feature doc:

```markdown
## Notes (session log — append only)
- YYYY-MM-DD HH:MM — Started auth middleware work. Files: auth/middleware.ts
- YYYY-MM-DD HH:MM — Committed: feat(auth): add session validation middleware
- YYYY-MM-DD HH:MM — Blocked on: shared UserPermissions type needs Agent B to finish first
- YYYY-MM-DD HH:MM — Done: auth middleware complete and tested
```

### Blocking Another Agent
If your work is blocked waiting for another agent:

1. Add to your feature doc: `**Blocked on:** <feature-name>.md — <what you need>`
2. Add to the blocking feature's doc: `**Blocks:** <your-feature>.md — <what they need>`
3. Report to human: "I'm blocked on X. Agent working on Y needs to complete Z first."

---

## Shared Files — High Conflict Risk

These files are touched by multiple features. Extra caution required:

| File | Risk Level | Protocol |
|---|---|---|
| `packages/shared/types.ts` | 🔴 CRITICAL | Only one agent modifies at a time. Declare in DECISIONS.md. |
| `src/db/schema.ts` | 🔴 CRITICAL | Migrations serialize. Never two agents migrating simultaneously. |
| `packages/shared/index.ts` | 🟡 HIGH | Add exports only, never remove. Human reviews all changes. |
| `src/routes/_layout.tsx` | 🟡 HIGH | Declare intent in your feature doc before editing. |
| `wrangler.toml` | 🟡 HIGH | One agent modifies at a time. Merge carefully. |
| `package.json` | 🟡 HIGH | Add deps only. Separate commits. Human merges. |
| `tailwind.config.ts` | 🟠 MEDIUM | Additive changes only. Never rename tokens. |
| `src/db/migrations/` | 🟠 MEDIUM | Never edit existing files. Sequential numbering required. |

---

## Branch Strategy for Multi-Agent Work

```
main
 ├── feat/feature-A  ← Agent A works here exclusively
 ├── feat/feature-B  ← Agent B works here exclusively
 └── feat/feature-C  ← Agent C works here exclusively
```

### Rules
- Each agent works on its own branch. Never on `main` directly.
- Agents never merge each other's branches.
- Human (or designated merge agent) merges feature branches.
- Before merging: `git diff main..feat/feature-A --stat` — see what changed.
- After merging one: `git rebase main` on others to get latest shared code.

### When Branches Diverge
If two branches both modified the same file:
1. Human reviews both diffs.
2. Decides which implementation is canonical.
3. One agent rebases and resolves conflict under human guidance.
4. Never auto-resolve conflicts in AI → AI scenarios.

---

## Shared Type Changes — Special Protocol

When an agent needs to change a type in `packages/shared/`:

1. **Propose the change** in your feature doc under "Notes".
2. **Tag it as SHARED TYPE CHANGE** in your MDD notes.
3. **Human approves** before the change is made.
4. **Change is made in its own commit**: `refactor(shared): update UserPermissions type`
5. **All agents pull** the change before continuing.
6. **All affected agents** update their feature docs to acknowledge the type change.

### Never
- Remove or rename existing shared types without human approval.
- Change a shared type's shape without confirming with all active agents.
- Add a field to a shared type that conflicts with another agent's pending change.

---

## Database Migration Serialization

Database migrations MUST be sequential. Two agents cannot both create migrations.

### Protocol
1. Only one active migration at a time across all agents.
2. Before creating a migration: check `.mdd/docs/` for any "Pending migration" note.
3. If clear: add "Pending migration: <description>" to your feature doc.
4. Create migration. Commit. Mark "Migration complete" in feature doc.
5. Other agents may now create their migrations.

### Checking Active Migrations
```bash
grep -r "Pending migration" .mdd/docs/
```

---

## PR and Merge Order

For multi-agent projects, define merge order to minimize conflicts:

1. **Foundation first**: shared types, DB schema, base components.
2. **Services second**: business logic built on foundation.
3. **Routes third**: API endpoints consuming services.
4. **UI last**: components consuming routes.

Each PR must pass the full test suite — including tests from OTHER agents' features.

---

## Human Arbitration Triggers

The human MUST be consulted when:

| Situation | Why |
|---|---|
| Two agents need the same file at the same time | Needs ownership decision |
| Shared type change affects > 1 active feature | Needs coordination |
| One agent's approach conflicts with another's | Needs architectural decision |
| Two agents both created migrations | Needs serialization |
| A merge conflict cannot be auto-resolved | Needs judgment call |
| An agent is blocked > 2 hours | Needs unblocking decision |

**Default: when in doubt, stop and report to human. Do not guess.**

---

## Context Sharing Between Agents

Agents cannot read each other's context windows. They communicate ONLY via:
- `.mdd/docs/` — feature documentation and status
- `docs/DECISIONS.md` — architectural decisions
- Git commits — what code changed
- `docs/CHANGELOG.md` — what features shipped

**Never assume another agent knows what you know.** Document everything in files.
