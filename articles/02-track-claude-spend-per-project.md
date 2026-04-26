---
layout: default
title: "Track Claude Token Spend Per Project (2026)"
description: "Per-project cost tracking reveals that 1 of 10 client projects consumes 27% of your Claude API spend. Here's how to build attribution."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /track-claude-token-spend-per-project-team/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, attribution, project-tracking]
---

# Track Claude Token Spend Per Project and Team

An agency running 10 client projects on a shared Claude API key discovered that Client A consumed $800/month while Client B used only $50/month. Without per-project tracking, they'd been splitting the $3,000 monthly bill evenly at $300 per client -- subsidizing heavy users with light users' budgets. Per-project attribution isn't just an accounting exercise; it's a profitability requirement.

## The Setup

The Claude API doesn't natively group costs by project or team. Every request goes through the same API key, and the Console shows aggregate billing. To get per-project attribution, you need to tag each request at the application layer and calculate costs from the `usage` object in each response. This requires a thin middleware layer between your application code and the Anthropic SDK that attaches metadata (project ID, team, user, feature) to every request and logs the associated cost.

## The Math

An agency with $3,000/month Claude spend across 10 clients:

**Before (even split):**
- Each client billed: $300/month
- Total billed to clients: $3,000
- Client A actual usage: $800 (undercharged by $500)
- Client B actual usage: $50 (overcharged by $250)
- Revenue leak from misattribution: clients subsidizing each other

**After (per-project tracking):**

| Client | Monthly Spend | Markup (30%) | Monthly Bill |
|--------|-------------|-------------|-------------|
| A | $800 | $240 | $1,040 |
| B | $50 | $15 | $65 |
| C | $450 | $135 | $585 |
| D-J (7 clients) | $1,700 combined | $510 | $2,210 |
| **Total** | **$3,000** | **$900** | **$3,900** |

**Revenue improvement: $900/month in proper markups, plus fairness across clients**

## The Technique

Build a project-aware cost tracker using request metadata.

```python
import anthropic
import json
from datetime import datetime
from collections import defaultdict
from dataclasses import dataclass, field

PRICING = {
    "claude-opus-4-7": {"input": 5.00, "output": 25.00,
                         "cache_read": 0.50, "cache_write": 6.25},
    "claude-sonnet-4-6": {"input": 3.00, "output": 15.00,
                           "cache_read": 0.30, "cache_write": 3.75},
    "claude-haiku-4-5": {"input": 1.00, "output": 5.00,
                          "cache_read": 0.10, "cache_write": 1.25},
}

@dataclass
class ProjectCostEntry:
    timestamp: str
    project: str
    team: str
    model: str
    input_tokens: int
    output_tokens: int
    total_cost: float

@dataclass
class ProjectTracker:
    entries: list[ProjectCostEntry] = field(default_factory=list)

    def log(self, project: str, team: str, model: str,
            usage) -> float:
        prices = PRICING.get(model, PRICING["claude-sonnet-4-6"])

        input_cost = usage.input_tokens * prices["input"] / 1_000_000
        output_cost = usage.output_tokens * prices["output"] / 1_000_000

        cache_read = getattr(usage, "cache_read_input_tokens", 0) or 0
        cache_write = getattr(usage, "cache_creation_input_tokens", 0) or 0
        cache_cost = (
            cache_read * prices["cache_read"] / 1_000_000
            + cache_write * prices["cache_write"] / 1_000_000
        )

        total = input_cost + output_cost + cache_cost

        self.entries.append(ProjectCostEntry(
            timestamp=datetime.utcnow().isoformat(),
            project=project,
            team=team,
            model=model,
            input_tokens=usage.input_tokens,
            output_tokens=usage.output_tokens,
            total_cost=total,
        ))
        return total

    def report_by_project(self) -> dict:
        """Aggregate costs by project."""
        totals = defaultdict(lambda: {
            "requests": 0, "input_tokens": 0,
            "output_tokens": 0, "total_cost": 0.0
        })
        for entry in self.entries:
            p = totals[entry.project]
            p["requests"] += 1
            p["input_tokens"] += entry.input_tokens
            p["output_tokens"] += entry.output_tokens
            p["total_cost"] += entry.total_cost
        return dict(totals)

    def report_by_team(self) -> dict:
        """Aggregate costs by team."""
        totals = defaultdict(lambda: {
            "requests": 0, "total_cost": 0.0
        })
        for entry in self.entries:
            t = totals[entry.team]
            t["requests"] += 1
            t["total_cost"] += entry.total_cost
        return dict(totals)

    def export_csv(self, path: str) -> None:
        """Export entries for billing systems."""
        import csv
        with open(path, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "timestamp", "project", "team", "model",
                "input_tokens", "output_tokens", "total_cost"
            ])
            for e in self.entries:
                writer.writerow([
                    e.timestamp, e.project, e.team, e.model,
                    e.input_tokens, e.output_tokens,
                    round(e.total_cost, 6)
                ])


# Usage
client = anthropic.Anthropic()
tracker = ProjectTracker()

def call_claude(prompt: str, project: str, team: str,
                model: str = "claude-sonnet-4-6") -> str:
    response = client.messages.create(
        model=model,
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}]
    )
    cost = tracker.log(project, team, model, response.usage)
    print(f"[{project}] Cost: ${cost:.4f}")
    return response.content[0].text

# Track different projects
call_claude("Summarize this report...", "client-a", "backend")
call_claude("Classify this ticket...", "client-b", "support")

# Generate reports
for project, data in tracker.report_by_project().items():
    print(f"{project}: {data['requests']} requests, ${data['total_cost']:.2f}")
```

