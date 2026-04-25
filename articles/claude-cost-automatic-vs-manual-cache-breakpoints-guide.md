---
layout: default
title: "Automatic vs Manual Cache Breakpoints"
description: "Claude supports up to 4 manual cache breakpoints per request. Learn where to place them for maximum savings on $5.00/MTok input."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /automatic-vs-manual-cache-breakpoints-guide/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, prompt-caching]
---

# Automatic vs Manual Cache Breakpoints Guide

Claude's prompt caching gives you up to 4 manual breakpoints per request. Each breakpoint defines a prefix boundary where cached content ends and fresh content begins. Placing them correctly can turn a $5.00/MTok input cost into $0.50/MTok. Placing them wrong wastes the 1.25x write premium on content that never gets reused.

## The Setup

You are building a legal document review system. Each request includes three layers of context: a 15,000-token system prompt with instructions and formatting rules, a 40,000-token reference document (the contract being reviewed), and a 5,000-token conversation history that changes with every turn.

Without breakpoints, the entire 60,000 tokens get processed at full price every time. With two well-placed breakpoints -- one after the system prompt, one after the reference document -- you cache 55,000 tokens and only pay full price for the 5,000 dynamic tokens.

On Opus 4.7, that drops per-request input cost from $0.30 to $0.053 -- an 82% savings on a single API call.

## The Math

**Legal review system, Opus 4.7, 50 queries per document:**

Without caching:
- 50 queries x 60,000 tokens x $5.00/MTok = $15.00 per document

With 2 manual breakpoints (system + document cached):
- Write: 55,000 tokens x $6.25/MTok = $0.344
- 49 reads: 49 x 55,000 tokens x $0.50/MTok = $1.348
- Dynamic input (uncached): 50 x 5,000 tokens x $5.00/MTok = $1.25
- Total: $2.94

**Savings: $12.06 per document (80%)**

At 100 documents per month: $1,206 saved.

Compare single breakpoint vs two breakpoints:
- 1 breakpoint (system prompt only, 15K cached): saves $3.38/document
- 2 breakpoints (system + doc, 55K cached): saves $12.06/document
- The second breakpoint adds $8.68 in savings per document.

## The Technique

Manual breakpoints use `cache_control` annotations in your message content. Each breakpoint caches everything from the start of the message sequence up to that point.

```python
import anthropic

client = anthropic.Anthropic()

def review_document(
    instructions: str,    # 15K tokens, stable across all documents
    document: str,        # 40K tokens, stable per document
    conversation: list,   # 5K tokens, changes every turn
    query: str
) -> str:
    """Legal review with two cache breakpoints."""

    response = client.messages.create(
        model="claude-opus-4-7-20250415",
        max_tokens=4096,
        system=[
            {
                "type": "text",
                "text": instructions,
                "cache_control": {"type": "ephemeral"}  # Breakpoint 1
            }
        ],
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": f"Reference document:\n{document}",
                        "cache_control": {"type": "ephemeral"}  # Breakpoint 2
                    },
                    {
                        "type": "text",
                        "text": query
                    }
                ]
            }
        ]
    )

    usage = response.usage
    cached = usage.cache_read_input_tokens
    written = usage.cache_creation_input_tokens
    fresh = usage.input_tokens

    print(f"Cached: {cached}, Written: {written}, Fresh: {fresh}")
    return response.content[0].text
```

Breakpoint placement rules:

1. **Most stable content first.** System prompts rarely change and should be the first breakpoint. Documents change per session. Conversation history changes per turn.

2. **Respect minimum token thresholds.** On Opus 4.7, each cached prefix must contain at least 4,096 tokens. A 2,000-token system prompt alone cannot be cached on Opus -- but a 2,000-token system prompt combined with a 3,000-token document can be, under a single breakpoint.

3. **Four breakpoints maximum.** You get 4 per request. Typical allocation:
   - Breakpoint 1: System prompt
   - Breakpoint 2: Reference data / documents
   - Breakpoint 3: Few-shot examples
   - Breakpoint 4: Conversation history prefix

4. **Order matters.** Caching is prefix-based. Content after the last breakpoint is always processed at full input price. Structure your content from most-stable to least-stable.

```bash
# Verify your breakpoint placement is working
# Check cache metrics from a test request
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "content-type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-6-20250929",
    "max_tokens": 100,
    "system": [{"type":"text","text":"'"$(cat system_prompt.txt)"'","cache_control":{"type":"ephemeral"}}],
    "messages": [{"role":"user","content":"test"}]
  }' | python3 -c "
import json, sys
r = json.load(sys.stdin)
u = r['usage']
print(f'Cache write: {u.get(\"cache_creation_input_tokens\", 0)}')
print(f'Cache read: {u.get(\"cache_read_input_tokens\", 0)}')
print(f'Uncached: {u[\"input_tokens\"]}')
"
```

## The Tradeoffs

Manual breakpoints require careful management:

- **Breakpoint ordering is rigid.** If you need to insert new content between two breakpoints, both downstream caches are invalidated. Plan your content layers before deployment.
- **4-breakpoint limit constrains complex prompts.** A system with instructions, tools, examples, documents, and conversation history has 5 natural layers but only 4 available breakpoints.
- **Over-segmenting wastes writes.** Each breakpoint creates a separate cacheable prefix. If two breakpoints cover content that always changes together, you pay two write premiums for the same invalidation event.
- **No automatic detection.** Claude does not identify optimal breakpoint locations. You must analyze your content stability patterns and place breakpoints manually.

## Implementation Checklist

1. Map your prompt content into layers ordered by stability (most stable first)
2. Verify each layer exceeds the minimum token threshold for your model
3. Place breakpoints at the end of each stable layer (max 4)
4. Test with a single request and verify `cache_creation_input_tokens` matches expected sizes
5. Run 10 sequential requests and confirm `cache_read_input_tokens` on requests 2-10
6. Monitor breakpoint efficiency: if any breakpoint shows more writes than reads, consolidate it

## Measuring Impact

Measure breakpoint effectiveness with per-breakpoint metrics:

- **Per-breakpoint hit rate**: Track which breakpoints produce reads vs writes. A breakpoint with a 50% hit rate is poorly placed.
- **Marginal savings per breakpoint**: Calculate savings from each additional breakpoint. If breakpoint 3 only saves $0.02/request, it may not justify the complexity.
- **Write frequency by breakpoint**: System prompt breakpoint should write once per deployment. Document breakpoint should write once per document. Conversation breakpoint writes once per session.
- Weekly review: remove breakpoints with hit rates below 80%.

## Related Guides

- [Claude Prompt Caching Pricing and Cost Savings](/claude-prompt-caching-pricing-and-cost-savings/)
- [Claude API Prompt Caching Performance Optimization](/claude-api-prompt-caching-performance-optimization-guide/)
- [Claude Code for Varnish Cache Workflow](/claude-code-for-varnish-cache-workflow-tutorial/)

## See Also

- [ccusage vs Manual Token Counting (2026)](/ccusage-vs-manual-token-counting-2026/)
