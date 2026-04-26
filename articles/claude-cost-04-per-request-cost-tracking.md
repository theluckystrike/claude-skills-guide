---
layout: default
title: "Per-Request Cost Tracking for Claude (2026)"
description: "Calculate exact cost per API call using the usage object formula. Identify your $0.50+ requests that drive 80% of monthly spend."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /per-request-cost-tracking-claude-api/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, tracking, per-request]
---

# Per-Request Cost Tracking for Claude API

Every Claude API response includes a `usage` object with exact token counts. Multiply those counts by the model's per-token price and you get the precise cost of that request -- no estimation needed. The formula: `(input_tokens x input_rate) + (output_tokens x output_rate) + (cache_tokens x cache_rate) + (web_searches x $0.01)`. For an Opus 4.7 request with 10,000 input and 2,000 output tokens, that's $0.05 + $0.05 = $0.10 per request. Track this per-request and you'll discover that 5% of your requests generate 40% of your bill.

## The Setup

The `usage` object returned in every API response contains five key fields: `input_tokens`, `output_tokens`, `cache_read_input_tokens`, `cache_creation_input_tokens`, and `server_tool_use` (which includes `web_search_requests`, `web_fetch_requests`, and `code_execution_requests`). These fields map directly to billable units. Most developers log only the response content and discard the usage data. By preserving and calculating costs from the usage object on every request, you build a complete cost ledger that enables optimization at the individual request level.

## The Math

The complete cost formula per request:

```
Total = (input_tokens * input_price / 1,000,000)
      + (output_tokens * output_price / 1,000,000)
      + (cache_creation_input_tokens * cache_write_price / 1,000,000)
      + (cache_read_input_tokens * cache_read_price / 1,000,000)
      + (web_search_requests * $0.01)
      + (code_execution_hours * $0.05)  [after 1,550 free hours/month]
```

Example with Sonnet 4.6 ($3.00 input, $15.00 output, $3.75 cache write, $0.30 cache read):

| Field | Value | Calculation | Cost |
|-------|-------|-------------|------|
| input_tokens | 5,000 | 5K x $3.00/MTok | $0.015000 |
| output_tokens | 1,500 | 1.5K x $15.00/MTok | $0.022500 |
| cache_creation | 10,000 | 10K x $3.75/MTok | $0.037500 |
| cache_read | 8,000 | 8K x $0.30/MTok | $0.002400 |
| web_search | 2 | 2 x $0.01 | $0.020000 |
| **Total** | | | **$0.097400** |

Without cache reads, the same input would cost: 23,000 x $3.00/MTok = $0.069 for input alone. The cache saved $0.069 - $0.015 - $0.037500 - $0.002400 = $0.014100 on this single request.

## The Technique

Build a per-request cost calculator that works with any Claude model.

