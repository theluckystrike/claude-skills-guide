---
layout: default
title: "Claude 200K vs 1M Context Cost (2026)"
description: "Claude Haiku at 200K context costs $0.20/request. Opus at 1M costs $5.00/request. Choose the right window for 25x savings."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-200k-vs-1m-context-cost-comparison/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# Claude 200K vs 1M Context Cost Comparison

Filling Claude Haiku 4.5's 200K context window costs $0.20 per request. Filling Opus 4.7's 1M context window costs $5.00 per request — 25 times more. Most tasks that appear to need 1M tokens can be accomplished with a 200K window and targeted context selection.

## The Setup

Claude Opus 4.7 and Sonnet 4.6 offer 1 million token context windows. Haiku 4.5 offers 200K tokens. The question is whether you actually need 1M tokens or whether 200K is sufficient for your workload.

Context window size determines two things: maximum capacity (hard limit) and typical cost (what you actually send). A 1M window does not mean you must fill it, but many developers do fill it — loading entire codebases, full documentation sets, or complete conversation histories because the window allows it.

This guide compares the cost implications of each context window tier and shows how to determine which window size your workload truly requires.

## The Math

**Maximum cost per request by model and context window:**

| Model | Window | Max Input Cost | Typical Cost (50% fill) |
|-------|--------|---------------|------------------------|
| Haiku 4.5 | 200K | $0.20 | $0.10 |
| Sonnet 4.6 | 1M | $3.00 | $1.50 |
| Opus 4.7 | 1M | $5.00 | $2.50 |

**Monthly cost at 100 requests/day filling 50% of the context window:**

| Model | Monthly Cost | vs Haiku |
|-------|-------------|---------|
| Haiku 4.5 (100K avg) | $300 | Baseline |
| Sonnet 4.6 (500K avg) | $4,500 | 15x |
| Opus 4.7 (500K avg) | $7,500 | 25x |

But if you use Sonnet/Opus with targeted 50K context:

| Model | Monthly Cost (50K context) | vs Haiku full |
|-------|--------------------------|--------------|
| Sonnet 4.6 (50K) | $450 | 1.5x |
| Opus 4.7 (50K) | $750 | 2.5x |

The model matters less than context discipline. Opus with 50K context ($750/month) costs less than Haiku at 200K context ($600/month, assuming frequent near-capacity usage).

## The Technique

### Determine Your Actual Context Requirements

```python
import anthropic

client = anthropic.Anthropic()

def analyze_context_needs(
    messages_sample: list,
    model: str = "claude-sonnet-4-6",
) -> dict:
    """Analyze a sample of requests to determine actual context needs."""
    token_counts = []
    for msg_set in messages_sample:
        count = client.messages.count_tokens(
            model=model,
            messages=msg_set,
        )
        token_counts.append(count.input_tokens)

    token_counts.sort()
    p50 = token_counts[len(token_counts) // 2]
    p90 = token_counts[int(len(token_counts) * 0.9)]
    p99 = token_counts[int(len(token_counts) * 0.99)]
    max_tokens = max(token_counts)

    return {
        "sample_size": len(token_counts),
        "p50_tokens": p50,
        "p90_tokens": p90,
        "p99_tokens": p99,
        "max_tokens": max_tokens,
        "fits_200k": f"{sum(1 for t in token_counts if t <= 200000) / len(token_counts) * 100:.1f}%",
        "recommendation": "haiku_200k" if p99 <= 200000 else "sonnet_or_opus_1m",
    }
```

### Model Selection Based on Context Needs

```python
def select_by_context(
    input_tokens: int,
    task_complexity: str = "moderate",
    cost_priority: bool = True,
) -> str:
    """Select the cheapest model that fits the context requirement."""
    # Haiku: 200K max context, cheapest
    # Sonnet: 1M max context, mid-price
    # Opus: 1M max context, highest quality + price

    if input_tokens <= 200_000:
        if task_complexity == "simple" or cost_priority:
            return "claude-haiku-4-5-20251001"  # $1/$5 per MTok
        elif task_complexity == "moderate":
            return "claude-sonnet-4-6"  # $3/$15 per MTok
        else:
            return "claude-opus-4-7"  # $5/$25 per MTok
    else:
        # Must use Sonnet or Opus for >200K context
        if task_complexity == "complex":
            return "claude-opus-4-7"
        return "claude-sonnet-4-6"

# Examples
print(select_by_context(50_000, "simple"))    # -> Haiku
print(select_by_context(50_000, "complex"))   # -> Opus
print(select_by_context(300_000, "simple"))   # -> Sonnet (Haiku can't handle >200K)
print(select_by_context(300_000, "complex"))  # -> Opus
```

