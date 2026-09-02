#!/usr/bin/env node
/**
 * generate-claude-md.js
 *
 * Reads boilerplate.config.json and generates a lean, project-specific CLAUDE.md
 * by CONCATENATING only the relevant rule file contents into a single file.
 *
 * This is token-optimal: Claude Code loads CLAUDE.md as one file, not 25 @-imports
 * that each require a separate file read. Saves ~40% tokens vs @import approach.
 *
 * Run: node scripts/generate-claude-md.js
 * Or:  pnpm setup (calls this as part of setup)
 *
 * Re-run whenever boilerplate.config.json changes.
 */

import { readFileSync, writeFileSync, existsSync, readdirSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const ROOT = resolve(__dirname, '..')

// ─── Load & validate config ───────────────────────────────────────────────────

const configPath = resolve(ROOT, 'boilerplate.config.json')
if (!existsSync(configPath)) {
  console.error('❌ boilerplate.config.json not found. Run this from the project root.')
  process.exit(1)
}

const config = JSON.parse(readFileSync(configPath, 'utf-8'))

// Load profile defaults if a profile is set
let profileDefaults = {}
const profilePath = resolve(ROOT, `profiles/${config.profile}.json`)
if (config.profile && existsSync(profilePath)) {
  profileDefaults = JSON.parse(readFileSync(profilePath, 'utf-8'))
}

// Merge: config overrides profile
const merged = deepMerge(profileDefaults, config)

// Determine minimal mode
const minimalMode = merged.minimal === true || config.minimal === true

// ─── Helper: Read file content ────────────────────────────────────────────────

function readRule(filePath) {
  const abs = resolve(ROOT, filePath)
  if (!existsSync(abs)) return null
  return readFileSync(abs, 'utf-8')
}

function sectionBlock(files, label, icon) {
  const contents = []
  for (const f of files) {
    const content = readRule(f)
    if (content) {
      // Strip leading H1 if it exists (we add our own section header)
      const stripped = content.replace(/^#\s+.+\n+/, '')
      contents.push(`<!-- ${f} -->\n${stripped.trim()}`)
    }
  }
  if (!contents.length) return ''
  return `\n---\n\n## ${icon} ${label}\n\n${contents.join('\n\n---\n\n')}\n`
}

// ─── Determine which rule files to load ───────────────────────────────────────

// Core rules — ALWAYS loaded (non-negotiable)
// In minimal mode, load only the essentials
const coreRulesAll = [
  '.claude/rules/core/principles.md',
  '.claude/rules/core/architecture.md',
  '.claude/rules/core/twelve-factor.md',
  '.claude/rules/core/security-headers.md',
  '.claude/rules/core/security.md',
  '.claude/rules/core/git.md',
  '.claude/rules/core/mdd.md',
  '.claude/rules/core/discipline.md',
  '.claude/rules/core/conventions.md',
  '.claude/rules/core/nfr.md',
  '.claude/rules/core/testing.md',
  '.claude/rules/core/deployment.md',
]

const coreRulesMinimal = [
  '.claude/rules/core/principles.md',
  '.claude/rules/core/security.md',
  '.claude/rules/core/mdd.md',
  '.claude/rules/core/discipline.md',
]

const coreRules = minimalMode ? coreRulesMinimal : coreRulesAll

// Stack rules
const stackKey = `${merged.stack.frontend}-${merged.stack.backend}`
  .replace('tanstack-start', 'tanstack')
  .replace('cloudflare-workers', 'cloudflare')

const stackRuleMap = {
  'tanstack-cloudflare': '.claude/rules/stack/tanstack-cloudflare.md',
  'nextjs-cloudflare':   '.claude/rules/stack/nextjs-cloudflare.md',
  'none-cloudflare':     '.claude/rules/stack/cloudflare-only.md',
}

const stackRules = []
if (stackRuleMap[stackKey] && existsSync(resolve(ROOT, stackRuleMap[stackKey]))) {
  stackRules.push(stackRuleMap[stackKey])
}

// Agent variant — load BOTH tauri files: cloudflare integration + desktop rules
const isAgent = merged.variants?.agent?.enabled
if (isAgent && merged.variants?.agent?.framework === 'tauri') {
  // tauri-cloudflare.md: monorepo structure, agent+web integration patterns
  const tauriCfPath = '.claude/rules/stack/tauri-cloudflare.md'
  if (existsSync(resolve(ROOT, tauriCfPath))) stackRules.push(tauriCfPath)
  // tauri-rules.md: IPC security, SQLite, auto-update, signing, platform-specific
  const tauriRulesPath = '.claude/rules/stack/tauri-rules.md'
  if (existsSync(resolve(ROOT, tauriRulesPath))) stackRules.push(tauriRulesPath)
}

// Monorepo rules
if (merged.monorepo === true) {
  stackRules.push('.claude/rules/stack/monorepo.md')
}

// Cross-platform rules — load for agent variants (covers Windows/macOS/Linux/browser diffs)
if (isAgent) {
  stackRules.push('.claude/rules/stack/cross-platform.md')
}

// Multi-agent rules
const multiAgentRules = []
if (merged.discipline?.multi_agent === true) {
  multiAgentRules.push('.claude/rules/core/multi-agent.md')
  // Worktree rules require multi_agent
  if (merged.discipline?.worktrees === true) {
    multiAgentRules.push('.claude/rules/core/worktrees.md')
  }
}

// Feature rules
const featureRuleMap = {
  'payments':       '.claude/rules/features/payments-stripe.md',
  'seo':            '.claude/rules/features/seo.md',
  'auth':           '.claude/rules/features/auth.md',
  'auto-update':    '.claude/rules/features/auto-update.md',
  'i18n':           '.claude/rules/features/i18n.md',
  'analytics':      '.claude/rules/features/analytics.md',
  'ai':             '.claude/rules/features/ai.md',
  'email':          '.claude/rules/features/email.md',
  'error-tracking': '.claude/rules/features/error-tracking.md',
  'file-uploads':   '.claude/rules/features/file-uploads.md',
  'realtime':       '.claude/rules/features/realtime.md',
  'openapi':        '.claude/rules/features/openapi.md',
  'timezone':       '.claude/rules/features/timezone.md',
  'mobile-web':     '.claude/rules/features/mobile-web.md',
  'pwa':            '.claude/rules/features/mobile-web.md', // same file covers both
}

const featureRules = []
for (const [feature, rulePath] of Object.entries(featureRuleMap)) {
  if (merged.features?.[feature] === true && existsSync(resolve(ROOT, rulePath))) {
    featureRules.push(rulePath)
  }
}

// Design system rules — loaded when designSystem is enabled (default: true)
// In minimal mode, load only the essentials
const designRulesAll = [
  '.claude/rules/design/design-system.md',
  '.claude/rules/design/tokens.md',
  '.claude/rules/design/typography.md',
  '.claude/rules/design/color.md',
  '.claude/rules/design/components.md',
  '.claude/rules/design/page-types.md',
  '.claude/rules/design/states.md',
  '.claude/rules/design/animation.md',
  '.claude/rules/design/accessibility.md',
  '.claude/rules/design/ux-patterns.md',
  '.claude/rules/design/responsive.md',
  '.claude/rules/design/performance.md',
  '.claude/rules/design/error-pages.md',
  '.claude/rules/design/email-templates.md',
]

const designRulesMinimal = [
  '.claude/rules/design/design-system.md',
  '.claude/rules/design/components.md',
  '.claude/rules/design/states.md',
]

const designRules = []
if (merged.features?.designSystem !== false) {
  const files = minimalMode ? designRulesMinimal : designRulesAll
  for (const rulePath of files) {
    if (existsSync(resolve(ROOT, rulePath))) {
      designRules.push(rulePath)
    }
  }
}

// Agent UX rules — only for agent variants
if (isAgent && !minimalMode) {
  designRules.push('.claude/rules/design/agent-ux.md')
}

// Custom rules (project-specific, always loaded if present)
const customRules = []
const customPath = resolve(ROOT, '.claude/rules/custom')
if (existsSync(customPath)) {
  for (const file of readdirSync(customPath)) {
    if (file.endsWith('.md') && file !== '.gitkeep') {
      customRules.push(`.claude/rules/custom/${file}`)
    }
  }
}

// Compliance rules — loaded based on compliance config flags
const complianceRuleMap = {
  'data-classification': '.claude/rules/compliance/data-classification.md', // always loaded if any compliance flag set
  'core':     '.claude/rules/compliance/compliance-core.md',
  'gdpr':     '.claude/rules/compliance/compliance-gdpr.md',
  'hipaa':    '.claude/rules/compliance/compliance-hipaa.md',
  'soc2':     '.claude/rules/compliance/compliance-soc2.md',
  'pci':      '.claude/rules/compliance/compliance-pci.md',
  'eu_ai_act':'.claude/rules/compliance/compliance-ai-act.md',
}

const complianceRules = []
const complianceCfg = merged.compliance ?? {}
const hasAnyCompliance = Object.values(complianceCfg).some(v => v === true)
  || merged.features?.payments === true // PCI always required if payments enabled

if (hasAnyCompliance || merged.features?.payments) {
  complianceRules.push(complianceRuleMap['data-classification'])
  complianceRules.push(complianceRuleMap['core'])
}
// Auto-enable PCI if payments enabled
if (merged.features?.payments === true || complianceCfg.pci === true) {
  complianceRules.push(complianceRuleMap['pci'])
}
for (const [key, rulePath] of Object.entries(complianceRuleMap)) {
  if (['data-classification', 'core', 'pci'].includes(key)) continue // already handled above
  if (complianceCfg[key] === true && existsSync(resolve(ROOT, rulePath))) {
    complianceRules.push(rulePath)
  }
}

// DPDPA: use GDPR rule file (covers both, differences flagged inline)
if (complianceCfg.dpdpa === true && !complianceCfg.gdpr) {
  complianceRules.push(complianceRuleMap['gdpr'])
}

// Extra rules from config.extend
const extraRules = (merged.extend?.extra_rule_files ?? []).map(f => `.claude/rules/${f}`)

// ─── Domain rules (legacy paths, always loaded) ──────────────────────────────

const domainRules = []
const domainPaths = [
  '.claude/rules/database.md',
  '.claude/rules/api.md',
  '.claude/rules/frontend.md',
]
for (const p of domainPaths) {
  if (existsSync(resolve(ROOT, p))) {
    domainRules.push(p)
  }
}

// ─── Generate CLAUDE.md ───────────────────────────────────────────────────────

const activeFeatures = Object.entries(merged.features ?? {})
  .filter(([, v]) => v === true)
  .map(([k]) => k)
  .join(', ')

const agentInfo = isAgent
  ? `\n| **Agent** | ${merged.variants.agent.framework} (auto-update: ${merged.features?.['auto-update'] ? '✅ enabled' : '⚠️ REQUIRED — enable in config'}) |`
  : ''

const modeLabel = minimalMode ? ' (minimal)' : ''

function importBlock(files, label, icon) {
  return sectionBlock(files, label, icon)
}

const disciplineWarnings = []
if (isAgent && !merged.features?.['auto-update']) {
  disciplineWarnings.push('⚠️ AUTO-UPDATE IS REQUIRED for agent variant but not enabled. Add `"auto-update": true` to features.')
}

const content = `# CLAUDE.md — ${merged.project.name}
> **Auto-generated by \`scripts/generate-claude-md.js\`${modeLabel ? ' (minimal mode)' : ''}**
> **DO NOT EDIT THIS FILE DIRECTLY.** Edit \`boilerplate.config.json\` and re-run \`pnpm setup\`.

---

## Project

| Field | Value |
|---|---|
| **Name** | ${merged.project.name} |
| **Description** | ${merged.project.description} |
| **Version** | ${merged.project.version ?? '0.1.0'} |
| **Profile** | \`${merged.profile}\`${modeLabel} |
| **Stack** | ${merged.stack.frontend} + ${merged.stack.backend} + ${merged.stack.database} + ${merged.stack.orm} |
| **Features** | ${activeFeatures || 'none'} |${agentInfo}

${disciplineWarnings.length ? `## ⚠️ Configuration Warnings\n${disciplineWarnings.map(w => `- ${w}`).join('\n')}\n---\n` : ''}

## Session Start Protocol

**Before touching any file, do all of this:**

1. Read \`docs/SPEC.md\` — understand what this product does
2. Read \`docs/ARCHITECTURE.md\` — understand how it's built
3. Read \`docs/DECISIONS.md\` — understand why decisions were made
4. Read \`.mdd/docs/<relevant-feature>.md\` if working on a specific feature
5. Run \`git log --oneline -20\` — see recent changes
6. Run \`git status\` — see what's currently modified

**Only then start coding.**
${importBlock(coreRules, 'Core Rules (Always Apply)', '🔒')}${importBlock(designRules, 'Design System Rules', '🎨')}${importBlock(domainRules, 'Domain Rules', '📐')}${importBlock(stackRules, 'Stack Rules', '⚙️')}${importBlock(multiAgentRules, 'Multi-Agent Rules', '🤖')}${importBlock(featureRules, 'Feature Rules', '✨')}${importBlock(complianceRules, 'Compliance & Data Rules', '⚖️')}${importBlock(customRules, 'Project-Specific Rules', '🏗️')}${importBlock(extraRules, 'Extra Rules', '➕')}
---

## Discipline Enforcement

${Object.entries(merged.discipline ?? {}).map(([k, v]) => `- **${k.replace(/_/g, ' ')}:** ${v}`).join('\n')}

---

## Definition of Done

A task is **DONE** when ALL of these are true:
- [ ] Feature works as described in \`docs/SPEC.md\`
- [ ] Tests pass: \`pnpm test\`
- [ ] Types pass: \`pnpm typecheck\`
- [ ] Lint passes: \`pnpm lint\`
- [ ] \`docs/ARCHITECTURE.md\` reflects current reality
- [ ] Any decisions logged in \`docs/DECISIONS.md\`
- [ ] MDD feature doc updated in \`.mdd/docs/\`
- [ ] Commit is clean and conventional

---

*Generated: ${new Date().toISOString()}*
*Config: ${merged.profile}${modeLabel} | Features: ${activeFeatures || 'none'}*
`

// ─── Write & report ───────────────────────────────────────────────────────────

writeFileSync(resolve(ROOT, 'CLAUDE.md'), content, 'utf-8')

// Estimate token count (~4 chars per token for mixed content)
const tokenEstimate = Math.ceil(content.length / 4)
const allRules = [
  ...coreRules,
  ...designRules,
  ...domainRules,
  ...stackRules,
  ...multiAgentRules,
  ...featureRules,
  ...complianceRules,
  ...customRules,
  ...extraRules,
]

console.log(`✅ CLAUDE.md generated (${modeLabel ? 'minimal' : 'full'} mode)`)
console.log(`   Profile:    ${merged.profile}`)
console.log(`   Core:       ${coreRules.length} rules`)
console.log(`   Design:     ${designRules.length} rules`)
console.log(`   Domain:     ${domainRules.length} rules`)
console.log(`   Stack:      ${stackRules.length} rules`)
console.log(`   Multi-agent: ${multiAgentRules.length} rules`)
console.log(`   Features:   ${featureRules.length} rules (${activeFeatures || 'none'})`)
console.log(`   Compliance: ${complianceRules.length} rules (${Object.entries(complianceCfg).filter(([,v])=>v).map(([k])=>k).join(', ') || 'pci (auto)'})`)
console.log(`   Custom:     ${customRules.length} rules`)
console.log(`   Total:      ${allRules.length} rule files concatenated`)
console.log(`   Output:     ${content.length.toLocaleString()} chars ≈ ${tokenEstimate.toLocaleString()} tokens`)
if (disciplineWarnings.length) {
  disciplineWarnings.forEach(w => console.warn(`   ${w}`))
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function deepMerge(base, override) {
  const result = { ...base }
  for (const [key, value] of Object.entries(override)) {
    if (value && typeof value === 'object' && !Array.isArray(value) && result[key]) {
      result[key] = deepMerge(result[key], value)
    } else {
      result[key] = value
    }
  }
  return result
}
