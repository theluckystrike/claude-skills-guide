---
layout: default
title: "Combining Caching with Batch API (2026)"
description: "Claude Code resource: combining Caching with Batch API — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /combining-caching-batch-api-95-percent-savings/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, prompt-caching, batch-api]
---

# Combining Caching with Batch API for 95% Savings

Claude's batch discount (50%) and cache read discount (90%) stack multiplicatively. The combined rate is 5% of standard input pricing. On Opus 4.7, that takes cached input from $5.00/MTok to $0.25/MTok. For a 10,000-request batch with 80K shared context, that drops the input cost from $4,000 to $200.

## The Setup

You are running a batch evaluation pipeline: 10,000 code samples, each analyzed against an 80,000-token rubric and style guide. The rubric is identical across all 10,000 requests. Only the code sample (roughly 2,000 tokens) differs per request.

Without any discounts, the shared context alone costs $4,000 on Opus 4.7. Batch processing cuts that to $2,000. But adding prompt caching to the batch drops it to $200.48 -- because 9,999 of the 10,000 requests read the rubric from cache at the stacked batch + cache rate.

## The Math

**10,000 batch requests, 80K shared context, Opus 4.7:**

Standard (no batch, no cache):
- 10,000 x 80,000 tokens x $5.00/MTok = $4,000.00

Batch only (50% discount):
- 10,000 x 80,000 tokens x $2.50/MTok = $2,000.00

Batch + cache (stacked 5% of standard):
- 1 cache write: 80,000 x $6.25/MTok x 0.5 (batch) = $0.25
- 9,999 cache reads: 9,999 x 80,000 x $0.25/MTok = $199.98
- **Total: $200.23**

**Savings vs standard: $3,799.77 (95%)**

The stacked rate per model for cached batch reads:

| Model | Standard Input | Batch + Cache Read | Effective Rate |
|-------|---------------|-------------------|----------------|
| Opus 4.7 | $5.00/MTok | $0.25/MTok | 5% |
| Sonnet 4.6 | $3.00/MTok | $0.15/MTok | 5% |
| Haiku 4.5 | $1.00/MTok | $0.05/MTok | 5% |

## The Technique

To combine caching with batching, you include `cache_control` breakpoints in your batch request bodies just as you would in real-time requests. The batch processor respects cache breakpoints and applies both discounts.

```python
import anthropic
import json

client = anthropic.Anthropic()

def create_cached_batch(
    shared_context: str,
    items: list[dict],  # Each has "id" and "content"
    model: str = "claude-opus-4-7-20250415"
) -> str:
    """Create a batch with caching on shared context."""

    requests = []
    for item in items:
        requests.append({
            "custom_id": item["id"],
            "params": {
                "model": model,
                "max_tokens": 2048,
                "system": [
                    {
                        "type": "text",
                        "text": shared_context,
                        "cache_control": {"type": "ephemeral"}
                    }
                ],
                "messages": [
                    {
                        "role": "user",
                        "content": item["content"]
                    }
                ]
            }
        })

    # Write the JSONL file for batch submission
    batch_file = "batch_requests.jsonl"
    with open(batch_file, "w") as f:
        for req in requests:
            f.write(json.dumps(req) + "\n")

    # Create the batch
    batch = client.batches.create(
        requests=requests
    )

    print(f"Batch ID: {batch.id}")
    print(f"Status: {batch.processing_status}")
    print(f"Total requests: {len(requests)}")

    return batch.id

# Usage
rubric = open("code_review_rubric.txt").read()  # 80K tokens

code_samples = [
    {"id": f"sample_{i}", "content": f"Review this code:\n{code}"}
    for i, code in enumerate(load_code_samples())
]

batch_id = create_cached_batch(rubric, code_samples[:10000])
```

To poll for batch completion and retrieve results:

```python
import time

def wait_for_batch(batch_id: str) -> list:
    """Poll batch status and retrieve results."""
    while True:
        batch = client.batches.retrieve(batch_id)

        if batch.processing_status == "ended":
            print(f"Completed: {batch.request_counts.succeeded} succeeded, "
                  f"{batch.request_counts.errored} errored")
            break

        print(f"Status: {batch.processing_status} "
              f"({batch.request_counts.processing} processing)")
        time.sleep(30)

    # Retrieve results
    results = list(client.batches.results(batch_id))
    return results
```

Important details for combining both discounts:

- Batch caching works best when requests with identical cached prefixes are submitted in the same batch. The batch processor groups requests by prefix for cache efficiency.
- The cache TTL during batch processing follows the same rules: 5-minute default, 1-hour extended. Since most batches complete within 1 hour, the default TTL typically covers the full batch.
- You cannot combine batch processing with fast mode. Fast mode (6x pricing on Opus 4.6) is real-time only.

## The Tradeoffs

The 95% savings come with operational constraints:

- **Latency**: Batch processing is not real-time. Most batches complete within 1 hour, but there is no SLA. Do not use this for user-facing requests.
- **Batch size limits**: Maximum 100,000 requests per batch, 256 MB total size. Exceeding either requires splitting into multiple batches, which may reduce cache hit rates across batch boundaries.
- **No streaming**: Batch results arrive as complete responses. You cannot stream partial results to users during processing.
- **24-hour expiration**: If a batch does not complete within 24 hours, remaining requests are cancelled. This is rare but possible during high-load periods.
- **Cache ordering within batches**: The batch processor may not execute requests in submission order. The first request in the batch might not be the one that triggers the cache write.

## Implementation Checklist

1. Identify batch-eligible workloads: tasks that tolerate 1-hour latency
2. Extract shared context (system prompts, rubrics, reference docs) into cacheable blocks
3. Verify shared context exceeds the minimum cacheable token threshold
4. Add `cache_control` breakpoints to the shared context in batch request bodies
5. Submit batches with shared-prefix requests grouped together
6. Monitor batch results for cache utilization metrics
7. Calculate actual cost per request and compare against the 5% theoretical rate

## Measuring Impact

Validate the stacked discount is applying correctly:

- **Per-batch cost**: Total batch cost / request count. For 10K Opus requests with 80K shared context, target is $0.02 per request for input tokens.
- **Cache hit ratio within batch**: Should approach 99.99% (only 1 write per 10,000 requests)
- **Batch vs real-time comparison**: Run a small sample (100 requests) both ways and compare per-request cost
- Use the Anthropic billing dashboard to verify batch pricing tiers are applying alongside cache discounts



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Prompt Caching Pricing and Cost Savings](/claude-prompt-caching-pricing-and-cost-savings/)
- [Anthropic Message Batches API Guide](/anthropic-message-batches-api-guide/)
- [Claude API Batch Processing Large Datasets](/claude-api-batch-processing-large-datasets-workflow-guide/)

## See Also

- [Claude Batch Plus Caching for 95% Cost Savings](/claude-batch-plus-caching-95-percent-cost-savings/)
- [Batch API Cost Calculator for Claude Models](/batch-api-cost-calculator-claude-models/)
