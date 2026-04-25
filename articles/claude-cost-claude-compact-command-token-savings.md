---
layout: default
title: "Claude /compact Command Token Savings (2026)"
description: "The /compact command reduces Claude Code context by 50-70%, saving $0.60 per session on Opus 4.7 — here is when and how to use it."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-compact-command-token-savings/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# Claude /compact Command Token Savings Guide

The /compact command in Claude Code reduces conversation context by 50-70%, taking a bloated 180K-token session down to approximately 60K tokens. On Opus 4.7 at $5.00 per million input tokens, each compaction saves $0.60 on the very next interaction. Run it 100 times per day across a team and you save $1,800/month.

## The Setup

Claude Code sessions grow with every interaction. Each code edit, terminal output, error trace, and assistant response adds to the context window. After 20-30 interactions, context often exceeds 150K tokens — meaning every subsequent message costs $0.75+ in input tokens on Opus.

The /compact command compresses this conversation history into a concise summary, resetting the context to a fraction of its size. This guide covers optimal timing, expected savings, and strategies for minimizing compaction-related context loss.

## The Math

**Session without /compact (30 interactions, Opus 4.7):**
- Context grows roughly 5K tokens per interaction
- By interaction 30: ~150K context tokens
- Average context across all 30 interactions: ~75K tokens
- Total input cost: 30 * 75K * $5.00/MTok = $11.25

**Session with /compact at interaction 15:**
- Interactions 1-15: average 37.5K context -> 15 * 37.5K * $5.00/MTok = $2.81
- Compaction reduces 75K to ~25K (67% reduction)
- Interactions 16-30: average 37.5K context -> 15 * 37.5K * $5.00/MTok = $2.81
- Total input cost: **$5.62**

**Savings per session: $5.63 (50%)**

At 10 sessions/day: $56.30/day saved -> **$1,689/month**

**Aggressive compaction (every 10 interactions):**
- Three compactions per 30-interaction session
- Average context stays under 40K
- Total input cost: ~$3.60/session
- **Savings: $7.65/session -> $2,295/month at 10 sessions/day**

## The Technique

### When to Run /compact

The optimal time to compact is at natural breakpoints in your workflow:

```bash
# In Claude Code, simply type:
/compact

# Claude will summarize the conversation and reset context
# The summary preserves:
# - Current task description
# - Files being edited
# - Key decisions made
# - Unresolved issues
```

Best times to compact:
1. After completing a feature or bug fix
2. After resolving an error (error traces no longer needed)
3. Before starting a new task in the same session
4. When Claude starts repeating itself (sign of context overload)
5. When you notice response latency increasing

### Monitoring Context Size

Track your context growth to know when compaction is worthwhile:

```python
import os
import json

def estimate_session_cost(
    interaction_count: int,
    avg_tokens_per_interaction: int = 5000,
    model_input_rate: float = 5.0,  # Opus 4.7
    compact_interval: int = 0,  # 0 = never compact
) -> dict:
    """Estimate session cost with and without compaction."""
    total_cost_no_compact = 0
    total_cost_with_compact = 0
    context_no_compact = 0
    context_with_compact = 0

    for i in range(interaction_count):
        # Without compaction
        context_no_compact += avg_tokens_per_interaction
        total_cost_no_compact += context_no_compact * model_input_rate / 1_000_000

        # With compaction
        context_with_compact += avg_tokens_per_interaction
        if compact_interval > 0 and (i + 1) % compact_interval == 0:
            context_with_compact = int(context_with_compact * 0.33)  # 67% reduction
        total_cost_with_compact += context_with_compact * model_input_rate / 1_000_000

    return {
        "interactions": interaction_count,
        "no_compact_cost": f"${total_cost_no_compact:.2f}",
        "with_compact_cost": f"${total_cost_with_compact:.2f}",
        "savings": f"${total_cost_no_compact - total_cost_with_compact:.2f}",
        "final_context_no_compact": f"{context_no_compact:,} tokens",
        "final_context_with_compact": f"{context_with_compact:,} tokens",
    }

# Compare: 30-interaction session on Opus 4.7
no_compact = estimate_session_cost(30, compact_interval=0)
compact_10 = estimate_session_cost(30, compact_interval=10)
compact_15 = estimate_session_cost(30, compact_interval=15)

print("No compaction:", no_compact)
print("Compact every 10:", compact_10)
print("Compact every 15:", compact_15)
```

