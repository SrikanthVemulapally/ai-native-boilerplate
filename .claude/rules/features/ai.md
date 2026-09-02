# Feature Rules: AI Integration
> Loaded when: features.ai=true

## Architecture: AI as a Feature, Not the Foundation

AI is one capability among many. It must:
- Degrade gracefully when unavailable
- Be cost-trackable per user/org
- Be testable without real API calls
- Never leak user data to third parties without consent

## Required Files

```
workers/api/src/
  routes/ai/
    chat.ts         ← Streaming chat endpoint
    complete.ts     ← One-shot completion
  lib/
    ai/
      client.ts     ← Anthropic client singleton
      prompts.ts    ← System prompts (versioned, NOT inline)
      cost.ts       ← Token tracking + cost calculation
      evals.ts      ← Eval runner
      cache.ts      ← Prompt cache helpers

packages/shared/
  types/ai.ts       ← Shared AI types (Message, Usage, EvalResult)
```

## Client Pattern

```typescript
// workers/api/src/lib/ai/client.ts
import Anthropic from '@anthropic-ai/sdk'

export function getAI(env: Env): Anthropic {
  return new Anthropic({ apiKey: env.ANTHROPIC_API_KEY })
}

// ALWAYS use streaming for user-facing responses
export async function* streamCompletion(
  client: Anthropic,
  messages: Anthropic.MessageParam[],
  systemPrompt: string,
  model = 'claude-opus-4-5',
) {
  const stream = client.messages.stream({
    model,
    max_tokens: 8096,
    system: systemPrompt,
    messages,
  })
  
  for await (const chunk of stream) {
    if (chunk.type === 'content_block_delta' && chunk.delta.type === 'text_delta') {
      yield chunk.delta.text
    }
  }
}
```

## Prompt Management

```typescript
// workers/api/src/lib/ai/prompts.ts
// ✅ Prompts are versioned, named constants — NOT inline strings
export const PROMPTS = {
  chat_assistant: {
    version: '1.2.0',
    system: `You are a helpful assistant for {{product_name}}. 
Your role: {{role_description}}
Always: {{always_rules}}
Never: {{never_rules}}`,
  },
  data_extractor: {
    version: '1.0.0',
    system: `Extract structured data from the following input...`,
  },
} as const

// ❌ Never do this — inline prompts are untestable and unversioned
const response = await client.messages.create({
  system: "You are a helpful assistant...", // hardcoded, untracked
})
```

## Cost Tracking (Required)

```typescript
// Track every AI call per user/org
await c.env.DB.prepare(`
  INSERT INTO ai_usage (id, user_id, org_id, model, input_tokens, output_tokens, cost_usd, created_at)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?)
`).bind(
  uuidv7(), userId, orgId, model,
  usage.input_tokens, usage.output_tokens,
  calculateCost(model, usage),
  new Date().toISOString()
).run()
```

## Evals (Required for production AI features)

```typescript
// packages/shared/evals/chat.eval.ts
export const chatEvals: Eval[] = [
  {
    name: 'basic_greeting',
    input: [{ role: 'user', content: 'Hello' }],
    judge: (output) => output.toLowerCase().includes('hello') || output.toLowerCase().includes('hi'),
  },
  {
    name: 'stays_in_scope',
    input: [{ role: 'user', content: 'Write me a poem about cats' }],
    judge: (output) => !output.includes('poem') && output.includes('assist'),
    // Should politely decline off-topic requests
  },
]

// Run: pnpm eval (before every release that changes prompts)
```

## Rules

- **Every AI feature has evals.** Run `/add-eval` when adding any AI feature.
- **Prompt versions are semver.** Increment on every change.
- **No user PII in prompts without explicit consent.** Sanitize before sending.
- **Rate limit per user.** Store limits in KV, check before every call.
- **Streaming for user-facing.** One-shot only for background/automated tasks.
- **Model pinned by config.** `ai.model` in `boilerplate.config.json`. Never hardcode.
- **Cost dashboard in admin panel.** Every org can see their AI usage.
- **Prompt cache where applicable.** Use Anthropic's cache_control for long system prompts.
