---
layout: default
title: "How Tool Definitions Add 346 Tokens (2026)"
description: "Claude injects 346 system tokens every time you enable tool use. Here's how to measure and minimize that $17/day hidden cost."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-tool-definitions-346-tokens-per-call/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, tool-use, tokens]
---

# How Tool Definitions Add 346 Tokens Per Call

Send a Claude API request with `tools: []` and your input token count jumps by 346 tokens before you type a single word. That's the system prompt overhead Anthropic injects whenever tool use is active. At Sonnet 4.6's $3.00 per million input tokens, those 346 tokens cost $0.001038 per request. Across 50,000 requests per day, you're paying $51.90 daily -- $1,557 monthly -- for tokens you never wrote.

## The Setup

When you pass a `tools` parameter in your API request, Claude adds an internal system prompt that explains to the model how to format tool calls. The size depends on the `tool_choice` setting and which [Claude Code router guide](/claude-code-router-guide/) model you're using. The overhead is separate from and additive to the tokens consumed by individual tool definitions (names, descriptions, and JSON schemas).

## The Math

Compare identical requests with and without tool use enabled on Opus 4.7 ($5.00/MTok input):

**Without tools:**
- System prompt: 200 tokens
- User message: 100 tokens
- Total input: 300 tokens
- Cost: $0.0015

**With tools (3 tools, ~300 tokens each):**
- System prompt: 200 tokens
- Tool system overhead: 346 tokens
- Tool definitions: 3 x 300 = 900 tokens
- User message: 100 tokens
- Total input: 1,546 tokens
- Cost: $0.00773

**The tool overhead alone (1,246 tokens) costs $0.00623 -- a 415% increase per request.**

At 10,000 requests/day over a month:
- Without tools: 300 x 10K x 30 x $5/MTok = **$450/month**
- With tools: 1,546 x 10K x 30 x $5/MTok = **$2,319/month**
- Tool overhead cost: **$1,869/month**

## The Technique

Measure and eliminate this overhead with a two-step approach: first audit, then conditionally disable.

```python
import anthropic
import json

client = anthropic.Anthropic()

def measure_tool_overhead():
    """Compare token usage with and without tools."""

    base_message = [{"role": "user", "content": "What is 2+2?"}]

    # Request WITHOUT tools
    resp_no_tools = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=50,
        messages=base_message
    )

    # Request WITH tools
    simple_tool = [{
        "name": "calculator",
        "description": "Calculate",
        "input_schema": {
            "type": "object",
            "properties": {"expr": {"type": "string"}},
            "required": ["expr"]
        }
    }]

    resp_with_tools = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=50,
        tools=simple_tool,
        messages=base_message
    )

    overhead = (resp_with_tools.usage.input_tokens
                - resp_no_tools.usage.input_tokens)

    print(f"Without tools: {resp_no_tools.usage.input_tokens} input tokens")
    print(f"With tools:    {resp_with_tools.usage.input_tokens} input tokens")
    print(f"Tool overhead: {overhead} tokens")
    print(f"Overhead cost at Opus $5/MTok: ${overhead * 5 / 1_000_000:.6f}")
    return overhead


def smart_request(user_message: str, needs_tools: bool = False):
    """Only include tools when actually needed."""
    kwargs = {
        "model": "claude-sonnet-4-6",
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": user_message}]
    }

    if needs_tools:
        kwargs["tools"] = load_tools()  # your tool definitions

    return client.messages.create(**kwargs)


def load_tools():
    """Load minimal tool definitions from config."""
    with open("tools.json") as f:
        return json.load(f)
```

The key insight: if your application handles both tool-use and non-tool-use requests, split them into separate code paths. Only attach the `tools` parameter when the request genuinely requires function calling. For classification, summarization, or generation tasks that never need tools, omit the parameter entirely and save 346+ tokens per call.

For requests that do need tools, minimize definition size. Strip unnecessary descriptions, remove optional schema properties the model rarely uses, and use `$ref` to avoid duplicating shared sub-schemas.

## The Tradeoffs

Splitting tool and non-tool code paths adds routing complexity. You need a reliable way to determine which requests need tools before sending them. Misrouting a tool-needing request to the non-tool path means the model cannot call any function. Also, some conversation flows start without tools but later require them -- you'll need to handle mid-conversation tool injection, which means managing message history across both modes. One practical concern: the `tool_choice` parameter itself affects overhead. Using `any` instead of `auto` saves 33 tokens per request (313 vs. 346), which at Opus 4.7 rates equals $0.000165 per request. That's $49.50/month at 10,000 requests/day -- a small win but entirely free to implement. If you know every request needs exactly one specific tool, use `tool_choice: {"type": "tool", "name": "your_tool"}` to get the 313-token overhead instead of 346.

When combining tool overhead reduction with batch processing, the savings stack. Batch mode cuts input token costs by 50%, reducing Opus 4.7 from $5.00/MTok to $2.50/MTok. The 346-token overhead at batch rates costs $0.000865 per request instead of $0.00173. At 50,000 daily requests, batch mode alone saves $43.25/day on the system overhead tokens. Combined with splitting tool and non-tool paths, a team processing 50,000 daily requests could save $2,592/month on overhead tokens alone by batching non-tool requests and omitting the `tools` parameter entirely.

## Implementation Checklist

- Measure your current tool overhead using the audit script above
- Classify your request types into "needs tools" and "no tools needed"
- Split API calls into two paths, omitting `tools` parameter when unused
- Trim tool descriptions to the minimum the model needs for accurate invocation
- Remove unused properties from tool input schemas
- Log `usage.input_tokens` on both paths to verify savings

## Measuring Impact

Track two metrics: average input tokens per request on the tool path vs. the non-tool path, and the percentage of requests routed to each. Multiply the delta by your model's input price. If you route 40% of 50,000 daily requests away from tools, saving 1,246 tokens each at Sonnet 4.6 rates ($3.00/MTok), that's 20,000 x 1,246 x $3.00/MTok = $74.76 per day, or $2,243 per month.

## Related Guides

- [Claude API Tool Use Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Claude Skills Token Optimization Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/)
- [Advanced Claude Skills with Tool Use](/advanced-claude-skills-with-tool-use-and-function-calling/)

- [Claude Code cost guide](/claude-code-cost-complete-guide/) — Complete guide to Claude Code costs, pricing, and optimization

