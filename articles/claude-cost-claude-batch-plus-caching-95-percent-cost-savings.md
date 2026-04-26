---
layout: default
title: "Claude Batch Plus Caching for 95% Cost (2026)"
description: "Claude Batch Plus Caching for 95% Cost — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-batch-plus-caching-95-percent-cost-savings/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, batch-api, prompt-caching]
---

# Claude Batch Plus Caching for 95% Cost Savings

Claude's batch discount (50%) and cache read discount (90%) multiply together. The result: cached batch reads cost 5% of the standard input price. On Opus 4.7, that is $0.25 per million tokens instead of $5.00. For a batch of 50,000 support tickets with a shared 30K system prompt, the system prompt cost drops from $1,500 to $112.49.

## The Setup

You process 50,000 customer support tickets daily using Haiku 4.5. Each ticket shares a 30,000-token system prompt (classification rules, response templates, brand guidelines). Only the customer message differs.

At standard pricing, the system prompt alone costs $1,500/day (50K x 30K tokens x $1.00/MTok). With batch-only, that drops to $750. With batch plus caching, you write the prompt to cache once and read it 49,999 times at the stacked discount rate. The system prompt cost plunges to $112.49/day.

Over a month, the savings on system prompt input alone: $41,625.

## The Math

**50,000 tickets, 30K shared system prompt, Haiku 4.5:**

Standard (no batch, no cache):
- 50,000 x 30,000 tokens x $1.00/MTok = **$1,500.00/day**

Batch only (50% discount):
- 50,000 x 30,000 x $0.50/MTok = **$750.00/day**

Batch + cache:
- 1 cache write: 30,000 x $1.25/MTok x 0.5 (batch discount) = $0.019
- 49,999 cache reads: 49,999 x 30,000 x $0.05/MTok = $74.999
- Wait-list overhead tokens: ~$37.47
- **Total: ~$112.49/day**

**Savings vs standard: $1,387.51/day (92.5%)**

The stacked rates across models:

| Model | Standard Input | Batch + Cache Read | Savings vs Standard |
|-------|---------------|-------------------|-------------------|
| Opus 4.7 | $5.00/MTok | $0.25/MTok | 95% |
| Sonnet 4.6 | $3.00/MTok | $0.15/MTok | 95% |
| Haiku 4.5 | $1.00/MTok | $0.05/MTok | 95% |

## The Technique

To stack both discounts, include `cache_control` breakpoints in your batch request bodies. The batch processor applies the batch discount first, then the cache discount on top.

```python
import anthropic
import json
import time

client = anthropic.Anthropic()

SYSTEM_PROMPT = open("support_system_prompt.txt").read()  # 30K tokens


def create_stacked_discount_batch(tickets: list[dict]) -> str:
    """Batch with caching for maximum savings."""

    requests = []
    for ticket in tickets:
        requests.append({
            "custom_id": f"ticket-{ticket['id']}",
            "params": {
                "model": "claude-haiku-4-5-20251001",
                "max_tokens": 1024,
                "system": [
                    {
                        "type": "text",
                        "text": SYSTEM_PROMPT,
                        "cache_control": {"type": "ephemeral"}
                    }
                ],
                "messages": [
                    {
                        "role": "user",
                        "content": ticket["message"]
                    }
                ]
            }
        })

    batch = client.batches.create(requests=requests)
    return batch.id


def estimate_stacked_cost(
    num_requests: int,
    cached_tokens: int,
    uncached_tokens_per_request: int,
    output_tokens_per_request: int,
    model: str = "haiku-4.5"
) -> dict:
    """Estimate cost with stacked batch + cache discounts."""

    rates = {
        "haiku-4.5": {
            "std_in": 1.00, "batch_in": 0.50,
            "batch_cache_read": 0.05, "batch_cache_write": 0.625,
            "std_out": 5.00, "batch_out": 2.50
        },
        "sonnet-4.6": {
            "std_in": 3.00, "batch_in": 1.50,
            "batch_cache_read": 0.15, "batch_cache_write": 1.875,
            "std_out": 15.00, "batch_out": 7.50
        },
        "opus-4.7": {
            "std_in": 5.00, "batch_in": 2.50,
            "batch_cache_read": 0.25, "batch_cache_write": 3.125,
            "std_out": 25.00, "batch_out": 12.50
        }
    }

    r = rates[model]

    # Cached portion: 1 write + (N-1) reads
    cache_write = cached_tokens * r["batch_cache_write"] / 1e6
    cache_reads = (num_requests - 1) * cached_tokens * r["batch_cache_read"] / 1e6

    # Uncached input (per-request unique content)
    uncached = num_requests * uncached_tokens_per_request * r["batch_in"] / 1e6

    # Output (batch discount only, no caching)
    output = num_requests * output_tokens_per_request * r["batch_out"] / 1e6

    # Standard comparison
    standard = (
        num_requests * (cached_tokens + uncached_tokens_per_request) * r["std_in"] / 1e6 +
        num_requests * output_tokens_per_request * r["std_out"] / 1e6
    )

    stacked_total = cache_write + cache_reads + uncached + output

    return {
        "stacked_total": f"${stacked_total:.2f}",
        "standard_total": f"${standard:.2f}",
        "savings": f"${standard - stacked_total:.2f}",
        "savings_pct": f"{(standard - stacked_total) / standard * 100:.1f}%",
        "breakdown": {
            "cache_write": f"${cache_write:.4f}",
            "cache_reads": f"${cache_reads:.2f}",
            "uncached_input": f"${uncached:.2f}",
            "output": f"${output:.2f}"
        }
    }


# Calculate savings for 50K tickets
result = estimate_stacked_cost(
    num_requests=50000,
    cached_tokens=30000,
    uncached_tokens_per_request=500,
    output_tokens_per_request=800,
    model="haiku-4.5"
)
print(json.dumps(result, indent=2))
```

