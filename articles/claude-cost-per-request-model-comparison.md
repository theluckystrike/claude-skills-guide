---
layout: default
title: "Claude Cost Per Request by Model Comparison"
description: "Each Claude API request costs $0.015 on Haiku, $0.045 on Sonnet, or $0.075 on Opus — here is how to calculate your exact spend."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-cost-per-request-model-comparison/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
render_with_liquid: false
---

# Claude Cost Per Request by Model Comparison

A single Claude API request with 5,000 input tokens and 2,000 output tokens costs $0.075 on Opus 4.7, $0.045 on Sonnet 4.6, or $0.015 on Haiku 4.5. At 10,000 requests per day, that difference is $600/day between Opus and Haiku — $18,000/month.

## The Setup

Developers often think in monthly budgets, but cost optimization happens at the per-request level. Knowing the exact cost of each API call lets you identify expensive request patterns and target them for optimization.

This guide provides per-request cost formulas for every Claude model and pricing tier, including batch processing and prompt caching combinations. Use it as a reference to calculate the true cost of your API usage patterns.

## The Math

### Cost Per Request Formula

Cost = (input_tokens * input_rate / 1,000,000) + (output_tokens * output_rate / 1,000,000)

### Standard Pricing — Cost Per Request at Common Token Volumes

| Tokens (in/out) | Opus 4.7 | Sonnet 4.6 | Haiku 4.5 |
|-----------------|----------|-----------|-----------|
| 1K / 500 | $0.0175 | $0.0105 | $0.0035 |
| 5K / 2K | $0.075 | $0.045 | $0.015 |
| 10K / 5K | $0.175 | $0.105 | $0.035 |
| 50K / 10K | $0.500 | $0.300 | $0.100 |
| 100K / 20K | $1.000 | $0.600 | $0.200 |
| 500K / 50K | $3.750 | $2.250 | $0.750 |

### Batch Processing — 50% Discount

| Tokens (in/out) | Opus Batch | Sonnet Batch | Haiku Batch |
|-----------------|-----------|-------------|------------|
| 5K / 2K | $0.0375 | $0.0225 | $0.0075 |
| 10K / 5K | $0.0875 | $0.0525 | $0.0175 |
| 50K / 10K | $0.250 | $0.150 | $0.050 |
| 100K / 20K | $0.500 | $0.300 | $0.100 |

### Monthly Cost Projections at 10,000 Requests/Day

At 5K input + 2K output tokens per request:

| Model | Daily | Monthly | Yearly |
|-------|-------|---------|--------|
| Opus 4.7 | $750 | $22,500 | $270,000 |
| Sonnet 4.6 | $450 | $13,500 | $162,000 |
| Haiku 4.5 | $150 | $4,500 | $54,000 |
| Opus Batch | $375 | $11,250 | $135,000 |
| Haiku Batch | $75 | $2,250 | $27,000 |

The range from most expensive (Opus standard) to cheapest (Haiku batch) is 10x: $270,000/year versus $27,000/year.

## The Technique

Track per-request costs in real-time with a lightweight cost calculator middleware:

```python
import anthropic
import json
from datetime import datetime

client = anthropic.Anthropic()

RATES = {
    "claude-opus-4-7": {"input": 5.0, "output": 25.0, "batch_input": 2.5, "batch_output": 12.5},
    "claude-sonnet-4-6": {"input": 3.0, "output": 15.0, "batch_input": 1.5, "batch_output": 7.5},
    "claude-haiku-4-5-20251001": {"input": 1.0, "output": 5.0, "batch_input": 0.5, "batch_output": 2.5},
}

def tracked_request(model: str, prompt: str, system: str = "",
                    max_tokens: int = 2048, log_file: str = "cost_log.jsonl") -> dict:
    """Make an API request and log the exact cost."""
    response = client.messages.create(
        model=model,
        max_tokens=max_tokens,
        system=system,
        messages=[{"role": "user", "content": prompt}],
    )

    rates = RATES[model]
    input_cost = response.usage.input_tokens * rates["input"] / 1_000_000
    output_cost = response.usage.output_tokens * rates["output"] / 1_000_000
    total_cost = input_cost + output_cost

    log_entry = {
        "timestamp": datetime.utcnow().isoformat(),
        "model": model,
        "input_tokens": response.usage.input_tokens,
        "output_tokens": response.usage.output_tokens,
        "input_cost": round(input_cost, 6),
        "output_cost": round(output_cost, 6),
        "total_cost": round(total_cost, 6),
    }

    with open(log_file, "a") as f:
        f.write(json.dumps(log_entry) + "\n")

    return {
        "content": response.content[0].text,
        **log_entry,
    }

# Analyze cost logs
def analyze_costs(log_file: str = "cost_log.jsonl") -> dict:
    """Summarize costs from the log file."""
    costs_by_model = {}
    total_requests = 0
    total_cost = 0.0

    with open(log_file) as f:
        for line in f:
            entry = json.loads(line)
            model = entry["model"]
            cost = entry["total_cost"]
            costs_by_model.setdefault(model, {"count": 0, "cost": 0.0})
            costs_by_model[model]["count"] += 1
            costs_by_model[model]["cost"] += cost
            total_requests += 1
            total_cost += cost

    return {
        "total_requests": total_requests,
        "total_cost": round(total_cost, 4),
        "avg_cost_per_request": round(total_cost / max(total_requests, 1), 6),
        "by_model": costs_by_model,
    }

result = tracked_request("claude-haiku-4-5-20251001", "What is 2+2?")
print(f"Cost: ${result['total_cost']:.6f}")
```

Use the cost log to identify your most expensive request patterns:

```bash
# Find your top 10 most expensive requests
python3 -c "
import json
entries = [json.loads(l) for l in open('cost_log.jsonl')]
entries.sort(key=lambda x: x['total_cost'], reverse=True)
for e in entries[:10]:
    print(f\"\${e['total_cost']:.4f} | {e['model']} | {e['input_tokens']}in/{e['output_tokens']}out\")
"
```

## The Tradeoffs

Per-request cost tracking adds minimal latency (a single file write) but requires log management. At high volumes (100K+ requests/day), the log file grows quickly — implement daily rotation and aggregation.

Cost-per-request analysis can create a false sense of optimization. A $0.015 Haiku request that produces unusable output is more expensive than a $0.075 Opus request that works the first time. Always factor in retry rates when comparing models.

## Implementation Checklist

1. Add cost tracking to your API client wrapper
2. Log every request with model, token counts, and calculated cost
3. Run a weekly cost analysis to identify the most expensive request patterns
4. Compare per-request costs across models for your top 5 patterns
5. Switch the highest-volume pattern to a cheaper model first
6. Validate quality before switching additional patterns

## Measuring Impact

Review cost logs weekly. Key metrics: average cost per request (target: below $0.03 for mixed workloads), 95th percentile cost per request (identifies expensive outliers), and total monthly spend (the bottom line). Plot cost per request over time — it should trend downward as you optimize routing. Set alerts for any request costing more than $1.00 to catch runaway context sizes.

## Related Guides

- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — detailed breakdown of Claude's token-based pricing structure
- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — reduce tokens to reduce per-request cost
- [Claude Skill Token Usage Profiling](/claude-skill-token-usage-profiling-and-optimization/) — measure token usage per workflow
