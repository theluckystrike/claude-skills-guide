---
sitemap: false
layout: default
title: "Anthropic SDK Python Async Context (2026)"
description: "Fix Anthropic SDK async context manager TypeError. Use AsyncAnthropic client instead of sync Anthropic. Step-by-step solution."
permalink: /anthropic-sdk-python-async-context-manager-error-fix/
date: 2026-04-20
last_tested: "2026-04-21"
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


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Fix: Anthropic SDK Grammar Too Large](/anthropic-sdk-structured-output-grammar-too-large/)
- [Fix: Anthropic SDK MCP Tools Get Empty](/anthropic-sdk-mcp-empty-arguments-bug/)
- [Anthropic Rate Limit Tokens Per Minute — Fix (2026)](/claude-code-anthropic-rate-limit-tokens-per-minute-fix-2026/)
- [Fix: Anthropic API 500 Error](/anthropic-sdk-strict-true-500-error/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
