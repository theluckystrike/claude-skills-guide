---
sitemap: false
layout: default
title: "Claude Agent Token Budget Management (2026)"
description: "Set per-agent token budgets to prevent runaway costs. A 5-agent fleet with 500K token caps stays under $25/sprint on Opus 4.7."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-agent-token-budget-management/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, multi-agent, token-budget]
---

# Claude Agent Token Budget Management Guide

Without token budgets, a single runaway agent loop can burn through $50+ in tokens before you notice. Setting per-agent budgets of 500K input and 100K output tokens caps each Opus 4.7 agent at $5.00/sprint. A 5-agent fleet with these budgets has a hard ceiling of $25.00/sprint regardless of what happens inside the agent loop.

## The Setup

You run a multi-agent coding system where agents iterate on tasks -- reading files, making changes, testing, and revising. Each agent iteration adds tool overhead: 346 tokens for the system prompt, 245 tokens per bash tool call, 700 tokens per text editor call. Over 100 iterations, tool overhead alone reaches 173,000 tokens across a 5-agent fleet.

Without budgets, an agent stuck in a retry loop can iterate hundreds of times, consuming millions of tokens. With budgets, the agent terminates gracefully when it hits its allocation, preserving the remaining budget for other agents.

## The Math

**Tool use overhead per sprint (verified):**
- System prompt overhead per agent: 346 tokens
- Per bash call: 245 tokens
- Per text editor call: 700 tokens
- Per computer use call: 735 tokens

**5 agents, 100 interactions each:**
- System overhead: 5 x 346 x 100 = 173,000 tokens
- If 50% bash + 50% editor: 5 x (50 x 245 + 50 x 700) = 236,250 tokens
- Total overhead: 409,250 tokens

**Overhead cost on Opus 4.7:**
- 409,250 x $5.00/MTok = $2.05 per sprint (just for tool overhead)

**Budget allocation example (Opus 4.7, 5 agents):**

| Agent | Input Budget | Output Budget | Max Input Cost | Max Output Cost | Max Total |
|-------|-------------|-------------|---------------|----------------|-----------|
| Agent 1 | 500K | 100K | $2.50 | $2.50 | $5.00 |
| Agent 2 | 500K | 100K | $2.50 | $2.50 | $5.00 |
| Agent 3 | 500K | 100K | $2.50 | $2.50 | $5.00 |
| Agent 4 | 500K | 100K | $2.50 | $2.50 | $5.00 |
| Agent 5 | 500K | 100K | $2.50 | $2.50 | $5.00 |
| **Total** | **2.5M** | **500K** | **$12.50** | **$12.50** | **$25.00** |

## The Technique

Implement token budgets as a wrapper around your API calls:

```python
import anthropic
from dataclasses import dataclass, field

client = anthropic.Anthropic()


@dataclass
class TokenBudget:
    """Track and enforce per-agent token budgets."""
    agent_id: int
    input_limit: int
    output_limit: int
    input_used: int = 0
    output_used: int = 0
    calls: int = 0

    @property
    def input_remaining(self) -> int:
        return max(0, self.input_limit - self.input_used)

    @property
    def output_remaining(self) -> int:
        return max(0, self.output_limit - self.output_used)

    @property
    def is_exhausted(self) -> bool:
        return self.input_remaining == 0 or self.output_remaining == 0

    @property
    def cost_so_far(self) -> float:
        """Cost estimate at Opus 4.7 pricing."""
        return (self.input_used * 5.0 + self.output_used * 25.0) / 1e6

    def record(self, input_tokens: int, output_tokens: int) -> None:
        self.input_used += input_tokens
        self.output_used += output_tokens
        self.calls += 1

    def __str__(self) -> str:
        return (
            f"Agent {self.agent_id}: "
            f"{self.input_used:,}/{self.input_limit:,} input, "
            f"{self.output_used:,}/{self.output_limit:,} output, "
            f"${self.cost_so_far:.3f}"
        )


class BudgetedAgent:
    """Agent wrapper that enforces token budgets."""

    def __init__(
        self,
        agent_id: int,
        model: str,
        input_limit: int = 500_000,
        output_limit: int = 100_000
    ):
        self.model = model
        self.budget = TokenBudget(
            agent_id=agent_id,
            input_limit=input_limit,
            output_limit=output_limit
        )

    def call(self, system: str, user_message: str, max_tokens: int = 2048) -> str:
        """Make an API call with budget enforcement."""
        if self.budget.is_exhausted:
            raise BudgetExhaustedError(
                f"Agent {self.budget.agent_id} budget exhausted: "
                f"{self.budget}"
            )

        # Cap max_tokens to remaining output budget
        effective_max = min(max_tokens, self.budget.output_remaining)

        response = client.messages.create(
            model=self.model,
            max_tokens=effective_max,
            system=system,
            messages=[{"role": "user", "content": user_message}]
        )

        usage = response.usage
        self.budget.record(usage.input_tokens, usage.output_tokens)

        # Warn at 80% utilization
        if self.budget.input_used > self.budget.input_limit * 0.8:
            print(f"WARNING: Agent {self.budget.agent_id} at "
                  f"{self.budget.input_used/self.budget.input_limit*100:.0f}% "
                  f"input budget")

        return response.content[0].text


class BudgetExhaustedError(Exception):
    pass


# Usage
agent = BudgetedAgent(
    agent_id=1,
    model="claude-opus-4-7-20250415",
    input_limit=500_000,
    output_limit=100_000
)

try:
    for i in range(200):  # Agent loop
        result = agent.call(
            system="You are a code reviewer.",
            user_message=f"Review iteration {i}: ..."
        )
except BudgetExhaustedError as e:
    print(f"Budget hit: {e}")

print(agent.budget)
```