```python
import anthropic
from dataclasses import dataclass
from typing import Optional

# All prices per million tokens (verified 2026-04-19)
MODEL_PRICES = {
    "claude-opus-4-7": {
        "input": 5.00, "output": 25.00,
        "cache_write_5m": 6.25, "cache_write_1h": 10.00,
        "cache_read": 0.50,
        "batch_input": 2.50, "batch_output": 12.50
    },
    "claude-sonnet-4-6": {
        "input": 3.00, "output": 15.00,
        "cache_write_5m": 3.75, "cache_write_1h": 6.00,
        "cache_read": 0.30,
        "batch_input": 1.50, "batch_output": 7.50
    },
    "claude-haiku-4-5": {
        "input": 1.00, "output": 5.00,
        "cache_write_5m": 1.25, "cache_write_1h": 2.00,
        "cache_read": 0.10,
        "batch_input": 0.50, "batch_output": 2.50
    },
}

@dataclass
class RequestCost:
    input_cost: float
    output_cost: float
    cache_write_cost: float
    cache_read_cost: float
    search_cost: float
    total_cost: float
    input_tokens: int
    output_tokens: int

    def __str__(self):
        return (
            f"Input: {self.input_tokens:,} tokens (${self.input_cost:.4f}) | "
            f"Output: {self.output_tokens:,} tokens (${self.output_cost:.4f}) | "
            f"Cache: write ${self.cache_write_cost:.4f}, "
            f"read ${self.cache_read_cost:.4f} | "
            f"Search: ${self.search_cost:.4f} | "
            f"Total: ${self.total_cost:.4f}"
        )


def calculate_request_cost(
    model: str,
    usage,
    is_batch: bool = False,
    cache_ttl: str = "5m"
) -> RequestCost:
    """Calculate exact cost from a response's usage object."""
    prices = MODEL_PRICES.get(model)
    if not prices:
        raise ValueError(f"Unknown model: {model}")

    # Adjust for batch pricing (50% discount)
    input_price = prices["batch_input"] if is_batch else prices["input"]
    output_price = prices["batch_output"] if is_batch else prices["output"]

    cache_write_key = f"cache_write_{cache_ttl}"
    cache_write_price = prices.get(cache_write_key, prices["cache_write_5m"])

    input_cost = usage.input_tokens * input_price / 1_000_000
    output_cost = usage.output_tokens * output_price / 1_000_000

    cache_read_tokens = getattr(usage, "cache_read_input_tokens", 0) or 0
    cache_write_tokens = getattr(usage, "cache_creation_input_tokens", 0) or 0
    cache_write_cost = cache_write_tokens * cache_write_price / 1_000_000
    cache_read_cost = cache_read_tokens * prices["cache_read"] / 1_000_000

    server_tools = getattr(usage, "server_tool_use", None)
    web_searches = 0
    if server_tools:
        web_searches = getattr(server_tools, "web_search_requests", 0) or 0
    search_cost = web_searches * 0.01

    total = input_cost + output_cost + cache_write_cost + cache_read_cost + search_cost

    return RequestCost(
        input_cost=round(input_cost, 6),
        output_cost=round(output_cost, 6),
        cache_write_cost=round(cache_write_cost, 6),
        cache_read_cost=round(cache_read_cost, 6),
        search_cost=round(search_cost, 4),
        total_cost=round(total, 6),
        input_tokens=usage.input_tokens,
        output_tokens=usage.output_tokens,
    )


# Usage
client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=2048,
    messages=[{"role": "user", "content": "Explain prompt caching in detail"}]
)

cost = calculate_request_cost("claude-sonnet-4-6", response.usage)
print(cost)
# Input: 12 tokens ($0.0000) | Output: 847 tokens ($0.0127) |
# Cache: write $0.0000, read $0.0000 | Search: $0.0000 |
# Total: $0.0128
```

Once you have per-request costs, find your expensive outliers:

```python
# Find the top 5% most expensive requests
costs_sorted = sorted(all_costs, key=lambda c: c.total_cost, reverse=True)
top_5_pct = costs_sorted[:len(costs_sorted) // 20]
print(f"Top 5% of requests cost: ${sum(c.total_cost for c in top_5_pct):.2f}")
print(f"Total spend: ${sum(c.total_cost for c in costs_sorted):.2f}")
print(f"Top 5% share: {sum(c.total_cost for c in top_5_pct) / sum(c.total_cost for c in costs_sorted):.0%}")
```

## The Tradeoffs

Per-request tracking adds a small computational overhead to every API call (microseconds for the cost calculation, milliseconds for the database write). For latency-sensitive applications serving real-time user requests, batch the database writes using an in-memory buffer that flushes every 100 requests or 10 seconds. The pricing dictionary needs manual updates when Anthropic changes rates. Consider fetching prices from a config service rather than hardcoding them.

## Implementation Checklist

- Add the `calculate_request_cost` function to your API wrapper
- Log every request's cost with metadata (endpoint, user, feature)
- Build a daily report of the top 20 most expensive requests
- Identify patterns in expensive requests (large context, specific features)
- Set per-request cost thresholds ($0.50, $1.00) and investigate requests exceeding them
- Track cost distribution: what percentage of requests generate what percentage of spend

## Measuring Impact

After one week of per-request tracking, generate a Pareto analysis. Typically, 10-20% of request types generate 60-80% of costs. These are your optimization targets. A common finding: long-running agentic sessions with growing context windows produce requests costing $0.50-$2.00 each, while 90% of requests cost under $0.05. Optimizing just the top 10% of requests (context windowing, model routing, caching) typically cuts total spend by 25-40%.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Enterprise Seat Management and Usage Monitoring](/claude-code-enterprise-seat-management-and-usage-monitoring/)
- [Claude Code for Cost Optimization Monitoring Guide](/claude-code-for-cost-optimization-monitoring-guide/)
- [Cost Allocation and Chargebacks for Enterprise Claude Code](/cost-allocation-and-chargebacks-for-enterprise-claude-code/)

## See Also

- [Claude Code Context Management Cost Tips 2026](/claude-code-context-management-cost-tips-2026/)
- [How 5 Parallel Claude Agents Cost $1,000/Month](/5-parallel-claude-agents-1000-per-month/)
