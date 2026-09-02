---
name: push
description: Commit, push, and create a PR with grouped changes and test plan
user-invocable: true
---

Push current work and create a PR: $ARGUMENTS

## Steps

1. **Quality Gate** — run all checks, stop if any fail:
   ```
   pnpm typecheck && pnpm lint && pnpm test:unit && pnpm build
   ```

2. **Stage and commit** (if uncommitted changes exist):
   - Generate conventional commit message from the diff
   - Run `git add -A && git commit -m "..."`

3. **Push** the current branch:
   ```
   git push -u origin $(git rev-parse --abbrev-ref HEAD)
   ```

4. **Analyze all commits on this branch** vs main:
   ```
   git log main..HEAD --oneline
   ```

5. **Create PR** using `gh pr create` with:
   - **Title:** `type(scope): summary of all changes`
   - **Body:**
     ```
     ## What changed
     [Group changes by area: API, UI, DB, config, etc.]

     ## Why
     [Link to spec section or decision]

     ## How to test
     [Step-by-step test plan for the reviewer]

     ## Checklist
     - [ ] Tests pass
     - [ ] Types pass
     - [ ] No secrets committed
     - [ ] docs/CHANGELOG.md updated
     - [ ] MDD doc updated (if feature change)
     ```

6. **Report the PR URL.**
