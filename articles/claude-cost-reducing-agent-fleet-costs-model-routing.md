---
layout: default
title: "Reducing Agent Fleet Costs with Model (2026)"
description: "Claude Code cost insight: route 70% of agent tasks to Haiku ($1/$5 MTok) instead of Opus ($5/$25 MTok). Save $16/sprint with intelligent model selection."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /reducing-agent-fleet-costs-model-routing/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, multi-agent, model-routing]
---

# Reducing Agent Fleet Costs with Model Routing

Intelligent model routing sends each agent task to the cheapest model that can handle it. In a typical multi-agent fleet, 70% of tasks are structured enough for Haiku 4.5 at $1.00/$5.00 per MTok. Routing those to Haiku instead of defaulting to Opus at $5.00/$25.00 per MTok saves $16 per sprint -- $480/month at 30 sprints.

## The Setup

You run a 5-agent fleet where every agent currently uses Opus 4.7. After analyzing task complexity, you discover that only 30% of tasks actually need Opus-level reasoning. The remaining 70% are extraction, formatting, classification, or template-following tasks where Haiku produces equivalent output.

The router evaluates each task at dispatch time and selects the appropriate model. No changes to your prompts. No changes to your output format. Just a routing layer that drops your per-sprint cost from $25 to $9.

## The Math

**Before routing (all Opus 4.7):**
- 5 agents x 500K input x $5.00/MTok = $12.50
- 5 agents x 100K output x $25.00/MTok = $12.50
- **Total: $25.00/sprint**

**After routing (30% Opus, 70% Haiku by token volume):**
- Opus tokens: 750K input x $5.00/MTok + 150K output x $25.00/MTok = $7.50
- Haiku tokens: 1.75M input x $1.00/MTok + 350K output x $5.00/MTok = $3.50
- **Total: $11.00/sprint**

**Savings: $14.00/sprint (56%)**

With Sonnet 4.6 as a middle tier for moderate-complexity tasks:
- 20% Opus: $5.00
- 30% Sonnet: 900K x $3.00/MTok + 180K x $15.00/MTok = $5.40
- 50% Haiku: $2.50
- **Total: $12.90/sprint** (48% savings)

## The Technique

Build a model router that classifies tasks by complexity and routes to the cheapest capable model:

```python
import anthropic
from enum import Enum
from dataclasses import dataclass

client = anthropic.Anthropic()


class ModelTier(Enum):
    OPUS = "claude-opus-4-7-20250415"       # $5/$25 - complex reasoning
    SONNET = "claude-sonnet-4-6-20250929"    # $3/$15 - moderate tasks
    HAIKU = "claude-haiku-4-5-20251001"      # $1/$5  - simple execution


# Task complexity classification
TASK_ROUTES = {
    # Haiku-eligible: structured, template-based, extraction
    "extract_fields": ModelTier.HAIKU,
    "classify_text": ModelTier.HAIKU,
    "format_output": ModelTier.HAIKU,
    "check_style": ModelTier.HAIKU,
    "summarize_short": ModelTier.HAIKU,
    "translate_simple": ModelTier.HAIKU,
    "validate_schema": ModelTier.HAIKU,

    # Sonnet-eligible: moderate reasoning, longer output
    "write_documentation": ModelTier.SONNET,
    "explain_code": ModelTier.SONNET,
    "suggest_improvements": ModelTier.SONNET,
    "draft_response": ModelTier.SONNET,

    # Opus-required: complex reasoning, synthesis, judgment
    "architectural_review": ModelTier.OPUS,
    "security_analysis": ModelTier.OPUS,
    "task_decomposition": ModelTier.OPUS,
    "multi_source_synthesis": ModelTier.OPUS,
    "strategic_planning": ModelTier.OPUS,
}


@dataclass
class RoutedRequest:
    task_type: str
    model: str
    prompt: str
    max_tokens: int
    estimated_cost: float


def route_task(task_type: str, prompt: str, max_tokens: int = 2048) -> RoutedRequest:
    """Route a task to the appropriate model based on complexity."""

    tier = TASK_ROUTES.get(task_type, ModelTier.SONNET)  # Default to Sonnet

    # Estimate cost
    est_input_tokens = len(prompt) // 4  # Rough estimate
    prices = {
        ModelTier.OPUS: (5.00, 25.00),
        ModelTier.SONNET: (3.00, 15.00),
        ModelTier.HAIKU: (1.00, 5.00),
    }
    pin, pout = prices[tier]
    est_cost = (est_input_tokens * pin + max_tokens * pout) / 1e6

    return RoutedRequest(
        task_type=task_type,
        model=tier.value,
        prompt=prompt,
        max_tokens=max_tokens,
        estimated_cost=est_cost
    )


def execute_routed(request: RoutedRequest) -> str:
    """Execute a routed request."""
    response = client.messages.create(
        model=request.model,
        max_tokens=request.max_tokens,
        messages=[{"role": "user", "content": request.prompt}]
    )
    return response.content[0].text


# Example: process a batch of mixed tasks
tasks = [
    ("classify_text", "Is this email spam or not? ..."),
    ("architectural_review", "Review this system design: ..."),
    ("format_output", "Convert this data to markdown table: ..."),
    ("write_documentation", "Document this API endpoint: ..."),
    ("extract_fields", "Extract name, email, phone from: ..."),
]

total_estimated = 0
for task_type, prompt in tasks:
    routed = route_task(task_type, prompt)
    print(f"{task_type}: {routed.model.split('-')[1]} "
          f"(~${routed.estimated_cost:.4f})")
    total_estimated += routed.estimated_cost

print(f"\nTotal estimated: ${total_estimated:.4f}")
```

