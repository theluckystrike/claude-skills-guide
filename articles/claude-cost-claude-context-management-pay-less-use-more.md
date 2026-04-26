---
layout: default
title: "Claude Context Management (2026)"
description: "Combine caching, pruning, and context budgets to cut Claude context costs by 78% — from $5.00 to $1.075 per 100K-token session."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-context-management-pay-less-use-more/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# Claude Context Management: Pay Less, Use More

Caching a 100K-token system prompt and reading it 10 times without caching costs $5.00 on Opus 4.7. With 5-minute caching, the same 10 reads cost $1.075 — a 78.5% reduction. Combined with context pruning and smart budgeting, you can process more context for less money.

## The Setup

Context management is not about using less context — it is about paying less for the context you use. Three complementary techniques achieve this: prompt caching (pay full price once, 90% off for repeats), context pruning (remove tokens that add no value), and budget enforcement (prevent context from growing beyond cost-effective levels).

This guide combines all three into a unified context management strategy with worked cost examples and production-ready code.

## The Math

**Scenario: 100K system prompt repeated across 10 requests, Opus 4.7**

**No caching, no pruning:**
- 10 requests * 100K * $5.00/MTok = **$5.00**

**With 5-minute caching:**
- 1 cache write: 100K * $6.25/MTok = $0.625
- 9 cache reads: 9 * 100K * $0.50/MTok = $0.45
- **Total: $1.075 (78.5% savings)**

**With 1-hour extended caching:**
- 1 cache write: 100K * $10.00/MTok = $1.00
- 9 cache reads: 9 * 100K * $0.50/MTok = $0.45
- **Total: $1.45 (71% savings, but cache survives longer)**

**With caching + pruning (100K down to 60K via noise removal):**
- 1 cache write: 60K * $6.25/MTok = $0.375
- 9 cache reads: 9 * 60K * $0.50/MTok = $0.27
- **Total: $0.645 (87% savings)**

**Monthly savings at 100 such request sets per day:**
- Without management: $15,000/month
- With full management: $1,935/month
- **Savings: $13,065/month**

## The Technique

### Layer 1: Prompt Caching

```python
import anthropic

client = anthropic.Anthropic()

# Large system prompt that repeats across requests
SYSTEM_CONTEXT = """[Your detailed system prompt, reference documents,
coding standards, API documentation, etc. — 100K+ tokens of context
that stays the same across requests.]"""

def cached_request(
    user_message: str,
    model: str = "claude-opus-4-7",
    max_tokens: int = 4096,
) -> dict:
    """Send request with cached system context for 90% input savings."""
    response = client.messages.create(
        model=model,
        max_tokens=max_tokens,
        system=[{
            "type": "text",
            "text": SYSTEM_CONTEXT,
            "cache_control": {"type": "ephemeral"},
        }],
        messages=[{"role": "user", "content": user_message}],
    )

    # Track caching performance
    cache_read = getattr(response.usage, "cache_read_input_tokens", 0)
    cache_write = getattr(response.usage, "cache_creation_input_tokens", 0)
    uncached = response.usage.input_tokens - cache_read

    return {
        "content": response.content[0].text,
        "cache_hit": cache_read > 0,
        "cache_read_tokens": cache_read,
        "cache_write_tokens": cache_write,
        "uncached_tokens": uncached,
        "estimated_savings": f"${cache_read * 4.5 / 1_000_000:.4f}",
    }

# First request: cache write (slightly more expensive)
result1 = cached_request("What is our error handling policy?")
print(f"Cache hit: {result1['cache_hit']}")

# Second request within 5 minutes: cache read (90% cheaper)
result2 = cached_request("How should I handle authentication errors?")
print(f"Cache hit: {result2['cache_hit']} | Savings: {result2['estimated_savings']}")
```

### Layer 2: Context Pruning

```python
def prune_context(
    messages: list,
    strategies: list = None,
) -> list:
    """Apply multiple pruning strategies to reduce context size."""
    if strategies is None:
        strategies = ["remove_noise", "dedup_code", "truncate_outputs"]

    pruned = messages.copy()

    if "remove_noise" in strategies:
        pruned = _remove_noise(pruned)
    if "dedup_code" in strategies:
        pruned = _deduplicate_code(pruned)
    if "truncate_outputs" in strategies:
        pruned = _truncate_long_outputs(pruned)

    return pruned

def _remove_noise(messages: list) -> list:
    """Remove build logs, warnings, and verbose diagnostic output."""
    noise_indicators = [
        "npm WARN", "WARNING:", "Compiling", "Building",
        "node_modules/", "at Object.", "at Module.",
        "DEPRECATION", "peer dep",
    ]
    cleaned = []
    for msg in messages:
        content = msg["content"]
        lines = content.split("\n")
        clean_lines = [l for l in lines if not any(n in l for n in noise_indicators)]

        removed = len(lines) - len(clean_lines)
        if removed > 0:
            clean_lines.append(f"[{removed} noise lines removed]")

        cleaned.append({**msg, "content": "\n".join(clean_lines)})
    return cleaned

def _deduplicate_code(messages: list) -> list:
    """Replace repeated code blocks with references."""
    seen_hashes = {}
    cleaned = []

    for msg in messages:
        content = msg["content"]
        parts = content.split("```")
        new_parts = [parts[0]]

        for i in range(1, len(parts), 2):
            if i >= len(parts):
                break
            code = parts[i].strip()
            import hashlib
            code_hash = hashlib.md5(code.encode()).hexdigest()[:8]

            if code_hash in seen_hashes:
                new_parts.append(f"[duplicate code block {code_hash}]")
            else:
                new_parts.append(f"```{parts[i]}```")
                seen_hashes[code_hash] = True

            if i + 1 < len(parts):
                new_parts.append(parts[i + 1])

        cleaned.append({**msg, "content": "".join(new_parts)})
    return cleaned

