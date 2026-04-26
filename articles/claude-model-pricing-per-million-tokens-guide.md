---
layout: default
title: "Claude Model Pricing Per Million Tokens (2026)"
description: "Complete Claude API pricing for Opus 4.7, Sonnet 4.6, and Haiku 4.5 — from $1/MTok to $25/MTok with batch and cache discounts."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-model-pricing-per-million-tokens-guide/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# Claude Model Pricing Per Million Tokens Guide

Claude Opus 4.7 output tokens cost $25.00 per million. Claude Haiku 4.5 output tokens cost $5.00 per million. That 5x difference means a batch of 1,000 code generation requests producing 2,000 tokens each costs $50.00 on Opus or $10.00 on Haiku — a $40.00 gap that compounds to $1,200/month at production scale.

## The Setup

Anthropic prices Claude API usage on a per-token basis with separate rates for input and output tokens. Prices vary by model tier, and additional discounts apply when you use prompt caching or batch processing. Understanding the full pricing matrix prevents overspending on the wrong model or missing available discounts.

This guide covers every current pricing dimension: per-model token rates, cache write/read costs, batch discounts, and special pricing for features like web search and code execution.

## The Math

### Current Model Pricing (Per Million Tokens)

| Feature | Opus 4.7 | Sonnet 4.6 | Haiku 4.5 |
|---------|----------|-----------|-----------|
| Input | $5.00 | $3.00 | $1.00 |
| Output | $25.00 | $15.00 | $5.00 |
| Cache write (5min) | $6.25 | $3.75 | $1.25 |
| Cache write (1hr) | $10.00 | $6.00 | $2.00 |
| Cache read | $0.50 | $0.30 | $0.10 |
| Batch input | $2.50 | $1.50 | $0.50 |
| Batch output | $12.50 | $7.50 | $2.50 |

### Legacy Model Warning

Claude Opus 4.1 costs $15.00/$75.00 per MTok — 3x the current Opus 4.7 rate. If you are still running Opus 4.1, migrating to Opus 4.7 saves 67% on both input and output while gaining a 1M context window (up from 200K) and 128K max output (up from 32K).

### Combined Discounts

The cheapest possible Claude API usage combines batch processing with cached input:
- Standard Opus input: $5.00/MTok
- Batch + cache read: $0.25/MTok (batch halves the rate, cache read is 10% of base)
- **Effective savings: 95%**

At 100M input tokens/month, that is the difference between $500.00 and $25.00.

## The Technique

Build a cost calculator that accounts for all pricing dimensions:

```python
PRICING = {
    "claude-opus-4-7": {
        "input": 5.00, "output": 25.00,
        "cache_write_5m": 6.25, "cache_write_1h": 10.00,
        "cache_read": 0.50,
        "batch_input": 2.50, "batch_output": 12.50,
    },
    "claude-sonnet-4-6": {
        "input": 3.00, "output": 15.00,
        "cache_write_5m": 3.75, "cache_write_1h": 6.00,
        "cache_read": 0.30,
        "batch_input": 1.50, "batch_output": 7.50,
    },
    "claude-haiku-4-5-20251001": {
        "input": 1.00, "output": 5.00,
        "cache_write_5m": 1.25, "cache_write_1h": 2.00,
        "cache_read": 0.10,
        "batch_input": 0.50, "batch_output": 2.50,
    },
}

def calculate_cost(
    model: str,
    input_tokens: int,
    output_tokens: int,
    cached_input_tokens: int = 0,
    cache_write_tokens: int = 0,
    use_batch: bool = False,
    cache_ttl: str = "5m",
) -> dict:
    """Calculate exact API cost for a request configuration."""
    p = PRICING[model]

    if use_batch:
        input_rate = p["batch_input"]
        output_rate = p["batch_output"]
    else:
        input_rate = p["input"]
        output_rate = p["output"]

    cache_read_rate = p["cache_read"]
    cache_write_rate = p[f"cache_write_{cache_ttl}"]

    uncached_input = input_tokens - cached_input_tokens
    input_cost = (uncached_input / 1_000_000) * input_rate
    output_cost = (output_tokens / 1_000_000) * output_rate
    cache_read_cost = (cached_input_tokens / 1_000_000) * cache_read_rate
    cache_write_cost = (cache_write_tokens / 1_000_000) * cache_write_rate

    total = input_cost + output_cost + cache_read_cost + cache_write_cost

    return {
        "model": model,
        "input_cost": round(input_cost, 6),
        "output_cost": round(output_cost, 6),
        "cache_read_cost": round(cache_read_cost, 6),
        "cache_write_cost": round(cache_write_cost, 6),
        "total": round(total, 6),
    }

# Compare: 10K requests, 5K input + 2K output, no caching
for model in PRICING:
    result = calculate_cost(model, 5000 * 10000, 2000 * 10000)
    print(f"{model}: ${result['total']:.2f}")

# Compare: same volume with batch processing
print("\nWith batch processing:")
for model in PRICING:
    result = calculate_cost(model, 5000 * 10000, 2000 * 10000, use_batch=True)
    print(f"{model}: ${result['total']:.2f}")
```

### Additional Costs to Budget For

- **Web search**: $10.00 per 1,000 searches (separate from token costs)
- **Code execution**: Free for first 1,550 hours/month, then $0.05/hour
- **Managed agents**: $0.08/hour runtime + normal token costs
- **Data residency (US-only)**: 10% surcharge on token costs for Opus 4.7 and Opus 4.6

## The Tradeoffs

The cheapest option is not always the best option. Batch processing requires accepting up to 24-hour turnaround -- unsuitable for real-time applications. Prompt caching has minimum token thresholds (4,096 tokens for Opus 4.7 and Haiku 4.5, 1,024 for Sonnet 4.6) and requires consistent prompt prefixes.

Opus 4.7's new tokenizer may use up to 35% more tokens for the same text compared to older models. Factor this into cost comparisons when migrating from legacy models.

Legacy model pricing creates a hidden trap for teams that have not updated their model strings. Claude Opus 4.1 charges $15.00/$75.00 per MTok -- 3x current Opus 4.7 rates. Haiku 3.5 charges $0.80/$4.00, only marginally cheaper than Haiku 4.5 at $1.00/$5.00 while being significantly less capable. Claude 3 Haiku (the oldest) charges $0.25/$1.25 but reaches end-of-life on April 19, 2026. Audit your codebase for hardcoded legacy model IDs and update them to current models to avoid paying premium prices for outdated capabilities.

## Implementation Checklist

1. Export your current API usage from the Anthropic dashboard
2. Categorize requests by model, token volume, and latency requirements
3. Identify requests eligible for batch processing (non-real-time)
4. Identify requests with repeated system prompts eligible for caching
5. Run the cost calculator with your actual volumes to project savings
6. Implement changes starting with the highest-spend category

## Measuring Impact

Track cost per request by model in your monitoring system. Compare your weekly Anthropic invoice against the projected savings from your cost calculator. Key metrics: average cost per request, total monthly spend by model, cache hit rate (target: above 80% for repeated prompts), and batch utilization percentage. Set up billing alerts at 80% of your monthly budget to catch unexpected spikes.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — detailed breakdown of what drives Claude API costs
- [Claude Code Monthly Cost Breakdown](/claude-code-monthly-cost-breakdown-realistic-usage-estimates/) — real-world cost estimates by usage pattern
- [Claude Opus 4.6 vs GPT-4o Comparison](/claude-opus-46-vs-gpt-4o-for-coding-tasks-comparison/) — how Claude pricing compares to competitors
