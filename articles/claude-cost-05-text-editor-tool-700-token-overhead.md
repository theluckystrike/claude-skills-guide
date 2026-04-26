---
layout: default
title: "Text Editor Tool (2026)"
description: "Claude's text editor tool adds 700 tokens per turn. Learn how phase-based tool loading cuts editor overhead by 60% in agent workflows."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-text-editor-tool-700-token-overhead/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, text-editor, tokens]
---

# Text Editor Tool: 700 Token Overhead Explained

Claude's text editor tool definition consumes 700 input tokens on every turn it's included. That's nearly three times the bash tool's 245-token overhead and twice the system prompt overhead of 346 tokens. For an agentic coding workflow where the editor is present on every turn, those 700 tokens at Opus 4.7 rates ($5.00/MTok) add $0.0035 per turn. A 30-turn coding session accumulates $0.105 in editor overhead alone -- and across a fleet of agents running 200 sessions daily, that's $630/month in tokens that describe a tool rather than do useful work.

## The Setup

The text editor tool is the heaviest of Claude's three built-in tool definitions. It weighs 700 tokens because its schema describes multiple operations (view, create, insert, replace) with detailed parameter specifications for each. Every time the tool appears in a request's `tools` array, those 700 tokens get serialized, sent to the API, and billed at the input token rate. In a typical coding agent session, the text editor is used for maybe 5-10 of 30 total turns, but its 700-token definition rides along on all 30 turns. That means 20 turns carry 700 tokens of dead weight each -- 14,000 wasted tokens per session.

## The Math

A coding agent that runs 30 turns per session with all three tools always loaded:

**Per-turn overhead (all tools):**
- System prompt: 346 tokens
- Bash tool: 245 tokens
- Text editor: 700 tokens
- Computer use: 735 tokens
- Total: 2,026 tokens per turn

**30-turn session, all tools always present:**
- Total overhead: 30 x 2,026 = 60,780 tokens
- At Opus 4.7 ($5.00/MTok): **$0.304 per session**

**After optimization (text editor on 10 of 30 turns, no computer use):**
- 10 turns with editor: 10 x (346 + 245 + 700) = 12,910 tokens
- 20 turns without editor: 20 x (346 + 245) = 11,820 tokens
- Total: 24,730 tokens
- At Opus 4.7: **$0.124 per session**

**Savings: $0.180 per session (59% reduction)**
**At 200 sessions/day: $1,080/month saved**

## The Technique

Implement a tool presence manager that tracks which tools the model actually requested and only includes them when contextually appropriate.

```python
import anthropic
from dataclasses import dataclass, field

client = anthropic.Anthropic()

BASH_TOOL = {
    "name": "bash",
    "description": "Run bash command",
    "input_schema": {
        "type": "object",
        "properties": {"command": {"type": "string"}},
        "required": ["command"]
    }
}

TEXT_EDITOR = {
    "name": "text_editor",
    "description": "View or edit files",
    "input_schema": {
        "type": "object",
        "properties": {
            "command": {"type": "string", "enum": ["view", "create", "insert", "replace"]},
            "path": {"type": "string"},
            "content": {"type": "string"}
        },
        "required": ["command", "path"]
    }
}

@dataclass
class AdaptiveToolManager:
    """Only include tools the agent is likely to need next."""
    recent_tool_uses: list[str] = field(default_factory=list)
    phase: str = "investigate"

    def update(self, response) -> None:
        """Track which tools were used in the last response."""
        for block in response.content:
            if block.type == "tool_use":
                self.recent_tool_uses.append(block.name)
                if len(self.recent_tool_uses) > 10:
                    self.recent_tool_uses.pop(0)

    def detect_phase(self) -> str:
        """Infer agent phase from recent tool usage."""
        if not self.recent_tool_uses:
            return "investigate"
        last_three = self.recent_tool_uses[-3:]
        if "text_editor" in last_three:
            return "edit"
        return "investigate"

    def get_tools(self) -> list[dict]:
        """Return tools appropriate for current phase."""
        phase = self.detect_phase()
        if phase == "investigate":
            return [BASH_TOOL]  # 245 tokens (saves 700)
        elif phase == "edit":
            return [BASH_TOOL, TEXT_EDITOR]  # 945 tokens
        return [BASH_TOOL, TEXT_EDITOR]  # fallback

# Usage in agent loop
manager = AdaptiveToolManager()
messages = [{"role": "user", "content": "Fix the failing test in test_auth.py"}]

for turn in range(30):
    tools = manager.get_tools()
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=4096,
        tools=tools,
        messages=messages
    )

    manager.update(response)

    # Process tool results and continue conversation
    if response.stop_reason == "tool_use":
        tool_results = execute_tools(response)
        messages.extend([
            {"role": "assistant", "content": response.content},
            {"role": "user", "content": tool_results}
        ])
    else:
        break  # agent finished
```

The adaptive manager keeps the text editor out of investigation turns (typically 60-70% of a session), saving 700 tokens per excluded turn.

## The Tradeoffs

The model might need the text editor unexpectedly during an investigation phase -- for example, discovering it needs to fix a typo while reading output. Without the editor tool available, it either has to wait for the next turn (when the manager detects the shift to edit phase) or produce a suboptimal response using bash for editing. One mitigation: if the model's response text mentions wanting to edit a file but no editor tool is available, add the editor on the next turn immediately. The latency cost of one extra round-trip is much cheaper than carrying 700 tokens on 20 unnecessary turns.

## Implementation Checklist

- Profile your agent sessions to find what percentage of turns actually use the text editor
- Implement phase detection based on recent tool invocations
- Start conservative: include the editor in "investigate" phase too, then gradually restrict
- Add a fallback that re-includes the editor if the model's text output mentions file editing
- Track per-session overhead tokens to verify the reduction
- Set up alerts if task completion rate drops after the change

## Measuring Impact

Compare total input tokens per session before and after deploying adaptive tool loading. Expect a 40-60% reduction in tool overhead tokens if the editor is excluded from 60-70% of turns. At Sonnet 4.6 ($3.00/MTok), saving 700 tokens on 20 turns = 14,000 tokens = $0.042 per session. At 200 daily sessions, that's $252/month. Track task completion rate alongside cost to ensure quality stays constant.

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude API Tool Use Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Advanced Claude Skills with Tool Use](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Claude Skills Token Optimization Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/)

## See Also

- [Token-Efficient Few-Shot Examples for Claude](/token-efficient-few-shot-examples-claude/)
- [Claude Code $200 Max Plan: Is It Worth the Cost](/claude-code-200-max-plan-worth-the-cost/)
- [Reduce Claude Code Token Consumption by 60%](/reduce-claude-code-token-consumption-60-percent/)
- [Claude Workspace Spend Limits Configuration](/claude-workspace-spend-limits-configuration/)
