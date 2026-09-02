# Contributing to the Boilerplate

This document is for evolving the boilerplate itself — adding new patterns, improving hooks, updating commands.

## Principles for Changing the Boilerplate

1. **Every rule must earn its place.** If a rule exists, it must prevent a real problem that has occurred.
2. **Simpler is better.** A 10-line hook that people read and understand beats a 50-line hook that people ignore.
3. **Test your hooks.** Before adding a new hook, verify it does what it claims. False positives kill adoption.
4. **Document the "why".** Future maintainers need to know why the rule exists, not just what it does.

## What to Add

### New hooks — when you encounter a recurring problem
Pattern: "Claude keeps doing X and it breaks things" → add a hook to prevent X.

### New slash commands — when you write the same prompt 3+ times
Pattern: "I always start with this 10-step workflow" → turn it into a command.

### New rules (`.claude/rules/*.md`) — when a new technology is added
Each rule file is domain-specific. Add one when you add a major new dependency with its own conventions.

### New MDD feature doc templates — when a new feature pattern emerges
Template for auth, payments, background jobs, file uploads, etc.

## What NOT to Add

- Rules that are already obvious from the language/framework
- Hooks that are too strict and block legitimate work
- Commands that are rarely used (they add noise)
- Duplicate coverage of existing rules

## Process

1. Identify a recurring problem in real projects.
2. Design the minimal solution (hook / command / rule).
3. Test it manually on a real project.
4. Update `README.md` if the file map changes.
5. Record the addition in this file under "What's new".

## What's New

| Date | Change | Why |
|---|---|---|
| YYYY-MM-DD | Initial boilerplate | Base for all new projects |

---

*This boilerplate is a living document. If something isn't working, fix it. If something is missing, add it. The goal is not a perfect system — it's a system that gets better with every project.*
