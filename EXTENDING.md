# Extending the Boilerplate

> How to customize, extend, and scale this boilerplate for any project type.

---

## 1. Customizing Your Project Config

Everything starts in `boilerplate.config.json`. This single file determines what
Claude knows, what rules are enforced, and what features are expected.

### Key config sections

```jsonc
{
  "minimal": false,          // true = lean mode (4 core rules + 3 design rules only)
  "profile": "full-stack",   // web-only | agent-web | api-only | full-stack | minimal

  "project": {
    "name": "My App",
    "description": "What it does"
  },

  "stack": {
    "frontend": "tanstack-start",  // tanstack-start | nextjs | remix | none
    "backend":  "cloudflare-workers", // cloudflare-workers | node | bun | none
    "database": "cloudflare-d1",    // cloudflare-d1 | postgres | sqlite | mysql
    "orm":      "drizzle"          // drizzle | prisma | knex | kysely
  },

  "features": {
    "designSystem": true,   // UI/UX rules (9-11 files)
    "auth":         true,   // Authentication patterns
    "payments":     true,   // Stripe subscription layer
    "seo":          true,   // SEO best practices
    "auto-update":  false,  // Tauri auto-update (REQUIRED if agent enabled)
    "i18n":         false,  // Internationalization
    "analytics":    false,  // Product analytics
    "ai":           false,  // AI/LLM features
    "email":        false   // Transactional email
  },

  "variants": {
    "agent": {
      "enabled": false,
      "framework": "tauri"  // tauri | electron
    }
  },

  "monorepo": false,        // true = loads monorepo rules

  "discipline": {
    "require_tests": true,
    "require_docs": true,
    "require_types": true,
    "require_lint": true,
    "require_conventional_commits": true,
    "spec_drift_audit": true,
    "multi_agent": false    // true = loads multi-agent coordination rules
  },

  "designSystem": {
    "headingFont": "inter",     // inter | plus-jakarta-sans | space-grotesk | outfit | fraunces
    "bodyFont": "inter",
    "baseColor": "neutral",     // neutral | stone | zinc | mauve | olive | mist | taupe
    "primaryColor": "",         // custom OKLCH color, e.g. "oklch(0.6 0.2 250)"
    "radius": 0.625,
    "darkMode": "system"        // system | light | dark
  },

  "extend": {
    "extra_rule_files": []     // custom rule files in .claude/rules/ to include
  }
}
```

---

## 2. Adding a New Stack

1. **Create the rule file:**
   ```
   .claude/rules/stack/my-stack.md
   ```
   Write the stack-specific rules: project structure, conventions, build commands,
   testing patterns, deployment.

2. **Register in the generator:**
   Open `scripts/generate-claude-md.js` and add to `stackRuleMap`:
   ```js
   'my-frontend-my-backend': '.claude/rules/stack/my-stack.md',
   ```

3. **Create a profile (optional):**
   ```json
   // profiles/my-stack.json
   {
     "stack": { "frontend": "my-frontend", "backend": "my-backend" },
     "features": { ... }
   }
   ```

4. **Run the generator:**
   ```bash
   node scripts/generate-claude-md.js
   ```

---

## 3. Adding a New Feature

1. **Create the rule file:**
   ```
   .claude/rules/features/my-feature.md
   ```
   Document: what the feature is, required packages, architecture pattern,
   implementation rules, testing requirements, security considerations.

2. **Register in the generator:**
   Open `scripts/generate-claude-md.js` and add to `featureRuleMap`:
   ```js
   'my-feature': '.claude/rules/features/my-feature.md',
   ```

3. **Add to config:**
   ```json
   "features": { "my-feature": true }
   ```

4. **Regenerate:**
   ```bash
   node scripts/generate-claude-md.js
   ```

---

## 4. Adding Project-Specific Rules (No Code Changes)

Drop any `.md` file into:
```
.claude/rules/custom/
```

It will be automatically loaded — no generator changes needed. Custom rules
load LAST, so they can override or extend any other rule.

**Example:** `.claude/rules/custom/api-contracts.md`
```markdown
# API Contracts

All API endpoints must be defined in `docs/api/` as OpenAPI specs before
implementation. Claude must read the spec before creating an endpoint.
```

