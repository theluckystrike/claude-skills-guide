---
layout: default
title: "Pruning Unused Claude Tools Saves Real (2026)"
description: "Remove 5 unused tool definitions and save $125 per 10,000 Opus requests. A step-by-step guide to tool inventory auditing."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /pruning-unused-claude-tools-saves-money/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, tool-use, optimization]
---

# Pruning Unused Claude Tools Saves Real Money

Five unused tool definitions sitting in your API requests cost $125.00 across 10,000 Opus 4.7 calls. Each tool definition averages 400-500 tokens of JSON schema, descriptions, and parameter specifications. Those tokens get billed at the full input rate on every single request, whether the model invokes that tool or not. Removing tools you don't use is the simplest cost cut available.

## The Setup

Tool definitions accumulate organically. A developer adds a `send_sms` tool during a prototype, another adds `translate_text` for a feature that gets shelved, and a third copies a `web_scraper` tool from a tutorial. Six months later, the tools array has 12 entries but only 4 ever get called. The unused 8 sit there consuming tokens on every request. Unlike unused code, unused tool definitions cost you money on every API call because they're serialized into the input context window and billed at the model's input token rate.

## The Math

A typical tool definition with name, description, and input schema runs 300-600 tokens. Taking 500 tokens as the midpoint:

**Before (10 tools, only 5 used):**
- 10 tools x 500 tokens = 5,000 tokens per request
- System overhead: 346 tokens
- Total tool tokens: 5,346 per request
- 10,000 Opus 4.7 requests: 53.46M tokens x $5.00/MTok = **$267.30**

**After (5 unused tools removed):**
- 5 tools x 500 tokens = 2,500 tokens per request
- System overhead: 346 tokens
- Total tool tokens: 2,846 per request
- 10,000 Opus 4.7 requests: 28.46M tokens x $5.00/MTok = **$142.30**

**Savings: $125.00 per 10,000 requests (47% reduction in tool token spend)**

At 10,000 requests/day, that's $3,750/month saved by deleting dead tool definitions.

## The Technique

Build a tool usage audit pipeline that tracks which tools actually get invoked, then prune the unused ones.

```python
import anthropic
import json
from collections import Counter
from datetime import datetime, timedelta

client = anthropic.Anthropic()

# Step 1: Instrument your API calls to log tool invocations
class ToolUsageTracker:
    def __init__(self):
        self.invocations = Counter()
        self.total_requests = 0

    def track_response(self, response):
        """Call this after every API response."""
        self.total_requests += 1
        for block in response.content:
            if block.type == "tool_use":
                self.invocations[block.name] += 1

    def get_unused_tools(self, all_tool_names: list[str],
                         min_requests: int = 1000) -> list[str]:
        """Return tools never invoked after min_requests calls."""
        if self.total_requests < min_requests:
            return []  # not enough data
        return [
            name for name in all_tool_names
            if self.invocations[name] == 0
        ]

    def get_report(self, all_tool_names: list[str]) -> str:
        """Generate a usage report."""
        lines = [f"Tool Usage Report ({self.total_requests} requests)"]
        lines.append("-" * 50)
        for name in all_tool_names:
            count = self.invocations[name]
            pct = (count / self.total_requests * 100) if self.total_requests else 0
            status = "UNUSED" if count == 0 else f"{count} calls ({pct:.1f}%)"
            lines.append(f"  {name}: {status}")
        return "\n".join(lines)

# Step 2: Run audit for 24 hours, then prune
tracker = ToolUsageTracker()

ALL_TOOLS = [
    {"name": "search_db", "description": "Query database",
     "input_schema": {"type": "object", "properties": {"q": {"type": "string"}}, "required": ["q"]}},
    {"name": "send_email", "description": "Send email",
     "input_schema": {"type": "object", "properties": {"to": {"type": "string"}}, "required": ["to"]}},
    {"name": "translate", "description": "Translate text",
     "input_schema": {"type": "object", "properties": {"text": {"type": "string"}}, "required": ["text"]}},
    {"name": "get_weather", "description": "Get weather",
     "input_schema": {"type": "object", "properties": {"city": {"type": "string"}}, "required": ["city"]}},
    {"name": "calc_tax", "description": "Calculate tax",
     "input_schema": {"type": "object", "properties": {"amount": {"type": "number"}}, "required": ["amount"]}},
]

# After collecting data, generate report and prune
tool_names = [t["name"] for t in ALL_TOOLS]
print(tracker.get_report(tool_names))

unused = tracker.get_unused_tools(tool_names, min_requests=1000)
ACTIVE_TOOLS = [t for t in ALL_TOOLS if t["name"] not in unused]

print(f"\nPruned {len(unused)} unused tools: {unused}")
print(f"Token savings estimate: {len(unused) * 500} tokens/request")
```

After identifying unused tools, remove them from your tools array. Store the full catalog in a config file for easy restoration if needs change, but keep the active request payload lean.

## The Tradeoffs

Pruning too aggressively can break edge cases. A tool invoked once per 10,000 requests might seem unused in a 1,000-request sample. Use at least 24 hours of production traffic before making pruning decisions. Keep removed tool definitions in version control so they can be restored quickly. Also consider seasonal patterns -- a `generate_tax_report` tool might only be used in Q1 but still needs to be available.

The savings multiply when you combine pruning with [model routing](/claude-code-router-guide/). Removing 5 tools at 500 tokens each saves 2,500 tokens per request. On Haiku 4.5 at $1.00/MTok, that saves $0.0025 per request. On Opus 4.7 at $5.00/MTok, the same pruning saves $0.0125 per request -- 5x more. If you are already routing simple requests to Haiku, focus your pruning efforts on the Opus request path where each saved token is worth 5x more. At 10,000 Opus requests/day, pruning 5 tools saves $3,750/month. The same pruning applied only to Haiku requests saves $750/month. Prioritize accordingly.

## Implementation Checklist

- Add tool invocation logging to your API response handler
- Run the audit for at least 24-48 hours of production traffic
- Generate usage report and identify zero-invocation tools
- Move unused tools to an archived config file (not deleted entirely)
- Deploy with the reduced tools array
- Monitor for any user-reported missing functionality
- Re-run audit weekly to catch newly unused tools

## Measuring Impact

Compare `usage.input_tokens` averages from the week before pruning to the week after. For each pruned tool, you should see a drop of 300-600 tokens per request. At Sonnet 4.6 rates ($3.00/MTok), removing 5 tools averaging 500 tokens each saves 2,500 tokens x $3.00/MTok = $0.0075 per request. At 10,000 daily requests, that's $75.00/day or $2,250/month.

## Related Guides

- [Claude API Tool Use Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Claude Skills Token Optimization Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/)
- [Advanced Claude Skills with Tool Use](/advanced-claude-skills-with-tool-use-and-function-calling/)

- [Claude Code cost guide](/claude-code-cost-complete-guide/) — Complete guide to Claude Code costs, pricing, and optimization

## See Also

- [Web Search Costs $10 per 1,000 Searches](/06-web-search-costs-10-per-thousand/)
