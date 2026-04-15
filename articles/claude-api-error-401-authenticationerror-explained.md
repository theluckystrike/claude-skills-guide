---
layout: default
title: "Claude API Error 401 authentication_error Fix"
description: "Fix Claude API 401 authentication_error. Covers invalid API keys, environment variable setup, and SDK authentication for Python and TypeScript."
date: 2026-04-15
last_modified_at: 2026-04-15
author: "Claude Code Guides"
permalink: /claude-api-error-401-authenticationerror-explained/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-api, sdk-python, sdk-typescript, api-errors]
---

# Claude API Error 401 authentication_error Fix

The 401 `authentication_error` means your API key is invalid, missing, or expired. This is one of the most common errors when first setting up the Claude API.

## The Error

```json
{
  "type": "error",
  "error": {
    "type": "authentication_error",
    "message": "There's an issue with your API key."
  },
  "request_id": "req_011CSHoEeqs5C35K2UUqR7Fy"
}
```

## Quick Fix

1. Verify your `ANTHROPIC_API_KEY` environment variable is set and not empty.
2. Confirm the key starts with `sk-ant-` and has not been revoked.
3. Restart your terminal or IDE after setting the environment variable.

## What Causes This

The Claude API requires a valid API key in the `x-api-key` header (or via the `ANTHROPIC_API_KEY` environment variable when using SDKs). Common causes:

- The `ANTHROPIC_API_KEY` environment variable is not set.
- The API key was copied with leading or trailing whitespace.
- The key was revoked or regenerated in the Anthropic Console.
- You are using a Bedrock or Vertex AI key format with the direct Anthropic API endpoint.

## Full Solution

### Set the Environment Variable

```bash
# Linux / macOS -- add to ~/.bashrc or ~/.zshrc
export ANTHROPIC_API_KEY="sk-ant-your-key-here"

# Windows PowerShell
$env:ANTHROPIC_API_KEY = "sk-ant-your-key-here"

# Windows Command Prompt
set ANTHROPIC_API_KEY=sk-ant-your-key-here
```

After setting, restart your terminal session or run `source ~/.bashrc`.

### Python SDK Authentication

The Python SDK reads `ANTHROPIC_API_KEY` automatically:

```python
import anthropic

# Option 1: Auto-reads ANTHROPIC_API_KEY from environment
client = anthropic.Anthropic()

# Option 2: Pass key explicitly (not recommended for production)
client = anthropic.Anthropic(api_key="sk-ant-your-key-here")
```

### TypeScript SDK Authentication

```typescript
import Anthropic from "@anthropic-ai/sdk";

// Option 1: Auto-reads ANTHROPIC_API_KEY from environment
const client = new Anthropic();

// Option 2: Pass key explicitly
const client2 = new Anthropic({ apiKey: "sk-ant-your-key-here" });
```

### Catch Authentication Errors

```python
import anthropic

client = anthropic.Anthropic()

try:
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[{"role": "user", "content": "Hello"}]
    )
except anthropic.AuthenticationError as e:
    print(f"401 Auth Error: {e.message}")
    print("Check your ANTHROPIC_API_KEY environment variable")
```

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

try {
  await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 1024,
    messages: [{ role: "user", content: "Hello" }]
  });
} catch (err) {
  if (err instanceof Anthropic.AuthenticationError) {
    console.error("401: Check your ANTHROPIC_API_KEY");
  }
}
```

### Debug with Logging

Enable SDK debug logging to see exactly what headers are being sent:

```bash
# Python SDK debug mode
ANTHROPIC_LOG=debug python your_script.py
```

```bash
# TypeScript SDK debug mode
ANTHROPIC_LOG=debug node your_script.js
```

### Platform-Specific Authentication

If you are using Bedrock or Vertex AI, you need the platform-specific client, not the default `Anthropic` client:

```python
import anthropic

# Amazon Bedrock (uses AWS credentials, not ANTHROPIC_API_KEY)
client = anthropic.AnthropicBedrock()

# Google Vertex AI (uses Google Cloud credentials)
client = anthropic.AnthropicVertex(project_id="your-project", region="us-east5")

# Microsoft Foundry
client = anthropic.AnthropicFoundry()
```

## Prevention

1. **Use environment variables**: Never hardcode API keys. The SDK reads `ANTHROPIC_API_KEY` automatically.
2. **Add to .env files**: Use `python-dotenv` or similar to load keys from `.env` files that are in `.gitignore`.
3. **Rotate keys safely**: When generating a new key in the Console, update all deployments before revoking the old key.
4. **Test with a simple request**: After setup, run a minimal "Hello" request to verify authentication before building complex logic.

## Related Guides

- [How to Set ANTHROPIC_API_KEY for Claude](/how-to-set-anthropicapikey-for-claude/) -- step-by-step environment variable setup for all platforms.
- [Claude Python SDK Installation Guide](/claude-python-sdk-installation-guide/) -- full setup from install to first API call.
- [Claude API Error 403 permission_error Fix](/claude-api-error-403-permissionerror-explained/) -- similar error when your key lacks specific permissions.
- [Claude API Error 402 billing_error Fix](/claude-api-error-402-billingerror-explained/) -- authentication succeeds but billing is not configured.
- [Claude TypeScript SDK Installation Guide](/claude-typescript-sdk-installation-guide/) -- TypeScript-specific setup and auth configuration.
