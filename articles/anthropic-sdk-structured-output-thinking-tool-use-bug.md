---
layout: default
title: "Fix: Structured Output + Thinking + Tool Use Bugs"
description: "Fix bugs combining structured outputs, thinking, and tool use in the Anthropic API. Missing tool_use blocks and invalid JSON."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /anthropic-sdk-structured-output-thinking-tool-use-bug/
reviewed: true
categories: [troubleshooting]
tags: [anthropic-sdk, python, error, troubleshooting, api, structured-output, streaming]
geo_optimized: true
---

# Fix: Structured Output + Thinking + Tool Use Bugs

## The Error

When using structured outputs (`output_config` with `json_schema`) combined with thinking and tool use, you hit one or both of these bugs:

**Bug 1: Model returns only thinking + empty text, no tool_use blocks**

```json
{
 "content": [
 {"type": "thinking", "thinking": "I need to call tool_1 and tool_2 in parallel..."},
 {"type": "text", "text": ""}
 ],
 "stop_reason": "end_turn"
}
```

The model's thinking correctly identifies the tools to call, but no `tool_use` blocks are emitted. `stop_reason` is `"end_turn"` instead of `"tool_use"`.

**Bug 2: Final structured output contains invalid JSON**

```json
{
 "content": [
 {
 "type": "text",
 "text": "{\"my_json\": \"is_broken \n\n\n\n\n\n\n {\"my_json\": \"is_not_broken\"}"
 }
 ]
}
```

Partial/malformed JSON followed by blank lines, then valid JSON — all in a single text block.

## Quick Fix

Disable structured outputs when using thinking + tool use. Validate output manually:

```python
from pydantic import BaseModel

class Output(BaseModel):
 param1: str
 param2: str

# Remove output_config, keep thinking and tools
response = await client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=10000,
 messages=[{"role": "user", "content": query}],
 tools=tools,
 thinking={"type": "adaptive"},
 # Do NOT use output_config with json_schema here
)

# Parse and validate manually on the final turn
if response.stop_reason == "end_turn":
 text_block = next(b for b in response.content if b.type == "text")
 result = Output.model_validate_json(text_block.text)
```

## What's Happening

The combination of three features — structured outputs, extended thinking, and tool use — creates an unstable interaction in the API's response generation:

### Bug 1: Missing tool_use Blocks

When the model has structured output format active and needs to call a tool, there is a conflict in the output constraints:

1. The structured output grammar constrains the text block to be valid JSON matching your schema
2. Tool use requires generating `tool_use` blocks (which are not JSON text blocks)
3. Extended thinking adds a preliminary reasoning step

The model's thinking block correctly determines that tools should be called. But when it transitions to generating content, the structured output grammar captures the output stream and constrains it to produce JSON. The tool_use block generation never fires, and the model ends the turn with an empty text block. See also [Fix: Anthropic SDK Grammar Too Large Error](/anthropic-sdk-structured-output-grammar-too-large/) for more on this topic.

### Bug 2: Invalid JSON in Structured Output

In the final turn (after tool results are provided), the model sometimes generates:

- **Case A**: Mixed text and JSON that cannot be parsed
- **Case B**: Partial JSON, followed by many blank lines, followed by valid JSON — all in one text block

This appears to be a token generation issue where the model starts producing JSON, hits an internal constraint, resets, and generates the correct JSON appended to the failed attempt. For a deeper dive, see [Fix Claude API Error 500 — Internal Server Error](/claude-api-error-500-fix/).

### Feature Interaction Matrix

| Thinking | Tools | Structured Output | Status |
|----------|-------|-------------------|--------|
| Off | Off | On | Works |
| Off | On | Off | Works |
| On | Off | On | Works (usually) |
| On | On | Off | Works |
| **On** | **On** | **On** | **Broken** |

## Step-by-Step Solution

### Option 1: Two-Phase Approach (Recommended)

Use thinking + tools in the first phase, then structured output in the final extraction:

