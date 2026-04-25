---
layout: default
title: "Claude Tool Use Hidden Token Costs"
description: "Every Claude API tool call adds 346 hidden tokens. Learn exactly where tool use costs come from and how to cut them by 50%."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-tool-use-hidden-token-costs-explained/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, tool-use, tokens]
---

# Claude Tool Use Hidden Token Costs Explained

Every time you enable tool use in a Claude API call, 346 invisible tokens get added to your input before your prompt even starts. At Opus 4.7 rates of $5.00 per million input tokens, that's $0.00173 per request -- and across 10,000 daily requests, it adds up to $17.30 per day you never budgeted for.

## The Setup

Most developers enable tool use with a set of tool definitions and assume the only cost is their prompt plus the model's response. But the Claude API injects additional tokens in three places you might not expect: a system prompt overhead (346 tokens for `auto` or `none` tool choice, 313 for `any` or specific tool), the serialized JSON schema of every tool definition, and the `tool_use` and `tool_result` content blocks that flow through the conversation. These hidden tokens compound because they're charged at the full input rate on every single request, even when no tool gets called.

## The Math

Consider a pipeline making 10,000 Opus 4.7 requests per day with 5 tool definitions averaging 400 tokens each.

**Before optimization (all tools always included):**
- System overhead: 346 tokens per request
- Tool definitions: 5 tools x 400 tokens = 2,000 tokens per request
- Total tool overhead: 2,346 tokens x 10,000 requests = 23.46M tokens/day
- Daily cost: 23.46M x $5.00/MTok = **$117.30/day ($3,519/month)**

**After optimization (only include tools needed per request):**
- Average tools per request drops to 2: 800 tokens
- System overhead: 346 tokens
- Total overhead: 1,146 tokens x 10,000 requests = 11.46M tokens/day
- Daily cost: 11.46M x $5.00/MTok = **$57.30/day ($1,719/month)**

**Monthly savings: $1,800 (51% reduction in tool overhead)**

## The Technique

The fix is conditional tool injection -- only send the tools each request actually needs.

```python
import anthropic

client = anthropic.Anthropic()

# Define your full tool catalog
ALL_TOOLS = {
    "search_db": {
        "name": "search_db",
        "description": "Search the database",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {"type": "string"}
            },
            "required": ["query"]
        }
    },
    "send_email": {
        "name": "send_email",
        "description": "Send an email",
        "input_schema": {
            "type": "object",
            "properties": {
                "to": {"type": "string"},
                "body": {"type": "string"}
            },
            "required": ["to", "body"]
        }
    },
    "get_weather": {
        "name": "get_weather",
        "description": "Get current weather",
        "input_schema": {
            "type": "object",
            "properties": {
                "city": {"type": "string"}
            },
            "required": ["city"]
        }
    }
}

def classify_intent(user_message: str) -> list[str]:
    """Lightweight classifier to pick relevant tools."""
    keywords = {
        "search_db": ["find", "search", "look up", "query"],
        "send_email": ["email", "send", "notify", "message"],
        "get_weather": ["weather", "temperature", "forecast"],
    }
    matched = []
    lower = user_message.lower()
    for tool_name, triggers in keywords.items():
        if any(kw in lower for kw in triggers):
            matched.append(tool_name)
    return matched or list(ALL_TOOLS.keys())  # fallback to all

def call_with_minimal_tools(user_message: str) -> dict:
    """Only include tools the request actually needs."""
    needed = classify_intent(user_message)
    tools = [ALL_TOOLS[name] for name in needed]

    return client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        tools=tools,
        messages=[{"role": "user", "content": user_message}]
    )

# Result: 1-2 tools per request instead of all 5
response = call_with_minimal_tools("Search for recent orders")
```

For even more savings, keep tool descriptions minimal. Replace verbose multi-sentence descriptions with terse one-liners. A description going from 50 tokens to 15 tokens saves 35 tokens per tool per request.

## The Tradeoffs

Conditional tool injection adds routing logic that can misclassify requests. If a user message needs `send_email` but your classifier misses it, the model cannot call that tool and the request fails or produces a suboptimal text-only response. You need a fallback strategy -- either include all tools when confidence is low, or let the model request a retry with additional tools. Additionally, splitting tool sets means more code paths to test and maintain. The classifier itself can be another source of cost: if you use a Haiku pre-classification call at $1.00/MTok input, that adds roughly $0.001 per request. At 10,000 requests/day, the classifier costs $10/day or $300/month -- still far less than the $1,800/month you save from tool pruning. A simpler keyword-based approach costs nothing but may misroute 5-10% of requests. Start with keywords and graduate to model-based classification only if accuracy becomes a problem.

## Edge Cases and Common Pitfalls

Tool overhead interacts with prompt caching in a way that catches many teams off guard. When you cache a system prompt that includes tool definitions, the cache write costs 1.25x the base input price ($6.25/MTok on Opus 4.7) for all tokens including tool definitions. If you then change the tool set on the next request, the cache is invalidated and you pay for a fresh write. Teams that conditionally inject tools must ensure the same tool set is used within each cache window, or the caching savings disappear entirely.

Another pitfall: tool definitions with deeply nested JSON schemas consume far more tokens than flat schemas. A tool with 3 levels of nested objects can reach 800-1,200 tokens, compared to 200-300 tokens for a flat schema with the same number of parameters. Flatten your schemas where possible and use string-encoded JSON for complex inputs instead of deeply nested schema definitions.

## Implementation Checklist

- Audit your current tool definitions and count total tokens per tool using `anthropic.count_tokens()`
- Build an intent classifier (keyword-based or a cheap Haiku pre-classification call at $1.00/MTok input)
- Implement conditional tool injection based on classified intent
- Add a fallback that includes all tools when classifier confidence is below threshold
- Monitor tool invocation rates to verify no tool is being starved by misclassification
- Track token overhead reduction in your cost dashboard

## Measuring Impact

Log `usage.input_tokens` from every API response before and after implementing conditional tool injection. Calculate the delta and multiply by your model's input price. For Opus 4.7 at $5.00/MTok, every 1,000 tokens saved across 10,000 requests equals $50.00 per day. Set up a daily report comparing overhead tokens (total input minus your known prompt length) to catch regressions. Track the classifier accuracy rate alongside cost savings -- if accuracy drops below 95%, investigate whether certain intent categories need more keyword coverage or a model-based pre-classifier.

## Related Guides

- [Claude API Tool Use Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Advanced Claude Skills with Tool Use](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Claude Skills Token Optimization Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/)

- [Claude Code cost guide](/claude-code-cost-complete-guide/) — Complete guide to Claude Code costs, pricing, and optimization

## See Also

- [Claude Bash Tool Costs 245 Tokens Per Call](/claude-bash-tool-costs-245-tokens-per-call/)
- [Claude tool_use Response Parsing Error — Fix (2026)](/claude-tool-use-response-parsing-error-fix/)
- [Web Search Costs $10 per 1,000 Searches](/claude-web-search-costs-10-per-thousand/)
