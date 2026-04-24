---
title: "Claude API System Prompt Too Long Error (2026)"
description: "Fix Claude API system prompt too long error. Compress system instructions and split into cached blocks. Step-by-step solution."
permalink: /claude-api-system-prompt-too-long-error-fix/
last_tested: "2026-04-21"
---

## The Error

```
Error 400: Invalid Request
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "messages: system prompt is too long. System prompt tokens (98,542) + message tokens (4,231) exceeds the model maximum context window (200,000)."
  }
}
```

## The Fix

1. **Check your system prompt token count before sending**

```python
import anthropic

client = anthropic.Anthropic()

# Count tokens in your system prompt
count = client.count_tokens(
    model="claude-sonnet-4-20250514",
    system="YOUR SYSTEM PROMPT HERE",
    messages=[{"role": "user", "content": "test"}]
)
print(f"Total tokens: {count.input_tokens}")
```

2. **Split system prompt into cached static + dynamic parts**

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "Your large static instructions here...",
            "cache_control": {"type": "ephemeral"}
        },
        {
            "type": "text",
            "text": "Small dynamic context that changes per request"
        }
    ],
    messages=[{"role": "user", "content": "Hello"}]
)
```

3. **Verify the fix:**

```bash
python3 -c "
import anthropic
client = anthropic.Anthropic()
r = client.messages.create(
    model='claude-sonnet-4-20250514', max_tokens=10,
    system=[{'type':'text','text':'You are a helpful assistant.','cache_control':{'type':'ephemeral'}}],
    messages=[{'role':'user','content':'ping'}])
print(f'OK: {r.usage.input_tokens} input tokens, cache_read={r.usage.cache_read_input_tokens}')
"
# Expected: OK: [count] input tokens, cache_read=0 (first call) or cache_read=[count] (subsequent)
```

## Why This Happens

The system prompt competes with your messages for space in the model's context window. A 100K-token system prompt leaves only 100K tokens for conversation in Claude's 200K window. This error surfaces when the combined token count of system prompt plus messages exceeds the model's maximum. It commonly occurs when developers embed entire codebases, documentation dumps, or RAG retrieval results directly into the system prompt without tracking token counts.

## If That Doesn't Work

- **Alternative 1:** Move reference material from system prompt to the first user message — system prompt space is premium
- **Alternative 2:** Summarize your system prompt using a cheaper model first: ask Haiku to condense your instructions to under 10K tokens
- **Check:** Use `client.count_tokens()` to measure before each call and abort if over 80% of the context window

## Prevention

Add to your `CLAUDE.md`:
```markdown
Keep system prompts under 10K tokens. Move large reference material to user messages with cache_control. Always count tokens before API calls when system prompt is dynamic. Use prompt caching for static system instructions.
```

**Related articles:** [Context Window Management](/claude-code-context-window-management-guide/), [Claude API 400 Error](/claude-api-error-400-invalidrequesterror-explained/), [Errors Atlas](/errors-atlas/)

## See Also

- [CLAUDE.md Too Long? How to Split and Optimize for Context Window (2026)](/claude-md-too-long-split-and-optimize-fix/)
- [Claude API 413 Request Payload Too Large — Fix (2026)](/claude-api-413-request-payload-too-large-fix/)
- [System Prompt Exceeds Token Limit — Fix (2026)](/claude-code-system-prompt-too-many-tokens-fix-2026/)


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Related Guides

- [Claude Code for Buck2 Build System](/claude-code-for-buck2-build-system-workflow-guide/)
- [Claude Code Hooks System](/understanding-claude-code-hooks-system-complete-guide/)
- [Claude Code for Trading System](/claude-code-trading-system-backtesting-2026/)
- [Read Claude Code System Prompts Repo](/how-to-read-claude-code-system-prompts-2026/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error. This fix also applies if you see variations of this error: - Connection or process errors with similar root causes in the same subsystem - Timeout variants where the operation starts but does not complete - Permission variants where access is denied to the same resource - Configuration variants where the same setting is missing or malformed If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message."
      }
    }
  ]
}
</script>
