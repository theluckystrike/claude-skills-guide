---
layout: default
title: "JSON Parse Error on Malformed Response (2026)"
permalink: /claude-code-json-parse-error-malformed-response-fix-2026/
date: 2026-04-20
description: "Fix JSON parse error on malformed API response in Claude Code. Retry the request or clear corrupted cache to resolve SyntaxError unexpected token."
last_tested: "2026-04-22"
---

## The Error

```
SyntaxError: Unexpected token '<' at position 0 in JSON
  at JSON.parse (<anonymous>)
  at parseAPIResponse (api-client.js:234)
  Expected valid JSON response from API, got HTML error page instead
```

This appears when Claude Code receives a non-JSON response from the Anthropic API, typically an HTML error page or a truncated response, and fails to parse it.

## The Fix

```bash
claude "Retry the last operation"
```

1. Simply retry the request. Malformed responses are usually transient and caused by network interruptions or API gateway timeouts.
2. If the error persists, check your network connection and the Anthropic status page.
3. Clear any cached responses that may be corrupted.

## Why This Happens

The Anthropic API returns JSON responses, but when the API is overloaded, a CDN or load balancer may return an HTML error page (502/503) instead. Claude Code's JSON parser expects valid JSON and crashes when it encounters HTML. This can also happen when a network proxy injects its own error pages, or when a streaming response is cut off mid-transmission, producing invalid JSON.

## If That Doesn't Work

Check the Anthropic API status page:

```bash
curl -s https://status.anthropic.com/api/v2/status.json | jq '.status'
```

Test the API connection directly:

```bash
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "content-type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}' | jq .
```

If behind a corporate proxy, check if it is intercepting API responses:

```bash
curl -v https://api.anthropic.com 2>&1 | grep "< HTTP"
```

## Prevention

```markdown
# CLAUDE.md rule
If you see a JSON parse error, retry once before investigating. Report persistent parse errors — they indicate a network or proxy issue, not a code problem.
```

## See Also

- [Config File JSON Parse Error — Fix (2026)](/claude-code-config-json-corrupted-parse-error-fix-2026/)
- [Response JSON Parse Failure — Fix (2026)](/claude-code-response-json-parse-failure-fix-2026/)


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

- [Fix Malformed YAML Frontmatter](/fix-malformed-yaml-frontmatter-skill-md/)
- [How to Use For JSON Mode LLM](/claude-code-for-json-mode-llm-workflow-guide/)
- [Claude XML Tags vs JSON for Token](/claude-xml-tags-vs-json-token-efficiency/)
- [JSON Formatter Chrome Extension](/json-formatter-chrome-extension-best/)

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
