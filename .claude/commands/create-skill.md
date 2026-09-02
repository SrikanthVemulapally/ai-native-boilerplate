# /create-skill [name]

Create a new reusable skill (slash command) for this project. Skills encode team knowledge — patterns, workflows, stack-specific guidance — so Claude loads exactly what it needs, when it needs it.

**Usage:** `/create-skill add-worker` or `/create-skill "handle Stripe webhooks"`

---

## When to Create a Skill

Create a skill when:
- You've explained the same pattern to Claude 2+ times in different sessions
- You have a multi-step workflow Claude should always follow for a specific task
- There's a stack-specific pattern with library-version pitfalls
- You want a repeatable scaffolding step (like `/scaffold` but for a specific pattern)

Do NOT create a skill when:
- It's a one-off task
- The pattern is already in CLAUDE.md
- It's too generic (that belongs in core rules)

---

## Phase 1 — Define

Ask the user (or infer from the name):

1. **What does this skill do?** (1 sentence)
2. **When should Claude use it?** (trigger conditions)
3. **What inputs does it take?** (`$ARGUMENTS` = whatever the user types after the command)
4. **What are the steps?** (numbered, with verification at each step)
5. **What are the success criteria?** (how does Claude know it's done?)

---

## Phase 2 — Check for Overlap

Read existing skills:
```bash
ls .claude/commands/
ls .claude/rules/features/
```

If a similar skill exists: ask if they want to extend it instead of creating a duplicate.

---

## Phase 3 — Create the File

Create `.claude/commands/<name>.md` with this structure:

```markdown
# /<name> [arguments]

[One-sentence description of what this skill does]

**Usage:** `/<name> [example-argument]`

---

## When to Use

[Trigger conditions — when should Claude invoke this?]

---

## Phase 1 — [First Phase Name]

[Detailed steps]

Verification:
```bash
[command to verify this phase succeeded]
```

---

## Phase N — [Last Phase Name]

[Final steps]

Success criteria:
- [ ] [criterion 1]
- [ ] [criterion 2]

---

## Anti-Patterns

- ❌ [common mistake] — [why it's wrong] → [correct approach]
```

---

## Phase 4 — Validate

Present the skill to the user:
"Here's the skill I created. Does this capture what you wanted? Should I adjust the steps or add any anti-patterns?"

---

## Phase 5 — Register

Add to `CLAUDE.md` in the slash commands reference section:
```
| `/<name>` | [description] |
```

Add to `README.md` slash commands table.

Commit: `docs: add /<name> skill`

---

## /refine-skill [name]

Improve an existing skill based on what you've learned:

1. Read the current skill file
2. Ask: "What's not working? What should be added/changed/removed?"
3. Make the targeted edits
4. Update the description if the scope changed
5. Commit: `docs: refine /<name> skill — [what changed]`
