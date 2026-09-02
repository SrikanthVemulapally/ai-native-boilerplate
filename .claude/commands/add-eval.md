---
name: add-eval
description: Add automated eval (LLM-as-judge or deterministic) for an AI-powered feature
user-invocable: true
---

Add eval for: $ARGUMENTS

## What Are Evals?

Evals are automated tests that measure the quality of AI-powered outputs.
Unlike unit tests (pass/fail on exact output), evals measure:
- Accuracy (is the answer factually correct?)
- Relevance (does it answer what was asked?)
- Format compliance (does it follow the output schema?)
- Safety (does it refuse harmful requests?)

## Eval Types to Choose From

### 1. Deterministic Eval (Preferred when possible)
- Check output matches expected JSON schema
- Check output contains required fields
- Check output doesn't contain forbidden strings
- Binary pass/fail — no LLM needed

### 2. LLM-as-Judge Eval
Use when deterministic is insufficient.
- A separate LLM grades the output on 1-5 scale with reasoning
- Cheaper model for judging (e.g., claude-haiku) unless high stakes

### 3. Human-in-the-Loop Sample Review
- Sample N% of real outputs and log for periodic human review
- Use when LLM judge isn't reliable enough

## Workflow

### Step 1: Define Success Criteria
- What does a GOOD output look like? (Write 3 examples)
- What does a BAD output look like? (Write 3 examples)
- What's the minimum acceptable score? (e.g., 4/5 average)

### Step 2: Build the Eval
Create `evals/<feature-name>/`:
```
evals/<feature-name>/
  index.ts         — eval runner
  cases.ts         — test cases (input → expected outcome)
  judge.ts         — LLM judge prompt (if LLM-as-judge)
  README.md        — what this eval measures and how to run it
```

### Step 3: Wire into CI
Add to `package.json`:
```json
"eval": "tsx evals/<feature-name>/index.ts"
```

Add to GitHub Actions on a schedule (not every PR — evals can be slow/costly).

### Step 4: Set Baseline
Run the eval on current codebase and record the score in `evals/<feature-name>/baseline.json`.
Future runs must meet or beat this score.

### Step 5: Add Alert
If eval score drops below threshold, alert via logging/error tracking.
