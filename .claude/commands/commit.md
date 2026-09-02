---
name: commit
description: Stage and commit with auto-generated conventional commit message + quality gate
user-invocable: true
---

Commit the current changes: $ARGUMENTS

## Steps

1. **Run quality gates first:**
   ```
   pnpm typecheck
   pnpm lint
   pnpm test:unit
   ```
   If any fail, report the failures and stop. Do NOT commit broken code.

2. **Review what's staged:**
   ```
   git diff --staged --stat
   git status
   ```

3. **Generate commit message** following conventional commits:
   Format: `type(scope): description`

   Types: `feat` | `fix` | `docs` | `refactor` | `test` | `chore` | `ci` | `perf` | `security`

   Rules:
   - Description in imperative mood: "add X", not "added X"
   - No period at the end
   - Under 72 characters for the first line
   - Body if needed: what changed and why

4. **Stage and commit:**
   ```
   git add -A
   git commit -m "[generated message]"
   ```

5. **Report:** Show the commit hash and message.

If `$ARGUMENTS` contains a hint for the commit type/scope, use it. Otherwise infer from the diff.
