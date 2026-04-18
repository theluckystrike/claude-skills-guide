---
layout: default
title: "How Claude Cache Reads Cost $0.50 vs $5.00"
description: "Claude cache reads cost 10% of standard input price. Opus 4.7 drops from $5.00 to $0.50 per million tokens on every cache hit."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-cache-reads-cost-050-vs-500/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, prompt-caching]
render_with_liquid: false
---

# How Claude Cache Reads Cost $0.50 vs $5.00

Every time Claude reads from cache instead of processing raw input, you pay $0.50 per million tokens on Opus 4.7 instead of $5.00. That 10x price difference is the single largest cost reduction lever available in the Anthropic API, and most teams never activate it.

## The Setup

You are building a document analysis pipeline. Each request sends a 100,000-token reference document plus a short query. You process 5 queries against the same document in sequence.

Without caching, you pay for 500,000 input tokens at full price. With caching, you pay for one cache write at 1.25x and four cache reads at 0.1x. The total drops from $2.50 to $0.825 -- a 67% reduction on Opus 4.7. That is Anthropic's own published example.

## The Math

**Anthropic's verified example: 100K cached tokens, 5 requests, Opus 4.7**

Without caching:
- 5 requests x 100,000 tokens x $5.00/MTok = $2.50

With 5-minute caching:
- 1 cache write: 100,000 tokens x $6.25/MTok = $0.625
- 4 cache reads: 4 x 100,000 tokens x $0.50/MTok = $0.20
- Total: $0.825

**Savings: $1.675 (67%)**

The pricing structure across all models follows the same 0.1x multiplier for reads:

| Model | Standard Input | Cache Read | Savings |
|-------|---------------|------------|---------|
| Opus 4.7 | $5.00/MTok | $0.50/MTok | 90% |
| Sonnet 4.6 | $3.00/MTok | $0.30/MTok | 90% |
| Haiku 4.5 | $1.00/MTok | $0.10/MTok | 90% |

## The Technique

The key to maximizing cache reads is structuring your requests so the cacheable prefix remains identical across calls. Any change in the cached prefix -- even a single character -- invalidates the cache and triggers a new write.

```python
import anthropic
import json

client = anthropic.Anthropic()

def analyze_document(document: str, queries: list[str]) -> list[str]:
    """Send multiple queries against the same cached document."""
    results = []

    for query in queries:
        response = client.messages.create(
            model="claude-opus-4-7-20250415",
            max_tokens=2048,
            system=[
                {
                    "type": "text",
                    "text": document,  # This gets cached after first call
                    "cache_control": {"type": "ephemeral"}
                }
            ],
            messages=[
                {"role": "user", "content": query}
            ]
        )

        usage = response.usage
        cost_type = "WRITE" if usage.cache_creation_input_tokens > 0 else "READ"
        cached_tokens = (
            usage.cache_read_input_tokens or
            usage.cache_creation_input_tokens
        )
        print(f"[{cost_type}] Cached: {cached_tokens} tokens")

        results.append(response.content[0].text)

    return results

# Usage
document = open("contract.txt").read()  # 100K tokens
queries = [
    "What are the payment terms?",
    "List all liability clauses.",
    "Summarize termination conditions.",
    "What are the renewal options?",
    "Identify any non-compete provisions."
]

answers = analyze_document(document, queries)
```

The first call triggers a cache write at $6.25/MTok for Opus 4.7. The remaining four calls hit the cache at $0.50/MTok. Total input cost for 100K tokens across 5 queries: $0.825 instead of $2.50.

Three rules for maximizing cache read ratio:

1. **Put static content first.** The cache is a prefix cache. Only content at the beginning of the message sequence, up to a `cache_control` breakpoint, gets cached.
2. **Keep the prefix byte-identical.** Do not inject timestamps, request IDs, or other per-request values into cached content.
3. **Pace your requests.** The default TTL is 5 minutes, refreshed on each hit. If you have bursts with gaps exceeding 5 minutes, consider the 1-hour cache (2.0x write cost, same 0.1x read cost).

## The Tradeoffs

Cache reads deliver 90% savings only when the cached content stays identical. These scenarios reduce or eliminate the benefit:

- **Dynamic system prompts**: If you inject user-specific data into the system prompt, each variation creates a separate cache entry. The write cost accumulates with no reads.
- **Infrequent access**: With the default 5-minute TTL, a prompt used once per hour gets written 12 times a day with zero reads. Each write costs 1.25x base, making it 25% more expensive than no caching at all.
- **Short prompts on Opus/Haiku**: The 4,096-token minimum means prompts under that threshold cannot be cached regardless of frequency.

For maximum savings, combine cache reads with batch processing. Batch mode halves the base input price (Opus 4.7 drops from $5.00 to $2.50/MTok), and cache reads are 10% of the base price ($0.50/MTok standard, $0.25/MTok batch). This combination achieves a 95% reduction compared to uncached standard pricing. For 100M cached input tokens per month on batch Opus, the cost drops from $500.00 (uncached standard) to $25.00 (batch + cache read). The prerequisite is that your workload can tolerate the up-to-24-hour batch processing window and that your cached prefix remains identical across batch requests.

## Implementation Checklist

1. Audit your API calls for repeated input content longer than your model's minimum cache threshold
2. Separate static content (documentation, rules, examples) from dynamic content (user queries)
3. Place all static content in the system message with a `cache_control` breakpoint
4. Log `cache_read_input_tokens` and `cache_creation_input_tokens` from every response
5. Alert if cache read ratio drops below 90% during business hours
6. Review cache write frequency weekly to identify wasted writes

## Measuring Impact

Compare your input token costs for the week before and after enabling caching:

- **Target metric**: Cache read ratio above 90% (reads / total cached interactions)
- **Dollar validation**: Input cost per 1,000 requests should drop by 80-90%
- **Anomaly detection**: A sudden spike in `cache_creation_input_tokens` means your prefix is changing unexpectedly
- Export usage data from the Anthropic console and calculate effective input price per million tokens

Calculate your effective per-token rate as a sanity check: divide your total daily input spend by total input tokens processed. With healthy caching on Opus 4.7, this number should be well below $1.00/MTok (closer to $0.50-$0.70/MTok depending on cache hit rate). If it is above $3.00/MTok, your caching is not activating properly -- investigate minimum token thresholds and prefix consistency.

## Related Guides

- [Claude Prompt Caching Pricing and Cost Savings](/claude-prompt-caching-pricing-and-cost-savings/)
- [Claude API Prompt Caching Performance Optimization](/claude-api-prompt-caching-performance-optimization-guide/)
- [Claude Code for Varnish Cache Workflow](/claude-code-for-varnish-cache-workflow-tutorial/)
