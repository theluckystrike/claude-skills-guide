---
layout: default
title: "Build a Claude Cost Attribution System"
description: "A 5-agent fleet had one agent consuming 3x tokens from runaway loops. Attribution found it, saving $300/month with a single fix."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /build-claude-cost-attribution-system/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, attribution, monitoring]
---

# Build a Claude Cost Attribution System

A 5-agent fleet spending $1,000/month on Claude API had one agent consuming $400 of that budget -- 3x more than any other agent -- due to a retry loop bug. Without per-agent cost attribution, the problem was invisible for months. After deploying attribution tracking, the team identified the runaway agent in 24 hours, fixed the loop, and reduced that agent's spend to $100/month. The $300/month savings took one afternoon to implement.

## The Setup

Cost attribution means tagging every API request with metadata that identifies who or what generated it: which agent, which user, which feature, which task. The Claude API doesn't provide built-in tagging, so you implement it at the application layer by wrapping API calls with a context object that includes attribution fields. These fields travel with the cost data into your analytics system, enabling drill-down views from total spend to individual request costs. The granularity of your attribution determines the precision of your optimization -- you can only cut costs you can see.

## The Math

A 5-agent fleet with $1,000/month total spend:

**Before attribution (blind allocation):**
- Assumed: $200/agent/month (even split)
- Reality: Agent-1: $100, Agent-2: $150, Agent-3: $150, Agent-4: $200, Agent-5: $400
- Agent-5 had a retry loop: 3x normal API calls

**After attribution and fix:**
- Agent-5 retry loop fixed: $400 drops to $100/month
- Total: $700/month (from $1,000)
- **Savings: $300/month (30%)**

Further optimization enabled by attribution:
- Agent-2 (summarization) moved from Opus to Sonnet: $150 drops to $90
- Agent-4 (classification) moved from Sonnet to Haiku: $200 drops to $67
- **Additional savings: $193/month**
- **Total savings: $493/month (49% of original spend)**

## The Technique

Build a comprehensive attribution system with hierarchical tags.

