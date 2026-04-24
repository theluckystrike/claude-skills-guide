---
layout: default
title: "Claude Batch Processing Limits"
description: "Claude batches cap at 100K requests and 256 MB. Learn chunking strategies and error recovery to maximize your 50% savings."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-batch-processing-limits-best-practices/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, batch-api]
render_with_liquid: false
---

# Claude Batch Processing Limits and Best Practices

Claude's Batch API has two hard limits: 100,000 requests per batch and 256 MB total payload size. Exceeding either causes the batch to be rejected. Within those limits, you get a 50% discount on every token -- Opus 4.7 drops from $5.00/$25.00 to $2.50/$12.50 per million tokens. Here is how to work within these constraints for maximum savings.

## The Setup

You are scaling a data processing pipeline from 10,000 to 500,000 requests. At 10K requests, a single batch handles everything. At 500K, you need to split across 5+ batches, handle partial failures across batches, and manage concurrent batch processing.

The 50% savings at this volume is substantial. On Sonnet 4.6 with 5K input and 3K output tokens per request, 500K requests at standard pricing costs $30,000. At batch pricing: $15,000. You save $15,000 per run -- but only if you handle the limits correctly.

## The Math

**Payload size estimation:**

Average request JSON size: ~2-3 KB (5K input tokens + params + headers)
- 100K requests x 2.5 KB = 250 MB (near the 256 MB limit)
- 100K requests x 3 KB = 300 MB (exceeds limit, must split)

**500K requests, Sonnet 4.6, 5K input + 3K output:**

Standard pricing:
- Input: 2.5B tokens x $3.00/MTok = $7,500
- Output: 1.5B tokens x $15.00/MTok = $22,500
- **Total: $30,000**

Batch pricing:
- Input: 2.5B x $1.50/MTok = $3,750
- Output: 1.5B x $7.50/MTok = $11,250
- **Total: $15,000**

**Savings: $15,000 (50%)**

Splitting 500K into batches of 80K each (safe margin under limits):
- 7 batches x ~80K requests each
- Total processing time: 1-3 hours (batches can run concurrently)

## The Technique

Here is a production-grade batch manager that handles chunking, concurrent submission, and error recovery:

```python
import anthropic
import json
import time
import threading
from dataclasses import dataclass, field

client = anthropic.Anthropic()

MAX_REQUESTS = 100_000
MAX_BYTES = 256 * 1024 * 1024  # 256 MB
SAFE_MARGIN = 0.9  # Use 90% of limits for safety


@dataclass
class BatchResult:
    batch_id: str
    succeeded: int = 0
    failed: int = 0
    failed_ids: list = field(default_factory=list)
    results: list = field(default_factory=list)


def chunk_by_limits(
    requests: list[dict],
    max_count: int = int(MAX_REQUESTS * SAFE_MARGIN),
    max_bytes: int = int(MAX_BYTES * SAFE_MARGIN)
) -> list[list[dict]]:
    """Split requests into chunks respecting both hard limits."""
    chunks = []
    current = []
    current_bytes = 0

    for req in requests:
        req_bytes = len(json.dumps(req).encode())

        if len(current) >= max_count or current_bytes + req_bytes > max_bytes:
            if current:
                chunks.append(current)
            current = []
            current_bytes = 0

        current.append(req)
        current_bytes += req_bytes

    if current:
        chunks.append(current)

    return chunks


def submit_batch(requests: list[dict]) -> str:
    """Submit a single batch and return its ID."""
    batch = client.batches.create(requests=requests)
    return batch.id


def wait_for_batch(batch_id: str) -> BatchResult:
    """Poll batch until complete, return structured result."""
    result = BatchResult(batch_id=batch_id)

    while True:
        status = client.batches.retrieve(batch_id)

        if status.processing_status == "ended":
            counts = status.request_counts
            print(f"  Batch {batch_id[:12]}: "
                  f"{counts.succeeded} ok, {counts.errored} errors")
            break

        time.sleep(30)

    for item in client.batches.results(batch_id):
        if item.result.type == "succeeded":
            result.succeeded += 1
            result.results.append({
                "id": item.custom_id,
                "content": item.result.message.content[0].text
            })
        else:
            result.failed += 1
            result.failed_ids.append(item.custom_id)

    return result


def process_at_scale(requests: list[dict]) -> dict:
    """Process any number of requests with automatic chunking."""
    chunks = chunk_by_limits(requests)

    print(f"Total: {len(requests)} requests in {len(chunks)} batches")
    for i, chunk in enumerate(chunks):
        size_mb = sum(len(json.dumps(r).encode()) for r in chunk) / 1e6
        print(f"  Batch {i+1}: {len(chunk)} requests, {size_mb:.1f} MB")

    # Submit all batches
    batch_ids = []
    for i, chunk in enumerate(chunks):
        bid = submit_batch(chunk)
        batch_ids.append(bid)
        print(f"  Submitted batch {i+1}: {bid[:12]}")

    # Wait for all batches (could parallelize with threads)
    all_results = []
    all_failed = []

    for bid in batch_ids:
        br = wait_for_batch(bid)
        all_results.extend(br.results)
        all_failed.extend(br.failed_ids)

    return {
        "total_succeeded": len(all_results),
        "total_failed": len(all_failed),
        "failed_ids": all_failed,
        "results": all_results
    }
```

