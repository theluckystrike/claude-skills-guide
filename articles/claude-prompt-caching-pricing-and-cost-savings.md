---
layout: default
title: "Claude Prompt Caching Pricing Guide"
description: "Calculate Claude prompt caching cost savings. Covers pricing per model, cache write vs read costs, 1-hour cache option, and ROI calculations."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-prompt-caching-pricing-and-cost-savings/
reviewed: true
score: 7
categories: [guides]
tags: [claude-api, prompt-caching, pricing, cost-optimization]
geo_optimized: true
---

# Claude Prompt Caching Pricing Guide

Prompt caching reads cost 10% of the base input price. With a large system prompt reused across multiple requests, caching can reduce your total input token costs by up to 90%. This guide shows you how to calculate the savings.

## Quick Fix

Cache reads cost 0.1x base input price. If you reuse the same prompt content 10+ times within 5 minutes, caching saves money immediately:

| Model | Base Input | Cache Write (5m) | Cache Read | Savings per Read |
|-------|-----------|-----------------|------------|-----------------|
| Opus 4.6 | $5/MTok | $6.25/MTok | $0.50/MTok | 90% |
| Sonnet 4.6 | $3/MTok | $3.75/MTok | $0.30/MTok | 90% |
| Haiku 4.5 | $1/MTok | $1.25/MTok | $0.10/MTok | 90% |

## Full Solution

### Cache Pricing Breakdown

There are two cache duration options with different write costs:

**5-Minute Cache (Default)**
- Write cost: 1.25x base input price
- Read cost: 0.1x base input price
- TTL refreshes on each cache hit

**1-Hour Cache**
- Write cost: 2x base input price
- Read cost: 0.1x base input price
- Better for batch workloads with longer gaps between requests

### Pricing Table (per Million Tokens)

| Model | Base Input | 5m Write | 1h Write | Cache Read | Output |
|-------|-----------|----------|----------|-----------|--------|
| Claude Opus 4.6 | $5.00 | $6.25 | $10.00 | $0.50 | $25.00 |
| Claude Sonnet 4.6 | $3.00 | $3.75 | $6.00 | $0.30 | $15.00 |
| Claude Haiku 4.5 | $1.00 | $1.25 | $2.00 | $0.10 | $5.00 |

### Break-Even Calculation

The cache write costs more than a regular input. You need enough cache reads to recoup the write cost:

**Formula**: Break-even reads = cache_write_cost / (base_input_cost - cache_read_cost)

For 5-minute cache on Sonnet 4.6:
- Write cost: $3.75 per MTok
- Base input: $3.00 per MTok
- Cache read: $0.30 per MTok
- Break-even: $3.75 / ($3.00 - $0.30) = 1.39 reads

**You break even after just 2 cache reads.** Every read after that saves 90%.

### Cost Savings Example

A chatbot with a 5,000-token system prompt handling 100 requests per 5-minute window on Sonnet 4.6:

**Without caching**:
- 100 requests x 5,000 tokens = 500,000 input tokens
- Cost: 0.5 MTok x $3.00 = $1.50

**With caching**:
- 1 cache write: 5,000 tokens x $3.75/MTok = $0.019
- 99 cache reads: 495,000 tokens x $0.30/MTok = $0.149
- 100 uncached question tokens: ~50,000 tokens x $3.00/MTok = $0.15
- Total: $0.318

**Savings: 79%** ($1.50 vs $0.318)

### ITPM Throughput Boost

Cache-read tokens do NOT count towards your Input Tokens Per Minute (ITPM) rate limit. With an 80% cache hit rate and a 2,000,000 ITPM limit:

- Effective throughput: 2,000,000 / (1 - 0.80) = 10,000,000 tokens per minute

This means caching not only saves money but gives you 5x more effective throughput.

### Implementation

