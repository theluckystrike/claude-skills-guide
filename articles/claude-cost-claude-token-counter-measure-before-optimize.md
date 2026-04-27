---
sitemap: false
layout: default
title: "Claude Token Counter (2026)"
description: "Use Anthropic's token counting API to find where your tokens go — most teams discover 40% waste in system prompts and tool defs."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-token-counter-measure-before-optimize/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction]
---

# Claude Token Counter: Measure Before You Optimize

Most Claude API users cannot answer a basic question: how many tokens does each part of my prompt consume? Teams that measure discover an average of 40% token waste in system prompts and tool definitions — that translates to $3,000/month in unnecessary spending at 10,000 requests/day on Opus 4.7.

## The Setup

You cannot optimize what you do not measure. Token counting reveals where your budget actually goes: system prompt overhead, tool definitions, user context, and output verbosity. Without this baseline, optimization efforts are guesswork.

Anthropic provides a token counting API endpoint that returns exact token counts before you send a request. This guide shows you how to build a token profiling system that identifies your biggest waste areas and quantifies the dollar impact of each.

Target audience: any team spending over $500/month on Claude API without a clear breakdown of where those tokens go.

## The Math

Typical unaudited request breakdown on Opus 4.7:

| Component | Tokens | Cost per 10K requests |
|-----------|--------|----------------------|
| System prompt | 2,000 | $100.00 |
| Tool definitions (3 tools) | 1,500 | $75.00 |
| Conversation history | 5,000 | $250.00 |
| Current user message | 1,000 | $50.00 |
| **Total input** | **9,500** | **$475.00** |
| Output | 2,000 | $500.00 (at $25/MTok) |
| **Total per 10K requests** | | **$975.00** |

After token auditing and optimization:

| Component | Tokens | Cost per 10K requests |
|-----------|--------|----------------------|
| System prompt (compressed) | 500 | $25.00 |
| Tool definitions (1 tool, conditional) | 300 | $15.00 |
| Conversation history (pruned) | 2,500 | $125.00 |
| Current user message | 800 | $40.00 |
| **Total input** | **4,100** | **$205.00** |
| Output (constrained) | 1,000 | $250.00 |
| **Total per 10K requests** | | **$455.00** |

**Savings: $520 per 10K requests (53%)**

At 30K requests/month: $1,560/month saved. At 300K requests/month: $15,600/month saved.

## The Technique

Build a token profiling wrapper that breaks down every request:

```python
import anthropic
import json
from dataclasses import dataclass

client = anthropic.Anthropic()

@dataclass
class TokenProfile:
    system_tokens: int
    tool_tokens: int
    history_tokens: int
    current_message_tokens: int
    total_input_tokens: int
    output_tokens: int
    input_cost: float
    output_cost: float
    total_cost: float

def profile_request(
    model: str,
    system: str,
    messages: list,
    tools: list = None,
    max_tokens: int = 2048,
) -> TokenProfile:
    """Profile token usage by component."""
    rates = {
        "claude-opus-4-7": (5.0, 25.0),
        "claude-sonnet-4-6": (3.0, 15.0),
        "claude-haiku-4-5-20251001": (1.0, 5.0),
    }
    input_rate, output_rate = rates.get(model, (3.0, 15.0))

    # Count system prompt tokens alone
    sys_count = client.messages.count_tokens(
        model=model,
        messages=[{"role": "user", "content": "x"}],
        system=system,
    )
    baseline = client.messages.count_tokens(
        model=model,
        messages=[{"role": "user", "content": "x"}],
    )
    system_tokens = sys_count.input_tokens - baseline.input_tokens

    # Count tool tokens
    tool_tokens = 0
    if tools:
        with_tools = client.messages.count_tokens(
            model=model,
            messages=[{"role": "user", "content": "x"}],
            tools=tools,
        )
        tool_tokens = with_tools.input_tokens - baseline.input_tokens

    # Count full request
    full_kwargs = {"model": model, "messages": messages}
    if system:
        full_kwargs["system"] = system
    if tools:
        full_kwargs["tools"] = tools
    full_count = client.messages.count_tokens(**full_kwargs)
    total_input = full_count.input_tokens

    # Derive history and current message tokens
    context_tokens = total_input - system_tokens - tool_tokens
    current_msg_tokens = len(messages[-1]["content"].split()) * 2  # rough estimate
    history_tokens = max(0, context_tokens - current_msg_tokens)

    # Make actual request to get output tokens
    response = client.messages.create(
        model=model,
        max_tokens=max_tokens,
        system=system if system else "",
        messages=messages,
        **({"tools": tools} if tools else {}),
    )
    output_tokens = response.usage.output_tokens

    input_cost = total_input * input_rate / 1_000_000
    output_cost = output_tokens * output_rate / 1_000_000

    return TokenProfile(
        system_tokens=system_tokens,
        tool_tokens=tool_tokens,
        history_tokens=history_tokens,
        current_message_tokens=current_msg_tokens,
        total_input_tokens=total_input,
        output_tokens=output_tokens,
        input_cost=round(input_cost, 6),
        output_cost=round(output_cost, 6),
        total_cost=round(input_cost + output_cost, 6),
    )

# Profile a typical request
profile = profile_request(
    model="claude-sonnet-4-6",
    system="You are a code reviewer. Check for bugs, security issues, and performance problems.",
    messages=[
        {"role": "user", "content": "Review this function:\n\ndef add(a, b):\n    return a + b"},
    ],
)

print(f"System prompt:    {profile.system_tokens:>6} tokens (${profile.system_tokens * 3 / 1_000_000:.6f})")
print(f"Tool definitions: {profile.tool_tokens:>6} tokens")
print(f"History:          {profile.history_tokens:>6} tokens")
print(f"Current message:  {profile.current_message_tokens:>6} tokens")
print(f"Total input:      {profile.total_input_tokens:>6} tokens (${profile.input_cost:.6f})")
print(f"Output:           {profile.output_tokens:>6} tokens (${profile.output_cost:.6f})")
print(f"Total cost:       ${profile.total_cost:.6f}")
```

