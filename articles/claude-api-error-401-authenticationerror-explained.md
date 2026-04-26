---
layout: default
title: "Fix: Claude API Error 401 (2026)"
description: "Fix Claude API 401 authentication_error. Covers invalid API keys, environment variable setup, and SDK authentication for Python and TypeScript."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-api-error-401-authenticationerror-explained/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-api, sdk-python, sdk-typescript, api-errors]
geo_optimized: true
last_tested: "2026-04-22"
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

For more on this topic, see [Fix: Claude Can't Open This Chat Error](/claude-cant-open-this-chat-fix/).


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

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-api-error-401-authenticationerror-explained)**

$99 once. Yours forever. I keep adding templates monthly.

</div>



**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [How to Set ANTHROPIC_API_KEY for Claude](/how-to-set-anthropicapikey-for-claude/) -- step-by-step environment variable setup for all platforms.
- [Claude Python SDK Installation Guide](/claude-python-sdk-installation-guide/) -- full setup from install to first API call.
- [Claude Code Permission Modes Explained](/claude-code-permission-modes/) -- similar error when your key lacks specific permissions.
- [Claude Code API Key vs Pro Subscription Billing](/claude-code-api-key-vs-pro-subscription-billing/) -- authentication succeeds but billing is not configured.
- [Claude TypeScript SDK Installation Guide](/claude-typescript-sdk-installation-guide/) -- TypeScript-specific setup and auth configuration.


## Common Questions

### What causes fix: claude api error 401 issues?

Common causes include misconfigured settings, outdated dependencies, and environment conflicts. Check your project configuration and ensure all dependencies are up to date.

### How do I prevent this error from recurring?

Set up automated checks in your development workflow. Use Claude Code's built-in validation tools to catch configuration issues before they reach production.

### Does this fix work on all operating systems?

The core fix applies to macOS, Linux, and Windows. Some path-related adjustments may be needed depending on your OS. Check the platform-specific notes in the guide above.

## Related Resources

- [Fix: Claude API Error 429 Rate Limit](/anthropic-api-error-429-rate-limit/)
- [Fix: Claude API Error 400](/claude-api-error-400-invalidrequesterror-explained/)
- [Fix Claude API Error 401](/claude-api-error-401-fix/)
