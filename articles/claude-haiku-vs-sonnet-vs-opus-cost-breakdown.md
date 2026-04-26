---
layout: default
title: "Claude Haiku vs Sonnet vs Opus Cost (2026)"
description: "Compare Claude API costs per million tokens across Haiku ($1), Sonnet ($3), and Opus ($5) to pick the right model for your budget."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-haiku-vs-sonnet-vs-opus-cost-breakdown/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# Claude Haiku vs Sonnet vs Opus Cost Breakdown 2026

Choosing Claude Opus 4.7 for every API call costs $75 per 1,000 requests at typical token volumes. Switching simple classification tasks to Haiku 4.5 drops that to $15 — an 80% reduction with no change to your output quality for straightforward work.

## The Setup

You run a production API that handles a mix of tasks: content classification, code review, data extraction, and complex reasoning. Every request currently hits Claude Opus 4.7 because it was easiest to configure one model across the board.

Your typical request profile: 5,000 input tokens and 2,000 output tokens. At 1,000 requests per day, you are spending $75/day ($2,250/month) on API calls that could run at one-fifth the cost.

This guide walks through exact per-token pricing for all three current Claude models, shows real cost calculations at production volumes, and gives you a decision framework for routing requests to the cheapest model that still delivers quality results.

## The Math

All prices are per million tokens, verified from Anthropic's official pricing docs as of April 2026.

| Model | Input/MTok | Output/MTok | Context Window | Max Output |
|-------|-----------|-------------|---------------|-----------|
| Claude Opus 4.7 | $5.00 | $25.00 | 1M tokens | 128K |
| Claude Sonnet 4.6 | $3.00 | $15.00 | 1M tokens | 64K |
| Claude Haiku 4.5 | $1.00 | $5.00 | 200K tokens | 64K |

For 1,000 requests at 5K input + 2K output tokens each:

**Opus 4.7**: (5M * $5/MTok) + (2M * $25/MTok) = $25 + $50 = **$75.00**

**Sonnet 4.6**: (5M * $3/MTok) + (2M * $15/MTok) = $15 + $30 = **$45.00** (40% savings)

**Haiku 4.5**: (5M * $1/MTok) + (2M * $5/MTok) = $5 + $10 = **$15.00** (80% savings)

At 30,000 requests/month, that translates to: Opus $2,250/month, Sonnet $1,350/month, Haiku $450/month. The gap between Opus and Haiku is $1,800/month — $21,600/year.

## The Technique

Build a model router that classifies incoming requests by complexity and routes them to the cheapest capable model.

```python
import anthropic

client = anthropic.Anthropic()

# Define task complexity tiers
TASK_ROUTING = {
    "classification": "claude-haiku-4-5-20251001",
    "extraction": "claude-haiku-4-5-20251001",
    "summarization": "claude-sonnet-4-6",
    "code_review": "claude-sonnet-4-6",
    "complex_reasoning": "claude-opus-4-7",
    "code_generation": "claude-opus-4-7",
}

def route_request(task_type: str, prompt: str, system: str = "") -> dict:
    """Route API requests to the cheapest capable model."""
    model = TASK_ROUTING.get(task_type, "claude-sonnet-4-6")

    message = client.messages.create(
        model=model,
        max_tokens=2048,
        system=system,
        messages=[{"role": "user", "content": prompt}],
    )
    return {
        "model_used": model,
        "content": message.content[0].text,
        "input_tokens": message.usage.input_tokens,
        "output_tokens": message.usage.output_tokens,
    }

# Example: classification task routed to Haiku
result = route_request(
    task_type="classification",
    prompt="Classify this support ticket as billing, technical, or general: 'I can't log into my account since the update.'",
)
print(f"Model: {result['model_used']}")
print(f"Tokens: {result['input_tokens']} in, {result['output_tokens']} out")
```

For dynamic routing based on prompt content rather than hardcoded task types, add a lightweight classifier:

```python
def detect_complexity(prompt: str) -> str:
    """Simple heuristic to detect task complexity."""
    complex_signals = ["explain why", "analyze", "compare and contrast",
                       "write a function", "debug this", "architect"]
    simple_signals = ["classify", "extract", "yes or no",
                      "summarize in one sentence", "which category"]

    prompt_lower = prompt.lower()
    complex_score = sum(1 for s in complex_signals if s in prompt_lower)
    simple_score = sum(1 for s in simple_signals if s in prompt_lower)

    if complex_score >= 2:
        return "complex_reasoning"
    elif simple_score >= 1:
        return "classification"
    return "summarization"  # default to mid-tier
```

## The Tradeoffs

Haiku 4.5 has a 200K context window versus 1M for Sonnet and Opus. If your workload requires processing documents larger than 200K tokens in a single request, Haiku cannot handle it.

Haiku also shows lower accuracy on tasks requiring multi-step reasoning, nuanced code generation, or ambiguous instruction following. Running a quality evaluation on 100 representative requests before switching production traffic is essential.

Model routing adds infrastructure complexity. You need to maintain the routing logic, monitor per-model quality metrics, and handle cases where the cheaper model produces unacceptable results.

Prompt caching discounts apply independently of model selection. Sonnet 4.6 cache reads cost $0.30/MTok (vs $3.00/MTok standard), while Haiku 4.5 cache reads cost $0.10/MTok (vs $1.00/MTok standard). For workloads with large repeated system prompts, combining model routing with prompt caching creates compound savings. A 50K-token system prompt on cached Haiku costs $0.005 per cache read versus $0.25 per uncached Opus read -- a 50x per-request reduction on the system prompt portion alone. At 30,000 requests/month, that difference is $7,350 in system prompt costs.

## Implementation Checklist

1. Audit your current API usage to categorize requests by task type
2. Run a 100-request quality test with Haiku on your simplest task category
3. Measure accuracy/quality difference between Haiku and your current model
4. Deploy the model router with one task category routed to Haiku
5. Monitor error rates and quality scores for 48 hours
6. Expand routing to additional task categories if quality holds
7. Track monthly spend reduction in your billing dashboard

## Measuring Impact

Compare your Anthropic API bill before and after implementing model routing. Track three metrics: total monthly spend (target: 40-80% reduction), quality score per task category (target: less than 5% degradation), and p95 latency per model (Haiku should be faster). Use the Anthropic usage dashboard to verify token counts by model. Set up weekly cost reports to catch any routing misconfigurations early.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — understand the token economics behind Claude costs
- [Claude Code Monthly Cost Breakdown](/claude-code-monthly-cost-breakdown-realistic-usage-estimates/) — realistic usage estimates for development workflows
- [Claude Opus 4.6 vs GPT-4o Comparison](/claude-opus-46-vs-gpt-4o-for-coding-tasks-comparison/) — cross-provider cost comparison for coding tasks

## See Also

- [Claude Haiku 4.5 vs GPT-4o Mini: Budget AI Coding](/claude-haiku-vs-gpt-4o-mini-comparison-2026/)
