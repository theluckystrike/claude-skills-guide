---
layout: default
title: "Anthropic Message Batches API Guide (2026)"
description: "Use the Anthropic Message Batches API for 50% cost savings on bulk processing. Setup, polling, error handling, and optimization tips."
date: 2026-04-15
permalink: /anthropic-message-batches-api-guide/
categories: [guides, anthropic-api]
tags: [batch-processing, API, cost-optimization, bulk-operations]
last_modified_at: 2026-04-17
geo_optimized: true
---

# Anthropic Message Batches API Guide

## The Problem

You need to process hundreds or thousands of Claude API requests but sending them one at a time is slow, expensive, and hits rate limits. Real-time responses are not required for your use case.

## Quick Fix

Use the Message Batches API to submit up to 100,000 requests in a single batch at 50% of standard API pricing:

```python
import anthropic
from anthropic.types.message_create_params import MessageCreateParamsNonStreaming
from anthropic.types.messages.batch_create_params import Request

client = anthropic.Anthropic()

message_batch = client.messages.batches.create(
 requests=[
 Request(
 custom_id="request-1",
 params=MessageCreateParamsNonStreaming(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Summarize this document..."}],
 ),
 ),
 ]
)
print(message_batch.id)
```

## What's Happening

The Message Batches API processes requests asynchronously instead of synchronously. When you submit a batch, Anthropic queues all requests and processes them in parallel. Most batches complete within 1 hour. Each request in the batch is handled independently, so one failure does not affect others.

The key advantage is cost: all batch usage is charged at 50% of standard API prices. For Claude Sonnet 4.6, that means $1.50 per million input tokens and $7.50 per million output tokens instead of $3 and $15 respectively.

## Step-by-Step Fix

### Step 1: Prepare your batch requests

Each request needs a unique `custom_id` (1-64 alphanumeric characters, hyphens, and underscores) and a `params` object with standard Messages API parameters:

```python
import anthropic
from anthropic.types.message_create_params import MessageCreateParamsNonStreaming
from anthropic.types.messages.batch_create_params import Request

client = anthropic.Anthropic()

requests = []
for i, doc in enumerate(documents):
 requests.append(
 Request(
 custom_id=f"doc-{i}",
 params=MessageCreateParamsNonStreaming(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[
 {"role": "user", "content": f"Summarize: {doc}"}
 ],
 ),
 )
 )

message_batch = client.messages.batches.create(requests=requests)
print(f"Batch ID: {message_batch.id}")
```

### Step 2: Poll for completion

Check the batch status until processing finishes:

```python
import time

while True:
 batch = client.messages.batches.retrieve(message_batch.id)
 if batch.processing_status == "ended":
 break
 print(f"Status: {batch.processing_status} - "
 f"{batch.request_counts.succeeded} succeeded, "
 f"{batch.request_counts.processing} processing")
 time.sleep(30)
```

### Step 3: Retrieve results

Stream results for the completed batch:

```python
for result in client.messages.batches.results(message_batch.id):
 if result.result.type == "succeeded":
 print(f"{result.custom_id}: {result.result.message.content[0].text}")
 elif result.result.type == "errored":
 print(f"{result.custom_id}: Error - {result.result.error}")
```

### Step 4: Handle errors and expiration

Individual requests can fail without affecting the batch. Batches expire if processing does not complete within 24 hours. Results are available for 29 days after creation.

```python
batch = client.messages.batches.retrieve(message_batch.id)
counts = batch.request_counts
print(f"Succeeded: {counts.succeeded}")
print(f"Errored: {counts.errored}")
print(f"Expired: {counts.expired}")
```

### Step 5: Use with prompt caching for better performance

Since batches can take time to process, use the 1-hour cache duration for shared context:

```python
requests.append(
 Request(
 custom_id=f"doc-{i}",
 params=MessageCreateParamsNonStreaming(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 system=[{
 "type": "text",
 "text": shared_system_prompt,
 "cache_control": {"type": "ephemeral"}
 }],
 messages=[
 {"role": "user", "content": f"Analyze: {doc}"}
 ],
 ),
 )
)
```

### Batch limits

- Maximum 100,000 requests or 256 MB per batch, whichever comes first
- Batches expire after 24 hours if not complete
- Results available for 29 days after creation
- All active Claude models are supported

### Pricing reference

| Model | Batch Input | Batch Output |
|-------|------------|-------------|
| Claude Opus 4.6 | $2.50/MTok | $12.50/MTok |
| Claude Sonnet 4.6 | $1.50/MTok | $7.50/MTok |
| Claude Haiku 4.5 | $0.50/MTok | $2.50/MTok |

## Prevention

Design your batch pipelines to handle partial failures. Always check `request_counts` after processing ends. Implement retry logic for expired or errored requests by resubmitting them in a new batch.

For large-scale evaluations, split work into multiple batches under the 100K request limit and process them concurrently for maximum throughput.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=anthropic-message-batches-api-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

---

## Related Guides

- [Claude API Batch Processing Large Datasets Guide](/claude-api-batch-processing-large-datasets-workflow-guide/)
- [Claude API Cost Optimization Strategies](/claude-api-cost-optimization-strategies-for-saas-application/)
- [Claude API Rate Limit Fix](/claude-api-rate-limit-fix/)
- [Claude API Tool Use Function Calling Guide](/claude-api-tool-use-function-calling-deep-dive-guide/)



- [Claude temperature settings guide](/claude-temperature-settings-guide/) — How to configure temperature and sampling parameters in Claude
## Related Articles

- [Message Batches API Tutorial with Cost Examples](/message-batches-api-tutorial-cost-examples/)
- [Claude Code for Claude Batch API: Anthropic Workflow Guide](/claude-code-for-claude-batch-api-anthropic-workflow-guide/)
- [Message Batches API Tutorial with Cost Examples](/claude-cost-message-batches-api-tutorial-cost-examples/)
