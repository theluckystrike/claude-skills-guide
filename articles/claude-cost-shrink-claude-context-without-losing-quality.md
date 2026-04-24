---
layout: default
title: "Shrink Claude Context Without Losing"
description: "Reduce Claude conversation context from 180K to 60K tokens using smart pruning — save $0.60 per compaction, $1,800/month at scale."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /shrink-claude-context-without-losing-quality/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
render_with_liquid: false
---

# Shrink Claude Context Without Losing Quality

A Claude Code session at 180K tokens of context costs $0.90 per interaction on Opus 4.7. Compacting that context to 60K tokens drops the cost to $0.30 — saving $0.60 per interaction. Over 100 sessions per day, that is $60/day or $1,800/month in pure input cost savings.

## The Setup

Context grows with every interaction. In a Claude Code session, the conversation accumulates tool calls, code output, error messages, and back-and-forth discussion. By the time you reach 180K tokens, most of that context is old diagnostic output, superseded code versions, and resolved error traces that Claude no longer needs.

Smart context pruning removes the noise while keeping the signal: current file state, active task description, and recent conversation turns. This guide covers four pruning strategies with code implementations and cost calculations.

## The Math

**Before pruning (180K context):**
- Per-interaction cost on Opus 4.7: 180K * $5.00/MTok = $0.90
- 100 interactions/day: $90/day -> $2,700/month

**After pruning (60K context):**
- Per-interaction cost: 60K * $5.00/MTok = $0.30
- 100 interactions/day: $30/day -> $900/month

**Savings: $1,800/month (67%)**

On Sonnet 4.6 at $3.00/MTok:
- Before: 180K * $3.00 = $0.54/interaction -> $1,620/month
- After: 60K * $3.00 = $0.18/interaction -> $540/month
- **Savings: $1,080/month**

Combined with prompt caching on the pruned context:
- Cache read at $0.50/MTok: 60K * $0.50/MTok = $0.03/interaction
- **With caching: $90/month (97% savings vs original)**

## The Technique

### Strategy 1: Sliding Window with Summary

```python
import anthropic

client = anthropic.Anthropic()

def sliding_window_context(
    messages: list,
    max_context_tokens: int = 60000,
    keep_recent: int = 10,
    model: str = "claude-sonnet-4-6",
) -> list:
    """Maintain a sliding window of recent messages plus a summary of older ones."""
    if len(messages) <= keep_recent:
        return messages

    recent = messages[-keep_recent:]
    older = messages[:-keep_recent]

    # Generate a concise summary of older messages
    summary_input = "\n".join(
        f"{m['role']}: {m['content'][:300]}" for m in older
    )

    summary_resp = client.messages.create(
        model="claude-haiku-4-5-20251001",  # Use cheap model for summarization
        max_tokens=500,
        system="Summarize this conversation history in under 200 words. Keep: key decisions, current task state, file names mentioned, unresolved issues.",
        messages=[{"role": "user", "content": summary_input}],
    )

    summary_msg = {
        "role": "user",
        "content": f"[Context summary: {summary_resp.content[0].text}]",
    }
    ack_msg = {"role": "assistant", "content": "I have the context. Continuing."}

    return [summary_msg, ack_msg] + recent

# Example: 50-message conversation pruned to summary + last 10
messages = [
    {"role": "user", "content": f"Message {i}: working on feature X..."} for i in range(50)
]
pruned = sliding_window_context(messages)
print(f"Original: {len(messages)} messages -> Pruned: {len(pruned)} messages")
```

### Strategy 2: Remove Diagnostic Noise

```python
def remove_diagnostic_noise(messages: list) -> list:
    """Strip verbose error traces, build output, and superseded code from context."""
    noise_patterns = [
        "Traceback (most recent call last)",
        "npm WARN",
        "warning:",
        "Compiling",
        "Building",
        "node_modules/",
        "at Object.<anonymous>",
    ]

    cleaned = []
    for msg in messages:
        content = msg["content"]
        # Check if message is primarily diagnostic noise
        noise_lines = sum(
            1 for line in content.split("\n")
            if any(p in line for p in noise_patterns)
        )
        total_lines = max(content.count("\n") + 1, 1)

        if noise_lines / total_lines > 0.7:
            # Replace with summary
            cleaned.append({
                "role": msg["role"],
                "content": f"[Diagnostic output removed — {total_lines} lines of build/error logs]",
            })
        else:
            cleaned.append(msg)

    return cleaned
```

