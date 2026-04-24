---
title: "Model Not Available on Your Plan — Fix"
permalink: /claude-code-model-not-available-your-plan-fix-2026/
description: "Fix 'model not available on your plan' error. Upgrade to the correct tier or switch to an available model in Claude Code."
last_tested: "2026-04-22"
render_with_liquid: false
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