```python
from anthropic import AsyncAnthropic
from pydantic import BaseModel

client = AsyncAnthropic()

class FinalOutput(BaseModel):
 summary: str
 confidence: float
 sources: list[str]

# Phase 1: Think and use tools (no structured output)
messages = [{"role": "user", "content": query}]

for i in range(10): # Bounded tool loop
 response = await client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=10000,
 system="Use the provided tools to gather information. When done, provide your final answer.",
 messages=messages,
 tools=tools,
 thinking={"type": "enabled", "budget_tokens": 5000},
 # NO output_config here
 )

 if response.stop_reason != "tool_use":
 break

 # Append assistant message and tool results
 messages.append({"role": "assistant", "content": response.content})
 tool_results = execute_tools(response)
 messages.append({"role": "user", "content": tool_results})

# Phase 2: Extract structured output (no tools, no thinking)
extraction_messages = messages + [{
 "role": "user",
 "content": "Based on the above conversation, provide your final structured answer."
}]

structured_response = await client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=5000,
 messages=extraction_messages,
 output_config={
 "format": {
 "type": "json_schema",
 "schema": FinalOutput.model_json_schema()
 }
 },
 # NO tools, NO thinking
)

result = FinalOutput.model_validate_json(structured_response.content[0].text)
```

### Option 2: Structured Output Without Thinking

If you need tools + structured output but can sacrifice thinking:

```python
response = await client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=10000,
 messages=messages,
 tools=tools,
 output_config={
 "format": {
 "type": "json_schema",
 "schema": schema
 }
 },
 # NO thinking parameter
)
```

Note: this can sometimes produce empty content. Add retry logic:

```python
for attempt in range(3):
 response = await client.messages.create(...)
 if response.content and any(
 b.type == "text" and b.text.strip() for b in response.content
 ):
 break
 await asyncio.sleep(1)
```

### Option 3: Thinking + Tools, Manual JSON Parsing

Use thinking and tools freely, then extract JSON from the final response with robust parsing:

```python
import json
import re

def extract_json(text: str) -> dict:
 """Extract the last valid JSON object from garbled text."""
 # Try the full text first
 try:
 return json.loads(text.strip())
 except json.JSONDecodeError:
 pass

 # Find all JSON-like objects in the text
 candidates = []
 brace_depth = 0
 start = None

 for i, char in enumerate(text):
 if char == '{':
 if brace_depth == 0:
 start = i
 brace_depth += 1
 elif char == '}':
 brace_depth -= 1
 if brace_depth == 0 and start is not None:
 candidate = text[start:i + 1]
 try:
 parsed = json.loads(candidate)
 candidates.append(parsed)
 except json.JSONDecodeError:
 pass
 start = None

 if not candidates:
 raise ValueError(f"No valid JSON found in response: {text[:200]}...")

 # Return the last valid JSON object (most likely the complete one)
 return candidates[-1]
```

### Option 4: Use messages.parse with Retry

```python
from anthropic import AsyncAnthropic

client = AsyncAnthropic()

async def parse_with_retry(params, max_retries=3):
 for attempt in range(max_retries):
 try:
 response = await client.messages.parse(**params)
 if response.parsed_output is not None:
 return response.parsed_output

 # Empty parsed output — retry
 if attempt < max_retries - 1:
 continue
 except Exception as e:
 if attempt < max_retries - 1:
 continue
 raise

 raise RuntimeError("Failed to get valid structured output after retries")
```

## Prevention

- **Do not combine all three features** (thinking + tools + structured output) in a single API call until the interaction is stabilized
- **Use a two-phase approach** — let the model think and use tools first, then extract structured output
- **Always validate JSON output** even when using structured outputs, since the model can produce malformed responses
- **Implement retry logic** for empty or invalid responses
- **Keep schemas simple** when combining with other features

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=anthropic-sdk-structured-output-thinking-tool-use-bug)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Issues

- [Fix: "Compiled grammar is too large" Error](/anthropic-sdk-structured-output-grammar-too-large)
- [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Fix: Claude API Error 400 Invalid Request](/claude-api-error-400-invalidrequesterror-explained/)

## Tools That Help

For developers building multi-step AI agent pipelines, a dev tool extension can help debug the intermediate tool calls and responses, making it easier to identify where structured output generation breaks down.