### Preserving Critical Context Before Compaction

Before running /compact, you can ensure important context persists by writing it to a file:

```bash
# In Claude Code, before compacting:
# 1. Ask Claude to write a summary of current state
# "Write a CLAUDE.md file summarizing our current task state,
#  files changed, and next steps."

# 2. Run /compact
/compact

# 3. Claude reads CLAUDE.md on next interaction and has the context
# The CLAUDE.md file acts as persistent memory across compactions
```

### Automated Compaction Trigger

For API-based implementations, trigger compaction automatically:

```python
import anthropic

client = anthropic.Anthropic()

MAX_CONTEXT_TOKENS = 80000  # Compact when context exceeds this

def managed_conversation(messages: list, system: str, new_message: str) -> tuple:
    """Manage conversation with automatic compaction."""
    messages.append({"role": "user", "content": new_message})

    # Check context size
    count = client.messages.count_tokens(
        model="claude-sonnet-4-6",
        system=system,
        messages=messages,
    )

    if count.input_tokens > MAX_CONTEXT_TOKENS:
        # Compact: summarize and reset
        summary_resp = client.messages.create(
            model="claude-haiku-4-5-20251001",
            max_tokens=1000,
            system="Summarize this conversation. Keep: current task, files mentioned, decisions made, pending items. Max 300 words.",
            messages=messages,
        )
        summary = summary_resp.content[0].text
        messages = [
            {"role": "user", "content": f"[Conversation summary: {summary}]"},
            {"role": "assistant", "content": "Understood. I have the context from our previous discussion."},
            {"role": "user", "content": new_message},
        ]
        print(f"Auto-compacted: {count.input_tokens} -> ~{len(summary.split()) * 2} tokens")

    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=4096,
        system=system,
        messages=messages,
    )

    messages.append({"role": "assistant", "content": response.content[0].text})
    return response.content[0].text, messages
```

## The Tradeoffs

Compaction is lossy. The summary cannot perfectly capture every detail from the original conversation. Specific variable names, exact error messages, and subtle contextual nuances may be lost.

Compacting too frequently creates a "summary of a summary" problem where information degrades with each compaction cycle. Limit to 2-3 compactions per session maximum.

The compaction summary itself costs tokens to generate. On Haiku ($1/$5 per MTok), summarizing 100K tokens of context costs approximately $0.10-$0.15. This is negligible compared to the savings on subsequent interactions.

## Implementation Checklist

1. Track your average session length (interactions and final context size)
2. Identify sessions that regularly exceed 100K tokens
3. Add /compact to your workflow at natural breakpoints
4. For API usage: implement auto-compaction at 80K tokens
5. Write critical context to CLAUDE.md before compacting
6. Monitor post-compaction quality for context loss issues

## Measuring Impact

Track three metrics: average context size per interaction (should decrease 40-60%), total monthly input token consumption (should decrease 30-50%), and re-explanation rate (how often you need to re-provide context after compaction — target under 10%). Calculate monthly savings by comparing pre-compaction and post-compaction input token totals multiplied by your model rate.

## Related Guides

- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — the context growth problem that /compact solves
- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — complementary token reduction strategies
- [Reduce Claude Code Hallucinations Save Tokens](/reduce-claude-code-hallucinations-save-tokens-accuracy-tips/) — cleaner context produces fewer hallucinations

## See Also

- [Claude Cache Minimum Token Requirements 2026](/claude-cache-minimum-token-requirements-2026/)
- [Claude Token Counter: Measure Before You Optimize](/claude-token-counter-measure-before-optimize/)
- [Claude Batch Plus Caching for 95% Cost Savings](/claude-batch-plus-caching-95-percent-cost-savings/)
