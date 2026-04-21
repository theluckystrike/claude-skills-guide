---
title: "API Key Region Mismatch eu-west-1 — Fix (2026)"
permalink: /claude-code-anthropic-api-key-region-mismatch-fix-2026/
description: "Set the correct ANTHROPIC_BASE_URL environment variable for your API key region. Fixes the region mismatch authentication error in Claude Code."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
API key not valid for region: eu-west-1 (key is for us-east-1)
```

## The Fix

```bash
# Set the API base URL to match your key's region
export ANTHROPIC_BASE_URL="https://api.anthropic.com"
# Or for EU keys:
# export ANTHROPIC_BASE_URL="https://api.eu-west-1.anthropic.com"

# Make it permanent
echo 'export ANTHROPIC_BASE_URL="https://api.anthropic.com"' >> ~/.zshrc
source ~/.zshrc
```

## Why This Works

Anthropic API keys are region-bound. A key issued for us-east-1 only authenticates against the US endpoint. If your client is configured to hit the EU endpoint (or vice versa), the server rejects the key with a region mismatch error. Aligning the base URL to the region where your key was created resolves the authentication failure.

## If That Doesn't Work

```bash
# Check which environment variable is overriding the URL
env | grep -i anthropic
# Remove conflicting settings
unset ANTHROPIC_API_BASE
unset CLAUDE_API_URL

# Verify the key works with the correct endpoint
curl -H "x-api-key: $ANTHROPIC_API_KEY" \
     -H "anthropic-version: 2023-06-01" \
     https://api.anthropic.com/v1/models
```

If you need to use a specific region for data residency, generate a new API key from the Anthropic Console with the correct region selected.

## Prevention

Add to your CLAUDE.md:
```
ANTHROPIC_BASE_URL must match the API key region. US keys use api.anthropic.com, EU keys use api.eu-west-1.anthropic.com. Never mix regions.
```
