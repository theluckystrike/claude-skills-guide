---
layout: default
title: "Claude Prompt Caching API Guide (2026)"
description: "Implement Claude prompt caching to cut API costs by 90%. Covers automatic caching, explicit breakpoints, cache lifetime, and monitoring hit rates."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-prompt-caching-api-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-api, sdk-python, prompt-caching, cost-optimization]
geo_optimized: true
---

# Claude Prompt Caching API Guide

Prompt caching lets you cache repeated portions of your prompts so the API reads them from cache instead of reprocessing. Cache reads cost 10% of the base input token price. This guide shows you how to implement it.

## Quick Fix

Add one line to enable automatic caching:

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 cache_control={"type": "ephemeral"}, # Enable automatic caching
 system="Your large system prompt here...",
 messages=[{"role": "user", "content": "Question?"}]
)
```

## What You Need

- Anthropic Python or TypeScript SDK
- A prompt with cacheable content that exceeds the model's minimum token threshold

## Full Solution

### Method 1: Automatic Caching (Recommended)

Add `cache_control` at the top level. The system automatically places the breakpoint on the last cacheable block:

```python
import anthropic

client = anthropic.Anthropic()

# Large system prompt that benefits from caching
SYSTEM_PROMPT = """You are a legal expert. Here is the full text of the contract...
[Insert 4000+ tokens of contract text here]
"""

# First request: creates the cache
response1 = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=1024,
 cache_control={"type": "ephemeral"},
 system=SYSTEM_PROMPT,
 messages=[{"role": "user", "content": "What are the termination clauses?"}]
)
print(f"Cache created: {response1.usage.cache_creation_input_tokens} tokens")

# Second request: reads from cache (10% cost)
response2 = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=1024,
 cache_control={"type": "ephemeral"},
 system=SYSTEM_PROMPT,
 messages=[{"role": "user", "content": "What is the payment schedule?"}]
)
print(f"Cache hit: {response2.usage.cache_read_input_tokens} tokens")
```

### Method 2: Explicit Cache Breakpoints

Place `cache_control` on specific content blocks for precise control. Up to 4 breakpoints per request:

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 system=[
 {
 "type": "text",
 "text": "You are a legal expert...[large prompt]...",
 "cache_control": {"type": "ephemeral"} # Breakpoint 1
 }
 ],
 messages=[
 {
 "role": "user",
 "content": [
 {
 "type": "text",
 "text": "[Large document to analyze]...",
 "cache_control": {"type": "ephemeral"} # Breakpoint 2
 }
 ]
 }
 ]
)
```

### Cache Lifetime Options

Choose between 5-minute and 1-hour cache durations:

```python
# Default: 5-minute cache (1.25x base input to write, 0.1x to read)
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 cache_control={"type": "ephemeral"},
 system="...",
 messages=[...]
)

# 1-hour cache (2x base input to write, 0.1x to read)
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 cache_control={"type": "ephemeral", "ttl": "1h"},
 system="...",
 messages=[...]
)
```

Use 1-hour caching for batch processing or extended thinking tasks where the same context is used across many requests over a longer period.

### Minimum Token Thresholds

Your cached content must meet these minimums for the cache to activate:

| Model | Minimum Tokens |
|-------|---------------|
| Claude Opus 4.6, Opus 4.5, Haiku 4.5 | 4,096 |
| Claude Sonnet 4.6, Haiku 3.5 | 2,048 |
| Claude Sonnet 4.5, Opus 4.1, Opus 4, Sonnet 4 | 1,024 |

### What Can Be Cached

- Tool definitions
- System messages
- Text messages
- Images and documents (PDFs)
- Tool use and tool result blocks

What cannot be cached: thinking blocks directly, sub-content blocks, empty text blocks.

### TypeScript Example

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const response = await client.messages.create({
 model: "claude-sonnet-4-6",
 max_tokens: 1024,
 cache_control: { type: "ephemeral" },
 system: "Your large system prompt...",
 messages: [{ role: "user", content: "Question?" }]
});

console.log(`Cache created: ${response.usage.cache_creation_input_tokens}`);
console.log(`Cache read: ${response.usage.cache_read_input_tokens}`);
```

### Monitor Cache Hit Rates

Always check the usage fields to verify caching is working:

```python
response = client.messages.create(...)

usage = response.usage
print(f"Input tokens: {usage.input_tokens}")
print(f"Cache write: {usage.cache_creation_input_tokens}")
print(f"Cache read: {usage.cache_read_input_tokens}")

if usage.cache_read_input_tokens > 0:
 total_input = usage.input_tokens + usage.cache_read_input_tokens
 hit_rate = usage.cache_read_input_tokens / total_input * 100
 print(f"Cache hit rate: {hit_rate:.1f}%")
```

### Cache Invalidation Rules

Understanding what invalidates the cache prevents unexpected cache misses:

1. **Tool definitions change**: Invalidates ALL cached content.
2. **Thinking parameters change**: Invalidates cached messages (but not system prompts or tools).
3. **Content before breakpoint changes**: Any change in content before the cache breakpoint invalidates the cache.
4. **Cache expires**: 5 minutes (default) or 1 hour. The TTL refreshes on each cache read.

## Prevention

1. **Start with automatic caching**: It handles breakpoint placement for you. Switch to explicit breakpoints only when you need fine-grained control.
2. **Cache stable content first**: System prompts and tool definitions are ideal candidates because they rarely change.
3. **Monitor every response**: Check `cache_creation_input_tokens` and `cache_read_input_tokens` to verify caching is active.
4. **Keep tools stable**: Define tools once and reuse the same definitions across all requests.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-prompt-caching-api-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>



**Know your costs →** Use our [Claude Code Cost Calculator](/calculator/) to estimate your monthly spend.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Prompt Caching Not Working](/claude-prompt-caching-not-working/) -- troubleshoot when caching silently fails.
- [Claude Prompt Caching Pricing Guide](/claude-prompt-caching-pricing-and-cost-savings/) -- calculate your cost savings.
- [Claude API Error 429 rate_limit_error Fix](/claude-api-error-429-ratelimiterror-explained/) -- cache-read tokens do not count toward ITPM limits.
- [Claude Extended Thinking API Guide](/claude-extended-thinking-api-guide/) -- use caching with extended thinking.
- [Claude Python SDK Getting Started](/claude-python-sdk-getting-started-example/) -- basic SDK setup before implementing caching.



## Related Articles

- [Claude Code API Response Caching Guide](/claude-code-api-response-caching-guide/)
- [Combining Caching with Batch API for 95% Savings](/combining-caching-batch-api-95-percent-savings/)
- [Prompt Compression Techniques for Claude API](/prompt-compression-techniques-claude-api/)
