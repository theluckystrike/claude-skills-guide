---
layout: default
title: "Fix Claude API Error 401 — Authentication Failed"
description: "Resolve Claude API 401 unauthorized errors. Covers API key validation, environment variable setup, and common authentication mistakes."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-api-error-401-fix/
reviewed: true
categories: [API Errors & HTTP Status Codes]
tags: ["claude-api", "error-401", "authentication", "api-key"]
geo_optimized: true
---

# Fix Claude API Error 401 — Authentication Failed

> **TL;DR:** A 401 error means your API key is missing, invalid, or expired. Verify your key, check environment variables, and ensure the correct header format.

## The Problem

When calling the Claude API, you receive an HTTP 401 response:

```json
{
 "type": "error",
 "error": {
 "type": "authentication_error",
 "message": "Invalid API key"
 }
}
```

This blocks all API requests until the authentication issue is resolved.

## Why This Happens

The Anthropic API requires a valid API key in the `x-api-key` header. A 401 occurs when:

- The API key is missing from the request headers
- The key has been revoked or rotated in the Anthropic Console
- Environment variables (`ANTHROPIC_API_KEY`) are not set or contain whitespace/newlines
- You are using the wrong header name (e.g., `Authorization: Bearer` instead of `x-api-key`)

## The Fix

### Step 1 — Verify Your API Key Exists and Is Valid

```bash
# Check if the environment variable is set
echo "Key length: ${#ANTHROPIC_API_KEY}"
echo "Key prefix: ${ANTHROPIC_API_KEY:0:10}..."

# Key should start with "sk-ant-" and be ~100+ characters
```

If the output shows length 0 or an unexpected prefix, your key is not set correctly.

### Step 2 — Set the API Key Correctly

**macOS / Linux (bash/zsh):**

```bash
# Add to your shell profile (~/.zshrc or ~/.bashrc)
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"

# Reload the profile
source ~/.zshrc # or source ~/.bashrc
```

**Windows (PowerShell):**

```powershell
# Set for current session
$env:ANTHROPIC_API_KEY = "sk-ant-api03-your-key-here"

# Set permanently
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "sk-ant-api03-your-key-here", "User")
```

**In code (Python SDK):**

```python
import anthropic

# Option 1: SDK reads ANTHROPIC_API_KEY automatically
client = anthropic.Anthropic()

# Option 2: Pass explicitly (not recommended for production)
client = anthropic.Anthropic(api_key="sk-ant-api03-...")
```

### Step 3 — Verify the Header Format

If you are making raw HTTP requests, ensure you use `x-api-key` (not `Authorization`):

```bash
# Correct
curl https://api.anthropic.com/v1/messages \
 -H "x-api-key: $ANTHROPIC_API_KEY" \
 -H "anthropic-version: 2023-06-01" \
 -H "content-type: application/json" \
 -d '{"model":"claude-sonnet-4-5-20250514","max_tokens":128,"messages":[{"role":"user","content":"Hi"}]}'

# Wrong — this will return 401
curl https://api.anthropic.com/v1/messages \
 -H "Authorization: Bearer $ANTHROPIC_API_KEY" \
 ...
```

### Step 4 — Verify It Works

```bash
curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com/v1/messages \
 -H "x-api-key: $ANTHROPIC_API_KEY" \
 -H "anthropic-version: 2023-06-01" \
 -H "content-type: application/json" \
 -d '{"model":"claude-sonnet-4-5-20250514","max_tokens":32,"messages":[{"role":"user","content":"test"}]}'
```

**Expected output:**

```
200
```

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| 401 in CI/CD pipeline | Secret not injected | Check GitHub Actions / CI secret configuration |
| 401 after key rotation | Old key cached | Restart application, clear env cache |
| 401 with SDK | `ANTHROPIC_API_KEY` not exported | Add `export` before the variable in shell profile |
| 401 with trailing newline | Copy-paste artifact | `export ANTHROPIC_API_KEY=$(echo -n "sk-ant-...")` |
| 401 on Bedrock/Vertex | Wrong auth method | Use AWS/GCP credentials, not Anthropic API key |

## Prevention

- **Never hardcode API keys:** Use environment variables or a secrets manager.
- **Rotate keys periodically:** Generate new keys in the [Anthropic Console](https://console.anthropic.com/) and update your environment.
- **Test auth separately:** Before debugging complex requests, verify auth with a minimal test call.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-api-error-401-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Issues

- [Fix Claude API Error 500 — Internal Server Error](/claude-api-error-500-fix) — Server-side error troubleshooting
- [Fix Claude API Rate Limit Errors](/claude-api-rate-limit-fix) — HTTP 429 rate limiting solutions
- [Claude API Error 400 Invalid Request Fix](/claude-api-error-400-invalidrequesterror-explained/) — Browse all API error guides

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*



## Related Articles

- [Fix Cannot Read Properties of Undefined — Claude (2026)](/claude-code-cannot-read-property-undefined-null-error/)
- [Fixing Claude Code's 'Unexpected End of Input' JSON Error](/claude-code-unexpected-end-of-input-json-error/)
- [Claude Code Unknown Skill Error: Fix Spawn Issues](/claude-code-spawn-unknown-error-node-skill-fix/)
- [Fix Claude Code API Error 400 Bad Request](/claude-code-api-error-400/)
- [Fix Claude Code Bun Errors](/claude-code-bun-error/)
- [Fix Next.js Hydration Errors Using Claude Code](/claude-code-next-js-hydration-error-fix/)
- [Claude Code Error Invalid API Key After Rotation Fix](/claude-code-error-invalid-api-key-after-rotation-fix/)
- [Fix Claude Code Remix Error Boundaries Nested — Quick Guide](/claude-code-remix-error-boundaries-nested-routes-guide/)
