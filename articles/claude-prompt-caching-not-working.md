---
layout: default
title: "Claude Prompt Caching Not Working Fix"
description: "Fix Claude prompt caching issues. Covers minimum token thresholds, cache invalidation, breakpoint placement, and monitoring cache hit rates."
date: 2026-04-15
last_modified_at: 2026-04-15
author: "Claude Code Guides"
permalink: /claude-prompt-caching-not-working/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-api, sdk-python, prompt-caching, cost-optimization]
---

# Claude Prompt Caching Not Working Fix

Prompt caching can cut your Claude API costs by up to 90% on repeated content, but it silently does nothing if your cached content is too short or your breakpoints are misconfigured. This guide covers every reason caching fails.

## The Error

Prompt caching does not produce an error when it fails. Instead, your `usage` response shows zero cached tokens:

```json
{
  "usage": {
    "input_tokens": 5000,
    "output_tokens": 200,
    "cache_creation_input_tokens": 0,
    "cache_read_input_tokens": 0
  }
}
```

If `cache_creation_input_tokens` and `cache_read_input_tokens` are both 0, caching is not working.

## Quick Fix

1. Verify your cached content meets the minimum token threshold for your model.
2. Use automatic caching (`cache_control` at top level) for the simplest setup.
3. Check that tool definitions have not changed between requests (this invalidates all caches).

## What Causes This

Prompt caching fails silently for several reasons:

- **Content too short**: Each model has a minimum cacheable length. Opus 4.6 requires at least 4,096 tokens. Sonnet 4.5 requires only 1,024 tokens.
- **Cache invalidation**: Changing tool definitions invalidates all cached content. Changing thinking parameters invalidates cached messages.
- **Wrong breakpoint placement**: Cached content must be at the beginning of the prompt. Moving cached blocks breaks the cache.
- **Cache expiry**: The default 5-minute TTL means caches expire if not hit within 5 minutes.

## Full Solution

### Use Automatic Caching (Recommended)

The simplest approach -- add `cache_control` at the top level and the system places the breakpoint automatically on the last cacheable block:

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=1024,
    cache_control={"type": "ephemeral"},
    system="You are a legal expert. Here is the full text of the contract...[4000+ tokens of content]",
    messages=[{"role": "user", "content": "Summarize the key terms."}]
)

# Check cache usage
print(f"Cache created: {response.usage.cache_creation_input_tokens} tokens")
print(f"Cache read: {response.usage.cache_read_input_tokens} tokens")
```

### Use Explicit Breakpoints

Place `cache_control` on specific content blocks. You can use up to 4 breakpoints per request:

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "You are a legal expert specializing in contract law...[large system prompt]",
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[
        {"role": "user", "content": "What are the termination clauses?"}
    ]
)
```

### Minimum Cacheable Length by Model

Your cached content must meet these minimums or caching silently does nothing:

| Model | Minimum Tokens |
|-------|---------------|
| Claude Opus 4.6 | 4,096 |
| Claude Opus 4.5 | 4,096 |
| Claude Haiku 4.5 | 4,096 |
| Claude Sonnet 4.6 | 2,048 |
| Claude Haiku 3.5 | 2,048 |
| Claude Sonnet 4.5 | 1,024 |
| Claude Opus 4.1 | 1,024 |
| Claude Opus 4 | 1,024 |
| Claude Sonnet 4 | 1,024 |

### Avoid Cache Invalidation

Tool definition changes invalidate ALL cached content. Keep your tools stable across requests:

```python
# Define tools ONCE and reuse
TOOLS = [
    {
        "name": "get_weather",
        "description": "Get the weather for a location",
        "input_schema": {
            "type": "object",
            "properties": {"location": {"type": "string"}},
            "required": ["location"]
        }
    }
]

# Both requests will share the cache because tools are identical
response1 = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    cache_control={"type": "ephemeral"},
    tools=TOOLS,
    messages=[{"role": "user", "content": "What's the weather in NYC?"}]
)

response2 = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    cache_control={"type": "ephemeral"},
    tools=TOOLS,  # Same tools -- cache hit!
    messages=[{"role": "user", "content": "What's the weather in LA?"}]
)
```

### Use 1-Hour Cache for Extended Workflows

For batch processing or extended thinking tasks, use the 1-hour TTL to improve hit rates:

```python
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=4096,
    cache_control={"type": "ephemeral", "ttl": "1h"},
    system="...[large system prompt]...",
    messages=[{"role": "user", "content": "Analyze this data"}]
)
```

The 1-hour cache costs 2x the base input price to write but 0.1x to read, making it worthwhile for workloads with many reads.

## Prevention

1. **Monitor cache hit rates**: Always check `cache_creation_input_tokens` and `cache_read_input_tokens` in every response.
2. **Keep tools stable**: Define tools once and pass the same definition across all requests.
3. **Place cached content first**: System prompts and tool definitions at the start of the prompt are the best cache candidates.
4. **Right-size your model**: If your system prompt is 2,000 tokens, use Sonnet 4.5 or 4 (1,024 minimum) rather than Opus 4.6 (4,096 minimum).

---

---

<div class="mastery-cta">

**You just spent mass time debugging this.**

What if Claude Code got it right the first time? The developers shipping fastest aren't smarter — they have better CLAUDE.md files. One file tells Claude exactly how your stack works so it stops guessing and starts engineering.

**[See what prevents these errors →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-prompt-caching-not-working)**

$99 once. Yours forever. 47/500 founding spots left.

</div>

## Related Guides

- [Claude Prompt Caching API Guide](/claude-prompt-caching-api-guide/) -- complete guide to implementing prompt caching.
- [Claude Prompt Caching Pricing Guide](/claude-prompt-caching-pricing-and-cost-savings/) -- calculate your savings with caching.
- [Claude API Error 429 rate_limit_error Fix](/claude-api-error-429-ratelimiterror-explained/) -- cached tokens do not count toward ITPM limits.
- [Claude Extended Thinking API Guide](/claude-extended-thinking-api-guide/) -- changing thinking params invalidates message caches.
- [Claude Python SDK Getting Started](/claude-python-sdk-getting-started-example/) -- set up the SDK before implementing caching.
