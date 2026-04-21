---
layout: default
title: "Fix Claude Opus Prefill Not Supported Error — Quick (2026)"
description: "Fix Claude Opus 4.6 prefill not supported error. Use structured outputs, system prompts, or output_config.format instead of assistant prefilling."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-opus-prefill-not-supported-error-fix/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-api, sdk-python, sdk-typescript, api-errors]
geo_optimized: true
last_tested: "2026-04-22"
---
# Claude Opus Prefill Not Supported Error Fix

Claude Opus 4.6 does not support prefilling assistant messages. If you send a request with a prefilled last assistant message, the API returns a 400 error. This guide shows the alternatives.

## The Error

```json
{
 "type": "error",
 "error": {
 "type": "invalid_request_error",
 "message": "Prefilling assistant messages is not supported for this model."
 }
}
```

## Quick Fix

1. Remove the prefilled assistant message from your request.
2. Use `output_config.format` with `json_schema` for structured JSON output.
3. Use system prompt instructions to control the output format.

## What Causes This

Prefilling is a technique where you add a partial assistant message at the end of the messages array to steer Claude's response format. For example, starting the response with `{` to force JSON output.

Claude Opus 4.6 (and Claude Mythos Preview) do not support this technique. The API rejects the request with a 400 `invalid_request_error`.

## Full Solution

### Remove the Prefilled Message

```python
import anthropic

client = anthropic.Anthropic()

# WRONG: Prefilled assistant message
messages = [
 {"role": "user", "content": "List 3 colors as JSON"},
 {"role": "assistant", "content": "{"} # Error on Opus 4.6!
]

# CORRECT: No prefill
messages = [
 {"role": "user", "content": "List 3 colors as JSON"}
]

response = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=1024,
 messages=messages
)
```

### Use Structured Outputs (Best Alternative)

The `output_config.format` parameter guarantees valid JSON output without prefilling:

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "List 3 colors with their hex codes"}],
 output_config={
 "format": {
 "type": "json_schema",
 "schema": {
 "type": "object",
 "properties": {
 "colors": {
 "type": "array",
 "items": {
 "type": "object",
 "properties": {
 "name": {"type": "string"},
 "hex": {"type": "string"}
 },
 "required": ["name", "hex"],
 "additionalProperties": False
 }
 }
 },
 "required": ["colors"],
 "additionalProperties": False
 }
 }
 }
)

import json
data = json.loads(response.content[0].text)
print(data)
```

### TypeScript with Structured Outputs

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const response = await client.messages.create({
 model: "claude-opus-4-6",
 max_tokens: 1024,
 messages: [{ role: "user", content: "List 3 colors with hex codes" }],
 output_config: {
 format: {
 type: "json_schema",
 schema: {
 type: "object",
 properties: {
 colors: {
 type: "array",
 items: {
 type: "object",
 properties: {
 name: { type: "string" },
 hex: { type: "string" }
 },
 required: ["name", "hex"],
 additionalProperties: false
 }
 }
 },
 required: ["colors"],
 additionalProperties: false
 }
 }
 }
});

const data = JSON.parse(
 response.content[0].type === "text" ? response.content[0].text : "{}"
);
console.log(data);
```

### Use System Prompts for Format Control

For simpler format requirements, system prompts work well without prefilling:

```python
response = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=1024,
 system="Always respond with valid JSON. No markdown, no explanations, just the JSON object.",
 messages=[{"role": "user", "content": "List 3 colors with hex codes"}]
)
```

### Model Compatibility

Prefilling works on these models but NOT on Opus 4.6:

| Model | Prefill Supported |
|-------|------------------|
| Claude Opus 4.6 | No |
| Claude Mythos Preview | No |
| Claude Sonnet 4.6 | Yes |
| Claude Sonnet 4.5 | Yes |
| Claude Haiku 4.5 | Yes |
| Claude Opus 4.5 | Yes |

If your code depends on prefilling and you need to use Opus 4.6, switch to structured outputs.

## Prevention

1. **Use structured outputs by default**: `output_config.format` with `json_schema` is more reliable than prefilling on ALL models and is the only option on Opus 4.6.
2. **Check model compatibility**: Before using prefilling, verify the model supports it.
3. **Write model-agnostic code**: Use structured outputs or system prompts so your code works across all Claude models without modification.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-opus-prefill-not-supported-error-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

- [Claude API Error 400 invalid_request_error Fix](/claude-api-error-400-invalidrequesterror-explained/) -- the error type returned when prefill is used on unsupported models.
- [Claude Extended Thinking API Guide](/claude-extended-thinking-api-guide/) -- Opus 4.6 capabilities beyond prefilling.
- [Claude API Tool Use Function Calling Deep Dive Guide](/claude-api-tool-use-function-calling-deep-dive-guide/) -- full parameter reference including output_config.
- [Claude Python SDK Getting Started](/claude-python-sdk-getting-started-example/) -- basic SDK setup.
- [Claude TypeScript SDK Installation Guide](/claude-typescript-sdk-installation-guide/) -- TypeScript SDK setup for structured outputs.


