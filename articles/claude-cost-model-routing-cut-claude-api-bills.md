---
layout: default
title: "Model Routing by Task Cuts Claude API (2026)"
description: "Model Routing by Task Cuts Claude API — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /model-routing-cut-claude-api-bills/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# Model Routing by Task Cuts Claude API Bills

A production pipeline sending 1 million requests per month through Claude Opus 4.7 costs $75,000. Adding an intelligent model router that sends 70% of simple tasks to Haiku 4.5 and keeps 30% on Opus drops that to $33,000/month — saving $42,000 every month with no infrastructure changes beyond the router itself.

## The Setup

Model routing is the practice of automatically selecting the cheapest Claude model that meets quality requirements for each individual request. Instead of one model for all tasks, you classify incoming requests by complexity and route them to the appropriate tier.

The three current Claude models span a 5x price range: Haiku 4.5 at $1.00/$5.00 per MTok, Sonnet 4.6 at $3.00/$15.00, and Opus 4.7 at $5.00/$25.00. Most production workloads contain a mix of simple and complex tasks. Routing exploits this distribution.

This guide covers a complete model routing implementation with classification logic, fallback handling, and cost tracking.

## The Math

Enterprise pipeline: 1,000,000 requests/month, 5K input + 2K output tokens average.

**Before (all Opus):**
- Input: 5B * $5.00/MTok = $25,000
- Output: 2B * $25.00/MTok = $50,000
- **Total: $75,000/month**

**After (70% Haiku / 20% Sonnet / 10% Opus):**
- Haiku: 700K * (5K * $1 + 2K * $5) / 1M = 700K * $0.015 = $10,500
- Sonnet: 200K * (5K * $3 + 2K * $15) / 1M = 200K * $0.045 = $9,000
- Opus: 100K * (5K * $5 + 2K * $25) / 1M = 100K * $0.075 = $7,500
- **Total: $27,000/month**

**Savings: $48,000/month (64%)**

Even a conservative 50/30/20 split saves $34,500/month.

## The Technique

Build a three-tier model router with automatic quality fallback:

