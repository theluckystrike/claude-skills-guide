---
layout: default
title: "Fix: Claude API Error 400 (2026)"
description: "Fix Claude API 400 invalid_request_error. Covers malformed JSON, missing parameters, prefill errors, and request validation with Python and TypeScript."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-api-error-400-invalidrequesterror-explained/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-api, sdk-python, sdk-typescript, api-errors]
geo_optimized: true
last_tested: "2026-04-22"
---

# Claude API Error 400 invalid_request_error Fix

The 400 `invalid_request_error` is the most common Claude API error. It means something in your request format or content is wrong. This guide covers every known cause and the fix for each.

## The Error

```json
{
 "type": "error",
 "error": {
 "type": "invalid_request_error",
 "message": "There was an issue with the format or content of your request."
 },
 "request_id": "req_011CSHoEeqs5C35K2UUqR7Fy"
}
```

## Quick Fix

1. Check that `model`, `max_tokens`, and `messages` are all present in your request.
2. Verify messages alternate between `user` and `assistant` roles.
3. If using Claude Opus 4.6, remove any prefilled assistant messages (prefill is not supported).

## What Causes This

The 400 error covers all request validation failures. The API checks your request format before processing. Common triggers include:

- Missing required parameters (`model`, `max_tokens`, `messages`).
- Invalid message role sequence (messages must alternate user/assistant).
- Prefilling assistant messages on models that do not support it.
- Invalid tool definitions or malformed JSON schemas.
- Exceeding the 100,000 message limit per request.
- Using `tool_choice` values incompatible with extended thinking (only `auto` or `none` work).

## Full Solution

### Validate Required Parameters

Every Messages API request needs these three fields:

For more on this topic, see [Fix: Claude Can't Open This Chat Error](/claude-cant-open-this-chat-fix/).


```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
 model="claude-sonnet-4-6", # Required: valid model ID
 max_tokens=1024, # Required: positive integer
 messages=[ # Required: non-empty array
 {"role": "user", "content": "Hello, Claude"}
 ]
)
```

### Fix Message Role Alternation

Messages must alternate between `user` and `assistant`. Two consecutive `user` messages will trigger a 400 error:

```python
# WRONG: Two user messages in a row
messages = [
 {"role": "user", "content": "Hello"},
 {"role": "user", "content": "Are you there?"} # Error!
]

# CORRECT: Alternating roles
messages = [
 {"role": "user", "content": "Hello"},
 {"role": "assistant", "content": "Hi there!"},
 {"role": "user", "content": "Are you there?"}
]
```

### Fix Prefill Not Supported Error

Claude Opus 4.6 does not support prefilling assistant messages. If you send a request with a prefilled last assistant message, you get a 400 `invalid_request_error`:

```python
# WRONG on Opus 4.6: prefilled assistant message
messages = [
 {"role": "user", "content": "Write JSON"},
 {"role": "assistant", "content": "{"} # Error on Opus 4.6!
]

# CORRECT: Use output_config instead
message = client.messages.create(
 model="claude-opus-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Write JSON for a user profile"}],
 output_config={
 "format": {
 "type": "json_schema",
 "schema": {
 "type": "object",
 "properties": {
 "name": {"type": "string"},
 "email": {"type": "string"}
 },
 "required": ["name", "email"],
 "additionalProperties": False
 }
 }
 }
)
```

### Handle Extended Thinking + Tool Use

When using extended thinking with tools, only `tool_choice: auto` or `tool_choice: none` is supported:

```python
# WRONG: tool_choice "any" with thinking
message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 tool_choice={"type": "any"}, # Error!
 tools=[...],
 messages=[...]
)

# CORRECT: Use "auto" with thinking
message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 tool_choice={"type": "auto"}, # OK
 tools=[...],
 messages=[...]
)
```

### Catch the Error in Code

```python
import anthropic

client = anthropic.Anthropic()

try:
 message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello"}]
 )
except anthropic.BadRequestError as e:
 print(f"400 Error: {e.message}")
 print(f"Request ID: {e.response.headers.get('request-id')}")
```

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

try {
 await client.messages.create({
 model: "claude-sonnet-4-6",
 max_tokens: 1024,
 messages: [{ role: "user", content: "Hello" }]
 });
} catch (err) {
 if (err instanceof Anthropic.BadRequestError) {
 console.log(`400 Error: ${err.message}`);
 }
}
```

## Prevention

1. **Use the SDK**: The Python and TypeScript SDKs validate request structure before sending, catching many 400 errors client-side.
2. **Read the error message**: The API `message` field in the error response explains exactly which parameter is invalid.
3. **Include the request_id**: Every error response includes a `request_id`. Include it when contacting Anthropic support.
4. **Check model compatibility**: Not all parameters work with all models. Extended thinking requires `budget_tokens >= 1024` and `budget_tokens < max_tokens`.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-api-error-400-invalidrequesterror-explained)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Opus Prefill Not Supported Error Fix](/claude-opus-prefill-not-supported-error-fix/) -- detailed guide on the prefill restriction for Opus models.
- [Claude API Error 413 request_too_large Fix](/claude-api-error-413-requesttoolarge-explained/) -- handle oversized request payloads.
- [Claude Extended Thinking API Guide](/claude-extended-thinking-api-guide/) -- correct parameter usage for thinking mode.
- [Claude Tool Use Not Working](/claude-tool-use-not-working/) -- debug tool definition validation errors.
- [Claude API Tool Use Function Calling Deep Dive Guide](/claude-api-tool-use-function-calling-deep-dive-guide/) -- full parameter reference for the Messages endpoint.



## Related Articles

- [Fix Claude Code API Error 400 Bad Request](/claude-code-api-error-400/)
