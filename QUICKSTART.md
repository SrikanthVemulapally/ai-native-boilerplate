# Quickstart — First Session Guide

> **For humans and AI agents starting a new project with this boilerplate.**
> Read this once. Follow the steps. By the end, your project is set up and discipline is enforced.

---

## For Humans: Before You Open Claude Code

**Step 1: Copy the boilerplate**
```bash
cp -r ai-native-boilerplate/ ~/my-new-project/
cd ~/my-new-project/
```

**Step 2: Initialize git**
```bash
git init
git config core.hooksPath .githooks
chmod +x .githooks/* .claude/hooks/*.sh
```

**Step 3: Configure your project**
Open `boilerplate.config.json` and fill in:
```json
{
  "project": {
    "name": "YOUR_APP_NAME",
    "description": "What your app does in one line"
  },
  "profile": "web-only",          // web-only | agent-web | api-only | full-stack
  "features": {
    "payments": true,             // Enable what you actually need
    "auth": true,
    "seo": true
  }
}
```

**Step 4: Generate your lean CLAUDE.md**
```bash
node scripts/generate-claude-md.js
```

This creates a CLAUDE.md tailored to your exact feature set — no wasted tokens.

**Step 5: Open Claude Code**
```bash
cd ~/my-new-project/
claude  # opens Claude Code in this directory
```

**Step 6: Say this to Claude:**
> `/setup`

Claude will guide you through the rest interactively.

---

## For AI Agents: First Session Protocol

You have been opened in a new project that uses the AI-Native Boilerplate.

**Execute this exact sequence before doing anything else:**

### 1. Read the law
```
Read CLAUDE.md completely. This is non-negotiable. Every rule applies to you.
```

### 2. Check what exists
```
Read: boilerplate.config.json → understand what features are enabled
Read: docs/SPEC.md → understand what has been specified (may be empty)
Read: docs/ARCHITECTURE.md → understand what has been decided
Read: .mdd/docs/ → list all feature docs (may be empty)
```

### 3. Run /catchup
```
/catchup
```
This gives you a full picture of where the project stands.

### 4. Establish project identity
If `docs/SPEC.md` is still a template (Version: 0.1, Status: Draft), you MUST fill it in before writing any code. Ask the human:

> "Before I write any code, I need to understand what we're building. Can you describe:
> 1. What problem does this solve?
> 2. Who uses it?
> 3. What are the 3-5 must-have features for v1?
> 4. What's the pricing model?"

Then fill in `docs/SPEC.md` with their answers and get explicit approval.

### 5. Only then: start building
```
/implement [first feature from spec]
```

---

## The Discipline Rules You Must Never Break

| Rule | Why |
|---|---|
| Read SPEC.md before every session | You cannot build what you don't understand |
| Every feature gets a .mdd/docs/ file | Features without docs drift from spec |
| No code without a failing test first | Untested code is untested behavior |
| Commit after every logical unit | Giant commits are unrecoverable |
| Update ARCHITECTURE.md when structure changes | Stale arch docs = confusion for next session |
| Log decisions in DECISIONS.md | Future sessions need to know why, not just what |
| Run quality gates before stopping | Half-finished features are worse than unstarted ones |

---

## Common First-Session Mistakes

❌ **Jumping straight to code**
✅ Fill in SPEC.md first. Code without spec = guaranteed rework.

❌ **Implementing everything at once**
✅ One feature. Spec → doc → tests → implement → commit. Repeat.

❌ **Skipping the MDD feature doc**
✅ Create `.mdd/docs/01-[feature].md` before writing a single line of implementation.

❌ **Not committing between features**
✅ Commit after each feature. Each commit should be `git revert`-able without affecting others.

❌ **Ignoring TypeScript errors**
✅ `pnpm typecheck` must pass before any commit. Type errors compound.

❌ **Modifying migrations**
✅ Migrations are immutable once committed. Write a new one.

---

## Useful Commands (First Session)

```bash
# Generate CLAUDE.md from config
node scripts/generate-claude-md.js

# Start dev server
pnpm dev

# Run all quality gates
pnpm typecheck && pnpm lint && pnpm test:unit

# Check DB schema
pnpm db:studio

# Generate a migration
pnpm db:generate

# Preview emails
pnpm email:preview
```

---

## Claude Code Slash Commands Available

| Command | When to Use |
|---|---|
| `/setup` | First time setup — interactive project config |
| `/catchup` | Start of every session — get current state |
| `/preflight` | Before implementing anything — verify spec + arch |
| `/implement [feature]` | Implement a spec'd feature end-to-end |
| `/scaffold [entity]` | Generate schema + service + API + UI for an entity |
| `/review [file/PR]` | Code review against spec + quality standards |
| `/migrate` | Safely create and apply DB migrations |
| `/commit` | Stage + commit with auto-generated message |
| `/push` | Push to remote with quality gates |
| `/debug [issue]` | Systematic debugging workflow |
| `/security-check` | Full security audit |
| `/performance` | Core Web Vitals + bundle + API latency audit |
| `/seo-audit` | SEO completeness check |
| `/audit` | Spec drift detection |
| `/debt` | Tech debt review and prioritization |
| `/release` | Tag + publish a release |

---

*Once you've done this once, it takes < 10 minutes to get a new project started with full discipline enforced.*
