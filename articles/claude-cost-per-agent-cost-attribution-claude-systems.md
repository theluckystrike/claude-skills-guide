---
layout: default
title: "Per-Agent Cost Attribution in Claude Systems"
description: "Track costs per agent in multi-agent fleets. Identify which of your 5 agents consumes 40% of the $25/sprint budget."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /per-agent-cost-attribution-claude-systems/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, multi-agent, cost-tracking]
render_with_liquid: false
---

# Per-Agent Cost Attribution in Claude Systems

In a 5-agent fleet spending $25.00 per sprint on Opus 4.7, one agent often consumes 40% of the budget while another uses only 10%. Without per-agent cost attribution, you cannot identify which agents are over-consuming, which tasks are expensive, or where model routing would save money.

## The Setup

You run a multi-agent system for automated code documentation. Five agents work in parallel: one analyzes the codebase structure, one writes function docs, one generates examples, one creates API references, and one produces tutorials.

Your total sprint cost is $25.00, but you suspect the tutorial agent -- which requires more reasoning and produces longer output -- costs significantly more than the example generator. Without attribution data, you are optimizing blind.

After implementing per-agent tracking, you discover the tutorial agent costs $10.00/sprint (40% of budget) while the example generator costs $2.50/sprint (10%). This data drives a targeted optimization: moving the example generator to Haiku saves $2.00/sprint without quality impact.

## The Math

**5-agent fleet, Opus 4.7, actual per-agent costs:**

| Agent | Task | Input Tokens | Output Tokens | Input Cost | Output Cost | Total | % of Budget |
|-------|------|-------------|--------------|-----------|------------|-------|------------|
| 1 | Structure analysis | 600K | 50K | $3.00 | $1.25 | $4.25 | 17% |
| 2 | Function docs | 400K | 120K | $2.00 | $3.00 | $5.00 | 20% |
| 3 | Examples | 300K | 80K | $1.50 | $2.00 | $3.50 | 14% |
| 4 | API reference | 450K | 90K | $2.25 | $2.25 | $4.50 | 18% |
| 5 | Tutorials | 500K | 180K | $2.50 | $4.50 | $7.00 | 28% |
| **Total** | | **2.25M** | **520K** | **$11.25** | **$13.00** | **$24.25** | |

**After moving Agent 3 (examples) to Haiku 4.5:**
- Agent 3 cost: $0.30 + $0.40 = $0.70 (was $3.50)
- Fleet total: $21.45 (was $24.25)
- **Savings: $2.80/sprint ($84/month)**

## The Technique

Implement a cost attribution system that tracks every API call by agent, task, and model:

```python
import anthropic
import json
import time
from dataclasses import dataclass, field
from datetime import datetime

client = anthropic.Anthropic()

MODEL_PRICES = {
    "claude-opus-4-7-20250415": {"input": 5.00, "output": 25.00},
    "claude-sonnet-4-6-20250929": {"input": 3.00, "output": 15.00},
    "claude-haiku-4-5-20251001": {"input": 1.00, "output": 5.00},
}


@dataclass
class CostEntry:
    agent_id: int
    task_type: str
    model: str
    input_tokens: int
    output_tokens: int
    cost: float
    timestamp: str


@dataclass
class CostTracker:
    sprint_id: str
    entries: list[CostEntry] = field(default_factory=list)

    def record(
        self,
        agent_id: int,
        task_type: str,
        model: str,
        input_tokens: int,
        output_tokens: int
    ) -> float:
        """Record a cost entry and return the cost."""
        prices = MODEL_PRICES[model]
        cost = (
            input_tokens * prices["input"] +
            output_tokens * prices["output"]
        ) / 1e6

        self.entries.append(CostEntry(
            agent_id=agent_id,
            task_type=task_type,
            model=model,
            input_tokens=input_tokens,
            output_tokens=output_tokens,
            cost=cost,
            timestamp=datetime.now().isoformat()
        ))
        return cost

    def by_agent(self) -> dict:
        """Aggregate costs by agent."""
        agents = {}
        for entry in self.entries:
            aid = entry.agent_id
            if aid not in agents:
                agents[aid] = {
                    "total_cost": 0, "calls": 0,
                    "input_tokens": 0, "output_tokens": 0,
                    "tasks": {}
                }
            agents[aid]["total_cost"] += entry.cost
            agents[aid]["calls"] += 1
            agents[aid]["input_tokens"] += entry.input_tokens
            agents[aid]["output_tokens"] += entry.output_tokens

            task = entry.task_type
            if task not in agents[aid]["tasks"]:
                agents[aid]["tasks"][task] = 0
            agents[aid]["tasks"][task] += entry.cost

        return agents

    def report(self) -> str:
        """Generate a cost attribution report."""
        total = sum(e.cost for e in self.entries)
        by_agent = self.by_agent()

        lines = [f"Sprint {self.sprint_id} Cost Report",
                 f"{'='*50}",
                 f"Total cost: ${total:.4f}",
                 f"Total calls: {len(self.entries)}",
                 ""]

        for aid in sorted(by_agent.keys()):
            data = by_agent[aid]
            pct = data["total_cost"] / total * 100 if total > 0 else 0
            lines.append(
                f"Agent {aid}: ${data['total_cost']:.4f} "
                f"({pct:.1f}%) - {data['calls']} calls"
            )
            for task, cost in data["tasks"].items():
                lines.append(f"  {task}: ${cost:.4f}")

        return "\n".join(lines)

    def save(self, filepath: str) -> None:
        """Save cost data to JSON for analysis."""
        data = {
            "sprint_id": self.sprint_id,
            "total_cost": sum(e.cost for e in self.entries),
            "entries": [
                {
                    "agent_id": e.agent_id,
                    "task_type": e.task_type,
                    "model": e.model,
                    "input_tokens": e.input_tokens,
                    "output_tokens": e.output_tokens,
                    "cost": e.cost,
                    "timestamp": e.timestamp
                }
                for e in self.entries
            ]
        }
        with open(filepath, "w") as f:
            json.dump(data, f, indent=2)


# Usage
tracker = CostTracker(sprint_id="S15")

def tracked_call(
    tracker: CostTracker,
    agent_id: int,
    task_type: str,
    model: str,
    system: str,
    message: str,
    max_tokens: int = 2048
) -> str:
    """Make an API call with cost tracking."""
    response = client.messages.create(
        model=model,
        max_tokens=max_tokens,
        system=system,
        messages=[{"role": "user", "content": message}]
    )

    usage = response.usage
    cost = tracker.record(
        agent_id=agent_id,
        task_type=task_type,
        model=model,
        input_tokens=usage.input_tokens,
        output_tokens=usage.output_tokens
    )

    return response.content[0].text


# After sprint
print(tracker.report())
tracker.save("costs/sprint-15.json")
```

