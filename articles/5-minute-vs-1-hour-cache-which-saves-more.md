---
layout: default
title: "5-Minute vs 1-Hour Cache"
description: "Claude's 5-minute cache costs 1.25x per write, 1-hour costs 2x. See break-even analysis to pick the right TTL for your workload."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /5-minute-vs-1-hour-cache-which-saves-more/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, prompt-caching]
render_with_liquid: false
---

# 5-Minute vs 1-Hour Cache: Which Saves More

Claude offers two cache TTL options: a 5-minute cache that costs 1.25x the base input price per write, and a 1-hour cache that costs 2.0x. Both deliver cache reads at 0.1x the base price. The right choice depends entirely on your request frequency, and picking wrong costs you money.

## The Setup

You run an internal knowledge base chatbot. Employees ask questions against a 40,000-token company handbook injected as the system prompt. Usage patterns vary: during work hours, you see 50+ queries per 5-minute window. During off-peak, gaps between queries stretch to 15-20 minutes.

With the 5-minute cache, you save 90% on every read during peak hours. But during off-peak, the cache expires between queries, triggering a new 1.25x write with zero reads to offset it. The 1-hour cache costs 60% more per write but stays warm through those 15-minute gaps.

Expected savings: $2,800/month with the right TTL choice vs $1,900/month with the wrong one.

## The Math

**5-minute cache break-even:**
- Write cost: 1.25x base input
- Read cost: 0.1x base input
- Break-even: 1 read (1.25x write + 0.1x read = 1.35x total < 2.0x for two uncached requests)

**1-hour cache break-even:**
- Write cost: 2.0x base input
- Read cost: 0.1x base input
- Break-even: 2 reads (2.0x write + 2 x 0.1x reads = 2.2x total < 3.0x for three uncached)

**Example with Opus 4.7, 40K cached tokens over 1 hour:**

Scenario A -- 200 requests/hour, evenly spaced (one every 18 seconds):
- 5-min cache: 1 write ($0.25) + 199 reads (199 x 40K x $0.50/MTok = $3.98) = **$4.23**
- 1-hr cache: 1 write ($0.40) + 199 reads ($3.98) = **$4.38**
- Winner: **5-minute cache by $0.15/hour**

Scenario B -- 60 requests/hour, clustered with 10-minute gaps:
- 5-min cache: ~6 writes ($1.50) + 54 reads ($1.08) = **$2.58**
- 1-hr cache: 1 write ($0.40) + 59 reads ($1.18) = **$1.58**
- Winner: **1-hour cache by $1.00/hour ($720/month)**

## The Technique

You cannot set TTL directly in the `cache_control` parameter. The 5-minute cache is the default. For 1-hour cache, you pass an extended TTL header with your request.

```python
import anthropic

client = anthropic.Anthropic()

def query_with_hourly_cache(system_text: str, user_query: str) -> str:
    """Use 1-hour cache for workloads with >5 min gaps between requests."""
    response = client.messages.create(
        model="claude-sonnet-4-6-20250929",
        max_tokens=2048,
        extra_headers={
            "anthropic-beta": "prompt-caching-2024-07-31"
        },
        system=[
            {
                "type": "text",
                "text": system_text,
                "cache_control": {"type": "ephemeral", "ttl": 3600}
            }
        ],
        messages=[
            {"role": "user", "content": user_query}
        ]
    )
    return response.content[0].text
```

To decide which TTL to use, measure your inter-request gap distribution:

```bash
# Analyze request timing from your logs
# Extract timestamps, compute gaps, decide TTL
python3 -c "
import json, sys
from datetime import datetime

logs = [json.loads(l) for l in open('api_requests.jsonl')]
timestamps = [datetime.fromisoformat(l['timestamp']) for l in logs]
gaps = [(timestamps[i+1] - timestamps[i]).seconds
        for i in range(len(timestamps)-1)]

over_5min = sum(1 for g in gaps if g > 300)
total = len(gaps)
pct_over_5min = over_5min / total * 100

print(f'Gaps > 5 min: {over_5min}/{total} ({pct_over_5min:.1f}%)')
print(f'Recommendation: {\"1-hour\" if pct_over_5min > 20 else \"5-minute\"} cache')
"
```

Decision framework:
- **More than 80% of gaps under 5 minutes**: Use 5-minute cache. The lower write cost (1.25x vs 2.0x) wins.
- **More than 20% of gaps between 5-60 minutes**: Use 1-hour cache. The reduced re-write frequency more than offsets the higher per-write cost.
- **Gaps frequently exceeding 1 hour**: Neither cache provides consistent value. Consider restructuring your workload into tighter batches.

Remember that 5-minute cache TTL refreshes on every hit. If you have steady traffic of at least one request per 5 minutes, the cache effectively never expires, and the cheaper write cost makes it the clear winner.

## The Tradeoffs

The 1-hour cache has specific downsides:

- **Higher upfront cost**: 2.0x base input per write means each cache miss costs 60% more than the 5-minute option. On Opus 4.7, that is $10.00/MTok vs $6.25/MTok per write.
- **No partial TTL**: You cannot set a 15-minute or 30-minute cache. It is either 5 minutes or 1 hour.
- **Same isolation rules**: Caches are still workspace-scoped. Switching workspaces means a new write regardless of TTL.
- **Wasted headroom**: If your gaps never exceed 5 minutes, you are paying 60% more per write for TTL you do not use.

## Implementation Checklist

1. Log timestamps for all API requests to your cached endpoint for one week
2. Calculate the distribution of inter-request gaps
3. If more than 20% of gaps exceed 5 minutes, switch to 1-hour cache
4. A/B test both TTLs on identical traffic for 48 hours
5. Compare total input costs (writes + reads) between the two options
6. Set up monitoring to alert when cache write frequency exceeds expected thresholds

## Measuring Impact

After switching TTLs, track:

- **Cache writes per hour**: Should drop significantly with 1-hour cache if gaps were causing 5-minute expiry
- **Effective input cost**: Total input spend / total input tokens processed (target: under $0.60/MTok for Opus 4.7 with good caching)
- **Write-to-read ratio**: For 5-minute cache, aim for 1:50 or better. For 1-hour cache, 1:200+
- Compare weekly spend before and after the TTL change using Anthropic usage dashboard

To quantify the exact cost of cache misses, calculate the re-write penalty for your model. On Sonnet 4.6 with 40K cached tokens, each cache miss (expiry followed by re-write) costs 40K x $3.75/MTok = $0.15 for a 5-minute write, or 40K x $6.00/MTok = $0.24 for a 1-hour write. If you observe 12 cache misses per hour with the 5-minute TTL, that is $1.80/hour in re-write costs. Switching to 1-hour cache reduces that to 1 write per hour at $0.24 -- saving $1.56/hour or $1,123/month.

## Related Guides

- [Claude Prompt Caching Pricing and Cost Savings](/claude-prompt-caching-pricing-and-cost-savings/)
- [Claude API Prompt Caching Performance Optimization](/claude-api-prompt-caching-performance-optimization-guide/)
- [Claude Code for Varnish Cache Workflow](/claude-code-for-varnish-cache-workflow-tutorial/)

## See Also

- [MCP vs CLI for Claude Code: When Each Saves More Tokens](/mcp-vs-cli-claude-code-saves-more-tokens/)
