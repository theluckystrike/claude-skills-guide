---
layout: default
title: "Claude Streaming API Guide (2026)"
description: "Implement Claude streaming with Server-Sent Events. Covers Python and TypeScript SDK helpers, event types, async streaming, and real-time output patterns."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-streaming-api-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-api, sdk-python, sdk-typescript, streaming]
geo_optimized: true
---

# Claude Streaming API Guide

Streaming lets you receive Claude's response incrementally via Server-Sent Events (SSE) instead of waiting for the full response. This is essential for real-time UX and for avoiding timeouts on long-running requests.

## Quick Fix

Stream a response in Python:

```python
import anthropic

client = anthropic.Anthropic()

with client.messages.stream(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello, Claude"}]
) as stream:
 for text in stream.text_stream:
 print(text, end="", flush=True)
```

## What You Need

- Anthropic Python or TypeScript SDK
- Set `stream=True` or use the SDK streaming helpers

## Full Solution

### Python: Stream Helper (Recommended)

The `stream()` context manager is the simplest way to stream:

```python
import anthropic

client = anthropic.Anthropic()

with client.messages.stream(
 model="claude-sonnet-4-6",
 max_tokens=4096,
 messages=[{"role": "user", "content": "Write a short story about a robot"}]
) as stream:
 for text in stream.text_stream:
 print(text, end="", flush=True)

# Get the complete message after streaming
message = stream.get_final_message()
print(f"\n\nTokens: {message.usage.input_tokens} in, {message.usage.output_tokens} out")
print(f"Stop reason: {message.stop_reason}")
```

### TypeScript: Stream Helper (Recommended)

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const stream = client.messages.stream({
 model: "claude-sonnet-4-6",
 max_tokens: 4096,
 messages: [{ role: "user", content: "Write a short story about a robot" }]
}).on("text", (text) => {
 process.stdout.write(text);
});

const message = await stream.finalMessage();
console.log(`\n\nTokens: ${message.usage.input_tokens} in, ${message.usage.output_tokens} out`);
```

### Python: Raw SSE Events

For full control over individual events:

```python
import anthropic

client = anthropic.Anthropic()

stream = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 stream=True,
 messages=[{"role": "user", "content": "Hello"}]
)

for event in stream:
 if event.type == "message_start":
 print(f"Model: {event.message.model}")
 elif event.type == "content_block_start":
 print(f"Content block type: {event.content_block.type}")
 elif event.type == "content_block_delta":
 if event.delta.type == "text_delta":
 print(event.delta.text, end="", flush=True)
 elif event.type == "message_delta":
 print(f"\nStop reason: {event.delta.stop_reason}")
 print(f"Output tokens: {event.usage.output_tokens}")
 elif event.type == "message_stop":
 print("[Stream complete]")
```

### TypeScript: Raw SSE Events

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const stream = await client.messages.create({
 model: "claude-sonnet-4-6",
 max_tokens: 1024,
 stream: true,
 messages: [{ role: "user", content: "Hello" }]
});

for await (const event of stream) {
 if (event.type === "content_block_delta" && event.delta.type === "text_delta") {
 process.stdout.write(event.delta.text);
 }
}
```

### SSE Event Types Reference

| Event | Description |
|-------|-------------|
| `message_start` | Stream opened, contains message metadata |
| `content_block_start` | New content block beginning |
| `content_block_delta` | Incremental content (text_delta, input_json_delta) |
| `content_block_stop` | Content block finished |
| `message_delta` | Message-level changes (stop_reason, usage) |
| `message_stop` | Stream complete |
| `ping` | Keep-alive signal |
| `error` | Error during streaming |

### Async Streaming (Python)

```python
from anthropic import AsyncAnthropic

client = AsyncAnthropic()

async def stream_response():
 async with client.messages.stream(
 model="claude-sonnet-4-6",
 max_tokens=4096,
 messages=[{"role": "user", "content": "Write a poem"}]
 ) as stream:
 async for text in stream.text_stream:
 print(text, end="", flush=True)

 message = stream.get_final_message()
 return message

import asyncio
result = asyncio.run(stream_response())
```

