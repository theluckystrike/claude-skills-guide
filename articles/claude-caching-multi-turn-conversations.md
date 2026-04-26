---
layout: default
title: "Claude Caching for Multi-Turn (2026)"
description: "Save 76% on multi-turn Claude conversations by caching growing context. 8-turn Sonnet 4.6 chat drops from $0.72 to $0.175."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-caching-multi-turn-conversations/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, prompt-caching, conversations]
---

# Claude Caching for Multi-Turn Conversations

An 8-turn conversation on Claude Sonnet 4.6 with 30,000 tokens of average context costs $0.72 without caching. With caching enabled on the conversation history, the same exchange costs $0.175. That is a 76% reduction, and it compounds as conversations grow longer.

## The Setup

You are building a conversational assistant where each turn sends the full conversation history to the API. By turn 8, you are sending roughly 30,000 tokens of accumulated context on every request, plus the new user message.

The cost problem is geometric. Turn 1 sends 2K tokens. Turn 2 sends 6K. Turn 8 sends 30K+. Each turn re-processes every previous message at full input price. Without caching, the accumulated input cost across all turns grows quadratically with conversation length.

Caching fixes this by storing the conversation prefix and only charging 10% ($0.30/MTok on Sonnet 4.6 vs $3.00/MTok) for the cached portion on subsequent turns.

## The Math

**8-turn conversation, Sonnet 4.6, average 30K cached tokens per turn:**

Without caching:
- 8 turns x 30,000 avg tokens x $3.00/MTok = $0.72

With caching:
- Turn 1 (cache write): 30,000 x $3.75/MTok = $0.1125
- Turns 2-8 (cache reads): 7 x 30,000 x $0.30/MTok = $0.063
- Total: $0.175

**Savings: $0.545 per conversation (76%)**

For a service handling 10,000 conversations per day:
- Without caching: $7,200/day = $216,000/month
- With caching: $1,750/day = $52,500/month
- **Monthly savings: $163,500**

At Opus 4.7 prices ($5.00 input, $0.50 cache read), the per-conversation savings are even larger: $1.20 uncached vs $0.29 cached per 8-turn conversation.

## The Technique

Multi-turn caching requires placing cache breakpoints at the end of the accumulated conversation history. The previous turns get cached, and only the new user message is processed at full price.

```python
import anthropic

client = anthropic.Anthropic()

def chat_with_caching(
    system_prompt: str,
    conversation_history: list[dict],
    new_message: str
) -> str:
    """Send a multi-turn message with caching on prior turns."""

    # Build messages array with cache breakpoint on history
    messages = []

    # Add all previous turns (these get cached)
    for i, msg in enumerate(conversation_history):
        entry = {"role": msg["role"], "content": msg["content"]}
        # Place cache breakpoint on the last history message
        if i == len(conversation_history) - 1:
            entry["content"] = [
                {
                    "type": "text",
                    "text": msg["content"],
                    "cache_control": {"type": "ephemeral"}
                }
            ]
        messages.append(entry)

    # Add the new user message (processed at full price)
    messages.append({"role": "user", "content": new_message})

    response = client.messages.create(
        model="claude-sonnet-4-6-20250929",
        max_tokens=4096,
        system=[
            {
                "type": "text",
                "text": system_prompt,
                "cache_control": {"type": "ephemeral"}
            }
        ],
        messages=messages
    )

    # Log cache performance
    usage = response.usage
    print(f"Cache read: {usage.cache_read_input_tokens} tokens")
    print(f"Cache write: {usage.cache_creation_input_tokens} tokens")
    print(f"Uncached input: {usage.input_tokens} tokens")

    return response.content[0].text

# Usage
system = "You are a helpful coding assistant."
history = []

# Simulate a multi-turn conversation
turns = [
    "How do I set up a Python virtual environment?",
    "Now install Flask in that environment.",
    "Show me a basic Flask route.",
    "Add error handling to that route."
]

for user_msg in turns:
    response = chat_with_caching(system, history, user_msg)
    history.append({"role": "user", "content": user_msg})
    history.append({"role": "assistant", "content": response})
```

Critical implementation detail: the cache breakpoint must sit on the last message in your conversation history, not on the new user message. This ensures the full prefix (system prompt + prior turns) gets cached, and only the new turn's content is billed at full input price.

You can place up to 4 cache breakpoints per request. For long conversations, consider placing breakpoints at natural boundaries: one on the system prompt, one after the first few turns (which rarely change), and one on the most recent cached turn.

## The Tradeoffs

Multi-turn caching has specific limitations:

- **Token minimum applies per breakpoint**: On Sonnet 4.6, the content before each breakpoint must be at least 1,024 tokens. Short early conversations may not meet this threshold.
- **Regenerated responses break the cache**: If a user clicks "retry" and gets a different assistant response, the conversation prefix changes, invalidating the cache for all subsequent turns.
- **Branching conversations**: Chat interfaces that allow users to edit earlier messages create new prefixes, each requiring a separate cache write.
- **Memory overhead**: Very long conversations (50+ turns) may approach the context window limit (1,000,000 tokens for Sonnet 4.6), where caching savings are offset by the sheer volume of tokens.

Consider the 1-hour cache TTL for conversation workloads where users leave and return within an hour. The 5-minute default cache expires during idle periods, triggering a full cache re-write ($3.75/MTok on Sonnet 4.6) when the user resumes. The 1-hour cache costs $6.00/MTok per write but survives 15-20 minute breaks. For a 30K-token conversation history, each avoided re-write saves $0.1125 on Sonnet 4.6. If 40% of your conversations have mid-session gaps exceeding 5 minutes, the 1-hour TTL saves roughly $450/month per 10,000 daily conversations.

## Implementation Checklist

1. Track conversation length across your user base (average turns, average tokens per turn)
2. Confirm typical conversations exceed the minimum cacheable token threshold by turn 2-3
3. Add `cache_control` breakpoints to the system prompt and last history message
4. Log cache read/write ratios per conversation to validate savings
5. Handle edge cases: retries, message edits, and conversation branching
6. Set conversation length limits to prevent context window exhaustion

## Measuring Impact

Validate multi-turn caching savings with these metrics:

- **Cost per conversation**: Total API cost / conversations completed. Target: 70-80% reduction vs baseline
- **Cache hit rate per turn**: Should increase as conversations grow longer (turn 8 should have 90%+ cached tokens)
- **Tokens per dollar**: Higher is better. Caching should increase this metric 3-5x for conversation workloads
- Compare average conversation cost week-over-week using Anthropic billing exports



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Prompt Caching Pricing and Cost Savings](/claude-prompt-caching-pricing-and-cost-savings/)
- [Claude API Prompt Caching Performance Optimization](/claude-api-prompt-caching-performance-optimization-guide/)
- [Claude Code for Varnish Cache Workflow](/claude-code-for-varnish-cache-workflow-tutorial/)
