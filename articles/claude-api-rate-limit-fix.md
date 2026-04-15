---
layout: default
title: "Fix Claude API Rate Limit Errors (HTTP 429)"
description: "Resolve Claude API rate limit errors with exponential backoff, request batching, and tier upgrades. Includes Python and TypeScript examples."
date: 2026-04-14
last_modified_at: 2026-04-14
author: "Claude Code Guides"
permalink: /claude-api-rate-limit-fix/
reviewed: true
categories: [API Errors & HTTP Status Codes]
tags: ["claude-api", "rate-limit", "error-429", "throttling"]
---

# Fix Claude API Rate Limit Errors (HTTP 429)

> **TL;DR:** HTTP 429 means you have exceeded your request or token rate limit. Implement exponential backoff, check your usage tier limits, and batch requests to stay within bounds.

## The Problem

Your Claude API calls start failing with HTTP 429:

```json
{
  "type": "error",
  "error": {
    "type": "rate_limit_error",
    "message": "Rate limit reached. Please retry after X seconds."
  }
}
```

Or you see a variation like "You've hit your limit" that resets at a specific time.

## Why This Happens

Anthropic enforces rate limits at multiple levels:

- **Requests per minute (RPM):** How many API calls you can make per minute
- **Tokens per minute (TPM):** Total input + output tokens per minute
- **Tokens per day (TPD):** Daily token budget (varies by plan tier)
- **Concurrent requests:** Maximum simultaneous in-flight requests

Limits vary by plan tier (Free, Build, Scale, Enterprise) and by model. Opus models typically have lower limits than Sonnet or Haiku.

## The Fix

### Step 1 — Check Your Current Limits and Usage

```bash
# Make a request and inspect rate limit headers
curl -s -D - https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-5-20250514","max_tokens":32,"messages":[{"role":"user","content":"hi"}]}' \
  -o /dev/null 2>&1 | grep -i "rate\|limit\|retry"
```

Key response headers:
- `anthropic-ratelimit-requests-limit` — Your RPM cap
- `anthropic-ratelimit-requests-remaining` — Remaining requests this window
- `anthropic-ratelimit-requests-reset` — When the window resets
- `retry-after` — Seconds to wait before retrying (on 429 responses)

### Step 2 — Implement Proper Retry Logic

**Python SDK (automatic retries built in):**

```python
import anthropic
import time

client = anthropic.Anthropic(max_retries=5)

def call_with_backoff(messages, max_attempts=5):
    """Call API with manual backoff for rate limits."""
    for attempt in range(max_attempts):
        try:
            return client.messages.create(
                model="claude-sonnet-4-5-20250514",
                max_tokens=1024,
                messages=messages
            )
        except anthropic.RateLimitError as e:
            if attempt == max_attempts - 1:
                raise
            wait = min(2 ** attempt, 60)  # Cap at 60s
            print(f"Rate limited. Waiting {wait}s...")
            time.sleep(wait)
    return None  # Unreachable but satisfies bounded return
```

**TypeScript SDK:**

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({ maxRetries: 5 });

async function callWithBackoff(
  messages: Anthropic.MessageParam[],
  maxAttempts = 5
): Promise<Anthropic.Message | null> {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await client.messages.create({
        model: "claude-sonnet-4-5-20250514",
        max_tokens: 1024,
        messages,
      });
    } catch (error) {
      if (error instanceof Anthropic.RateLimitError) {
        if (attempt === maxAttempts - 1) throw error;
        const wait = Math.min(2 ** attempt * 1000, 60000);
        await new Promise((r) => setTimeout(r, wait));
      } else {
        throw error;
      }
    }
  }
  return null;
}
```

### Step 3 — Batch Requests Efficiently

If you are processing many items, use a rate-limited queue:

```python
import asyncio
import anthropic

MAX_CONCURRENT = 5  # Stay well below RPM limit
semaphore = asyncio.Semaphore(MAX_CONCURRENT)
client = anthropic.AsyncAnthropic(max_retries=3)

async def process_item(item):
    async with semaphore:
        return await client.messages.create(
            model="claude-haiku-3-5-20241022",
            max_tokens=512,
            messages=[{"role": "user", "content": item}]
        )

async def main():
    items = ["task1", "task2", "task3"]  # Your work items
    results = await asyncio.gather(
        *[process_item(item) for item in items],
        return_exceptions=True
    )
    for r in results:
        assert not isinstance(r, Exception), f"Failed: {r}"
    return results
```

### Step 4 — Verify Rate Limits Are Not Exhausted

```bash
# Check remaining quota
curl -s -D - https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-5-20250514","max_tokens":16,"messages":[{"role":"user","content":"1"}]}' \
  2>&1 | grep "ratelimit-requests-remaining"
```

**Expected output:**

```
anthropic-ratelimit-requests-remaining: 48
```

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| 429 on first request of the day | Daily token limit hit (rolls over) | Wait for reset time shown in error |
| 429 only with Opus | Lower per-model RPM limits | Switch to Sonnet for high-throughput tasks |
| 429 in parallel workers | Concurrent request limit | Add a semaphore / rate limiter |
| "You've hit your limit" | Plan-level daily cap | Upgrade tier or wait for reset |

## Prevention

- **Use Haiku for high-volume tasks:** Haiku has much higher rate limits than Opus or Sonnet.
- **Cache responses:** Avoid redundant API calls by caching deterministic responses locally.
- **Monitor usage:** Track your `ratelimit-*-remaining` headers in dashboards to catch limits before they hit.

## Related Issues

- [Fix Claude API Error 500 — Internal Server Error](/claude-api-error-500-fix) — Server-side errors
- [Fix Claude API Error 401 — Authentication Failed](/claude-api-error-401-fix) — API key issues
- [Hub: API Errors & HTTP Status Codes](/claude-api-errors-hub) — Browse all API error guides

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*
