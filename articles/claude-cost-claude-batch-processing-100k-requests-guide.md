---
sitemap: false
layout: default
title: "Claude Batch Processing 100K Requests (2026)"
description: "Claude Batch Processing 100K Requests — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-batch-processing-100k-requests-guide/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, batch-api]
---

# Claude Batch Processing 100K Requests Guide

The Claude Batch API accepts up to 100,000 requests per batch with a 256 MB size limit. At batch pricing, 100,000 Sonnet 4.6 requests with 5,000 input and 3,000 output tokens each costs $3,000 instead of $6,000 at standard rates. That is $3,000 saved on a single batch submission.

## The Setup

You are processing a dataset of 100,000 product descriptions that need rewriting for SEO. Each description averages 5,000 input tokens (original text plus instructions) and 3,000 output tokens (rewritten version). The entire dataset needs processing within 24 hours.

At Sonnet 4.6 standard pricing, this would cost $6,000. The Batch API cuts that to $3,000 while processing the full 100K within the batch limit. You need to handle the 256 MB size constraint, implement robust error recovery, and track costs across the full run.

## The Math

**100,000 product descriptions, Sonnet 4.6:**

Standard pricing:
- Input: 500M tokens x $3.00/MTok = $1,500.00
- Output: 300M tokens x $15.00/MTok = $4,500.00
- **Total: $6,000.00**

Batch pricing:
- Input: 500M tokens x $1.50/MTok = $750.00
- Output: 300M tokens x $7.50/MTok = $2,250.00
- **Total: $3,000.00**

**Savings: $3,000.00 (50%)**

On Haiku 4.5 for the same workload:
- Batch total: $250 input + $750 output = $1,000.00
- Standard total: $500 + $1,500 = $2,000.00
- Savings: $1,000.00

## The Technique

Processing 100K requests requires handling the 256 MB size limit. With an average request of ~2 KB (5K tokens of input plus JSON overhead), 100K requests total roughly 200 MB, which fits in a single batch. Larger requests may require splitting.

```python
import anthropic
import json
import time
import sys

client = anthropic.Anthropic()

MAX_BATCH_SIZE = 100_000
MAX_BATCH_MB = 256


def estimate_request_size(request: dict) -> int:
    """Estimate request size in bytes."""
    return len(json.dumps(request).encode("utf-8"))


def chunk_requests(
    requests: list[dict],
    max_count: int = MAX_BATCH_SIZE,
    max_bytes: int = MAX_BATCH_MB * 1024 * 1024
) -> list[list[dict]]:
    """Split requests into chunks respecting both limits."""
    chunks = []
    current_chunk = []
    current_size = 0

    for req in requests:
        req_size = estimate_request_size(req)

        if (len(current_chunk) >= max_count or
                current_size + req_size > max_bytes):
            chunks.append(current_chunk)
            current_chunk = []
            current_size = 0

        current_chunk.append(req)
        current_size += req_size

    if current_chunk:
        chunks.append(current_chunk)

    return chunks


def process_large_batch(
    items: list[dict],
    model: str = "claude-sonnet-4-6-20250929"
) -> dict:
    """Process up to 100K items with automatic chunking."""

    # Build requests
    requests = []
    for item in items:
        requests.append({
            "custom_id": item["id"],
            "params": {
                "model": model,
                "max_tokens": 4096,
                "messages": [
                    {
                        "role": "user",
                        "content": item["prompt"]
                    }
                ]
            }
        })

    # Chunk if needed
    chunks = chunk_requests(requests)
    print(f"Total requests: {len(requests)}")
    print(f"Chunks needed: {len(chunks)}")

    all_results = []
    failed_ids = []

    for i, chunk in enumerate(chunks):
        print(f"\nChunk {i+1}/{len(chunks)}: {len(chunk)} requests")

        batch = client.batches.create(requests=chunk)
        print(f"  Batch ID: {batch.id}")

        # Poll with progress
        while True:
            status = client.batches.retrieve(batch.id)
            counts = status.request_counts

            if status.processing_status == "ended":
                print(f"  Completed: {counts.succeeded} ok, "
                      f"{counts.errored} errors")
                break

            done = counts.succeeded + counts.errored
            total = done + counts.processing
            pct = (done / total * 100) if total > 0 else 0
            print(f"  Progress: {done}/{total} ({pct:.1f}%)")
            time.sleep(60)

        # Collect results
        results = list(client.batches.results(batch.id))
        for result in results:
            if result.result.type == "succeeded":
                all_results.append({
                    "id": result.custom_id,
                    "output": result.result.message.content[0].text,
                    "tokens_in": result.result.message.usage.input_tokens,
                    "tokens_out": result.result.message.usage.output_tokens
                })
            else:
                failed_ids.append(result.custom_id)

    total_in = sum(r["tokens_in"] for r in all_results)
    total_out = sum(r["tokens_out"] for r in all_results)

    return {
        "succeeded": len(all_results),
        "failed": len(failed_ids),
        "failed_ids": failed_ids,
        "total_input_tokens": total_in,
        "total_output_tokens": total_out,
        "results": all_results
    }


# Run
items = load_product_descriptions()  # 100K items
output = process_large_batch(items)

print(f"\nResults: {output['succeeded']} succeeded, "
      f"{output['failed']} failed")
print(f"Input tokens: {output['total_input_tokens']:,}")
print(f"Output tokens: {output['total_output_tokens']:,}")
```

