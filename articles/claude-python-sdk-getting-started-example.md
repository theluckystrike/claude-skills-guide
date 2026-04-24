---
layout: default
title: "Claude Python SDK Getting Started"
description: "Build your first Claude Python app with messages, streaming, error handling, and token counting. Complete working examples with the Anthropic SDK."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-python-sdk-getting-started-example/
reviewed: true
score: 7
categories: [guides]
tags: [claude-api, sdk-python, getting-started, tutorial]
geo_optimized: true
---

# Claude Python SDK Getting Started Example

Build your first Claude-powered application in Python. This guide walks through messages, streaming, token counting, and error handling with complete working code.

## Quick Fix

Minimal working example in 5 lines:

```python
import anthropic

client = anthropic.Anthropic()
message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello, Claude"}]
)
print(message.content[0].text)
```

## What You Need

- Python 3.9+
- `pip install anthropic`
- `ANTHROPIC_API_KEY` environment variable set

## Full Solution

### Step 1: Simple Message

```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "What is the capital of France?"}]
)

# Access the response text
print(message.content[0].text)

# Check usage
print(f"Input tokens: {message.usage.input_tokens}")
print(f"Output tokens: {message.usage.output_tokens}")

# Check stop reason
print(f"Stop reason: {message.stop_reason}")
```

### Step 2: Multi-Turn Conversation

```python
import anthropic

client = anthropic.Anthropic()

messages = [
 {"role": "user", "content": "What is the capital of France?"}
]

# First turn
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=messages
)

# Add assistant response to conversation
messages.append({"role": "assistant", "content": response.content[0].text})

# Add follow-up question
messages.append({"role": "user", "content": "What is its population?"})

# Second turn
response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=messages
)

print(response.content[0].text)
```

### Step 3: System Prompt

```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 system="You are a helpful math tutor. Explain concepts simply and use examples.",
 messages=[{"role": "user", "content": "Explain the Pythagorean theorem"}]
)

print(message.content[0].text)
```

### Step 4: Streaming

Stream the response for real-time output:

```python
import anthropic

client = anthropic.Anthropic()

with client.messages.stream(
 model="claude-sonnet-4-6",
 max_tokens=4096,
 messages=[{"role": "user", "content": "Write a haiku about programming"}]
) as stream:
 for text in stream.text_stream:
 print(text, end="", flush=True)

print() # Newline after stream completes

# Get the complete message object
message = stream.get_final_message()
print(f"Total output tokens: {message.usage.output_tokens}")
```

### Step 5: Token Counting

Count tokens before sending a request to estimate costs:

```python
import anthropic

client = anthropic.Anthropic()

count = client.messages.count_tokens(
 model="claude-sonnet-4-6",
 messages=[{"role": "user", "content": "Hello, how are you?"}]
)

print(f"Input tokens: {count.input_tokens}")
```

### Step 6: Error Handling

Handle all possible API errors:

```python
import anthropic

client = anthropic.Anthropic()

try:
 message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello"}]
 )
 print(message.content[0].text)
except anthropic.APIConnectionError:
 print("Could not connect to the API. Check your internet connection.")
except anthropic.AuthenticationError:
 print("Invalid API key. Check your ANTHROPIC_API_KEY.")
except anthropic.RateLimitError:
 print("Rate limited. Wait and retry.")
except anthropic.BadRequestError as e:
 print(f"Bad request: {e.message}")
except anthropic.APIStatusError as e:
 print(f"API error {e.status_code}: {e.message}")
```

### Step 7: Adjust Temperature

```python
import anthropic

client = anthropic.Anthropic()

# Low temperature for factual/analytical tasks
factual = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 temperature=0.0,
 messages=[{"role": "user", "content": "What is 2 + 2?"}]
)

# Higher temperature for creative tasks
creative = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 temperature=1.0,
 messages=[{"role": "user", "content": "Write a creative story opening"}]
)
```

### Step 8: Async Usage

```python
from anthropic import AsyncAnthropic
import asyncio

client = AsyncAnthropic()

async def main():
 message = await client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello"}]
 )
 print(message.content[0].text)

asyncio.run(main())
```

### Complete Example: Chat Application

```python
import anthropic

client = anthropic.Anthropic()
messages = []

SYSTEM_PROMPT = "You are a helpful assistant. Be concise but thorough."
MAX_TURNS = 20

print("Chat with Claude (type 'quit' to exit)")
print("-" * 40)

for turn in range(MAX_TURNS):
 user_input = input("\nYou: ")
 if user_input.lower() == "quit":
 break

 messages.append({"role": "user", "content": user_input})

 try:
 print("\nClaude: ", end="", flush=True)
 with client.messages.stream(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 system=SYSTEM_PROMPT,
 messages=messages
 ) as stream:
 full_response = ""
 for text in stream.text_stream:
 print(text, end="", flush=True)
 full_response += text

 messages.append({"role": "assistant", "content": full_response})
 print()

 except anthropic.APIError as e:
 print(f"\nError: {e.message}")
 messages.pop() # Remove the failed user message
```

## Prevention

1. **Start with Sonnet 4.6**: It is the best balance of speed and intelligence for development. Switch to Opus 4.6 for complex production tasks.
2. **Always handle errors**: Wrap every API call in try/except with specific error types.
3. **Use streaming for UX**: Streaming responses feel faster to users even when total latency is similar.
4. **Monitor token usage**: Check `message.usage` in every response to track costs.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-python-sdk-getting-started-example)**

$99 once. Free forever. 47/500 founding spots left.

</div>

## Related Guides

- [Claude Python SDK Installation Guide](/claude-python-sdk-installation-guide/) -- installation and environment setup.
- [Claude Streaming API Guide](/claude-streaming-api-guide/) -- advanced streaming patterns and event handling.
- [Claude Tool Use Not Working](/claude-tool-use-not-working/) -- add function calling to your application.
- [Claude Prompt Caching API Guide](/claude-prompt-caching-api-guide/) -- reduce costs for multi-turn conversations.
- [How to Set ANTHROPIC_API_KEY for Claude](/how-to-set-anthropicapikey-for-claude/) -- API key configuration across platforms.



## Related Articles

- [Claude Code Pulumi Python Infrastructure Guide](/claude-code-pulumi-python-infrastructure-guide/)
- [Claude Code Python SDK Package Guide](/claude-code-python-sdk-package-guide/)
- [How to Use Python Developers](/claude-code-for-chinese-python-developers-guide-2026/)
- [Claude Code for Hindi Speaking Developers - Getting Started](/claude-code-for-hindi-speaking-developers-getting-started/)