Quick cost analysis from saved data:

```bash
# Analyze sprint cost data
python3 -c "
import json

data = json.load(open('costs/sprint-15.json'))
entries = data['entries']

# Top cost agents
from collections import defaultdict
by_agent = defaultdict(float)
for e in entries:
    by_agent[e['agent_id']] += e['cost']

print('Cost by agent:')
for aid, cost in sorted(by_agent.items(), key=lambda x: -x[1]):
    pct = cost / data['total_cost'] * 100
    print(f'  Agent {aid}: \${cost:.4f} ({pct:.1f}%)')

# Optimization opportunities
print(f\"\\nTotal: \${data['total_cost']:.4f}\")
print('Agents above 25% budget share are optimization candidates')
"
```

## The Tradeoffs

Cost attribution adds development and runtime overhead:

- **Implementation cost**: Building and maintaining the tracking system requires engineering time. For fleets spending under $100/month, the optimization savings may not justify the investment.
- **Storage requirements**: Logging every API call at the token level generates significant data. A 5-agent fleet making 500 calls/sprint produces ~500 cost entries per sprint.
- **Privacy considerations**: Cost data may reveal information about prompt content or task complexity. Ensure cost logs do not contain sensitive prompt text.
- **Attribution accuracy**: Token counts from the API are exact, but cost calculations depend on the pricing table being current. Update prices when Anthropic changes rates.

## Implementation Checklist

1. Add agent_id and task_type metadata to every API call
2. Extract input_tokens and output_tokens from every response's usage field
3. Calculate per-call cost using current model pricing
4. Aggregate by agent, task type, and model for sprint-level reports
5. Identify agents consuming more than 25% of the fleet budget
6. Evaluate whether high-cost agents can be moved to cheaper models
7. Generate weekly cost attribution reports for review

## Measuring Impact

Use attribution data to drive optimization:

- **Cost concentration index**: Percentage of total cost consumed by the most expensive agent. Above 40% signals an optimization opportunity.
- **Cost per output unit**: Cost per article, review, or document by agent. Normalizes for different output volumes.
- **Model optimization candidates**: Agents with high cost but simple task types are candidates for Haiku/Sonnet routing.
- **Sprint-over-sprint trend**: Track per-agent costs across sprints to catch creeping cost increases early.

## Related Guides

- [Claude Opus Orchestrator Sonnet Worker Architecture](/claude-opus-orchestrator-sonnet-worker-architecture/)
- [Parallel Subagents Claude Code Best Practices](/parallel-subagents-claude-code-best-practices-2026/)
- [Monitoring and Logging Claude Code Multi-Agent Systems](/monitoring-and-logging-claude-code-multi-agent-systems/)

## Related Articles

- [Build a Claude Cost Attribution System](/build-claude-cost-attribution-system/)