```python
import anthropic
import time
from dataclasses import dataclass, field
from typing import Optional

client = anthropic.Anthropic()

@dataclass
class RoutingResult:
    model: str
    content: str
    input_tokens: int
    output_tokens: int
    cost: float
    was_escalated: bool = False

MODEL_TIERS = [
    {"name": "claude-haiku-4-5-20251001", "input_rate": 1.0, "output_rate": 5.0},
    {"name": "claude-sonnet-4-6", "input_rate": 3.0, "output_rate": 15.0},
    {"name": "claude-opus-4-7", "input_rate": 5.0, "output_rate": 25.0},
]

# Complexity classification rules
COMPLEXITY_RULES = {
    0: {  # Haiku tier
        "max_input_tokens": 5000,
        "task_patterns": ["classify", "extract", "detect", "label", "tag",
                          "yes or no", "true or false", "which category"],
    },
    1: {  # Sonnet tier
        "max_input_tokens": 50000,
        "task_patterns": ["summarize", "explain", "review", "draft",
                          "rewrite", "translate", "describe"],
    },
    2: {  # Opus tier
        "max_input_tokens": 1000000,
        "task_patterns": ["analyze the entire", "design a system",
                          "find the root cause", "architect",
                          "debug this complex", "security audit"],
    },
}

def classify_complexity(prompt: str, input_tokens: int) -> int:
    """Return model tier index (0=Haiku, 1=Sonnet, 2=Opus)."""
    prompt_lower = prompt.lower()

    # Check for Opus keywords first (highest priority)
    for pattern in COMPLEXITY_RULES[2]["task_patterns"]:
        if pattern in prompt_lower:
            return 2

    # Check Haiku keywords
    for pattern in COMPLEXITY_RULES[0]["task_patterns"]:
        if pattern in prompt_lower:
            if input_tokens <= COMPLEXITY_RULES[0]["max_input_tokens"]:
                return 0

    # Large inputs go to Sonnet minimum (Haiku caps at 200K context)
    if input_tokens > 200000:
        return 1

    # Default to Sonnet
    return 1

def route_request(
    prompt: str,
    system: str = "",
    max_tokens: int = 2048,
    quality_validator: Optional[callable] = None,
) -> RoutingResult:
    """Route request to cheapest viable model with optional escalation."""
    estimated_input = len(prompt.split()) * 2  # rough token estimate
    tier = classify_complexity(prompt, estimated_input)
    model_config = MODEL_TIERS[tier]

    response = client.messages.create(
        model=model_config["name"],
        max_tokens=max_tokens,
        system=system,
        messages=[{"role": "user", "content": prompt}],
    )

    content = response.content[0].text
    cost = (response.usage.input_tokens * model_config["input_rate"] +
            response.usage.output_tokens * model_config["output_rate"]) / 1_000_000

    # Optional quality check with escalation
    if quality_validator and not quality_validator(content) and tier < 2:
        next_tier = tier + 1
        next_config = MODEL_TIERS[next_tier]
        response = client.messages.create(
            model=next_config["name"],
            max_tokens=max_tokens,
            system=system,
            messages=[{"role": "user", "content": prompt}],
        )
        content = response.content[0].text
        escalation_cost = (response.usage.input_tokens * next_config["input_rate"] +
                          response.usage.output_tokens * next_config["output_rate"]) / 1_000_000
        cost += escalation_cost
        model_config = next_config

    return RoutingResult(
        model=model_config["name"],
        content=content,
        input_tokens=response.usage.input_tokens,
        output_tokens=response.usage.output_tokens,
        cost=cost,
        was_escalated=(tier != MODEL_TIERS.index(model_config)),
    )

# Usage example
result = route_request(
    prompt="Classify this email as spam or not spam: 'You won a prize! Click here!'",
    system="Respond with only SPAM or NOT_SPAM.",
)
print(f"Model: {result.model} | Cost: ${result.cost:.6f}")
```

Key design decisions in this router:

1. **Keyword-based classification** keeps the router fast (no API call for classification itself)
2. **Escalation on quality failure** prevents bad outputs from reaching users
3. **Cost tracking per request** enables monitoring and optimization
4. **Input token estimation** routes large-context requests away from Haiku's 200K limit

## The Tradeoffs

The router itself adds latency — roughly 1-2ms for keyword matching, but escalation doubles latency when triggered. Keep escalation rate below 5% to maintain response time SLAs.

Building the quality validator requires domain-specific logic. A generic "is this response good?" check does not work reliably. You need task-specific validators (e.g., "does the classification output match one of the allowed labels?").

Maintaining the routing rules requires ongoing attention. As your task mix changes, re-evaluate the keyword patterns and tier assignments quarterly.

## Implementation Checklist

1. Audit one week of API logs to identify task type distribution
2. Classify each task type into Haiku/Sonnet/Opus tier
3. Implement the routing logic with keyword-based classification
4. Add cost tracking to every request
5. Deploy with 10% of traffic, compare costs and quality
6. Scale to 100% after validating quality holds
7. Set up monthly routing optimization reviews

## Measuring Impact

Track three dashboards: (1) cost per request by model tier — verify the expected 56-64% reduction, (2) escalation rate — target below 5%, above that indicates poor initial routing, (3) quality scores by task category — any drop greater than 5% triggers a routing rule review. Export weekly cost reports comparing pre-router and post-router spend.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — understand the pricing model that makes routing valuable
- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — complement routing with token reduction
- [Claude Code Monthly Cost Breakdown](/claude-code-monthly-cost-breakdown-realistic-usage-estimates/) — baseline your costs before implementing routing

## See Also

- [How Context Window Size Drives Claude API Bills](/context-window-size-drives-claude-api-bills/)
- [Reducing Agent Fleet Costs with Model Routing](/reducing-agent-fleet-costs-model-routing/)
- [System Prompt Optimization to Cut Claude Costs](/system-prompt-optimization-cut-claude-costs/)