Best practices for production batch processing:

```bash
# Pre-submission validation
python3 -c "
import json

# Validate batch before submission
requests = [json.loads(l) for l in open('batch_requests.jsonl')]

total_bytes = sum(len(json.dumps(r).encode()) for r in requests)
total_count = len(requests)

print(f'Requests: {total_count:,} (limit: 100,000)')
print(f'Size: {total_bytes/1e6:.1f} MB (limit: 256 MB)')

if total_count > 100000:
    chunks_needed = (total_count // 90000) + 1
    print(f'WARNING: Must split into {chunks_needed} batches')

if total_bytes > 256 * 1024 * 1024:
    chunks_needed = (total_bytes // (230 * 1024 * 1024)) + 1
    print(f'WARNING: Must split into {chunks_needed} batches (size)')

# Validate each request has custom_id
missing_ids = [i for i, r in enumerate(requests) if 'custom_id' not in r]
if missing_ids:
    print(f'ERROR: {len(missing_ids)} requests missing custom_id')
"
```

Key best practices:

1. **Use 90% of limits** to account for JSON serialization overhead differences between your estimate and the API's parser.
2. **Retry failed requests in separate batches.** Collect `failed_ids`, rebuild those requests, submit as a new batch.
3. **Use deterministic custom_ids.** If you need to retry a batch, duplicate IDs let you deduplicate results.
4. **Process results promptly.** The 29-day retention window is generous but not permanent.
5. **Monitor batch duration.** If batches consistently approach the 24-hour timeout, reduce batch size.

## The Tradeoffs

Operating at batch limits introduces specific risks:

- **Timeout risk increases with size.** A 100K batch during high API load may take longer than a 10K batch. Consider whether 10 x 10K batches (with faster individual completion) is better than 1 x 100K.
- **Debugging is harder at scale.** A single malformed request in 100K is difficult to identify without good `custom_id` conventions.
- **Memory pressure.** Downloading 100K results creates a large in-memory object. Use streaming result retrieval or process results in pages.
- **Concurrency limits.** Anthropic may restrict the number of concurrent active batches per API key. Check current limits in your account settings.

## Implementation Checklist

1. Estimate per-request payload size (JSON serialized bytes)
2. Calculate total requests x size to determine chunking needs
3. Implement the chunking function with 90% safety margin
4. Add pre-submission validation (count, size, custom_id presence)
5. Submit chunks and track batch IDs for result retrieval
6. Implement retry pipeline for failed requests
7. Set up alerting for batches approaching the 24-hour timeout

## Measuring Impact

Monitor batch operations at scale:

- **Chunk efficiency**: Actual requests per chunk vs the 100K limit. Closer to 100K means fewer batches and less overhead.
- **Processing speed**: Requests completed per minute. Track across batches to identify slowdowns.
- **Retry volume**: Failed requests requiring resubmission. Should be under 0.1% of total.
- Compare total cost for the full batch run against standard API pricing to verify the 50% discount

## Related Guides

- [Anthropic Message Batches API Guide](/anthropic-message-batches-api-guide/)
- [Claude API Batch Processing Large Datasets](/claude-api-batch-processing-large-datasets-workflow-guide/)
- [Claude Code for Batch Processing Optimization](/claude-code-for-batch-processing-optimization-workflow/)

## Related Articles

- [Migrating Real-Time Claude Calls to Batch API](/migrating-real-time-claude-calls-to-batch/)
- [Claude Batch Processing 100K Requests Guide](/claude-cost-claude-batch-processing-100k-requests-guide/)
- [Claude Batch Plus Caching for 95% Cost Savings](/claude-cost-claude-batch-plus-caching-95-percent-cost-savings/)
- [Claude Workspace Spend Limits Configuration](/claude-cost-05-claude-workspace-spend-limits/)
