---
title: "Anthropic SDK Python Async Context"
description: "Fix Anthropic SDK async context manager TypeError. Use AsyncAnthropic client instead of sync Anthropic. Step-by-step solution."
permalink: /anthropic-sdk-python-async-context-manager-error-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
TypeError: object Anthropic can't be used in 'await' expression

# Or when using streaming:
TypeError: 'MessageStream' object is not an async iterator
  async for event in stream:
                     ^^^^^^
```

## The Fix

1. **Use AsyncAnthropic instead of the synchronous client**

```python
# WRONG - sync client in async context
import anthropic
import asyncio

async def main():
    client = anthropic.Anthropic()  # This is sync-only
    response = await client.messages.create(...)  # Fails

# CORRECT - async client
async def main():
    client = anthropic.AsyncAnthropic()  # Async client
    response = await client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1024,
        messages=[{"role": "user", "content": "Hello"}]
    )
    print(response.content[0].text)

asyncio.run(main())
```

2. **For async streaming, use the async context manager**

```python
async def stream_response():
    client = anthropic.AsyncAnthropic()
    async with client.messages.stream(
        model="claude-sonnet-4-20250514",
        max_tokens=1024,
        messages=[{"role": "user", "content": "Hello"}]
    ) as stream:
        async for text in stream.text_stream:
            print(text, end="", flush=True)
```

3. **Verify the fix:**

```bash
python3 -c "
import anthropic, asyncio
async def test():
    client = anthropic.AsyncAnthropic()
    r = await client.messages.create(model='claude-sonnet-4-20250514', max_tokens=10, messages=[{'role':'user','content':'ping'}])
    print(f'OK: {r.content[0].text}')
asyncio.run(test())
"
# Expected: OK: [response text]
```

## Why This Happens

The Anthropic Python SDK provides two separate client classes: `Anthropic` (synchronous, uses `httpx.Client`) and `AsyncAnthropic` (asynchronous, uses `httpx.AsyncClient`). The sync client's methods return values directly while the async client's methods return coroutines. Mixing them — using `await` with sync methods or calling async methods without `await` — produces these TypeErrors because Python's async protocol requires matching interfaces.

## If That Doesn't Work

- **Alternative 1:** If you must use the sync client in an async context, wrap it with `asyncio.to_thread()`: `await asyncio.to_thread(client.messages.create, ...)`
- **Alternative 2:** Upgrade the SDK — `pip install --upgrade anthropic` — older versions had bugs in the async streaming interface
- **Check:** Run `python3 -c "import anthropic; print(anthropic.__version__)"` — async streaming requires version 0.18.0+

## Prevention

Add to your `CLAUDE.md`:
```markdown
Use AsyncAnthropic for all async/await code. Never mix sync Anthropic client with await. Pin anthropic SDK to latest stable version in requirements.txt.
```

**Related articles:** [Claude API Error Handling](/claude-code-api-error-handling-standards/), [Claude API Timeout Guide](/claude-code-timeout-fix/), [Errors Atlas](/errors-atlas/)

## See Also

- [Anthropic SDK TypeScript Tool Results Type Error — Fix (2026)](/anthropic-sdk-typescript-type-mismatch-tool-results-fix/)
