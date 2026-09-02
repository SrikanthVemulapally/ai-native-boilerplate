# Monorepo Rules — pnpm Workspaces
> Loaded for all projects using the monorepo structure.
> Monorepos without discipline are worse than single repos.

---

## Workspace Structure

```
pnpm-workspace.yaml defines:
  apps/*       → deployable applications
  workers/*    → Cloudflare Workers (standalone deployments)
  packages/*   → shared internal libraries (not deployed standalone)
```

### Package Roles

| Package | Role | Can import from |
|---------|------|-----------------|
| `apps/web` | TanStack Start app | `packages/*` |
| `apps/agent` | Tauri desktop app | `packages/*` |
| `workers/ingest` | Cloudflare Worker | `packages/shared`, `packages/db` |
| `workers/processor` | Cloudflare Worker | `packages/shared`, `packages/db` |
| `packages/shared` | Shared types + utils | nothing internal |
| `packages/db` | Drizzle schema + client | `packages/shared` |
| `packages/config-resolver` | Config logic | `packages/shared` |

**The dependency graph must be a DAG. No circular dependencies. Ever.**

---

## Import Rules

### Cross-Package Imports
```typescript
// ✅ CORRECT — use workspace alias
import { UserSchema } from '@workspace/shared';
import { db } from '@workspace/db';

// ❌ WRONG — relative path across packages
import { UserSchema } from '../../packages/shared/src/schemas/user';
```

### Package.json Workspace Linking
```json
{
  "dependencies": {
    "@workspace/shared": "workspace:*",
    "@workspace/db": "workspace:*"
  }
}
```

Always `workspace:*` — never pin internal packages to a version number.

### What Goes in Each Package

**`packages/shared`** (zero dependencies, pure TypeScript):
- Zod schemas that are shared across apps and workers
- TypeScript types and interfaces
- Pure utility functions (no Node.js APIs, no browser APIs)
- Constants (error codes, event types, limits)

**`packages/db`** (depends on shared):
- Drizzle schema definition
- Drizzle client factory
- Migration utilities
- Query helper functions

**`packages/config-resolver`** (depends on shared):
- Per-org config resolution logic
- Config validation schemas
- Default config factories

---

## Adding a New Package

```bash
# 1. Create the package directory
mkdir -p packages/my-package/src

# 2. Create package.json
cat > packages/my-package/package.json << EOF
{
  "name": "@workspace/my-package",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts"
  }
}
EOF

# 3. Create src/index.ts
touch packages/my-package/src/index.ts

# 4. Add tsconfig.json
# 5. Document the package in docs/ARCHITECTURE.md
# 6. Log the decision in docs/DECISIONS.md
```

**Before creating a new package**: ask "does this belong in `packages/shared`?" Packages multiply — justify new ones in `DECISIONS.md`.

---

## Build Order

```bash
# Packages must build before apps that consume them
pnpm --filter @workspace/shared build
pnpm --filter @workspace/db build
pnpm --filter @workspace/config-resolver build
pnpm --filter apps/web build
```

In CI, use `pnpm --filter ... --filter ...` with proper dependency ordering, or use `turbo` for build caching.

---

## pnpm Discipline

### The lockfile is law
- `pnpm-lock.yaml` is committed and never manually edited.
- CI always runs `pnpm install --frozen-lockfile`.
- Never run `pnpm install` without `--frozen-lockfile` in CI.
- Never run `pnpm install --no-lockfile` — this defeats the purpose.

### Adding Dependencies
```bash
# Add to a specific app/package (always target correctly)
pnpm --filter apps/web add react-query
pnpm --filter @workspace/shared add zod

# Add dev dependency
pnpm --filter apps/web add -D vitest

# Add to root (tooling only — eslint, prettier, turbo)
pnpm add -D -w eslint
```

**Never add a dep to the workspace root unless it's pure build tooling.**

### Removing Dependencies
```bash
pnpm --filter apps/web remove old-library
# Then: pnpm install to update lockfile
# Then: check pnpm why old-library — confirm it's gone from the whole tree
```

### Checking for Duplicate Dependencies
```bash
pnpm dedupe
```

Run this quarterly. Duplicate deps bloat the lockfile and can cause version conflicts.

---

## TypeScript Path Aliases

Configure consistent path aliases in each `tsconfig.json`:

```json
{
  "compilerOptions": {
    "paths": {
      "@workspace/shared": ["../../packages/shared/src/index.ts"],
      "@workspace/db": ["../../packages/db/src/index.ts"],
      "@/*": ["./src/*"]
    }
  }
}
```

In Vite/TanStack config:
```typescript
resolve: {
  alias: {
    '@': path.resolve(__dirname, './src'),
    '@workspace/shared': path.resolve(__dirname, '../../packages/shared/src'),
  }
}
```

---

## Version Management

All packages are `"version": "0.0.0"` with `"private": true`. There is no versioning of internal packages — the monorepo itself is versioned via git tags.

**Never publish internal packages to npm.** They are private to this monorepo.

---

## Scripts Convention

Each workspace package must define these scripts in `package.json`:

```json
{
  "scripts": {
    "dev": "...",          // run in development mode
    "build": "...",        // production build
    "typecheck": "tsc --noEmit",  // type check only
    "lint": "eslint src/", // lint
    "test": "vitest run",  // run tests once
    "test:watch": "vitest" // watch mode
  }
}
```

Root `package.json` orchestrates:
```json
{
  "scripts": {
    "dev": "pnpm -r --parallel dev",
    "build": "pnpm -r build",
    "typecheck": "pnpm -r typecheck",
    "lint": "pnpm -r lint",
    "test": "pnpm -r test"
  }
}
```

---

## Common Mistakes

| Mistake | Impact | Fix |
|---------|--------|-----|
| Relative imports across package boundaries | Breaks tree-shaking, creates implicit deps | Use `@workspace/` aliases |
| Adding app-specific code to `packages/shared` | Bloats shared bundle | Move to app-specific location |
| Circular package dependency | Build failure, impossible to resolve | Redesign the dependency graph |
| Running `pnpm install` without `--filter` and adding to wrong package | Wrong package gets the dep | Always target with `--filter` |
| Mutating shared types without updating all consumers | Type errors across packages | Update all consumers in same PR |
