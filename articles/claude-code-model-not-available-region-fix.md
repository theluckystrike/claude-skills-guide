---
sitemap: false
layout: default
title: "Claude Code Model Not Available (2026)"
description: "Fix Claude Code model not available in your region. Switch API endpoint or use an available model variant. Step-by-step solution."
permalink: /claude-code-model-not-available-region-fix/
date: 2026-04-20
last_tested: "2026-04-21"
---

## The Error

```
Error 403: Forbidden
{
  "type": "error",
  "error": {
    "type": "forbidden",
    "message": "The model 'claude-opus-4-20250514' is not available in your region. Your API key is associated with a region that does not have access to this model."
  }
}

# Or:
Error: Model not found. The model `claude-opus-4-20250514` does not exist or
  you do not have access to it.
```

## The Fix

1. **Check which models are available for your account**

```bash
curl -s https://api.anthropic.com/v1/models \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for model in data.get('data', []):
    print(f\"  {model['id']}\")
"
```

2. **Switch to an available model**

```bash
# In your Claude Code configuration or environment:
export CLAUDE_MODEL="claude-sonnet-4-20250514"

# Or specify per-request in API calls:
claude -p "Your prompt" --model claude-sonnet-4-20250514
```

3. **Verify the fix:**

```bash
claude -p "What model are you?" --model claude-sonnet-4-20250514 --trust --yes
# Expected: Response confirming the model is accessible
```

## Why This Happens

Anthropic enforces regional availability for certain models based on regulatory requirements, data residency rules, and capacity allocation. Your API key is tied to a region (determined at account creation or by your organization settings), and not all models are available in all regions. Opus-tier models may have more restricted availability than Sonnet or Haiku. The region is embedded in your API key — you cannot change it without creating a new key in a different region.

## If That Doesn't Work

- **Alternative 1:** Contact Anthropic support to request model access for your region or to migrate your account
- **Alternative 2:** Use Amazon Bedrock or Google Cloud Vertex AI as alternative providers — they have their own regional availability
- **Check:** Run `curl -s https://api.anthropic.com/v1/models -H "x-api-key: $ANTHROPIC_API_KEY" -H "anthropic-version: 2023-06-01"` to see your complete model list

## Prevention

Add to your `CLAUDE.md`:
```markdown
Check model availability before switching models in production. Default to claude-sonnet-4-20250514 which has the broadest regional availability. For Opus workloads, verify access with a test call before building pipelines around it.
```

**Related articles:** [API Key Region Mismatch Fix](/claude-code-anthropic-api-key-region-mismatch-fix-2026/), [Claude API 401 Auth Error](/claude-api-error-401-authenticationerror-explained/), [Errors Atlas](/errors-atlas/)

## See Also

- [Model Not Available on Your Plan — Fix (2026)](/claude-code-model-not-available-your-plan-fix-2026/)


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




**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [How Do I Make A Claude Skill Available](/how-do-i-make-a-claude-skill-available-organization-wide/)
- [Claude Code Router: Model Routing Guide](/claude-code-router-guide/)
- [Claude Code Model Compression](/claude-code-model-compression-quantization/)
- [Claude Code for Climate Model Data](/claude-code-climate-model-netcdf-processing-2026/)

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
