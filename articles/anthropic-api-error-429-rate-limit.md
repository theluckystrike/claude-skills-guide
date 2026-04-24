---
layout: default
title: "Fix: Claude API Error 429 Rate Limit"
description: "Fix Anthropic API error 429 rate limit reached with proper backoff, SDK retries, and usage optimization strategies. Tested and working in 2026."
last_tested: "2026-04-22"
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /anthropic-api-error-429-rate-limit/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-code, api-errors, rate-limits, 429, sdk]
geo_optimized: true
---

# Fix: Claude API Error 429 Rate Limit Reached

## The Error

```json
{
 "type": "error",
 "error": {
 "type": "rate_limit_error",
 "message": "Rate limit reached. Please try again later."
 }
}
```

HTTP status code: [Claude rate exceeded error fix](/claude-rate-exceeded-error-fix/) Too Many Requests. The response includes a `retry-after` header indicating how long to wait.

## Quick Fix

1. Check the `retry-after` response header and wait the specified duration
2. Enable SDK automatic retries (both SDKs retry 429s by default with 2 retries)
3. Reduce request frequency or switch to the Message Batches API for bulk workloads

```typescript
const client = new Anthropic({
 maxRetries: 5, // Default is 2
});
```

## What Causes This

Anthropic enforces rate limits at multiple levels using a token bucket algorithm where capacity is continuously replenished rather than reset at fixed intervals.

**Types of rate limits:**

- **Requests Per Minute (RPM)** -- a hard cap on the number of API calls per minute
- **Input Tokens Per Minute (ITPM)** -- limit on input tokens processed per minute
- **Output Tokens Per Minute (OTPM)** -- limit on output tokens generated per minute

**Rate limits at Tier 4 (highest self-serve tier):**

| Model | RPM | ITPM | OTPM |
|-------|-----|------|------|
| Opus 4.x | 4,000 | 2,000,000 | 400,000 |
| Sonnet 4.x | 4,000 | 2,000,000 | 400,000 |
| Haiku 4.5 | 4,000 | 4,000,000 | 800,000 |

Opus 4.x rate limits are shared across Opus 4.6, 4.5, 4.1, and 4. Sonnet 4.x rate limits are shared across Sonnet 4.6, 4.5, and 4.

**Cache-aware ITPM:** Only uncached input tokens count towards ITPM for most models. With an 80% cache hit rate and a 2M ITPM limit, effective throughput reaches 10M tokens per minute.

You may also see 429 errors from **acceleration limits** -- sharp increases in usage can trigger rate limiting even if you are within your tier's steady-state limits.

## Full Solution

### Option 1: SDK Automatic Retry

Both official SDKs include built-in retry with exponential backoff. The default is 2 retries for connection errors, 408, 409, 429, and 500+ status codes.

```typescript
// TypeScript SDK
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
 maxRetries: 5, // Default is 2
});
```

```python
# Python SDK
import anthropic

client = anthropic.Anthropic(
 max_retries=5, # Default is 2
)

# Or per-request override:
client.with_options(max_retries=5).messages.create(...)
```

### Option 2: Manual Retry with Backoff

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

async function callWithBackoff(
 fn: () => Promise<any>,
 maxRetries = 5,
 baseDelay = 1000
): Promise<any> {
 for (let attempt = 0; attempt < maxRetries; attempt++) {
 try {
 return await fn();
 } catch (error) {
 if (
 error instanceof Anthropic.RateLimitError &&
 attempt < maxRetries - 1
 ) {
 const delay = baseDelay * 2 ** attempt + Math.random() * 1000;
 await new Promise((r) => setTimeout(r, delay));
 continue;
 }
 throw error;
 }
 }
}
```

### Option 3: Use the Message Batches API

For workloads that can tolerate asynchronous processing, the Message Batches API offers 50% cost savings and separate rate limits. Most batches complete within 1 hour.

```python
import anthropic

client = anthropic.Anthropic()

batch = client.messages.batches.create(
 requests=[
 {
 "custom_id": f"request-{i}",
 "params": {
 "model": "claude-sonnet-4-6",
 "max_tokens": 1024,
 "messages": [{"role": "user", "content": prompt}],
 },
 }
 for i, prompt in enumerate(prompts)
 ]
)

# Check batch status later
result = client.messages.batches.retrieve(batch.id)
```

A single batch can contain up to 100,000 requests or 256 MB, whichever is reached first. Results are available for 29 days after creation.

### Option 4: Monitor Rate Limit Headers

The API returns these headers with every response:

- `anthropic-ratelimit-requests-limit` / `anthropic-ratelimit-requests-remaining` / `anthropic-ratelimit-requests-reset`
- `anthropic-ratelimit-tokens-limit` / `anthropic-ratelimit-tokens-remaining` / `anthropic-ratelimit-tokens-reset`
- `anthropic-ratelimit-input-tokens-limit` / `anthropic-ratelimit-input-tokens-remaining` / `anthropic-ratelimit-input-tokens-reset`
- `anthropic-ratelimit-output-tokens-limit` / `anthropic-ratelimit-output-tokens-remaining` / `anthropic-ratelimit-output-tokens-reset`
- `retry-after`

Monitor the `remaining` headers to throttle your requests before hitting the limit.

## Prevention

- **Use prompt caching** -- cached input tokens do not count toward ITPM limits, dramatically increasing effective throughput
- **Use the Message Batches API** for non-urgent workloads (50% cost savings and separate rate limits)
- **Implement client-side throttling** to prevent bursts that trigger RPM limits
- **Monitor rate limit headers** and adjust throughput before hitting limits
- **Avoid sharp usage increases** which can trigger acceleration limits even within your tier

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=anthropic-api-error-429-rate-limit)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

- [Fix: Anthropic SDK Streaming Hangs Indefinitely](/anthropic-sdk-streaming-hang-timeout/)
- [Fix: Anthropic SDK TypeError: terminated](/anthropic-sdk-typeerror-terminated/)
- [Claude API Error 400 Invalid Request Fix](/claude-api-error-400-invalidrequesterror-explained/)
- [Claude Prompt Caching Pricing and Cost Savings](/claude-prompt-caching-pricing-and-cost-savings/)
- [Claude API Batch Processing Large Datasets Workflow Guide](/claude-api-batch-processing-large-datasets-workflow-guide/)



- [Claude AI rate exceeded error fix](/claude-ai-rate-exceeded-error-fix/) — Fix the Claude AI rate exceeded error message
## Related Articles

- [Fix Claude Code API Rate Limit Reached Error](/claude-code-api-error-rate-limit-reached/)
- [Fix Anthropic API Streaming Interrupted](/anthropic-api-streaming-interrupted-fix/)
- [Anthropic Rate Limit Tokens Per Minute — Fix (2026)](/claude-code-anthropic-rate-limit-tokens-per-minute-fix-2026/)