### Strategy 3: Deduplicate Code Blocks

```python
import hashlib

def deduplicate_code_blocks(messages: list) -> list:
    """Replace repeated code blocks with references to keep only the latest version."""
    seen_code = {}  # hash -> message index
    cleaned = []

    for i, msg in enumerate(messages):
        content = msg["content"]
        # Find code blocks
        blocks = content.split("```")
        if len(blocks) < 3:
            cleaned.append(msg)
            continue

        new_content_parts = [blocks[0]]
        for j in range(1, len(blocks), 2):
            if j + 1 > len(blocks) - 1:
                break
            code = blocks[j]
            code_hash = hashlib.md5(code.strip().encode()).hexdigest()[:8]

            if code_hash in seen_code:
                new_content_parts.append(f"[code block {code_hash} — see latest version below]")
            else:
                new_content_parts.append(f"```{code}```")
            seen_code[code_hash] = i

            if j + 1 < len(blocks):
                new_content_parts.append(blocks[j + 1])

        cleaned.append({"role": msg["role"], "content": "".join(new_content_parts)})

    return cleaned
```

### Strategy 4: Claude Code /compact Equivalent

```python
def compact_context(messages: list, model: str = "claude-sonnet-4-6") -> list:
    """Replicate Claude Code's /compact behavior programmatically."""
    # Step 1: Remove diagnostic noise
    cleaned = remove_diagnostic_noise(messages)

    # Step 2: Deduplicate code blocks
    cleaned = deduplicate_code_blocks(cleaned)

    # Step 3: Apply sliding window with summary
    cleaned = sliding_window_context(cleaned, max_context_tokens=60000, keep_recent=10)

    return cleaned

# Full pipeline
original_size = sum(len(m["content"]) for m in messages)
compacted = compact_context(messages)
compacted_size = sum(len(m["content"]) for m in compacted)

reduction = (1 - compacted_size / original_size) * 100
print(f"Reduced context by {reduction:.0f}%")
print(f"Estimated token savings: {(original_size - compacted_size) // 4}")
```

## The Tradeoffs

Context pruning can remove information Claude needs for subsequent tasks. The sliding window approach mitigates this with summaries, but summaries are lossy — specific details like exact error codes or variable names may be lost.

Using Haiku for summarization adds a small cost ($0.001-$0.005 per summary) but is much cheaper than keeping the full context.

Over-aggressive pruning in the middle of a debugging session can force you to re-explain the problem, wasting tokens. Prune at natural breakpoints: after resolving a bug, after completing a feature, or before starting a new task.

## Implementation Checklist

1. Measure your average context size at various points in a session
2. Identify the context size threshold where cost becomes significant (typically 100K+)
3. Implement diagnostic noise removal first (lowest risk, highest impact)
4. Add code block deduplication for coding workflows
5. Implement sliding window summarization for the oldest context
6. Test that pruned sessions maintain continuity on 10 representative workflows

## Measuring Impact

Track context size per interaction over time. Plot the growth curve with and without pruning. Target keeping context below 60K tokens for standard sessions and below 100K for complex multi-file tasks. Measure the number of times you need to re-explain context that was pruned — this should be under 5% of interactions. Calculate monthly savings by multiplying average token reduction by interaction count and model rate.

## Related Guides

- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — comprehensive token management strategies
- [Why Is Claude Code Expensive](/why-is-claude-code-expensive-large-context-tokens/) — how context growth drives costs
- [Claude Skill Token Usage Profiling](/claude-skill-token-usage-profiling-and-optimization/) — identify which workflows grow context fastest

## See Also

- [Async Claude Processing: Half Price Same Quality](/claude-cost-async-claude-processing-half-price-same-quality/)
- [Chunking Strategies to Cut Claude Context Costs](/claude-cost-chunking-strategies-cut-claude-context-costs/)
