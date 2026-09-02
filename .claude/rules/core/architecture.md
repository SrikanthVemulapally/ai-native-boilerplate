# Architecture Principles — SOLID, Clean Architecture, Layered Design

> **Non-negotiable.** These principles prevent the #1 AI coding failure: uncontrolled coupling that makes changes ripple across the entire codebase.

## SOLID Principles

### S — Single Responsibility
One module = one reason to change. If a file handles auth logic AND email sending AND database queries, split it.

```typescript
// ❌ BAD — does 3 things
class UserService {
  async createUser() { /* DB */ }
  async sendWelcomeEmail() { /* email */ }
  async validatePassword() { /* auth */ }
}

// ✅ GOOD — each has one job
class UserRepository { async create() {} }
class EmailService { async sendWelcome() {} }
class PasswordValidator { validate() {} }
```

### O — Open/Closed
Open for extension, closed for modification. Add behavior through composition or new modules, not by editing existing ones.

```typescript
// ❌ BAD — editing existing switch every time
function getPaymentProvider(name: string) {
  if (name === 'stripe') return new Stripe();
  if (name === 'paddle') return new Paddle();
  // add more here every time...
}

// ✅ GOOD — register new providers, don't modify
const providers = new Map<string, PaymentProvider>();
providers.set('stripe', () => new Stripe());
providers.set('paddle', () => new Paddle());
function getPaymentProvider(name: string) {
  return providers.get(name)?.();
}
```

### L — Liskov Substitution
Subtypes must be substitutable for their base types without breaking behavior. If a `PremiumUser` extends `User`, it must work everywhere a `User` works.

### I — Interface Segregation
Many specific interfaces > one general interface. Don't force modules to depend on methods they don't use.

```typescript
// ❌ BAD — fat interface
interface UserRepository {
  findById(): User;
  create(): User;
  update(): User;
  delete(): void;      // read-only services don't need this
  sendEmail(): void;   // not a repository concern
}

// ✅ GOOD — segregated
interface UserReader { findById(): User; }
interface UserWriter { create(): User; update(): User; delete(): void; }
```

### D — Dependency Inversion
Depend on abstractions, not concretions. High-level modules don't import low-level modules — both depend on interfaces.

```typescript
// ❌ BAD — high-level depends on concrete low-level
class OrderService {
  private stripe = new Stripe();  // hardcoded dependency
}

// ✅ GOOD — both depend on abstraction
interface PaymentGateway { charge(amount: number): Promise<Result>; }
class OrderService {
  constructor(private payments: PaymentGateway) {}  // injected
}
```

## Clean Architecture Layers

```
┌─────────────────────────────────────────────┐
│  Presentation (UI, routes, API handlers)    │  ← Depends inward only
├─────────────────────────────────────────────┤
│  Application (use cases, orchestration)      │  ← Business logic
├─────────────────────────────────────────────┤
│  Domain (entities, business rules, types)    │  ← Pure, no dependencies
├─────────────────────────────────────────────┤
│  Infrastructure (DB, APIs, external services)│  ← Implementation details
└─────────────────────────────────────────────┘
```

### Rules
1. **Dependency direction: inward only.** Infrastructure knows about Domain. Domain does NOT know about Infrastructure.
2. **Domain layer is pure.** No imports from `drizzle`, `stripe`, `react`, `hono`, or any framework. Just types and business logic.
3. **Infrastructure is swappable.** Change D1 for Turso? Only infrastructure layer changes. Domain and application layers are untouched.
4. **Presentation is thin.** Routes extract input, call application layer, format response. No business logic in handlers.

### Monorepo Mapping
```
packages/
  domain/          ← Entities, value objects, business rules (pure TypeScript)
  application/     ← Use cases, DTOs, orchestration
  infrastructure/  ← Drizzle repos, Stripe client, Resend client, R2 client
  presentation/    ← React components, Hono routes, TanStack routes
```

### For single-app projects
```
src/
  domain/          ← types/, rules/, entities/
  application/     ← services/, use-cases/, dto/
  infrastructure/  ← db/, clients/, repositories/
  presentation/    ← routes/, components/, pages/
```

## Law of Demeter
A module should only talk to its immediate friends, not friends of friends.

```typescript
// ❌ BAD — reaching through 3 objects
const zip = user.getAddress().getCity().getZipCode();

// ✅ GOOD — ask for what you need
const zip = user.getZipCode();  // delegate internally
```

## Composition Over Inheritance
Prefer composing small modules over deep inheritance hierarchies. AI agents overuse inheritance — correct this.

```typescript
// ❌ BAD — inheritance tree
class BaseUser { ... }
class PremiumUser extends BaseUser { ... }
class AdminUser extends PremiumUser { ... }  // 3 levels deep

// ✅ GOOD — composition
class User { constructor(private role: Role, private permissions: Permissions) {} }
```

## Dependency Injection
- Inject dependencies via constructor, not module-level singletons
- Use a simple container or manual injection — no heavyweight frameworks unless project size warrants it
- Test doubles (mocks/stubs) become trivial when dependencies are injected
- Never `import` concrete infrastructure in domain/application layers

## Module Boundaries
- **Circular dependencies = build error.** If module A imports B and B imports A, refactor.
- **No barrel files in application/domain layers.** They defeat tree-shaking and hide real dependencies.
- **Public API per module.** Each module exports only what other modules need. Internal implementation is private.
- **One default export per file.** Named exports for utilities, default export for the main thing.

## AI Agent Specific Rules
1. **Never cross layers.** A React component does NOT import from `infrastructure/db`. It calls a use case.
2. **Never put business logic in routes/handlers.** Extract to application layer.
3. **Never import framework types in domain.** No `DrizzleRow`, no `Stripe.Customer` — define your own domain types and map at the boundary.
4. **When adding a feature, identify the layer first.** "Where does this belong?" before writing code.
5. **Refactoring across layers = architectural decision.** Log to DECISIONS.md.