### Quick Token Audit Script

Run this against your production prompts to find the biggest waste areas:

```bash
#!/bin/bash
# Quick token count check for your system prompt
echo "Checking system prompt token count..."
curl -s https://api.anthropic.com/v1/messages/count_tokens \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "content-type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-6",
    "system": "Your system prompt goes here. Replace with your actual system prompt to get an accurate count.",
    "messages": [{"role": "user", "content": "test"}]
  }' | python3 -c "
import sys, json
r = json.load(sys.stdin)
tokens = r['input_tokens']
opus_cost_10k = tokens * 10000 * 5 / 1_000_000
sonnet_cost_10k = tokens * 10000 * 3 / 1_000_000
print(f'Tokens: {tokens}')
print(f'Cost per 10K requests: Opus \${opus_cost_10k:.2f} | Sonnet \${sonnet_cost_10k:.2f}')
"
```

## The Tradeoffs

Token counting API calls add latency and cost. Do not count tokens on every production request — profile a representative sample of 100-500 requests, then apply optimizations based on the findings.

The token counting endpoint may return slightly different counts than the actual message endpoint due to internal formatting. Use it for relative comparisons and optimization guidance, not exact cost prediction.

Opus 4.7 uses a newer tokenizer that may produce up to 35% more tokens for the same text compared to older models. If you are migrating from an older Claude model, re-profile your prompts — token counts will change.

## Implementation Checklist

1. Run the token profiler on your top 10 most-used prompts
2. Identify which component (system, tools, history, message) dominates
3. Prioritize optimization on the largest component
4. Compress the top token consumer and re-measure
5. Calculate dollar savings at your actual request volume
6. Deploy optimized prompts and verify token reduction in billing

## Measuring Impact

Before optimization: record average input tokens, average output tokens, and total monthly spend. After optimization: measure the same metrics. Calculate the delta. Your token profiling investment pays off when the monthly savings exceed the engineering time spent profiling. At $5.00/MTok on Opus, reducing 100 tokens per request saves $5.00 per 10K requests — even small optimizations compound at scale.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code Token Usage Optimization](/claude-code-token-usage-optimization-best-practices-guide/) — apply optimizations after measuring
- [Reduce Claude Code Hallucinations Save Tokens](/reduce-claude-code-hallucinations-save-tokens-accuracy-tips/) — fewer hallucinations means fewer retries and tokens
- [Claude Skill Token Usage Profiling](/claude-skill-token-usage-profiling-and-optimization/) — per-skill token usage analysis

## See Also

- [Claude Cache Minimum Token Requirements 2026](/claude-cache-minimum-token-requirements-2026/)
- [Claude /compact Command Token Savings Guide](/claude-compact-command-token-savings/)
