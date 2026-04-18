---
layout: default
title: "Claude Prompt Caching Saves 90% on Input Costs"
description: "Cut Claude API input token costs from $5.00 to $0.50 per million tokens with prompt caching. Real break-even math included."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-prompt-caching-saves-90-percent-input-costs/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, prompt-caching]
render_with_liquid: false
---

# Claude Prompt Caching Saves 90% on Input Costs

A single cached read on Claude Opus 4.7 costs $0.50 per million tokens. Without caching, that same input costs $5.00 per million tokens. That is a 90% reduction on every repeated input token, and it requires roughly five lines of code to activate.

## The Setup

You run a customer support bot powered by Claude Sonnet 4.6. Your system prompt is 50,000 tokens of product documentation, tone guidelines, and few-shot examples. Every customer conversation sends that full prompt to the API.

At 1,000 conversations per day, you are paying $150.00 daily just for the system prompt input tokens alone. That is $4,500 per month before you count the actual customer messages or output tokens.

With prompt caching, that same system prompt gets written to cache once and read 999 times at 10% of the base price. Your daily system prompt cost drops to $15.17. Monthly savings: $4,045.

## The Math

**Without caching (Sonnet 4.6, 50K system prompt, 1,000 calls/day):**

- Daily input cost: 1,000 calls x 50,000 tokens x $3.00/MTok = $150.00/day
- Monthly: $4,500.00

**With 5-minute caching:**

- 1 cache write: 50,000 tokens x $3.75/MTok = $0.19
- 999 cache reads: 999 x 50,000 tokens x $0.30/MTok = $14.99
- Daily total: $15.17
- Monthly: $455.00

**Savings: $4,045 per month (89.9%)**

The cache write costs 1.25x the base input price ($3.75 vs $3.00 per MTok for Sonnet 4.6). But each cache read costs just 0.1x the base price ($0.30 vs $3.00). The write pays for itself after a single read.

## The Technique

Prompt caching works by adding `cache_control` breakpoints to your message content. The API caches everything up to that breakpoint and serves it from memory on subsequent requests.

Here is a Python implementation using the Anthropic SDK:

```python
import anthropic

client = anthropic.Anthropic()

# Your large system prompt (must be >= 1,024 tokens for Sonnet 4.6)
system_prompt = open("system_prompt.txt").read()

def query_with_cache(user_message: str) -> str:
    response = client.messages.create(
        model="claude-sonnet-4-6-20250929",
        max_tokens=4096,
        system=[
            {
                "type": "text",
                "text": system_prompt,
                "cache_control": {"type": "ephemeral"}
            }
        ],
        messages=[
            {"role": "user", "content": user_message}
        ]
    )

    # Check cache performance in response headers
    usage = response.usage
    print(f"Cache read tokens: {usage.cache_read_input_tokens}")
    print(f"Cache write tokens: {usage.cache_creation_input_tokens}")

    return response.content[0].text
```

The `cache_control` with `type: "ephemeral"` sets a 5-minute TTL that refreshes automatically each time the cache is hit. For workloads with gaps longer than 5 minutes between calls, use the 1-hour cache by specifying the appropriate header, though this costs 2.0x the base input price for writes ($6.00/MTok on Sonnet 4.6).

Key implementation details:

- Place `cache_control` breakpoints at the end of your static content sections
- You can set up to 4 breakpoints per request
- The content before each breakpoint gets cached as a prefix
- Minimum cacheable size: 1,024 tokens for Sonnet 4.6, 4,096 tokens for Opus 4.7 and Haiku 4.5

Monitor your cache hit rate by checking `cache_read_input_tokens` vs `cache_creation_input_tokens` in every response. A healthy system should show cache reads on 95%+ of requests.

## The Tradeoffs

Caching does not help in these situations:

- **Unique prompts**: If every request has a completely different system prompt, there is nothing to cache. The 1.25x write cost becomes pure overhead.
- **Low-volume endpoints**: If you make fewer than 2 requests within a 5-minute window, the cache expires before it pays off.
- **Small prompts**: Below the minimum token threshold (1,024 for Sonnet, 4,096 for Opus), caching simply does not activate.
- **Cache isolation**: Since February 2026, caches are isolated per workspace, not per organization. A prompt cached in one workspace cannot be read from another.

For workloads with gaps between requests exceeding 5 minutes, consider the 1-hour cache TTL. It costs 2.0x the base input price for writes ($6.00/MTok on Sonnet 4.6 vs $3.75/MTok for the 5-minute cache) but survives idle periods up to 60 minutes. The break-even point: if more than 20% of your inter-request gaps exceed 5 minutes, the 1-hour cache saves more overall. On Opus 4.7, the 1-hour cache write costs $10.00/MTok vs $6.25/MTok for 5-minute, but a single avoided re-write of 50K tokens saves $0.3125 ($6.25/MTok x 50K) -- recovered with just 1 additional cache read at $0.025.

You can also stack caching with batch processing for the absolute lowest cost. Batch processing halves the base rate, and cache reads are 10% of the base rate. On batch Opus 4.7, cached reads cost just $0.25/MTok -- 95% less than standard uncached input at $5.00/MTok. A pipeline processing 50M cached input tokens monthly drops from $250.00 (standard uncached) to $12.50 (batch + cache read).

## Implementation Checklist

1. Identify your largest static prompt components (system prompts, few-shot examples, documentation)
2. Verify the static content exceeds the minimum cacheable token count for your model
3. Add `cache_control` breakpoints to the end of each static content block
4. Deploy and monitor `cache_read_input_tokens` in response usage data
5. Calculate your actual cache hit rate: reads / (reads + writes)
6. If hit rate is below 80%, investigate request timing patterns
7. Consider 1-hour cache if requests are spaced more than 5 minutes apart

## Measuring Impact

Track these metrics before and after enabling caching:

- **Cache hit rate**: `cache_read_input_tokens / total_input_tokens` per hour
- **Cost per request**: Compare your daily API bill divided by request count
- **Break-even verification**: Confirm your write-to-read ratio exceeds 1:1 for 5-minute cache or 1:2 for 1-hour cache
- Use the Anthropic dashboard usage tab to compare week-over-week input token costs

## Related Guides

- [Claude Prompt Caching Pricing and Cost Savings](/claude-prompt-caching-pricing-and-cost-savings/)
- [Claude API Prompt Caching Performance Optimization](/claude-api-prompt-caching-performance-optimization-guide/)
- [Claude Code for Varnish Cache Workflow](/claude-code-for-varnish-cache-workflow-tutorial/)
