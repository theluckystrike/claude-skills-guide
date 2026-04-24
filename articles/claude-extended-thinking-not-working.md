---
layout: default
title: "Fix Claude Extended Thinking Not"
description: "Fix Claude extended thinking errors. Covers budget_tokens validation, tool_choice conflicts, display options, and multi-turn thinking continuity."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-extended-thinking-not-working/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-api, sdk-python, extended-thinking, api-errors]
geo_optimized: true
---
# Claude Extended Thinking Not Working Fix

Extended thinking gives Claude deeper reasoning capabilities, but misconfigured parameters produce 400 errors or empty thinking blocks. This guide covers every failure mode and the exact fix.

## The Error

```json
{
 "type": "error",
 "error": {
 "type": "invalid_request_error",
 "message": "thinking.budget_tokens: must be >= 1024 and < max_tokens"
 }
}
```

## Quick Fix

1. Set `budget_tokens` to at least 1024 and strictly less than `max_tokens`.
2. When using tools with thinking, set `tool_choice` to `auto` or `none` only.
3. Pass thinking blocks back unmodified in multi-turn conversations.

## What Causes This

Extended thinking fails when:

- `budget_tokens` is less than 1024 or greater than or equal to `max_tokens`.
- `tool_choice` is set to `any` or a specific tool name (only `auto` and `none` work with thinking).
- Thinking is toggled on or off mid-assistant-turn.
- Thinking blocks are modified or stripped when passing them back in multi-turn conversations.
- Thinking parameters change between turns, invalidating cached messages.

## Full Solution

### Basic Extended Thinking Setup

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=[{"role": "user", "content": "Solve this step by step: What is 127 * 389?"}]
)

for block in response.content:
 if block.type == "thinking":
 print(f"Thinking: {block.thinking[:200]}...")
 elif block.type == "text":
 print(f"Answer: {block.text}")
```

### Fix budget_tokens Validation

The `budget_tokens` value must satisfy: `1024 <= budget_tokens < max_tokens`:

```python
# WRONG: budget_tokens >= max_tokens
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=8000,
 thinking={"type": "enabled", "budget_tokens": 8000}, # Error: not < max_tokens
 messages=[...]
)

# WRONG: budget_tokens < 1024
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=8000,
 thinking={"type": "enabled", "budget_tokens": 500}, # Error: < 1024
 messages=[...]
)

# CORRECT
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000}, # 1024 <= 10000 < 16000
 messages=[...]
)
```

### Fix Tool Choice Conflicts

Extended thinking only supports `tool_choice: auto` or `tool_choice: none`:

```python
# WRONG: tool_choice "any" with thinking
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 tool_choice={"type": "any"}, # Error!
 tools=[{"name": "calc", "description": "Calculate", "input_schema": {"type": "object", "properties": {}}}],
 messages=[...]
)

# CORRECT: tool_choice "auto" with thinking
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 tool_choice={"type": "auto"}, # OK
 tools=[{"name": "calc", "description": "Calculate", "input_schema": {"type": "object", "properties": {}}}],
 messages=[...]
)
```

### Control Thinking Display

By default, Claude 4 models return summarized thinking. You can control this with the `display` parameter:

```python
# Summarized thinking (default) -- charged for full tokens, returns summary
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000, "display": "summarized"},
 messages=[...]
)

# Omit thinking content -- returns empty thinking blocks with encrypted signature
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000, "display": "omitted"},
 messages=[...]
)
```

### Multi-Turn Thinking Continuity

Pass thinking blocks back unmodified to maintain reasoning continuity:

```python
# First turn
response1 = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=[{"role": "user", "content": "What is 127 * 389?"}]
)

# Second turn -- pass ALL content blocks back unmodified
messages = [
 {"role": "user", "content": "What is 127 * 389?"},
 {"role": "assistant", "content": response1.content}, # Includes thinking blocks
 {"role": "user", "content": "Now multiply that result by 2"}
]

response2 = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=messages
)
```

### TypeScript Example

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const response = await client.messages.create({
 model: "claude-sonnet-4-6",
 max_tokens: 16000,
 thinking: { type: "enabled", budget_tokens: 10000 },
 messages: [{ role: "user", content: "Solve step by step: What is 127 * 389?" }]
});

for (const block of response.content) {
 if (block.type === "thinking") {
 console.log("Thinking:", block.thinking.slice(0, 200));
 } else if (block.type === "text") {
 console.log("Answer:", block.text);
 }
}
```

## Prevention

1. **Always set max_tokens > budget_tokens + expected output**: A good rule is `max_tokens = budget_tokens + 4096`.
2. **Default to tool_choice auto**: When combining tools with thinking, always use `auto`.
3. **Never modify thinking blocks**: In multi-turn conversations, return them exactly as received.
4. **Keep thinking params stable**: Changing thinking parameters between turns invalidates cached messages but not cached system prompts or tools.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-extended-thinking-not-working)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

- [Claude Extended Thinking API Guide](/claude-extended-thinking-api-guide/) -- full tutorial on using extended thinking effectively.
- [Claude Tool Use Not Working](/claude-tool-use-not-working/) -- debug tool_choice and tool definition issues.
- [Claude API Error 400 invalid_request_error Fix](/claude-api-error-400-invalidrequesterror-explained/) -- the error type returned for thinking parameter violations.
- [Claude Prompt Caching Not Working](/claude-prompt-caching-not-working/) -- understand how thinking changes affect cache invalidation.
- [Claude Streaming API Guide](/claude-streaming-api-guide/) -- streaming works with extended thinking for real-time output.