### Streaming with Extended Thinking

Extended thinking content streams alongside text content:

```python
import anthropic

client = anthropic.Anthropic()

with client.messages.stream(
 model="claude-sonnet-4-6",
 max_tokens=16000,
 thinking={"type": "enabled", "budget_tokens": 10000},
 messages=[{"role": "user", "content": "Solve: What is 127 * 389?"}]
) as stream:
 for event in stream:
 pass # Process events
 message = stream.get_final_message()

for block in message.content:
 if block.type == "thinking":
 print(f"Thinking: {block.thinking[:100]}...")
 elif block.type == "text":
 print(f"Answer: {block.text}")
```

### Streaming with Tool Use

When streaming tool use, you receive `input_json_delta` events as Claude builds the tool input:

```python
import anthropic

client = anthropic.Anthropic()

tools = [
 {
 "name": "get_weather",
 "description": "Get weather for a location",
 "input_schema": {
 "type": "object",
 "properties": {"location": {"type": "string"}},
 "required": ["location"]
 }
 }
]

stream = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 stream=True,
 tools=tools,
 messages=[{"role": "user", "content": "Weather in NYC?"}]
)

for event in stream:
 if event.type == "content_block_delta":
 if event.delta.type == "text_delta":
 print(event.delta.text, end="")
 elif event.delta.type == "input_json_delta":
 print(f"[Tool input: {event.delta.partial_json}]", end="")
```

### Avoid Timeout with get_final_message

For long requests where you do not need real-time output, use `get_final_message()` to avoid the SDK's 10-minute non-streaming timeout:

```python
import anthropic

client = anthropic.Anthropic()

with client.messages.stream(
 model="claude-opus-4-6",
 max_tokens=128000,
 messages=[{"role": "user", "content": "Write a comprehensive analysis"}]
) as stream:
 message = stream.get_final_message()

# message is a complete Message object
print(message.content[0].text)
```

### CLI Streaming

```bash
ant messages create --stream --format jsonl \
 --model claude-sonnet-4-6 \
 --max-tokens 1024 \
 --message '{role: user, content: "Hello"}'
```

## Prevention

1. **Use streaming for any request with max_tokens > 4096**: This prevents timeout issues and gives users immediate feedback.
2. **Always use the SDK helpers**: `stream()` / `text_stream` in Python and `.stream()` / `.on("text")` in TypeScript handle all event parsing for you.
3. **Handle stream errors**: Wrap streaming code in try/except because errors can arrive mid-stream after a 200 response.
4. **Use get_final_message() for batch-style workloads**: When you need the complete response without implementing event handling.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-streaming-api-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Streaming Not Working](/claude-streaming-not-working/) -- troubleshoot streaming failures and mid-stream errors.
- [Claude SDK Timeout Configuration](/claude-sdk-timeout-configuration-customization/) -- configure timeouts for streaming connections.
- [Claude Extended Thinking API Guide](/claude-extended-thinking-api-guide/) -- stream extended thinking output in real time.
- [Claude Tool Use Not Working](/claude-tool-use-not-working/) -- handle streamed tool use events.
- [Claude Python SDK Getting Started](/claude-python-sdk-getting-started-example/) -- basic SDK setup before implementing streaming.



## Related Articles

- [White Label Developer Copilot Built On — Developer Guide](/white-label-developer-copilot-built-on-claude-code-api/)
- [Claude Code Fetch API Wrapper Guide](/claude-code-fetch-api-wrapper-guide/)
- [Claude Code API Idempotency Implementation — Developer Guide](/claude-code-api-idempotency-implementation/)
- [Claude Code API Response Caching Guide](/claude-code-api-response-caching-guide/)
- [Claude Code API Rate Limiting Implementation Guide](/claude-code-api-rate-limiting-implementation/)
- [Reduce Claude Code API Costs by 50%](/claude-code-reduce-api-costs-guide/)
- [Claude Code WireMock API Mocking Guide](/claude-code-wiremock-api-mocking-guide/)
- [Building TypeScript APIs with Claude Code and Hono Framework](/claude-code-hono-framework-typescript-api-workflow/)