### Cost-Aware Context Sizing

```python
def fit_context_to_budget(
    documents: list,
    max_budget_per_request: float = 0.50,
    model: str = "claude-opus-4-7",
) -> list:
    """Select documents to include within a cost budget."""
    rates = {
        "claude-opus-4-7": 5.0,
        "claude-sonnet-4-6": 3.0,
        "claude-haiku-4-5-20251001": 1.0,
    }
    rate = rates[model]
    max_tokens = int(max_budget_per_request * 1_000_000 / rate)

    # Sort documents by relevance (assumed pre-scored)
    selected = []
    total_tokens = 0

    for doc in documents:
        doc_tokens = len(doc["content"].split()) * 2  # rough estimate
        if total_tokens + doc_tokens <= max_tokens:
            selected.append(doc)
            total_tokens += doc_tokens
        else:
            break

    actual_cost = total_tokens * rate / 1_000_000
    return {
        "selected_docs": len(selected),
        "total_docs": len(documents),
        "tokens": total_tokens,
        "estimated_cost": f"${actual_cost:.4f}",
        "budget": f"${max_budget_per_request:.2f}",
    }

# Example: Fit documents into a $0.50 Opus budget
docs = [
    {"content": "First relevant document... " * 500, "relevance": 0.95},
    {"content": "Second document... " * 500, "relevance": 0.90},
    {"content": "Third document... " * 500, "relevance": 0.85},
    {"content": "Fourth document... " * 5000, "relevance": 0.80},
]
result = fit_context_to_budget(docs, max_budget_per_request=0.50)
print(f"Selected {result['selected_docs']}/{result['total_docs']} docs at {result['estimated_cost']}")
```

## The Tradeoffs

Haiku's 200K window is sufficient for most tasks: typical code reviews (10-50K tokens), document Q&A (5-30K tokens), and conversation sessions under 20 turns. The 1M window is genuinely needed for full-codebase analysis, very long documents, and extended multi-tool sessions.

Choosing Haiku for cost savings means accepting lower capability on complex tasks. The 200K vs 1M decision is inseparable from the Haiku vs Sonnet/Opus capability decision.

If your workload splits between small-context and large-context requests, route small requests to Haiku and large requests to Sonnet. This captures savings on high-volume simple requests while maintaining capacity for occasional large-context analysis.

## Implementation Checklist

1. Sample 100 production requests and count their actual token usage
2. Calculate what percentage fit within 200K tokens
3. Route requests under 200K to Haiku if task complexity allows
4. Set per-request cost budgets that limit context filling
5. Monitor the percentage of requests that genuinely need more than 200K
6. Review routing rules quarterly

## Measuring Impact

Track the distribution of context sizes across all requests. If 80%+ of requests use under 100K tokens, most of your traffic can run on Haiku at $1/MTok instead of Opus at $5/MTok. Calculate the monthly cost difference between your current model assignment and an optimized routing based on actual context needs. The savings potential is proportional to the percentage of small-context requests currently running on expensive models.

## Related Guides

- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — why context is the primary cost driver
- [Claude Code Context Window Management Guide](/claude-code-context-window-management-guide/) — practical context management
- [Why Does Anthropic Limit Claude Code Context Window](/why-does-anthropic-limit-claude-code-context-window/) — the design reasoning behind context limits

## See Also

- [Claude Context Management: Pay Less, Use More](/claude-cost-claude-context-management-pay-less-use-more/)
- [Claude 1M Context Window: What It Really Costs](/claude-cost-claude-1m-context-window-what-it-costs/)
- [Optimal Context Size for Cost-Efficient Claude](/claude-cost-optimal-context-size-cost-efficient-claude/)
- [Claude Code Context Management Cost Tips 2026](/claude-cost-04-claude-code-context-management-tips/)
- [Claude Haiku 4.5 Budget-Friendly Coding Guide](/claude-cost-claude-haiku-45-budget-friendly-coding/)
