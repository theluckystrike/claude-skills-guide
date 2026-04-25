---
layout: default
title: "When Full Context Costs More Than a RAG (2026)"
description: "Full-context queries cost $1.00+ each on Opus. RAG drops that to $0.10. Here is the exact break-even point for switching."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /when-full-context-costs-more-than-rag/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# When Full Context Costs More Than a RAG Pipeline

Loading 200K tokens of documentation into every Claude Opus 4.7 request costs $1.00 per query. A RAG pipeline retrieving 20K relevant tokens costs $0.10 per query plus $50-200/month in infrastructure. At more than 50 queries per day, RAG is cheaper. At fewer than 50, full context wins.

## The Setup

RAG (Retrieval-Augmented Generation) and full-context loading solve the same problem: giving Claude the information it needs to answer questions. Full context is simpler — dump everything in and let Claude find the answer. RAG is more complex — find the relevant pieces first, then send only those.

The cost equation depends on four variables: knowledge base size, query volume, infrastructure costs, and cache hit rates. This guide provides exact calculations to determine the crossover point for your specific workload.

## The Math

**Fixed costs:**
- RAG infrastructure: $50-200/month (vector DB, embedding model)
- Full context: $0/month (no additional infrastructure)

**Variable costs per query on Opus 4.7:**

| Approach | Input Tokens | Cost/Query |
|----------|-------------|------------|
| Full context (200K) | 200,000 | $1.00 |
| Full context + caching | 200,000 (cached) | $0.10 |
| RAG (20K retrieved) | 20,000 | $0.10 |
| RAG + caching | 20,000 (cached) | $0.01 |

**Break-even analysis (RAG infra at $100/month):**

Without caching:
- Full context: $1.00/query * Q/day * 30 = $30Q/month
- RAG: $0.10/query * Q/day * 30 + $100 = $3Q + $100/month
- Break-even: $30Q = $3Q + $100 -> Q = 3.7 queries/day

With caching on full context:
- Full context cached: $0.10/query * Q/day * 30 = $3Q/month
- RAG: $3Q + $100/month
- **With caching, full context is always cheaper** (no infra overhead)

**But caching has a critical requirement:** consistent traffic within 5-minute TTL windows. If your queries arrive sporadically (less than 1 per 5 minutes), cache misses negate the savings.

**Realistic scenario — 500 queries/day, sporadic traffic:**
- Full context (50% cache hit rate): 250 * $1.00 + 250 * $0.10 = $275/day -> $8,250/month
- RAG: 500 * $0.10 + $100 infra = $50/day + $100 -> $1,600/month
- **RAG saves $6,650/month**

## The Technique

### Calculate Your Break-Even Point

```python
def calculate_breakeven(
    knowledge_base_tokens: int,
    rag_retrieval_tokens: int = 20000,
    model: str = "claude-opus-4-7",
    rag_infra_monthly: float = 100.0,
    cache_hit_rate: float = 0.0,  # 0.0 to 1.0
) -> dict:
    """Calculate when RAG becomes cheaper than full context."""
    rates = {
        "claude-opus-4-7": {"input": 5.0, "cache_read": 0.5},
        "claude-sonnet-4-6": {"input": 3.0, "cache_read": 0.3},
        "claude-haiku-4-5-20251001": {"input": 1.0, "cache_read": 0.1},
    }
    r = rates[model]

    # Full context cost per query
    full_uncached_cost = knowledge_base_tokens * r["input"] / 1_000_000
    full_cached_cost = knowledge_base_tokens * r["cache_read"] / 1_000_000
    full_avg_cost = full_uncached_cost * (1 - cache_hit_rate) + full_cached_cost * cache_hit_rate

    # RAG cost per query (no caching on RAG for simplicity)
    rag_cost_per_query = rag_retrieval_tokens * r["input"] / 1_000_000

    # Break-even calculation
    # full_avg_cost * Q * 30 = rag_cost_per_query * Q * 30 + rag_infra_monthly
    cost_diff_per_query = full_avg_cost - rag_cost_per_query

    if cost_diff_per_query <= 0:
        breakeven_daily = float("inf")  # Full context is always cheaper
    else:
        breakeven_daily = rag_infra_monthly / (cost_diff_per_query * 30)

    return {
        "full_context_cost_per_query": f"${full_avg_cost:.4f}",
        "rag_cost_per_query": f"${rag_cost_per_query:.4f}",
        "rag_infra_monthly": f"${rag_infra_monthly:.2f}",
        "breakeven_queries_per_day": f"{breakeven_daily:.1f}",
        "at_100_per_day": {
            "full_context_monthly": f"${full_avg_cost * 100 * 30:.2f}",
            "rag_monthly": f"${rag_cost_per_query * 100 * 30 + rag_infra_monthly:.2f}",
        },
        "at_500_per_day": {
            "full_context_monthly": f"${full_avg_cost * 500 * 30:.2f}",
            "rag_monthly": f"${rag_cost_per_query * 500 * 30 + rag_infra_monthly:.2f}",
        },
    }

# Scenario 1: Large KB, no caching
result = calculate_breakeven(200_000, cache_hit_rate=0.0)
print("No caching:", result)

# Scenario 2: Large KB, 80% cache hit rate
result = calculate_breakeven(200_000, cache_hit_rate=0.8)
print("80% cache:", result)

# Scenario 3: Small KB
result = calculate_breakeven(50_000, cache_hit_rate=0.0)
print("Small KB:", result)
```