def _truncate_long_outputs(messages: list, max_lines: int = 30) -> list:
    """Truncate tool outputs longer than max_lines."""
    cleaned = []
    for msg in messages:
        content = msg["content"]
        lines = content.split("\n")
        if len(lines) > max_lines:
            half = max_lines // 2
            truncated = lines[:half] + [f"\n[...{len(lines) - max_lines} lines truncated...]\n"] + lines[-half:]
            cleaned.append({**msg, "content": "\n".join(truncated)})
        else:
            cleaned.append(msg)
    return cleaned
```

### Layer 3: Budget Enforcement

```python
class ContextBudgetManager:
    """Enforce context budgets across requests."""

    def __init__(self, model: str = "claude-opus-4-7", daily_budget: float = 10.0):
        self.model = model
        self.daily_budget = daily_budget
        self.daily_spend = 0.0
        self.rates = {"claude-opus-4-7": 5.0, "claude-sonnet-4-6": 3.0}
        self.rate = self.rates.get(model, 5.0)

    def can_afford(self, estimated_tokens: int) -> bool:
        cost = estimated_tokens * self.rate / 1_000_000
        return (self.daily_spend + cost) <= self.daily_budget

    def request(self, system: str, messages: list, max_tokens: int = 4096) -> dict:
        count = client.messages.count_tokens(
            model=self.model, system=system, messages=messages,
        )

        if not self.can_afford(count.input_tokens):
            return {
                "error": "BUDGET_EXCEEDED",
                "remaining_budget": f"${self.daily_budget - self.daily_spend:.2f}",
                "request_cost": f"${count.input_tokens * self.rate / 1_000_000:.4f}",
            }

        response = client.messages.create(
            model=self.model, max_tokens=max_tokens,
            system=system, messages=messages,
        )

        cost = count.input_tokens * self.rate / 1_000_000
        self.daily_spend += cost

        return {
            "content": response.content[0].text,
            "cost": f"${cost:.4f}",
            "daily_spend": f"${self.daily_spend:.2f}",
            "budget_remaining": f"${self.daily_budget - self.daily_spend:.2f}",
        }

# Usage
budget = ContextBudgetManager(daily_budget=10.0)
result = budget.request(
    system="You are a code reviewer.",
    messages=[{"role": "user", "content": "Review this function: def add(a,b): return a+b"}],
)
print(f"Cost: {result.get('cost')} | Remaining: {result.get('budget_remaining')}")
```

## The Tradeoffs

Caching requires minimum token thresholds: 4,096 tokens for Opus 4.7 and Haiku 4.5, 1,024 for Sonnet 4.6. Short system prompts cannot be cached alone — combine them with other stable context to reach the threshold.

Context pruning is lossy. Removed information cannot be recovered without re-reading source files. Apply pruning to diagnostic output and old conversation turns, not to active working context.

Budget enforcement can block legitimate expensive requests. Implement override mechanisms for high-value tasks that justify exceeding the budget.

## Implementation Checklist

1. Enable caching on your largest system prompts
2. Monitor cache hit rates for the first week
3. Implement noise removal for tool outputs and error traces
4. Add code block deduplication to long sessions
5. Set daily context budgets per project or team
6. Review budget utilization and cache performance weekly

## Measuring Impact

Three key metrics: cache hit rate (target above 80%), average context size after pruning (target 40-60% reduction), and daily spend versus budget (target under 80% utilization for safety margin). Calculate total monthly savings as: (pre-optimization spend - post-optimization spend). Track each optimization layer separately to understand which contributes most.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — why context management matters
- [Claude Code Context Window Management Guide](/claude-code-context-window-management-guide/) — additional context management techniques
- [Why Does Anthropic Limit Claude Code Context Window](/why-does-anthropic-limit-claude-code-context-window/) — the reasoning behind context constraints

## See Also

- [Claude Agent Token Budget Management Guide](/claude-agent-token-budget-management/)
- [Claude 200K vs 1M Context Cost Comparison](/claude-200k-vs-1m-context-cost-comparison/)
- [Claude 1M Context Window: What It Really Costs](/claude-1m-context-window-what-it-costs/)
- [Shrink Claude Context Without Losing Quality](/shrink-claude-context-without-losing-quality/)
- [Claude Orchestrator-Worker Cost Optimization](/claude-orchestrator-worker-cost-optimization/)
