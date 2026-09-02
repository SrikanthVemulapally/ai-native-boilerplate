---
name: scaffold
description: Scaffold a complete full-stack feature — schema, migration, service, API route, UI component
user-invocable: true
---

Scaffold the feature: $ARGUMENTS

## What Gets Created

1. **Drizzle schema** — table definition with proper types, indexes, timestamps
2. **Migration** — generated via `pnpm db:generate`
3. **Zod validators** — input validation schemas for all API inputs
4. **Service layer** — pure business logic, no HTTP/framework coupling
5. **API route handler** — thin layer: validate input → call service → return response
6. **UI components** — if applicable (form, list, detail view)
7. **Tests** — unit tests for service layer, integration test for API route
8. **MDD feature doc** — `.mdd/docs/<NN>-<feature>.md`

## Rules
- Follow ARCHITECTURE.md layer boundaries exactly.
- Service layer must be importable without any HTTP context.
- All inputs go through Zod validation before reaching the service.
- All database access goes through the service, never from the route handler.
- Use existing patterns from the codebase (check similar features first).

## Before scaffolding, confirm:
1. What is the entity name? (e.g., "Post", "Invoice", "Subscription")
2. What are the required fields?
3. What are the CRUD operations needed? (Create, Read, Update, Delete — which?)
4. Is this user-scoped (every user sees their own data) or org-scoped?
5. Any special business rules? (status transitions, permissions, limits?)

Ask these questions if not provided in $ARGUMENTS.