```python
import anthropic
import json
from dataclasses import dataclass, field, asdict
from datetime import datetime
from typing import Optional
from contextlib import contextmanager

PRICING = {
    "claude-opus-4-7": {"input": 5.00, "output": 25.00},
    "claude-sonnet-4-6": {"input": 3.00, "output": 15.00},
    "claude-haiku-4-5": {"input": 1.00, "output": 5.00},
}

@dataclass
class Attribution:
    agent_id: str
    task_type: str
    user_id: Optional[str] = None
    project: Optional[str] = None
    feature: Optional[str] = None
    session_id: Optional[str] = None
    parent_task_id: Optional[str] = None

@dataclass
class CostRecord:
    timestamp: str
    attribution: Attribution
    model: str
    input_tokens: int
    output_tokens: int
    total_cost: float
    request_id: str = ""

class AttributedClient:
    """Claude client with built-in cost attribution."""

    def __init__(self, store_path: str = "cost_attribution.jsonl"):
        self.client = anthropic.Anthropic()
        self.store_path = store_path
        self._current_attribution: Optional[Attribution] = None

    @contextmanager
    def attribution(self, **kwargs):
        """Context manager for setting attribution on requests."""
        self._current_attribution = Attribution(**kwargs)
        try:
            yield self
        finally:
            self._current_attribution = None

    def create(self, **kwargs) -> anthropic.types.Message:
        """Make an attributed API call."""
        if not self._current_attribution:
            raise RuntimeError("Must set attribution before making requests")

        response = self.client.messages.create(**kwargs)

        model = kwargs.get("model", "unknown")
        prices = PRICING.get(model, PRICING["claude-sonnet-4-6"])
        cost = (
            response.usage.input_tokens * prices["input"] / 1_000_000
            + response.usage.output_tokens * prices["output"] / 1_000_000
        )

        record = CostRecord(
            timestamp=datetime.utcnow().isoformat(),
            attribution=self._current_attribution,
            model=model,
            input_tokens=response.usage.input_tokens,
            output_tokens=response.usage.output_tokens,
            total_cost=round(cost, 6),
            request_id=response.id,
        )

        self._store(record)
        return response

    def _store(self, record: CostRecord) -> None:
        """Append record to JSONL file."""
        with open(self.store_path, "a") as f:
            data = asdict(record)
            f.write(json.dumps(data) + "\n")


def generate_attribution_report(store_path: str = "cost_attribution.jsonl"):
    """Generate cost report grouped by attribution dimensions."""
    from collections import defaultdict

    by_agent = defaultdict(lambda: {"requests": 0, "cost": 0.0})
    by_task = defaultdict(lambda: {"requests": 0, "cost": 0.0})
    by_model = defaultdict(lambda: {"requests": 0, "cost": 0.0})

    with open(store_path) as f:
        for line in f:
            record = json.loads(line)
            agent = record["attribution"]["agent_id"]
            task = record["attribution"]["task_type"]
            model = record["model"]
            cost = record["total_cost"]

            by_agent[agent]["requests"] += 1
            by_agent[agent]["cost"] += cost
            by_task[task]["requests"] += 1
            by_task[task]["cost"] += cost
            by_model[model]["requests"] += 1
            by_model[model]["cost"] += cost

    print("=== COST BY AGENT ===")
    for agent, data in sorted(by_agent.items(),
                               key=lambda x: x[1]["cost"], reverse=True):
        print(f"  {agent}: {data['requests']} requests, "
              f"${data['cost']:.2f}")

    print("\n=== COST BY TASK TYPE ===")
    for task, data in sorted(by_task.items(),
                              key=lambda x: x[1]["cost"], reverse=True):
        print(f"  {task}: {data['requests']} requests, "
              f"${data['cost']:.2f}")

    print("\n=== COST BY MODEL ===")
    for model, data in sorted(by_model.items(),
                                key=lambda x: x[1]["cost"], reverse=True):
        avg = data["cost"] / data["requests"] if data["requests"] else 0
        print(f"  {model}: {data['requests']} requests, "
              f"${data['cost']:.2f} (avg ${avg:.4f}/req)")


# Usage
ac = AttributedClient()

with ac.attribution(agent_id="agent-1", task_type="classification",
                     project="customer-support"):
    response = ac.create(
        model="claude-haiku-4-5",
        max_tokens=100,
        messages=[{"role": "user", "content": "Classify: billing issue"}]
    )

with ac.attribution(agent_id="agent-3", task_type="code-generation",
                     project="dev-tools"):
    response = ac.create(
        model="claude-opus-4-7",
        max_tokens=4096,
        messages=[{"role": "user", "content": "Write a sorting function"}]
    )

generate_attribution_report()
```

## The Tradeoffs

Attribution adds a layer of instrumentation that all API call sites must use. Forgetting to wrap a call in an attribution context means unattributed costs that muddy your analysis. Enforce attribution through code review and linting rules that flag bare `client.messages.create()` calls. The JSONL storage approach works for small-to-medium volumes but needs replacement with a proper time-series database (InfluxDB, TimescaleDB) at scale. Attribution granularity is a spectrum: too coarse (agent-level only) misses optimization opportunities, too fine (per-user per-feature per-session) creates analysis paralysis.

## Implementation Checklist

- Define your attribution taxonomy: agent, task type, project, feature
- Wrap all API call sites with the AttributedClient
- Add linting rules to prevent unattributed API calls
- Set up daily and weekly attribution reports
- Review reports in team standups to identify optimization targets
- Act on the top 3 most expensive attribution categories each week
- Archive attribution data monthly for trend analysis

## Measuring Impact

The attribution system pays for itself when it surfaces the first actionable insight. Track "insights surfaced" and "dollars saved per insight." Common first findings: one agent type consuming disproportionate tokens (fix: loop detection), one task type using an over-powered model (fix: model routing), or one project generating 10x more requests than expected (fix: request deduplication). A well-maintained attribution system surfaces $500-$2,000/month in savings opportunities within the first week.

## Related Guides

- [Claude Code Enterprise Seat Management and Usage Monitoring](/claude-code-enterprise-seat-management-and-usage-monitoring/)
- [Cost Allocation and Chargebacks for Enterprise Claude Code](/cost-allocation-and-chargebacks-for-enterprise-claude-code/)
- [Claude Code for Cost Optimization Monitoring Guide](/claude-code-for-cost-optimization-monitoring-guide/)

## See Also

- [Per-Agent Cost Attribution in Claude Systems](/per-agent-cost-attribution-claude-systems/)
- [Reduce Claude Code Token Consumption by 60%](/reduce-claude-code-token-consumption-60-percent/)
