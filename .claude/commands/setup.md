# /setup — Project Initialization

Run this when starting a new project from this boilerplate.

## What This Does

1. Guides you through filling in `boilerplate.config.json`
2. Runs `scripts/generate-claude-md.js` to produce a lean, project-specific `CLAUDE.md`
3. Sets up git hooks
4. Creates the initial `docs/` structure from templates
5. Validates that all required tools and dependencies are available

## Steps

### Step 1 — Read and understand the project

Read these files first:
- `boilerplate.config.json` — understand what needs to be filled in
- `boilerplate.config.schema.json` — understand all available options
- `profiles/` — understand the available profiles

### Step 2 — Interview the user

Ask these questions ONE AT A TIME:

1. "What is your project called?" → set `project.name`
2. "One sentence: what does it do?" → set `project.description`
3. "Which profile fits best?
   - `web-only` — web app only, no desktop agent
   - `agent-web` — desktop agent + web admin (like Pulse)
   - `api-only` — headless backend/API service
   - `full-stack` — everything
   → set `profile`"
4. "Which features do you need? (answer yes/no for each that's unclear from the profile)"
   - payments (Stripe)?
   - auth?
   - SEO?
   - AI features (Anthropic)?
   - email (Resend)?
   - analytics?
   - i18n?

### Step 3 — Write the config

Update `boilerplate.config.json` with the user's answers.

**IMPORTANT:** If profile is `agent-web`, automatically set `features.auto-update: true`.
This is non-negotiable — do not ask.

### Step 4 — Generate CLAUDE.md

```bash
node scripts/generate-claude-md.js
```

Report what was generated:
- How many stack rule files loaded
- How many feature rule files loaded
- Any configuration warnings

### Step 5 — Set up git

```bash
git init
git config core.hooksPath .githooks
chmod +x .githooks/*
chmod +x .claude/hooks/*.sh
```

### Step 6 — Initialize docs

Create the docs structure from templates:
- Copy `docs/SPEC.md` template and fill in project name + description
- Copy `docs/ARCHITECTURE.md` template and fill in stack info from config
- Create `docs/DECISIONS.md` with first entry: "Chose [profile] profile — [reason from user]"
- Create `.mdd/docs/` directory

### Step 7 — Validate

Check:
- [ ] `CLAUDE.md` exists and contains correct project name
- [ ] `docs/SPEC.md` exists with project name filled in
- [ ] `docs/ARCHITECTURE.md` exists
- [ ] `.githooks/pre-commit` is executable
- [ ] `boilerplate.config.json` has no placeholder values (`YOUR_PROJECT_NAME`, etc.)

### Step 8 — Report

Tell the user:
- ✅ What was set up
- 📋 What they should fill in next (SPEC.md sections, env vars)
- 🚀 How to start: `pnpm dev`
- 📖 Where to read: `README.md`, `PRINCIPLES.md`

## Extension Points After Setup

To add a new feature later:
1. Set `features.<feature>: true` in `boilerplate.config.json`
2. Run `node scripts/generate-claude-md.js`
3. CLAUDE.md automatically adds the new feature rules

To add a custom rule:
1. Create `.claude/rules/custom/your-rule.md`
2. Run `node scripts/generate-claude-md.js`
3. Your rule is automatically appended (runs last, wins over core rules)

To switch profiles:
1. Change `profile` in `boilerplate.config.json`
2. Run `node scripts/generate-claude-md.js`
3. CLAUDE.md updates to reflect the new profile's rule set
