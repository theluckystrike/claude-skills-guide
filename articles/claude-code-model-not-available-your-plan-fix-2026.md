---
layout: default
title: "Model Not Available on Your Plan — Fix (2026)"
permalink: /claude-code-model-not-available-your-plan-fix-2026/
date: 2026-04-20
description: "Fix 'model not available on your plan' error. Upgrade to the correct tier or switch to an available model in Claude Code."
last_tested: "2026-04-22"
---

## The Error

```
Error: model 'claude-opus-4-20250514' is not available on your current plan. Available models: claude-sonnet-4-20250514, claude-haiku-3-20250310
```

This error appears when you request a model that your Anthropic plan does not include. Opus-tier models require a Scale or Enterprise plan.

## The Fix

1. Check which models your API key has access to:

```bash
curl -s https://api.anthropic.com/v1/models \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" | python3 -m json.tool
```

2. Switch Claude Code to a model you have access to:

```bash
claude config set model claude-sonnet-4-20250514
```

3. Or set it per-session:

```bash
claude --model claude-sonnet-4-20250514 "explain this codebase"
```

4. To use Opus, upgrade your plan at:

```bash
open https://console.anthropic.com/settings/billing
```

## Why This Happens

Anthropic gates model access by billing tier. Free and Build tier accounts only get access to Haiku and Sonnet models. Opus and extended-thinking variants require Scale tier or above. The API validates your plan before processing the request and returns this error immediately.

## If That Doesn't Work

- Check if your organization admin has restricted which models your API key can use:

```bash
curl -s https://api.anthropic.com/v1/organizations \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01"
```

- Verify you are not accidentally using a different API key from a lower-tier org:

```bash
echo $ANTHROPIC_API_KEY | head -c 20
```

- If you just upgraded, wait 5 minutes for plan changes to propagate, then retry.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Model Selection
- Default to claude-sonnet-4-20250514 unless Opus is specifically needed.
- Check plan tier before switching models in config.
- Pin model version in CLAUDE.md to avoid surprises after upgrades.
```


## Related

- [Claude rate exceeded error fix](/claude-rate-exceeded-error-fix/) — Fix Claude rate exceeded and rate limit errors

- [Claude AI rate exceeded error fix](/claude-ai-rate-exceeded-error-fix/) — Fix the Claude AI rate exceeded error message

- [Claude Sonnet 4.5 model guide](/claude-sonnet-4-5-20250929-model-guide/) — Sonnet 4.5 model capabilities and requirements
- [Claude Sonnet 4 model guide](/claude-sonnet-4-20250514-model-guide/) — Sonnet 4 model capabilities and requirements

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

- [How Do I Make A Claude Skill Available](/how-do-i-make-a-claude-skill-available-organization-wide/)
- [Claude Code Model Not Available](/claude-code-model-not-available-region-fix/)
- [How AI Agents Plan and Execute Tasks](/how-ai-agents-plan-and-execute-tasks-explained/)
- [Claude Code Free vs Pro Plan](/claude-code-free-tier-vs-pro-plan-feature-comparison-2026/)

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