```python
import anthropic

client = anthropic.Anthropic()

SYSTEM_PROMPT = """Your large, reusable system prompt here...
[4096+ tokens for Opus 4.6, 1024+ tokens for Sonnet 4.5]
"""

response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 cache_control={"type": "ephemeral"},
 system=SYSTEM_PROMPT,
 messages=[{"role": "user", "content": "User question here"}]
)

# Monitor costs
usage = response.usage
print(f"Input tokens: {usage.input_tokens} @ base price")
print(f"Cache write: {usage.cache_creation_input_tokens} @ 1.25x")
print(f"Cache read: {usage.cache_read_input_tokens} @ 0.1x")
```

### When to Use 1-Hour Cache

Use the 1-hour cache when requests are spaced more than 5 minutes apart:

```python
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 cache_control={"type": "ephemeral", "ttl": "1h"},
 system=SYSTEM_PROMPT,
 messages=[{"role": "user", "content": "Question?"}]
)
```

The 1-hour write costs 2x base (vs 1.25x for 5-minute), so you need more reads to break even:

- Break-even for 1-hour on Sonnet 4.6: $6.00 / ($3.00 - $0.30) = 2.22, so **3 reads**.

### Batch API + Caching

The Batch API already gives 50% off input/output. Adding caching gives additional savings on the discounted price:

- Batch input for Sonnet 4.6: $1.50/MTok (50% off $3.00)
- Batch + cache read: $0.15/MTok (10% of $1.50)
- Total savings vs standard: 95%

Use the 1-hour cache TTL with batches since batch processing can take up to an hour.

## Prevention

1. **Start with automatic caching**: Add `cache_control: {"type": "ephemeral"}` to every request with a reusable system prompt.
2. **Monitor cache metrics**: Track `cache_creation_input_tokens` and `cache_read_input_tokens` in every response.
3. **Match TTL to usage pattern**: Use 5-minute for real-time chat, 1-hour for batch processing.
4. **Right-size your model**: Sonnet 4.5 has a 1,024 token minimum vs Opus 4.6's 4,096 -- smaller prompts can cache on Sonnet but not Opus.

---

---

<div class="mastery-cta">

Claude Code is expensive because it's reading your entire codebase every time. A CLAUDE.md tells it what matters upfront — architecture, conventions, boundaries. Less scanning. Fewer wrong turns. Lower bills.

I spend $200+/month on Claude subs. These configs are how I keep the output worth the cost.

**[Get the configs →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-perf&utm_campaign=claude-prompt-caching-pricing-and-cost-savings)**

$99 once. Pays for itself in saved tokens within a week.

</div>

## Related Guides

- [Claude Prompt Caching API Guide](/claude-prompt-caching-api-guide/) -- implementation guide with code examples.
- [Claude Prompt Caching Not Working](/claude-prompt-caching-not-working/) -- troubleshoot silent caching failures.
- [Claude API Error 429 rate_limit_error Fix](/claude-api-error-429-ratelimiterror-explained/) -- caching boosts your effective ITPM throughput.
- [Claude Streaming API Guide](/claude-streaming-api-guide/) -- combine streaming with caching for optimal performance.
- [Claude Python SDK Getting Started](/claude-python-sdk-getting-started-example/) -- basic SDK setup before implementing caching.



## Related Articles

- [Claude Code For Spot Instance — Complete Developer Guide](/claude-code-for-spot-instance-cost-savings-workflow/)
- [Claude Prompt Caching Saves 90% on Input Costs](/claude-prompt-caching-saves-90-percent-input-costs/)
- [Claude Caching for Multi-Turn Conversations](/claude-caching-multi-turn-conversations/)
- [Claude Prompt Caching Implementation Tutorial](/claude-prompt-caching-implementation-tutorial/)
- [When NOT to Use Claude Prompt Caching](/when-not-to-use-claude-prompt-caching/)
- [Claude Batch Plus Caching for 95% Cost Savings](/claude-batch-plus-caching-95-percent-cost-savings/)
- [Per-Agent Cost Attribution in Claude Systems](/per-agent-cost-attribution-claude-systems/)
- [Prompt Caching Break-Even Calculator for Claude](/prompt-caching-break-even-calculator-claude/)
- [When NOT to Use Claude Prompt Caching](/when-not-to-use-claude-prompt-caching/)
- [How to limit Claude Code to specific directories (cost savings)](/limit-claude-code-specific-directories-cost-savings/)