For dynamic routing based on prompt analysis (when task type is not pre-classified):

```bash
# Quick task complexity classifier
python3 -c "
def classify_complexity(prompt: str) -> str:
    \"\"\"Heuristic-based complexity classification.\"\"\"
    indicators = {
        'high': ['analyze', 'synthesize', 'evaluate', 'design',
                 'architect', 'review security', 'compare and contrast'],
        'medium': ['explain', 'document', 'improve', 'suggest',
                   'write', 'describe in detail'],
        'low': ['extract', 'classify', 'format', 'convert',
                'list', 'count', 'validate', 'check']
    }

    prompt_lower = prompt.lower()
    for level, words in indicators.items():
        if any(w in prompt_lower for w in words):
            return level
    return 'medium'  # Default

# Test
prompts = [
    'Extract all email addresses from this text',
    'Analyze the security implications of this architecture',
    'Format this JSON as a markdown table',
    'Explain how this recursive algorithm works',
]

model_map = {'high': 'Opus (\$5/\$25)', 'medium': 'Sonnet (\$3/\$15)', 'low': 'Haiku (\$1/\$5)'}
for p in prompts:
    level = classify_complexity(p)
    print(f'{level:>6} -> {model_map[level]:>20} | {p[:50]}')
"
```

## The Tradeoffs

Model routing introduces new failure modes:

- **Misrouting risk**: A complex task routed to Haiku produces poor results. Implement quality checks on Haiku outputs and auto-escalate to Sonnet on failure.
- **Router maintenance**: As your task types evolve, the routing table must be updated. Stale routes waste money (over-routing to Opus) or hurt quality (under-routing to Haiku).
- **Latency variability**: Different models have different response times. Haiku is faster than Opus, so routing more tasks to Haiku actually improves overall pipeline latency.
- **Testing complexity**: You now need to test each prompt on multiple models to validate routing decisions, increasing your test matrix.

## Implementation Checklist

1. Catalog all task types in your agent fleet
2. Classify each as high/medium/low complexity
3. Map: high -> Opus ($5/$25), medium -> Sonnet ($3/$15), low -> Haiku ($1/$5)
4. Build the routing function with cost estimation
5. Test Haiku on 50 examples of each "low" task to verify quality
6. Deploy with cost tracking per model per task type
7. Review routing accuracy weekly and adjust classifications

## Measuring Impact

Track routing effectiveness:

- **Model distribution**: Percentage of requests by model. Target: 50-70% Haiku, 20-30% Sonnet, 10-20% Opus.
- **Cost per task type**: Track average cost for each task type. Verify Haiku tasks cost 5x less than equivalent Opus tasks.
- **Quality by model**: Score outputs from each model tier. If Haiku quality drops below threshold, reclassify those tasks upward.
- **Monthly savings**: Compare total fleet cost before and after routing implementation.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Opus Orchestrator Sonnet Worker Architecture](/claude-opus-orchestrator-sonnet-worker-architecture/)
- [Parallel Subagents Claude Code Best Practices](/parallel-subagents-claude-code-best-practices-2026/)
- [Monitoring and Logging Claude Code Multi-Agent Systems](/monitoring-and-logging-claude-code-multi-agent-systems/)

## See Also

- [Model Routing by Task Cuts Claude API Bills](/model-routing-cut-claude-api-bills/)
- [Multi-Agent Claude Fleet Cost Architecture Guide](/multi-agent-claude-fleet-cost-architecture/)
- [Cost-Efficient Multi-Agent Coding Workflows](/cost-efficient-multi-agent-coding-workflows/)
