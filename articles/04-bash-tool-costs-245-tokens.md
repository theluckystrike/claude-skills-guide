---
layout: default
title: "Claude Bash Tool Costs 245 Tokens (2026)"
description: "Each Claude bash tool invocation adds 245 input tokens. At Opus rates, 100 daily debug sessions cost $225/month in overhead alone."
date: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-bash-tool-costs-245-tokens-per-call/
reviewed: true
score: 8
categories: [cost-optimization]
tags: [claude, cost-reduction, bash-tool, tokens]
---

# Claude Bash Tool Costs 245 Tokens Per Call

The Claude bash tool adds 245 input tokens to every request where it's included. That's the schema definition overhead -- name, description, parameter specifications -- serialized into your input context. At Opus 4.7's $5.00 per million input tokens, each bash tool inclusion costs $0.001225. An agent that makes 20 bash calls in a debugging session accumulates 4,900 tokens of tool overhead alone, costing $0.0245. Run 100 such sessions daily and you're spending $73.50/month just on bash tool definition tokens.

## The Setup

The bash tool is one of three built-in tools Anthropic provides for agentic workflows. Its definition consumes 245 input tokens on every turn where it's available. In an iterative coding agent, the bash tool might be invoked 10-30 times per session as the model runs commands, checks output, fixes errors, and reruns. Each round-trip carries the 245-token overhead plus the 346-token system prompt overhead for tool use. The real cost isn't just the overhead per call -- it's the compound effect across dozens of iterations in a single session. Add the text editor tool (700 tokens) and you're looking at 1,291 tokens of fixed overhead per turn.

## The Math

An agent debugging a failing test suite with 20 bash calls in one session:

**Tool overhead per turn:**
- System prompt overhead: 346 tokens
- Bash tool definition: 245 tokens
- Text editor definition: 700 tokens
- Total overhead: 1,291 tokens per turn

**20-turn debugging session:**
- Fixed overhead: 20 x 1,291 = 25,820 tokens
- Bash command outputs (avg 500 tokens each): 20 x 500 = 10,000 tokens
- Total tool-related tokens: 35,820

**At Opus 4.7 ($5.00/MTok input):**
- Tool overhead cost per session: 35,820 x $5.00/MTok = **$0.179**

**At scale (100 sessions/day, 30 days):**
- Monthly tool overhead: 100 x 30 x $0.179 = **$537.00/month**

**Optimized (remove text editor when not needed, batch bash calls):**
- Drop text editor: saves 700 tokens/turn = 14,000 tokens/session
- Batch 20 commands into 10 calls: saves 10 x 591 = 5,910 tokens/session
- Savings per session: 19,910 tokens = $0.0996
- Monthly savings: $298.70

## The Technique

Reduce bash tool overhead by batching commands and conditionally including tools.

```bash
#!/bin/bash
# Instead of running 5 separate bash tool calls:
#   ls -la
#   cat package.json | jq '.dependencies'
#   npm test 2>&1 | tail -20
#   git status
#   git log --oneline -5

# Batch into a single call:
echo "=== FILES ===" && ls -la && \
echo "=== DEPS ===" && cat package.json | jq '.dependencies' && \
echo "=== TESTS ===" && npm test 2>&1 | tail -20 && \
echo "=== GIT STATUS ===" && git status && \
echo "=== RECENT COMMITS ===" && git log --oneline -5
```

On the API side, structure your agent to prefer batched commands:

```python
import anthropic

client = anthropic.Anthropic()

def build_agent_tools(phase: str) -> list[dict]:
    """Include only the tools needed for each agent phase."""

    bash_tool = {
        "name": "bash",
        "description": "Run a bash command",
        "input_schema": {
            "type": "object",
            "properties": {
                "command": {"type": "string", "description": "The bash command to run"}
            },
            "required": ["command"]
        }
    }

    text_editor = {
        "name": "text_editor",
        "description": "Edit a file",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "content": {"type": "string"}
            },
            "required": ["path", "content"]
        }
    }

    # Phase-based tool selection
    if phase == "investigate":
        return [bash_tool]  # only need bash for reading/running
    elif phase == "edit":
        return [text_editor]  # only need editor for changes
    elif phase == "verify":
        return [bash_tool]  # only need bash for testing
    else:
        return [bash_tool, text_editor]  # full set when unsure

# Investigation phase: bash only (saves 700 tokens/turn from text_editor)
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=4096,
    tools=build_agent_tools("investigate"),
    messages=[{"role": "user", "content": "Investigate why tests fail"}]
)
```

The phase-based approach eliminates the text editor's 700 tokens during investigation and verification phases, cutting per-turn overhead from 1,291 to 591 tokens -- a 54% reduction.

## The Tradeoffs

Batching bash commands reduces the model's ability to react to intermediate results. If the first command in a batch fails, the model can't adjust its approach until the entire batch completes. Phase-based tool selection requires knowing the agent's workflow stage, which adds orchestration complexity. Some tasks naturally require both bash and editor tools simultaneously -- forcing a phase boundary between reading and editing can make the agent less efficient overall.

## Implementation Checklist

- Count current average bash tool calls per session from your logs
- Identify command sequences that can be batched (read-only operations are best candidates)
- Implement phase-based tool injection in your agent loop
- Add `echo "=== SECTION ==="` separators in batched commands for parseable output
- Monitor session token counts before and after optimization
- Track task completion rates to ensure batching doesn't degrade quality

## Measuring Impact

Log the number of tool calls per session and total `usage.input_tokens`. After implementing batching, you should see fewer turns per session and lower total input tokens. Calculate savings as: (old_turns - new_turns) x overhead_per_turn x input_price. For a 20-turn session reduced to 12 turns with bash-only phases, savings are 8 x 591 x $5.00/MTok = $0.0236 per session. At 100 sessions/day, that's $70.88/month.

To baseline your current overhead accurately, log the `usage.input_tokens` field from the API response and subtract your known prompt size. The difference is tool overhead plus conversation history tokens. For agents running on Sonnet 4.6 at $3.00/MTok instead of Opus, the per-session savings from batching are proportionally smaller ($0.0142 per session) but still meaningful at scale -- $42.53/month at 100 sessions/day.



**Know your costs →** Use our [Claude Code Cost Calculator](/calculator/) to estimate your monthly spend.

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude API Tool Use Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Advanced Claude Skills with Tool Use](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Claude Skills Token Optimization Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/)

- [Claude Code cost guide](/claude-code-cost-complete-guide/) — Complete guide to Claude Code costs, pricing, and optimization

## See Also

- [How Tool Definitions Add 346 Tokens Per Call](/claude-tool-definitions-346-tokens-per-call/)