---

## 5. Adding a New Profile

1. Create `profiles/my-profile.json` with the default config for that project type.
2. Set `"profile": "my-profile"` in `boilerplate.config.json`.
3. Run the generator.

---

## 6. Minimal Mode (Low Overhead)

For lightweight projects (prototypes, internal tools, hackathons):

```json
{
  "minimal": true,
  "profile": "minimal"
}
```

This loads only:
- **4 core rules** (principles, security, MDD, discipline)
- **3 design rules** (design-system, components, states)
- **0 feature rules** (unless explicitly enabled)
- **0 stack rules** (unless explicitly set)

Token savings: ~60% reduction vs full mode.

You can still enable individual features even in minimal mode — just set them
to `true` in the `features` object.

---

## 7. Token Overhead Estimation

| Mode | Rules Loaded | Est. CLAUDE.md Size | Est. Tokens |
|---|---|---|---|
| **Minimal** | 7 files | ~8 KB | ~2,000 |
| **Web-only** | ~20 files | ~35 KB | ~9,000 |
| **Agent+Web** | ~24 files | ~42 KB | ~10,500 |
| **Full-stack** | ~28 files | ~50 KB | ~12,500 |

The generator reports exact token estimates after each run.

**To reduce overhead further:**
- Use `"minimal": true`
- Disable features you don't need (`"seo": false`, `"analytics": false`)
- Disable design system if headless API (`"designSystem": false`)

---

## 8. Creating a New Subagent

1. Create `.claude/agents/my-agent.md`:
   ```markdown
   ---
   name: my-agent
   description: Does X when invoked
   tools: Read, Write, Bash
   ---

   You are a specialist in X. Your job is to:
   1. ...
   2. ...
   ```

2. Invoke via slash command or let Claude auto-dispatch based on the task.

---

## 9. Creating a New Slash Command

1. Create `.claude/commands/my-command.md`:
   ```markdown
   # My Command

   Description of what this command does.

   ## Steps

   1. First do this
   2. Then do that
   3. Output: $ARGUMENTS
   ```

2. Use via `/my-command` in Claude Code.

---

## 10. Creating a New Hook

1. Create `.claude/hooks/my-hook.sh`:
   ```bash
   #!/bin/bash
   # Description: What this hook does
   # Fires on: PreToolUse | PostToolUse | SessionStart | Stop | PreCompact | PostCompact

   # Your enforcement logic here
   # Exit 0 = allow, non-zero = block
   ```

2. Register in `.claude/settings.json`:
   ```json
   {
     "hooks": {
       "PostToolUse": [
         { "command": ".claude/hooks/my-hook.sh", "timeout": 5 }
       ]
     }
   }
   ```

3. Make executable: `chmod +x .claude/hooks/my-hook.sh`

---

## 11. Sharing Across Projects

This boilerplate is designed to be forked, customized, and reused.

**For a new project:**
```bash
cp -r ai-native-boilerplate/ my-new-project/
cd my-new-project/
git init
git config core.hooksPath .githooks
chmod +x .githooks/* .claude/hooks/*.sh
node scripts/generate-claude-md.js
```

**For a team:**
1. Fork this repo
2. Add your team's custom rules in `.claude/rules/custom/`
3. Create team-specific profiles in `profiles/`
4. Share the fork as your org's boilerplate

---

## 12. Compatibility with Other AI Tools

This boilerplate works with any AI coding tool that reads project config files:

| Tool | Config File | Compatibility |
|---|---|---|
| Claude Code | `CLAUDE.md` | ✅ Full (native) |
| Cursor | `.cursorrules` | ✅ Symlink or copy CLAUDE.md |
| Windsurf | `.windsurfrules` | ✅ Symlink or copy CLAUDE.md |
| GitHub Copilot | `.github/copilot-instructions.md` | ✅ Copy relevant sections |
| Cline | `.clinerules` | ✅ Symlink or copy CLAUDE.md |
| Aider | `CONVENTIONS.md` | ✅ Copy relevant sections |

The generator produces a single `CLAUDE.md` — for other tools, simply copy
or symlink it to their expected config file name.