For retrying failed requests:

```bash
# Retry failed requests from a previous batch
python3 -c "
import json

# Load failed IDs from previous run
failed = json.load(open('failed_ids.json'))
all_items = {item['id']: item for item in json.load(open('items.json'))}

retry_items = [all_items[fid] for fid in failed if fid in all_items]
print(f'Retrying {len(retry_items)} failed requests')

# Submit as a new small batch
# (reuse process_large_batch from above)
"
```

Key considerations for 100K batches:

- **Monitor batch processing time**: Batches this large typically complete within 1-2 hours, but can take up to 24 hours during high-demand periods.
- **Results expire after 29 days**: Download and store results immediately upon completion.
- **Idempotency via custom_id**: Use deterministic IDs so you can deduplicate if you accidentally submit the same batch twice.

## The Tradeoffs

Large batches introduce specific risks:

- **All-or-nothing timeout**: If a 100K batch does not complete within 24 hours, all remaining unprocessed requests are cancelled. For critical workloads, consider splitting into smaller batches (10K each) so partial completion is preserved.
- **Memory requirements**: Downloading 100K results at once can consume significant memory. Stream results or paginate if your processing pipeline cannot handle the full response set.
- **Cost commitment**: A 100K Opus 4.7 batch costs approximately $3,000 at batch pricing. There is no cost preview -- you are committed once the batch starts processing.
- **No priority ordering**: Requests within a batch may process in any order. If some items are higher priority, submit them in a separate smaller batch.

## Implementation Checklist

1. Count total requests and estimate per-request size in bytes
2. Verify total batch stays under 100,000 requests and 256 MB
3. If exceeding limits, implement the chunking function above
4. Assign unique, deterministic `custom_id` values to every request
5. Submit batches and implement polling with progress logging
6. Build retry logic for failed requests (submit as new batch)
7. Download and store results within the 29-day retention window

## Measuring Impact

Track these metrics for large batch operations:

- **Processing throughput**: Requests completed per hour. Typical: 50K-100K per hour for Haiku, 10K-50K for Sonnet.
- **Cost per 1K requests**: Should be exactly 50% of standard per-1K cost for the same model.
- **Error rate**: Percentage of failed requests per batch. Below 0.1% is normal. Above 1% indicates systematic request issues.
- Compare total batch cost against the standard pricing estimate to verify the 50% discount applied



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Anthropic Message Batches API Guide](/anthropic-message-batches-api-guide/)
- [Claude API Batch Processing Large Datasets](/claude-api-batch-processing-large-datasets-workflow-guide/)
- [Claude Code for Batch Processing Optimization](/claude-code-for-batch-processing-optimization-workflow/)

## See Also

- [Async Claude Processing: Half Price Same Quality](/async-claude-processing-half-price-same-quality/)
- [Automatic vs Manual Cache Breakpoints Guide](/automatic-vs-manual-cache-breakpoints-guide/)
- [Claude 200K vs 1M Context Cost Comparison](/claude-200k-vs-1m-context-cost-comparison/)
- [Claude Batch API 50% Discount Complete Guide](/claude-batch-api-50-percent-discount-guide/)
- [Claude Opus 4.7: Is It Worth the Extra Cost?](/claude-opus-47-is-it-worth-extra-cost/)
