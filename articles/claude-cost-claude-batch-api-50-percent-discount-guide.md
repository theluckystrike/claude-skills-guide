---
layout: default
title: "Claude Batch API 50% Discount Complete (2026)"
description: "Claude Batch API 50% Discount Complete — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-batch-api-50-percent-discount-guide/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, batch-api]
---

# Claude Batch API 50% Discount Complete Guide

The Claude Batch API charges exactly half the standard rate on every model, for both input and output tokens. Opus 4.7 drops from $5.00/$25.00 to $2.50/$12.50 per million tokens. Sonnet 4.6 drops from $3.00/$15.00 to $1.50/$7.50. The only requirement: your workload can tolerate up to one hour of processing delay.

## The Setup

You run a code review pipeline that analyzes 5,000 pull requests per week using Opus 4.7. Each review takes roughly 20,000 input tokens (the code diff plus review instructions) and produces 5,000 output tokens (the review comments).

At standard pricing, your weekly bill is $1,125. Switching the same workload to the Batch API -- with identical prompts, models, and output quality -- cuts it to $562.50. You save $562.50 per week ($2,437/month) by changing how you submit requests.

## The Math

**5,000 code reviews per week, Opus 4.7:**

Standard API:
- Input: 100M tokens x $5.00/MTok = $500.00
- Output: 25M tokens x $25.00/MTok = $625.00
- **Total: $1,125.00/week**

Batch API:
- Input: 100M tokens x $2.50/MTok = $250.00
- Output: 25M tokens x $12.50/MTok = $312.50
- **Total: $562.50/week**

**Savings: $562.50/week ($29,250/year)**

Full batch pricing table:

| Model | Standard In/Out | Batch In/Out | Weekly Savings (5K reviews) |
|-------|----------------|-------------|---------------------------|
| Opus 4.7 | $5.00/$25.00 | $2.50/$12.50 | $562.50 |
| Sonnet 4.6 | $3.00/$15.00 | $1.50/$7.50 | $337.50 |
| Haiku 4.5 | $1.00/$5.00 | $0.50/$2.50 | $112.50 |

## The Technique

The Batch API accepts up to 100,000 requests per batch, with a 256 MB size limit. You submit a batch of requests, receive a batch ID, and poll for results.

```python
import anthropic
import time

client = anthropic.Anthropic()

def submit_review_batch(reviews: list[dict]) -> str:
    """Submit code reviews as a batch for 50% savings.

    Each review dict has: id, diff_text, instructions
    """
    requests = []
    for review in reviews:
        requests.append({
            "custom_id": review["id"],
            "params": {
                "model": "claude-opus-4-7-20250415",
                "max_tokens": 8192,
                "messages": [
                    {
                        "role": "user",
                        "content": (
                            f"{review['instructions']}\n\n"
                            f"Code diff:\n```\n{review['diff_text']}\n```"
                        )
                    }
                ]
            }
        })

    batch = client.batches.create(requests=requests)
    print(f"Batch {batch.id}: {len(requests)} requests submitted")
    print(f"Estimated cost: ${len(requests) * 0.1125:.2f} "
          f"(vs ${len(requests) * 0.225:.2f} standard)")
    return batch.id


def poll_batch(batch_id: str, interval: int = 30) -> list:
    """Wait for batch completion and return results."""
    while True:
        batch = client.batches.retrieve(batch_id)
        counts = batch.request_counts

        if batch.processing_status == "ended":
            print(f"Done: {counts.succeeded} succeeded, "
                  f"{counts.errored} errored")
            break

        print(f"Processing: {counts.processing}/{counts.succeeded + counts.processing + counts.errored}")
        time.sleep(interval)

    return list(client.batches.results(batch_id))


# Submit 5,000 code reviews
reviews = load_pending_reviews()  # Your data source
batch_id = submit_review_batch(reviews)
results = poll_batch(batch_id)

# Process results
for result in results:
    review_id = result.custom_id
    if result.result.type == "succeeded":
        review_text = result.result.message.content[0].text
        save_review(review_id, review_text)
    else:
        log_error(review_id, result.result.error)
```

Key implementation details:

- **Request independence**: Each request in a batch is processed independently. You can mix different models, parameters, and even system prompts in the same batch (though all requests must use the same API version).
- **Error isolation**: If one request fails, the others still complete. Check `result.result.type` for each response.
- **No streaming**: Batch responses are complete -- you cannot stream partial output. Design your downstream processing accordingly.
- **Result retention**: Completed batch results are available for 29 days. Download and store them if needed beyond that window.

For quick batch submission via the command line:

```bash
# Create a JSONL file with batch requests
cat > batch.jsonl << 'JSONL_END'
{"custom_id":"r1","params":{"model":"claude-sonnet-4-6-20250929","max_tokens":2048,"messages":[{"role":"user","content":"Summarize this code: def add(a,b): return a+b"}]}}
{"custom_id":"r2","params":{"model":"claude-sonnet-4-6-20250929","max_tokens":2048,"messages":[{"role":"user","content":"Summarize this code: def mul(a,b): return a*b"}]}}
JSONL_END

# Submit via API
curl -X POST https://api.anthropic.com/v1/messages/batches \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"requests": '"$(cat batch.jsonl | jq -s .)"'}'
```

## The Tradeoffs

The 50% discount comes with real constraints:

- **Latency**: Most batches complete within 1 hour, but the SLA is 24 hours. Time-sensitive workloads (real-time chat, interactive coding) cannot use batches.
- **No cancellation granularity**: You can cancel an entire batch, but not individual requests within it. If you discover bad data in request #500 of 5,000, the only option is to cancel the whole batch and resubmit.
- **No fast mode**: Batch processing is incompatible with Opus 4.6 fast mode (which charges 6x standard rates). You cannot get both the speed boost and the batch discount.
- **Rate limits**: While the per-batch limit is 100,000 requests, your overall API rate limits still apply. High-volume batches may take longer during peak usage periods.

## Implementation Checklist

1. Identify API workloads that do not require real-time responses
2. Estimate batch size: count pending requests and total token volume
3. Verify total batch size stays under 256 MB
4. Convert real-time API calls to batch request format (add `custom_id` per request)
5. Submit batch and implement polling logic for completion
6. Build result processing pipeline that handles both successes and errors
7. Compare first batch invoice against standard API cost for the same volume

## Measuring Impact

Verify the 50% discount is applying correctly:

- **Per-request cost**: Total batch cost / succeeded requests. Should be exactly 50% of standard per-request cost.
- **Processing time distribution**: Log time from submission to completion. Median should be under 30 minutes for batches under 10,000 requests.
- **Error rate**: Track errored/total ratio. If above 1%, investigate request formatting issues.
- Compare monthly API spend before and after batch migration using Anthropic billing exports

## Related Guides

- [Anthropic Message Batches API Guide](/anthropic-message-batches-api-guide/)
- [Claude API Batch Processing Large Datasets](/claude-api-batch-processing-large-datasets-workflow-guide/)
- [Claude Code for Batch Processing Optimization](/claude-code-for-batch-processing-optimization-workflow/)

## See Also

- [Claude Batch Processing 100K Requests Guide](/claude-batch-processing-100k-requests-guide/)
- [Claude Max Subscription vs API for Agent Fleets](/claude-max-subscription-vs-api-agent-fleets/)
- [When to Use Claude Batch vs Real-Time API](/when-to-use-claude-batch-vs-real-time-api/)
- [Batch API Job Failed Status — Fix (2026)](/claude-code-batch-api-job-failed-fix-2026/)
- [How to Reduce Claude API Token Usage by 50%](/reduce-claude-api-token-usage-50-percent/)
