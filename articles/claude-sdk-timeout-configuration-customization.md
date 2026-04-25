---
layout: default
title: "Claude SDK Timeout Configuration Guide"
description: "Configure Claude SDK timeouts and retries for Python and TypeScript. Covers default timeouts, per-request overrides, and the 10-minute streaming rule."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-sdk-timeout-configuration-customization/
reviewed: true
score: 7
categories: [guides]
tags: [claude-api, sdk-python, sdk-typescript, configuration]
geo_optimized: true
---

# Claude SDK Timeout Configuration Guide

The Claude SDK defaults to a 10-minute timeout and 2 retries. For production workloads, you need to tune these values based on your request patterns. This guide covers every timeout and retry option.

## The Error

When a request exceeds the timeout:

```text
anthropic.APITimeoutError: Request timed out.
```

When a non-streaming request is expected to exceed 10 minutes:

```text
ValueError: Non-streaming request expected to exceed 10 minute timeout. Use streaming or increase timeout.
```

## Quick Fix

1. Use streaming for long-running requests (avoids the 10-minute limit).
2. Increase the timeout for specific requests using `with_options()`.
3. Increase retries to handle transient connection failures.

## What Causes This

- Non-streaming requests with large `max_tokens` values can exceed the default 10-minute timeout.
- The SDK validates non-streaming requests and throws `ValueError` before sending if the expected time exceeds 10 minutes.
- Network issues or slow responses from the API can cause `APITimeoutError`.

## Full Solution

### Python: Client-Level Timeout

```python
import anthropic
import httpx

# Simple timeout (all operations use the same value)
client = anthropic.Anthropic(timeout=20.0) # 20 seconds

# Fine-grained timeout control
client = anthropic.Anthropic(
 timeout=httpx.Timeout(
 60.0, # Total timeout
 read=5.0, # Read timeout per chunk
 write=10.0, # Write timeout
 connect=2.0 # Connection timeout
 )
)
```

### Python: Per-Request Timeout Override

```python
import anthropic

client = anthropic.Anthropic()

# Override timeout for a single request
message = client.with_options(timeout=120.0).messages.create(
 model="claude-opus-4-6",
 max_tokens=4096,
 messages=[{"role": "user", "content": "Complex analysis task..."}]
)
```

### TypeScript: Client-Level Timeout

```typescript
import Anthropic from "@anthropic-ai/sdk";

// 20-second timeout
const client = new Anthropic({ timeout: 20 * 1000 });
```

For TypeScript, when using large `max_tokens` without streaming, the SDK dynamically calculates timeouts up to 60 minutes.

### Python: Configure Retries

```python
import anthropic

# Disable retries
client = anthropic.Anthropic(max_retries=0)

# Increase retries for resilient production workloads
client = anthropic.Anthropic(max_retries=5)

# Per-request retry override
message = client.with_options(max_retries=5).messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello"}]
)
```

The SDK retries on these conditions with exponential backoff:
- Connection errors
- HTTP 408 (Request Timeout)
- HTTP 409 (Conflict)
- HTTP 429 (Rate Limited)
- HTTP >= 500 (Server Errors, including 529 Overloaded)

### TypeScript: Configure Retries

```typescript
import Anthropic from "@anthropic-ai/sdk";

// Disable retries
const client = new Anthropic({ maxRetries: 0 });

// Increase retries
const client2 = new Anthropic({ maxRetries: 5 });
```

### Avoid the 10-Minute Timeout with Streaming

The SDK throws `ValueError` if a non-streaming request is expected to take more than 10 minutes. The solution is to use streaming with `get_final_message()`:

```python
import anthropic

client = anthropic.Anthropic()

# This might throw ValueError for very large outputs:
# message = client.messages.create(model="claude-opus-4-6", max_tokens=128000, ...)

# Use streaming instead -- no 10-minute limit
with client.messages.stream(
 model="claude-opus-4-6",
 max_tokens=128000,
 messages=[{"role": "user", "content": "Write a comprehensive report"}]
) as stream:
 message = stream.get_final_message()

print(message.content[0].text)
```

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const stream = client.messages.stream({
 model: "claude-opus-4-6",
 max_tokens: 128000,
 messages: [{ role: "user", content: "Write a comprehensive report" }]
});

const message = await stream.finalMessage();
```

### Recommended Production Configuration

```python
import anthropic
import httpx

client = anthropic.Anthropic(
 max_retries=3,
 timeout=httpx.Timeout(
 300.0, # 5-minute total timeout
 read=30.0, # 30-second read timeout
 write=30.0, # 30-second write timeout
 connect=10.0 # 10-second connect timeout
 )
)
```

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
 maxRetries: 3,
 timeout: 300 * 1000 // 5 minutes
});
```

### Default Values Reference

| Setting | Python Default | TypeScript Default |
|---------|---------------|-------------------|
| Timeout | 10 minutes | 10 minutes |
| Max retries | 2 | 2 |
| Retry conditions | Connection, 408, 409, 429, >=500 | Same |
| Backoff | Exponential | Exponential |

## Prevention

1. **Use streaming for long outputs**: Any request with `max_tokens > 4096` benefits from streaming.
2. **Set appropriate timeouts**: Match your timeout to the expected response time. A 10-second question does not need a 10-minute timeout.
3. **Increase retries in production**: 3-5 retries catches most transient failures without excessive delay.
4. **Use TCP keep-alive**: The SDKs automatically set TCP keep-alive options to detect broken connections.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-sdk-timeout-configuration-customization)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

## Related Guides

- [Claude Streaming Not Working](/claude-streaming-not-working/) -- fix streaming issues that arise from timeout misconfiguration.
- [Claude API Error 500 api_error Fix](/claude-api-error-500-apierror-explained/) -- server errors that retries can recover from.
- [Claude API Error 429 rate_limit_error Fix](/claude-api-error-429-ratelimiterror-explained/) -- rate limit handling works with retry configuration.
- [Claude Python SDK Installation Guide](/claude-python-sdk-installation-guide/) -- install the SDK before configuring timeouts.
- [Claude API Error 529 overloaded_error Fix](/claude-api-error-529-overloadederror-explained/) -- overload errors also benefit from retry configuration.



## Related Articles

- [Claude Timeout — How to Fix It (2026)](/claude-code-timeout-fix/)
- [How to Use Timeout & Budget Workflow (2026)](/claude-code-for-timeout-budget-workflow-tutorial/)
- [Claude Code MCP Timeout: How to Configure Settings](/claude-code-mcp-timeout-settings-configuration-guide/)
- [Fix: Claude Code 2m Bash Timeout](/claude-code-timeout-2m-fix/)
