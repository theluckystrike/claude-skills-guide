---
title: "API 529 Overloaded Retry Backoff — Fix (2026)"
permalink: /claude-code-api-overloaded-529-backoff-fix-2026/
description: "Fix API 529 overloaded errors with exponential backoff. Implement retry logic with jitter to handle Anthropic capacity limits."
last_tested: "2026-04-22"
---

## The Error

```
Error 529: API is temporarily overloaded. Please retry after 30 seconds.
Retry-After: 30
```

This error means Anthropic's servers are at capacity. Unlike [Claude rate exceeded error fix](/claude-rate-exceeded-error-fix/) (rate limit), 529 indicates server-side load, not per-account limits. It typically occurs during peak usage hours.

## The Fix

1. Implement exponential backoff with jitter:

```bash
# Quick retry with backoff
for i in 1 2 3 4 5; do
  response=$(claude "hello" 2>&1)
  if echo "$response" | grep -q "529"; then
    sleep_time=$((2 ** i + RANDOM % 5))
    echo "Retry $i: waiting ${sleep_time}s..."
    sleep $sleep_time
  else
    echo "$response"
    break
  fi
done
```

2. In Python, use the SDK's built-in retry:

```python
import anthropic
client = anthropic.Anthropic(max_retries=5)
# SDK automatically retries 529 with exponential backoff
```

3. In Node.js:

```javascript
const client = new Anthropic({ maxRetries: 5 });
```

## Why This Happens

529 errors indicate that Anthropic's infrastructure is experiencing high demand. This is different from 429 rate limits which are per-account. During peak hours (US business hours, product launches), the API may shed load by returning 529. The `Retry-After` header tells you exactly how long to wait.

## If That Doesn't Work

- Respect the `Retry-After` header value exactly — do not retry sooner.
- Switch to a smaller model (Haiku) for non-critical tasks during peak hours.
- Use the Message Batches API for non-urgent work — batches are processed during off-peak times.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# API Resilience
- Always configure max_retries >= 3 for SDK clients.
- For batch workloads, use the Message Batches API instead of synchronous calls.
- Schedule heavy API usage outside US business hours (9 AM - 5 PM PT).
```


## Related

- [Claude internal server error fix](/claude-internal-server-error-fix/) — Fix Claude internal server error (500/overloaded)
- [Claude Code Request Timed Out 120000ms — Fix (2026)](/claude-code-api-timeout-ms-setting-fix-2026/)
- [API Version Deprecated Error — Fix (2026)](/claude-code-api-version-deprecation-error-fix-2026/)


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

- [The Retry Loop Tax](/retry-loop-tax-error-handling-token-cost/)
- [Claude Code Bullmq Delayed Retry](/claude-code-bullmq-delayed-retry-job-workflow-guide/)
- [How to Stop Claude Code Retry Loops](/stop-claude-code-retry-loops-token-waste/)
- [Claude API 529 Overloaded Error](/claude-api-529-overloaded-error-handling-fix/)

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
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