### Hybrid Approach: Cache for Bursts, RAG for Sparse Traffic

```python
import time

class HybridContextManager:
    """Switch between cached full-context and RAG based on traffic pattern."""

    def __init__(
        self,
        full_context: str,
        chunks: list,
        model: str = "claude-opus-4-7",
        cache_ttl: int = 300,  # 5 minutes
    ):
        self.full_context = full_context
        self.chunks = chunks
        self.model = model
        self.cache_ttl = cache_ttl
        self.last_request_time = 0
        self.cache_warm = False
        self.client = anthropic.Anthropic()

    def query(self, question: str) -> dict:
        """Route to cached full-context or RAG based on traffic pattern."""
        now = time.time()
        time_since_last = now - self.last_request_time

        if time_since_last < self.cache_ttl and self.cache_warm:
            # Cache is warm — use full context with cache read
            result = self._full_context_query(question)
            result["strategy"] = "cached_full_context"
        elif time_since_last < self.cache_ttl * 0.5:
            # Frequent queries — warm the cache
            result = self._full_context_query(question)
            self.cache_warm = True
            result["strategy"] = "cache_warming"
        else:
            # Sparse traffic — use RAG
            result = self._rag_query(question)
            self.cache_warm = False
            result["strategy"] = "rag"

        self.last_request_time = now
        return result

    def _full_context_query(self, question: str) -> dict:
        response = self.client.messages.create(
            model=self.model,
            max_tokens=1024,
            system=[{
                "type": "text",
                "text": self.full_context,
                "cache_control": {"type": "ephemeral"},
            }],
            messages=[{"role": "user", "content": question}],
        )
        return {"answer": response.content[0].text, "tokens": response.usage.input_tokens}

    def _rag_query(self, question: str) -> dict:
        # Simple keyword retrieval
        query_words = set(question.lower().split())
        scored = [(sum(1 for w in query_words if w in c["content"].lower()), c) for c in self.chunks]
        scored.sort(reverse=True, key=lambda x: x[0])
        top_chunks = [c["content"] for _, c in scored[:3]]

        response = self.client.messages.create(
            model=self.model,
            max_tokens=1024,
            system="Answer based on the provided context.",
            messages=[{
                "role": "user",
                "content": f"Context:\n{'---'.join(top_chunks)}\n\nQuestion: {question}",
            }],
        )
        return {"answer": response.content[0].text, "tokens": response.usage.input_tokens}
```

### Decision Matrix

```python
def recommend_approach(
    kb_tokens: int,
    daily_queries: int,
    peak_queries_per_5min: int,
    quality_requirement: str = "standard",
) -> str:
    """Recommend the right approach based on your workload."""
    # Rule 1: Small KB -> always full context
    if kb_tokens <= 50_000:
        return "full_context (small KB, caching optional)"

    # Rule 2: High-frequency bursts -> cached full context
    if peak_queries_per_5min >= 5:
        return "cached_full_context (high burst rate keeps cache warm)"

    # Rule 3: High quality + low volume -> full context
    if quality_requirement == "critical" and daily_queries < 50:
        return "full_context (quality > cost for low volume)"

    # Rule 4: High volume + sparse traffic -> RAG
    if daily_queries > 100:
        return "rag (high volume, RAG infra cost amortized)"

    # Rule 5: Medium volume -> hybrid
    return "hybrid (switch between cached and RAG based on traffic)"

print(recommend_approach(200_000, 500, 2))   # RAG
print(recommend_approach(200_000, 30, 10))    # Cached full context
print(recommend_approach(30_000, 100, 3))     # Full context
```

## The Tradeoffs

RAG can miss relevant context that full-context loading would catch. For legal, medical, or compliance queries where missing information has consequences, full context is safer even if more expensive.

RAG infrastructure requires maintenance: embedding model updates, vector database scaling, chunking strategy tuning. Budget 2-4 hours/month of engineering time for RAG maintenance.

Cached full context fails when traffic is sporadic. If your cache hit rate drops below 50%, RAG becomes cheaper even at lower query volumes.

## Implementation Checklist

1. Measure your knowledge base size in tokens
2. Count your daily query volume and traffic pattern (bursty vs sparse)
3. Calculate break-even using the function above
4. If above break-even: implement RAG
5. If below break-even: implement cached full context
6. If borderline: implement hybrid approach
7. Monitor costs monthly and re-evaluate quarterly

## Measuring Impact

Track cost per query across your chosen approach. If using the hybrid strategy, monitor how often each mode (cached vs RAG) is triggered and the cost per query in each mode. Compare total monthly spend against the pre-optimization baseline. The hybrid approach should match or beat the cheaper of the two pure approaches at your actual traffic pattern.

## Related Guides

- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — context economics that drive this decision
- [Claude Code Context Window Management Guide](/claude-code-context-window-management-guide/) — practical context management techniques
- [Why Does Anthropic Limit Claude Code Context Window](/why-does-anthropic-limit-claude-code-context-window/) — understanding context design choices

## See Also

- [RAG vs Context Stuffing: Claude Cost Analysis](/rag-vs-context-stuffing-claude-cost-analysis/)
- [Chunking Strategies to Cut Claude Context Costs](/chunking-strategies-cut-claude-context-costs/)