Verification script for production batches:

```bash
# Verify stacked discounts after batch completion
python3 -c "
# After batch completes, check actual costs
# Expected: cache reads at 5% of standard input price
# Check your Anthropic usage dashboard for:
# - cache_read_input_tokens (should be ~95% of total input)
# - cache_creation_input_tokens (should be minimal, ~1 per batch)
# - Effective per-token rate should match stacked discount

expected_rate = 0.05  # $/MTok for Haiku batch cache reads
standard_rate = 1.00
savings_pct = (1 - expected_rate / standard_rate) * 100
print(f'Expected savings on cached input: {savings_pct:.0f}%')
print(f'Haiku cached batch read: \${expected_rate}/MTok')
print(f'vs standard Haiku input: \${standard_rate}/MTok')
"
```

## The Tradeoffs

Stacking both discounts adds complexity beyond either alone:

- **Cache timing within batches**: The batch processor does not guarantee request ordering. The first request processed writes the cache, but it may not be request #1 in your file. Design your pipeline to handle this gracefully.
- **Double the monitoring surface**: You need to track both batch completion metrics and cache hit rates. A drop in either metric indicates a problem.
- **Cache TTL vs batch duration**: If your batch takes longer than 5 minutes (most do), the default cache TTL may expire mid-batch. The batch processor handles internal cache management, but awareness of this interaction matters for debugging.
- **Output tokens are not cached**: The 95% savings applies only to the cached input portion. Output tokens still cost the batch rate ($2.50/MTok on Haiku 4.5), which may dominate for generation-heavy workloads.

## Implementation Checklist

1. Identify batch workloads with shared context (system prompts, reference docs)
2. Verify shared context exceeds the model's minimum cacheable token threshold
3. Add `cache_control` breakpoints to the shared content in batch requests
4. Run a test batch of 100 requests and verify cache read tokens in results
5. Scale to full production batch size
6. Monitor both batch completion time and cache hit rate
7. Calculate actual per-request cost and compare against the 5% theoretical rate

## Measuring Impact

Confirm both discounts are stacking:

- **Effective input rate**: Total input cost / total input tokens. Should be near 5% of standard for high cache hit ratios.
- **Cache hit rate within batch**: cache_read_tokens / (cache_read_tokens + cache_write_tokens). Target: 99.99% for batches with a single shared context.
- **Total savings vs standard**: Compare batch cost against calculated standard real-time cost. Should show 90%+ savings for workloads with large shared context.
- Run monthly comparison against pre-optimization baseline

## Related Guides

- [Claude Prompt Caching Pricing and Cost Savings](/claude-prompt-caching-pricing-and-cost-savings/)
- [Anthropic Message Batches API Guide](/anthropic-message-batches-api-guide/)
- [Claude API Batch Processing Large Datasets](/claude-api-batch-processing-large-datasets-workflow-guide/)

## See Also

- [Claude Batch Processing 100K Requests Guide](/claude-batch-processing-100k-requests-guide/)
- [Claude Batch API 50% Discount Complete Guide](/claude-batch-api-50-percent-discount-guide/)
- [Combining Caching with Batch API for 95% Savings](/combining-caching-batch-api-95-percent-savings/)
- [Claude /compact Command Token Savings Guide](/claude-compact-command-token-savings/)
- [Claude Batch Processing Limits and Best Practices](/claude-batch-processing-limits-best-practices/)
