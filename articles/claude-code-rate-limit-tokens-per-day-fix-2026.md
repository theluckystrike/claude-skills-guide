---
layout: default
title: "Daily Token Limit Exceeded Error — Fix (2026)"
permalink: /claude-code-rate-limit-tokens-per-day-fix-2026/
date: 2026-04-20
description: "Fix 'daily token limit exceeded' error. Monitor usage, reduce token consumption, or upgrade plan for higher daily limits."
last_tested: "2026-04-22"
---

## The Error

```
Error 429: You have exceeded your daily token limit of 1,000,000 input tokens. Limit resets at 00:00 UTC. Current usage: 1,000,247 tokens.
```

This error occurs when you hit your plan's daily token ceiling. Unlike per-minute rate limits, this is a hard daily cap that only resets at midnight UTC.

## The Fix

1. Check your current usage and limits:

```bash
curl -s https://api.anthropic.com/v1/usage \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" | python3 -m json.tool
```

2. Reduce token consumption immediately:

```bash
# Use compact mode in Claude Code to reduce context
claude /compact

# Switch to a smaller model for routine tasks
claude config set model claude-haiku-3-20250310
```

3. Check when your limit resets:

```bash
python3 -c "
from datetime import datetime, timezone
now = datetime.now(timezone.utc)
reset = now.replace(hour=0, minute=0, second=0)
if reset < now:
    from datetime import timedelta
    reset += timedelta(days=1)
hours_left = (reset - now).seconds // 3600
print(f'Resets in {hours_left} hours at 00:00 UTC')
"
```

## Why This Happens

Anthropic enforces daily token limits per organization to prevent runaway costs and ensure fair usage. Build tier accounts have lower daily limits than Scale tier. Agentic workflows that loop many times can burn through daily limits quickly, especially when sending large codebases as context.

## If That Doesn't Work

- Request a limit increase through the Anthropic Console.
- Split work across multiple API keys if you have multiple organizations.
- Use prompt caching to reduce input token consumption by up to 90%.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Token Budget
- Monitor daily token usage. Stay under 80% of daily limit.
- Use /compact regularly to reduce conversation context size.
- Enable prompt caching for repeated large contexts.
- Use Haiku for simple tasks, reserve Sonnet/Opus for complex work.
```

## See Also

- [Anthropic Rate Limit Tokens Per Minute — Fix (2026)](/claude-code-anthropic-rate-limit-tokens-per-minute-fix-2026/)


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

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Fix Skill Exceeded Maximum Output](/claude-code-skill-exceeded-maximum-output-length-error-fix/)
- [Context Window Exceeded — Fix (2026)](/claude-code-context-window-exceeded-mid-conversation-fix-2026/)
- [Fix Claude Rate Exceeded Error (2026)](/claude-rate-exceeded-error-fix/)
- [Fix Claude AI Rate Exceeded Error](/claude-ai-rate-exceeded-error-fix/)

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
