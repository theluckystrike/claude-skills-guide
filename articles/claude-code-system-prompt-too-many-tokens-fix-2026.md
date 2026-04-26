---
layout: default
title: "System Prompt Exceeds Token Limit — Fix (2026)"
permalink: /claude-code-system-prompt-too-many-tokens-fix-2026/
date: 2026-04-20
description: "System Prompt Exceeds Token Limit — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
---

## The Error

```
Error 400: system prompt exceeds maximum token count. Got 32847 tokens, maximum is 16384 for this model.
```

This error fires when your system prompt is too large for the selected model's system prompt allocation. Each model has a different maximum.

## The Fix

1. Count your current system prompt tokens:

```bash
python3 -c "
text = open('system-prompt.txt').read()
# Rough estimate: 1 token per 4 characters
print(f'Estimated tokens: {len(text) // 4}')
print(f'Character count: {len(text)}')
"
```

2. Trim the system prompt to essentials. Move reference data to the first user message:

```python
# Before (too large):
system = huge_context + instructions + examples

# After (fits):
system = instructions_only  # Keep under 8K tokens
first_message = f"Reference context:\n{huge_context}\n\nNow: {user_query}"
```

3. Use prompt caching to reduce costs on the large context:

```python
import anthropic
client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    system=[{"type": "text", "text": short_instructions, "cache_control": {"type": "ephemeral"}}],
    messages=[{"role": "user", "content": context + query}]
)
```

## Why This Happens

The system prompt has a separate token budget from the conversation context. Stuffing entire codebases, documentation, or lengthy instructions into the system prompt exceeds this budget. The limit exists because system prompts are processed differently from user messages in the model's attention mechanism.

## If That Doesn't Work

- Split your system prompt into a short preamble (system) and detailed context (first message).
- Use CLAUDE.md for persistent instructions instead of passing them programmatically.
- Switch to a model with a larger system prompt allowance.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# System Prompt Size
- Keep system prompts under 8,000 tokens (roughly 32,000 characters).
- Put reference data in user messages, not system prompt.
- Use prompt caching for repeated large contexts.
```

## See Also

- [Why Your Claude Prompts Use Too Many Tokens](/why-claude-prompts-use-too-many-tokens/)
- [Claude API System Prompt Too Long Error — Fix (2026)](/claude-api-system-prompt-too-long-error-fix/)
- [File Watcher EMFILE Too Many Open Files Fix](/claude-code-file-watcher-emfile-too-many-open-files-fix-2026/)
- [Claude Code System Prompts Explained (2026)](/claude-code-system-prompts-guide-2026/)
- [Claude Code subagent spawning too many agents — cost control](/claude-code-subagent-spawning-too-many-cost-control/)


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

- [Tool Result Exceeds 100KB Truncating — Fix (2026)](/claude-code-tool-result-too-large-fix-2026/)
- [Knowledge Base Exceeds 512KB Maximum — Fix (2026)](/claude-code-knowledge-base-too-large-fix-2026/)
- [Large File Committed Exceeds GitHub](/claude-code-large-file-committed-github-limit-fix-2026/)
- [File Exceeds 10MB Limit in Claude Code — Fix (2026)](/claude-code-max-file-size-exceeded-fix-2026/)

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
