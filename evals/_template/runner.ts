/**
 * AI Eval Runner Template
 *
 * Usage:
 *   1. Copy this file to `evals/<feature-name>/runner.ts`
 *   2. Create `cases.jsonl` with test cases
 *   3. Create `rubric.md` with evaluation criteria
 *   4. Set baseline: `tsx evals/<feature-name>/runner.ts --set-baseline`
 *   5. Run evals: `tsx evals/<feature-name>/runner.ts`
 *   6. Check regression: `tsx evals/<feature-name>/runner.ts --check-regression`
 *
 * This runner supports:
 *   - Deterministic checks (exact match, regex, schema validation)
 *   - LLM-as-judge (uses a cheaper model to grade outputs)
 *   - Baseline tracking and regression detection
 *   - JSON output for CI integration
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const BASELINE_PATH = join(__dirname, 'baseline.json');
const CASES_PATH = join(__dirname, 'cases.jsonl');
const RESULTS_DIR = join(__dirname, 'results');

interface EvalCase {
  input: string;
  expected?: string;
  category?: string;
  type?: 'exact' | 'regex' | 'schema' | 'llm-judge';
  schema?: object; // JSON schema for schema validation
  forbidden?: string[]; // strings that must NOT appear in output
  required?: string[]; // strings that MUST appear in output
}

interface EvalResult {
  case_index: number;
  input: string;
  category: string;
  passed: boolean;
  score: number; // 0-1
  reason: string;
  output: string;
}

interface Baseline {
  timestamp: string;
  total_cases: number;
  passed: number;
  pass_rate: number;
  avg_score: number;
  by_category: Record<string, { total: number; passed: number; pass_rate: number }>;
}

// --- Deterministic Evaluators ---

function exactMatch(output: string, expected: string): { passed: boolean; score: number; reason: string } {
  const passed = output.trim() === expected.trim();
  return { passed, score: passed ? 1 : 0, reason: passed ? 'Exact match' : `Expected "${expected}", got "${output}"` };
}

function regexMatch(output: string, pattern: string): { passed: boolean; score: number; reason: string } {
  const regex = new RegExp(pattern);
  const passed = regex.test(output);
  return { passed, score: passed ? 1 : 0, reason: passed ? 'Regex matched' : `Pattern "${pattern}" not found` };
}

function forbiddenStrings(output: string, forbidden: string[]): { passed: boolean; score: number; reason: string } {
  const violations = forbidden.filter(s => output.includes(s));
  const passed = violations.length === 0;
  return { passed, score: passed ? 1 : 0, reason: passed ? 'No forbidden strings' : `Found forbidden: ${violations.join(', ')}` };
}

function requiredStrings(output: string, required: string[]): { passed: boolean; score: number; reason: string } {
  const missing = required.filter(s => !output.includes(s));
  const passed = missing.length === 0;
  return { passed, score: passed ? 1 : 0, reason: passed ? 'All required strings present' : `Missing: ${missing.join(', ')}` };
}

// --- LLM-as-Judge (implement with your AI provider) ---

async function llmJudge(input: string, output: string, rubricPath: string): Promise<{ passed: boolean; score: number; reason: string }> {
  const rubric = readFileSync(rubricPath, 'utf-8');

  // TODO: Implement with your AI provider
  // const response = await fetch('https://api.anthropic.com/v1/messages', { ... });
  // Parse the judge's score and reasoning

  // Placeholder — replace with actual LLM call
  return {
    passed: false,
    score: 0,
    reason: 'LLM judge not implemented — implement llmJudge() with your AI provider',
  };
}

// --- Main Runner ---

async function runEvals(): Promise<void> {
  if (!existsSync(CASES_PATH)) {
    console.error(`❌ No cases.jsonl found at ${CASES_PATH}`);
    process.exit(1);
  }

  const cases: EvalCase[] = readFileSync(CASES_PATH, 'utf-8')
    .split('\n')
    .filter(line => line.trim())
    .map(line => JSON.parse(line));

  const results: EvalResult[] = [];

  for (let i = 0; i < cases.length; i++) {
    const c = cases[i];
    const category = c.category || 'default';

    // TODO: Call your AI feature here to get the output
    // const output = await yourAIFeature(c.input);
    const output = ''; // Replace with actual call

    let evalResult: { passed: boolean; score: number; reason: string };

    switch (c.type || 'llm-judge') {
      case 'exact':
        evalResult = exactMatch(output, c.expected || '');
        break;
      case 'regex':
        evalResult = regexMatch(output, c.expected || '');
        break;
      case 'schema':
        // Validate output against JSON schema
        try {
          const parsed = JSON.parse(output);
          // TODO: Use Ajv or Zod to validate against c.schema
          evalResult = { passed: true, score: 1, reason: 'Schema valid' };
        } catch {
          evalResult = { passed: false, score: 0, reason: 'Invalid JSON' };
        }
        break;
      case 'llm-judge':
        evalResult = await llmJudge(c.input, output, join(__dirname, 'rubric.md'));
        break;
      default:
        // Combined check: required + forbidden
        const req = c.required ? requiredStrings(output, c.required) : { passed: true, score: 1, reason: '' };
        const forb = c.forbidden ? forbiddenStrings(output, c.forbidden) : { passed: true, score: 1, reason: '' };
        evalResult = {
          passed: req.passed && forb.passed,
          score: (req.score + forb.score) / 2,
          reason: [req.reason, forb.reason].filter(r => r).join('; '),
        };
    }

    results.push({
      case_index: i,
      input: c.input.substring(0, 100),
      category,
      passed: evalResult.passed,
      score: evalResult.score,
      reason: evalResult.reason,
      output: output.substring(0, 200),
    });
  }

  // Calculate summary
  const passed = results.filter(r => r.passed).length;
  const passRate = passed / results.length;
  const avgScore = results.reduce((sum, r) => sum + r.score, 0) / results.length;

  const byCategory: Record<string, { total: number; passed: number; pass_rate: number }> = {};
  for (const r of results) {
    if (!byCategory[r.category]) byCategory[r.category] = { total: 0, passed: 0, pass_rate: 0 };
    byCategory[r.category].total++;
    if (r.passed) byCategory[r.category].passed++;
  }
  for (const cat of Object.keys(byCategory)) {
    byCategory[cat].pass_rate = byCategory[cat].passed / byCategory[cat].total;
  }

  const summary: Baseline = {
    timestamp: new Date().toISOString(),
    total_cases: results.length,
    passed,
    pass_rate: passRate,
    avg_score: avgScore,
    by_category: byCategory,
  };

  // Output
  const args = process.argv.slice(2);

  if (args.includes('--set-baseline')) {
    writeFileSync(BASELINE_PATH, JSON.stringify(summary, null, 2));
    console.log(`✅ Baseline set: ${passed}/${results.length} passed (${(passRate * 100).toFixed(1)}%), avg score: ${avgScore.toFixed(2)}`);
    return;
  }

  if (args.includes('--check-regression')) {
    if (!existsSync(BASELINE_PATH)) {
      console.error('❌ No baseline found. Run with --set-baseline first.');
      process.exit(1);
    }
    const baseline: Baseline = JSON.parse(readFileSync(BASELINE_PATH, 'utf-8'));

    const regressed = [];
    if (passRate < baseline.pass_rate) regressed.push(`Pass rate: ${(passRate * 100).toFixed(1)}% < baseline ${(baseline.pass_rate * 100).toFixed(1)}%`);
    if (avgScore < baseline.avg_score) regressed.push(`Avg score: ${avgScore.toFixed(2)} < baseline ${baseline.avg_score.toFixed(2)}`);

    for (const [cat, data] of Object.entries(byCategory)) {
      const baseCat = baseline.by_category[cat];
      if (baseCat && data.pass_rate < baseCat.pass_rate) {
        regressed.push(`Category "${cat}": ${(data.pass_rate * 100).toFixed(1)}% < baseline ${(baseCat.pass_rate * 100).toFixed(1)}%`);
      }
    }

    if (regressed.length > 0) {
      console.error('🚫 EVAL REGRESSION DETECTED:');
      regressed.forEach(r => console.error(`  - ${r}`));
      process.exit(1);
    } else {
      console.log(`✅ No regression. Current: ${(passRate * 100).toFixed(1)}% (baseline: ${(baseline.pass_rate * 100).toFixed(1)}%)`);
      return;
    }
  }

  // Default: run and report
  console.log(JSON.stringify({ summary, results }, null, 2));
}