## The Tradeoffs

Per-project tracking requires discipline in tagging every request. Untagged requests go to a "default" bucket that defeats the purpose. In microservice architectures, propagating project context across service boundaries adds complexity. For teams using shared prompts across projects, you'll need to decide whether to attribute shared costs proportionally or to a shared overhead bucket. Start with coarse-grained attribution (project level) before investing in fine-grained tracking (feature or user level).

A common mistake is tracking only input and output token costs while ignoring cache write costs, cache read costs, and web search fees ($10.00 per 1,000 searches). For accurate attribution, your tracker must parse `cache_read_input_tokens`, `cache_creation_input_tokens`, and `server_tool_use.web_search_requests` from every response. Without these fields, your per-project costs will underreport by 15-40% for projects that use caching or web search heavily.

## Implementation Checklist

- Define your project and team taxonomy (consistent naming is critical)
- Wrap all Claude API calls with the tracking middleware
- Ensure every call site passes project and team identifiers
- Set up daily export of cost data to CSV or your billing system
- Build a weekly report that shows spend by project and by team
- Review the "untagged" bucket weekly and fix missing attributions
- Add project/team to your code review checklist for new API call sites

## Measuring Impact

The tracker itself costs nothing in API overhead (it only reads the usage object already in the response). Measure its value by tracking billing accuracy: compare pre-attribution revenue (flat splits) to post-attribution revenue (actual usage billing). Most agencies find 20-40% of clients are over-billed and 10-20% are under-billed. Correcting this improves both fairness and profitability. The typical revenue improvement from accurate attribution is 15-30% of total Claude API spend.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Enterprise Seat Management and Usage Monitoring](/claude-code-enterprise-seat-management-and-usage-monitoring/)
- [Cost Allocation and Chargebacks for Enterprise Claude Code](/cost-allocation-and-chargebacks-for-enterprise-claude-code/)
- [Claude Code for Cost Optimization Monitoring Guide](/claude-code-for-cost-optimization-monitoring-guide/)

- [Claude Code cost guide](/claude-code-cost-complete-guide/) — Complete guide to Claude Code costs, pricing, and optimization
