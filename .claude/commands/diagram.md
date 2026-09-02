# /diagram [type]

Generate diagrams from **actual code** — not from memory or assumptions. Reads the real codebase and produces accurate ASCII/Mermaid diagrams.

**Types:** `architecture` | `api` | `database` | `dataflow` | `all`

If no type specified, ask which one.

---

## Phase 1 — Read First, Draw Later

**MANDATORY:** Read the actual source files before drawing anything.

### architecture
Read:
- `docs/ARCHITECTURE.md` (existing diagram to update, not replace blindly)
- `wrangler.toml`, `turbo.json`, `pnpm-workspace.yaml` (package structure)
- `apps/*/package.json`, `workers/*/package.json` (what each package does)
- Top-level `src/` or `app/` structure

Output: ASCII block diagram showing all packages, their roles, and the connections between them (HTTP, RPC, queue, DB).

### api
Read:
- All route files (`routes/`, `api/`, `server/`)
- tRPC router files if present
- OpenAPI spec if present (`docs/API.md`, `openapi.yaml`)

Output: Mermaid `graph LR` or table of every endpoint grouped by domain — method, path, auth required, brief description.

### database
Read:
- `schema.ts` or `schema/` directory
- Migration files (latest 5)
- `docs/ARCHITECTURE.md` data map section

Output: Mermaid `erDiagram` — all tables, columns with types, primary/foreign keys, relationships.

### dataflow
Read:
- Ingest/processor pipeline files
- Queue configurations
- Worker files

Output: ASCII sequence diagram showing data moving through the system (client → ingest → queue → processor → DB → rollup).

### all
Run all four types in sequence.

---

## Phase 2 — Generate

Rules for the output:
- **Accurate over pretty** — if you're not sure about a connection, mark it `(?)` rather than guessing
- **No fabrication** — only diagram what you actually read in the code
- **Delta, not replacement** — if an existing diagram exists in ARCHITECTURE.md, show what changed vs what was there before
- **Mermaid preferred** for ER and sequence diagrams (renders on GitHub)
- **ASCII preferred** for architecture blocks (readable everywhere)

---

## Phase 3 — Update ARCHITECTURE.md

After generating:
1. Present the diagram to the user
2. Ask: "Update `docs/ARCHITECTURE.md` with this? (yes/no/edit first)"
3. If yes: update the relevant section only — don't rewrite the whole file
4. Commit: `docs: update [type] diagram from /diagram command`
