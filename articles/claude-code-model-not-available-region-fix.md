---
title: "Claude Code Model Not Available"
description: "Fix Claude Code model not available in your region. Switch API endpoint or use an available model variant. Step-by-step solution."
permalink: /claude-code-model-not-available-region-fix/
last_tested: "2026-04-21"
render_with_liquid: false
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