Fleet-level budget monitoring:

```bash
# Monitor fleet budget utilization
python3 -c "
# Simulated fleet status
agents = [
    {'id': 1, 'input_used': 420000, 'input_limit': 500000, 'output_used': 85000, 'output_limit': 100000},
    {'id': 2, 'input_used': 310000, 'input_limit': 500000, 'output_used': 55000, 'output_limit': 100000},
    {'id': 3, 'input_used': 500000, 'input_limit': 500000, 'output_used': 98000, 'output_limit': 100000},
    {'id': 4, 'input_used': 180000, 'input_limit': 500000, 'output_used': 30000, 'output_limit': 100000},
    {'id': 5, 'input_used': 450000, 'input_limit': 500000, 'output_used': 90000, 'output_limit': 100000},
]

total_cost = 0
for a in agents:
    cost = (a['input_used'] * 5.0 + a['output_used'] * 25.0) / 1e6
    pct = a['input_used'] / a['input_limit'] * 100
    status = 'EXHAUSTED' if pct >= 100 else 'WARNING' if pct >= 80 else 'OK'
    total_cost += cost
    print(f'Agent {a[\"id\"]}: {pct:5.1f}% input | \${cost:.3f} | {status}')

print(f'\\nFleet total: \${total_cost:.3f} (budget: \$25.00)')
"
```

## The Tradeoffs

Token budgets protect against runaway costs but add constraints:

- **Premature termination**: An agent working on a complex task may exhaust its budget before completion. Size budgets based on observed task complexity, not arbitrary limits.
- **Uneven utilization**: Some agents finish under budget while others hit limits. Consider a shared budget pool where agents can draw from a common reserve.
- **Monitoring overhead**: Budget tracking adds code complexity and (minimal) compute overhead per API call.
- **Budget tuning requires data**: Initial budgets are guesses. Run 5-10 sprints to establish baseline token consumption per agent before setting firm limits.

## Implementation Checklist

1. Measure actual token usage per agent across 5-10 unbudgeted sprints
2. Set initial budgets at 120% of observed p95 usage (buffer for variance)
3. Implement the BudgetedAgent wrapper with usage tracking
4. Add 80% and 95% budget warning alerts
5. Implement graceful shutdown when budget is exhausted (save progress, report partial results)
6. Review and adjust budgets monthly based on actual usage patterns
7. Set a fleet-level budget cap as a final safety net

## Measuring Impact

Track budget effectiveness:

- **Budget hit rate**: Percentage of agents that exhaust their budget per sprint. Above 20% means budgets are too tight.
- **Utilization efficiency**: Average percentage of budget consumed per agent. Target: 60-80%. Below 50% means budgets are too generous.
- **Cost predictability**: Variance in sprint cost before and after budgets. With budgets, variance should approach zero.
- **Prevented overruns**: Track instances where budget enforcement stopped runaway loops. Each prevented overrun saves $10-50+.



**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Opus Orchestrator Sonnet Worker Architecture](/claude-opus-orchestrator-sonnet-worker-architecture/)
- [Parallel Subagents Claude Code Best Practices](/parallel-subagents-claude-code-best-practices-2026/)
- [Monitoring and Logging Claude Code Multi-Agent Systems](/monitoring-and-logging-claude-code-multi-agent-systems/)

## See Also

- [Text Editor Tool: 700 Token Overhead Explained](/claude-text-editor-tool-700-token-overhead/)
- [Claude Max Subscription vs API for Agent Fleets](/claude-max-subscription-vs-api-agent-fleets/)
- [Claude Context Management: Pay Less, Use More](/claude-context-management-pay-less-use-more/)
- [Claude Cache Minimum Token Requirements 2026](/claude-cache-minimum-token-requirements-2026/)
- [Claude Opus 4.7: Is It Worth the Extra Cost?](/claude-opus-47-is-it-worth-extra-cost/)
