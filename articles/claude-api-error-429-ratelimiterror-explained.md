---
layout: default
title: "Claude API Error 429 rate_limit_error"
description: "Fix Claude API 429 rate_limit_error with retry logic, backoff strategies, and rate limit header monitoring. Includes Python and TypeScript examples."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-api-error-429-ratelimiterror-explained/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-api, sdk-python, sdk-typescript, rate-limits]
geo_optimized: true
---

# Claude API Error 429 rate_limit_error Fix

When you hit the Claude API rate limit, the API returns a 429 status code with a `rate_limit_error` type. This guide explains exactly why it happens and how to handle it in your code.

## The Error

```json
{
 "type": "error",
 "error": {
 "type": "rate_limit_error",
 "message": "Your account has hit a rate limit."
 },
 "request_id": "req_018EeWyXxfu5pfWkrYcMdjWG"
}
```

## Quick Fix

1. Check the `retry-after` response header for how long to wait.
2. Enable the SDK's built-in retry mechanism (on by default with 2 retries).
3. Monitor [Claude rate exceeded error fix](/claude-rate-exceeded-error-fix/) headers to throttle before hitting the limit.

## What Causes This

The Claude API enforces three types of rate limits per tier:

- **RPM** (Requests Per Minute): Maximum number of API calls per minute.
- **ITPM** (Input Tokens Per Minute): Maximum input tokens processed per minute.
- **OTPM** (Output Tokens Per Minute): Maximum output tokens generated per minute.

Limits vary by spend tier. At Tier 4, Claude Opus 4.x allows 4,000 RPM, 2,000,000 ITPM, and 400,000 OTPM. The Opus 4.x rate limit is shared across Opus 4.6, 4.5, 4.1, and 4.

The API uses a token bucket algorithm where capacity is continuously replenished rather than reset at fixed intervals. You can also see 429 errors due to acceleration limits when your organization has a sharp increase in usage.

## Full Solution

### Python SDK with Built-in Retries

The Python SDK retries 429 errors automatically with exponential backoff (2 retries by default):

```python
import anthropic

# Default: 2 retries with exponential backoff
client = anthropic.Anthropic()

# Increase retries for high-throughput workloads
client = anthropic.Anthropic(max_retries=5)

# Override retries per request
message = client.with_options(max_retries=5).messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello"}]
)
```

### TypeScript SDK with Built-in Retries

```typescript
import Anthropic from "@anthropic-ai/sdk";

// Default: 2 retries with exponential backoff
const client = new Anthropic();

// Increase retries
const client2 = new Anthropic({ maxRetries: 5 });
```

### Monitor Rate Limit Headers

The API returns rate limit status in response headers. Check these before you hit the limit:

```python
import anthropic

client = anthropic.Anthropic()
response = client.messages.with_raw_response.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello"}]
)

# Check remaining capacity
remaining_requests = response.headers.get("anthropic-ratelimit-requests-remaining")
remaining_tokens = response.headers.get("anthropic-ratelimit-tokens-remaining")
reset_time = response.headers.get("anthropic-ratelimit-requests-reset")
retry_after = response.headers.get("retry-after")

print(f"Requests remaining: {remaining_requests}")
print(f"Tokens remaining: {remaining_tokens}")
print(f"Reset at: {reset_time}")
```

### Rate Limit Headers Reference

| Header | Description |
|--------|-------------|
| `anthropic-ratelimit-requests-limit` | Maximum requests per period |
| `anthropic-ratelimit-requests-remaining` | Requests left in current window |
| `anthropic-ratelimit-requests-reset` | When the request limit resets |
| `anthropic-ratelimit-tokens-limit` | Maximum tokens per period |
| `anthropic-ratelimit-tokens-remaining` | Tokens left in current window |
| `anthropic-ratelimit-tokens-reset` | When the token limit resets |
| `retry-after` | Seconds to wait before retrying |

## Prevention

1. **Use prompt caching**: Cache-read input tokens do NOT count towards ITPM limits. With an 80% cache hit rate and a 2M ITPM limit, your effective throughput reaches 10M tokens per minute.
2. **Use the Batch API**: For non-time-sensitive workloads, the Message Batches API has separate, higher rate limits (500,000 batch requests in queue at Tier 4) and costs 50% less.
3. **Upgrade your spend tier**: Higher tiers get higher rate limits. Tier 1 starts at $5 credit purchase; Tier 4 requires $400.
4. **Set workspace limits**: Configure per-workspace limits to prevent one service from consuming your entire organization's quota.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-api-error-429-ratelimiterror-explained)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

- [Claude API Error 529 overloaded_error Fix](/claude-api-error-529-overloadederror-explained/) -- handle API overload errors that look similar to rate limits.
- [Claude Prompt Caching API Guide](/claude-prompt-caching-api-guide/) -- reduce ITPM usage by caching repeated prompt content.
- [Claude API Error 400 invalid_request_error Fix](/claude-api-error-400-invalidrequesterror-explained/) -- debug malformed requests that waste your rate limit budget.
- [Claude Streaming API Guide](/claude-streaming-api-guide/) -- streaming responses help avoid timeout issues on long requests.
- [Claude SDK Timeout Configuration](/claude-sdk-timeout-configuration-customization/) -- configure timeouts alongside retry logic.




- [Claude AI rate exceeded error fix](/claude-ai-rate-exceeded-error-fix/) — Fix the Claude AI rate exceeded error message
