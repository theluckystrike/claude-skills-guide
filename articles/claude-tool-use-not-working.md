---
layout: default
title: "Fix Claude Tool Use Not Working (2026)"
description: "Fix Claude tool use errors. Covers tool definition validation, tool_choice settings, strict mode, stop_reason handling, and multi-turn tool loops."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-tool-use-not-working/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-api, sdk-python, sdk-typescript, tool-use]
geo_optimized: true
last_tested: "2026-04-22"
---
# Claude Tool Use Not Working Fix

Tool use (function calling) lets Claude call external functions, but misconfigured tool definitions or incorrect response handling will break the interaction loop. This guide covers every common failure.

## The Error

When tool definitions are invalid:

```json
{
 "type": "error",
 "error": {
 "type": "invalid_request_error",
 "message": "tools.0.input_schema: invalid JSON schema"
 }
}
```

When the response has `stop_reason: "tool_use"` but your code does not handle it, Claude's tool call goes unanswered and the conversation stalls.

## Quick Fix

1. Verify your tool `input_schema` is a valid JSON Schema object with `type: "object"`.
2. Check `stop_reason` in every response -- if it is `"tool_use"`, you must execute the tool and send back a `tool_result`.
3. When using thinking with tools, set `tool_choice` to `auto` (not `any` or a specific tool).

## What Causes This

Tool use fails when:

- The `input_schema` is not a valid JSON Schema (missing `type`, invalid property definitions).
- Your code ignores `stop_reason: "tool_use"` and does not send back a `tool_result` message.
- `tool_choice` is set to `any` or a specific tool while extended thinking is enabled.
- `strict: true` is used with a schema that has unsupported features (some complex nested schemas cause 500 errors).
- The `tool_result` content block has the wrong `tool_use_id`.

## Full Solution

### Basic Tool Definition

Every tool needs `name`, `description`, and a valid `input_schema`:

```python
import anthropic
import json

client = anthropic.Anthropic()

tools = [
 {
 "name": "get_weather",
 "description": "Get the current weather for a given location",
 "input_schema": {
 "type": "object",
 "properties": {
 "location": {
 "type": "string",
 "description": "City and state, e.g. San Francisco, CA"
 }
 },
 "required": ["location"]
 }
 }
]

response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 tools=tools,
 messages=[{"role": "user", "content": "What's the weather in San Francisco?"}]
)
```

### Handle the Tool Use Loop

When Claude wants to call a tool, the response has `stop_reason: "tool_use"`. You must execute the tool and send back the result:

```python
import anthropic
import json

client = anthropic.Anthropic()
messages = [{"role": "user", "content": "What's the weather in San Francisco?"}]

# Tool use loop -- bounded to 10 iterations max
for iteration in range(10):
 response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 tools=tools,
 messages=messages
 )

 if response.stop_reason == "end_turn":
 # Claude is done -- print final text
 for block in response.content:
 if hasattr(block, "text"):
 print(block.text)
 break

 if response.stop_reason == "tool_use":
 # Add assistant response to messages
 messages.append({"role": "assistant", "content": response.content})

 # Execute each tool call
 tool_results = []
 for block in response.content:
 if block.type == "tool_use":
 # Your tool implementation here
 result = json.dumps({"temperature": "68F", "conditions": "foggy"})
 tool_results.append({
 "type": "tool_result",
 "tool_use_id": block.id,
 "content": result
 })

 messages.append({"role": "user", "content": tool_results})
```

### Use the SDK Tool Runner (Python)

The Python SDK has a built-in tool runner that handles the loop automatically:

```python
from anthropic import beta_tool

@beta_tool
def get_weather(location: str) -> str:
 """Get the weather for a given location."""
 return json.dumps({"location": location, "temperature": "68F"})

runner = client.beta.messages.tool_runner(
 max_tokens=1024,
 model="claude-sonnet-4-6",
 tools=[get_weather],
 messages=[{"role": "user", "content": "What's the weather in NYC?"}]
)
```

### Use the SDK Tool Runner (TypeScript with Zod)

```typescript
import Anthropic from "@anthropic-ai/sdk";
import { betaZodTool } from "@anthropic-ai/sdk/helpers/beta/zod";
import { z } from "zod";

const client = new Anthropic();

const weatherTool = betaZodTool({
 name: "get_weather",
 inputSchema: z.object({ location: z.string() }),
 description: "Get weather for a location",
 run: (input) => `Weather in ${input.location} is foggy, 68F`
});

const result = await client.beta.messages.toolRunner({
 model: "claude-sonnet-4-6",
 max_tokens: 1000,
 messages: [{ role: "user", content: "What's the weather in NYC?" }],
 tools: [weatherTool]
});
```

### Tool Choice Options

Control whether and how Claude uses tools:

```python
# auto (default): Claude decides whether to use a tool
response = client.messages.create(..., tool_choice={"type": "auto"})

# any: Claude MUST use a tool
response = client.messages.create(..., tool_choice={"type": "any"})

# specific tool: Claude MUST use this exact tool
response = client.messages.create(..., tool_choice={"type": "tool", "name": "get_weather"})

# none: Claude cannot use tools (even if tools are defined)
response = client.messages.create(..., tool_choice={"type": "none"})
```

### Enable Strict Mode

Add `strict: true` for guaranteed schema conformance on tool inputs:

```python
tools = [
 {
 "name": "get_weather",
 "description": "Get weather",
 "strict": True,
 "input_schema": {
 "type": "object",
 "properties": {
 "location": {"type": "string"}
 },
 "required": ["location"],
 "additionalProperties": False
 }
 }
]
```

Note: With `strict: true`, your schema must include `additionalProperties: false` and all properties must be `required`. Complex nested schemas may cause 500 errors.

## Prevention

1. **Always handle stop_reason "tool_use"**: Check every response. If `stop_reason` is `tool_use`, the conversation is incomplete until you send back a `tool_result`.
2. **Use the SDK tool runner**: It handles the tool call loop automatically and prevents missed tool calls.
3. **Validate schemas locally**: Test your `input_schema` against a JSON Schema validator before sending to the API.
4. **Bound your tool loop**: Always set a maximum iteration count to prevent infinite tool call chains.
5. **Match tool_use_id exactly**: The `tool_use_id` in your `tool_result` must match the `id` from the `tool_use` block.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-tool-use-not-working)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

- [Claude Extended Thinking Not Working](/claude-extended-thinking-not-working/) -- tool_choice restrictions when thinking is enabled.
- [Claude API Error 400 invalid_request_error Fix](/claude-api-error-400-invalidrequesterror-explained/) -- covers tool schema validation errors.
- [Claude Streaming API Guide](/claude-streaming-api-guide/) -- stream tool use responses for real-time feedback.
- [Claude API Tool Use Function Calling Deep Dive Guide](/claude-api-tool-use-function-calling-deep-dive-guide/) -- full parameter reference including tools and tool_choice.
- [Claude Python SDK Getting Started](/claude-python-sdk-getting-started-example/) -- basic SDK setup before implementing tools.



## Related Articles

- [Fix Claude Code Skill Tool Not Found Error — Quick Guide](/claude-code-skill-tool-not-found-error-solution/)
- [Claude Tool Use Hidden Token Costs Explained](/claude-tool-use-hidden-token-costs-explained/)
- [Tool Use Schema Validation Error — Fix (2026)](/claude-code-tool-use-schema-validation-error-fix-2026/)
- [Claude tool_use Response Parsing Error — Fix (2026)](/claude-tool-use-response-parsing-error-fix/)
