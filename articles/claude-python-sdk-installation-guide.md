---
layout: default
title: "Claude Python SDK Installation Guide"
description: "Install and configure the Anthropic Python SDK. Covers pip install, platform extras for Bedrock and Vertex AI, async setup, and environment configuration."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-python-sdk-installation-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-api, sdk-python, installation, getting-started]
geo_optimized: true
---

# Claude Python SDK Installation Guide

The Anthropic Python SDK is the fastest way to start building with Claude. This guide covers installation, platform-specific extras, and your first API call.

## Quick Fix

Install the SDK and make your first call in under 2 minutes:

```bash
pip install anthropic
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
```

```python
import anthropic
client = anthropic.Anthropic()
message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello, Claude"}]
)
print(message.content[0].text)
```

## What You Need

- Python 3.9 or higher
- An Anthropic API key from the Console
- pip (included with Python)

## Full Solution

### Install the Base SDK

```bash
pip install anthropic
```

### Install Platform-Specific Extras

If you are using Claude through AWS Bedrock, Google Vertex AI, or need better async performance:

```bash
# Amazon Bedrock support
pip install anthropic[bedrock]

# Google Vertex AI support
pip install anthropic[vertex]

# Improved async performance with aiohttp
pip install anthropic[aiohttp]

# Multiple extras at once
pip install anthropic[bedrock,vertex,aiohttp]
```

### Set Your API Key

The SDK reads the `ANTHROPIC_API_KEY` environment variable automatically:

```bash
# Linux / macOS (add to ~/.bashrc or ~/.zshrc for persistence)
export ANTHROPIC_API_KEY="sk-ant-your-key-here"

# Windows PowerShell
$env:ANTHROPIC_API_KEY = "sk-ant-your-key-here"
```

Or pass it explicitly (not recommended for production):

```python
import anthropic
client = anthropic.Anthropic(api_key="sk-ant-your-key-here")
```

### Synchronous Usage

```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Explain quantum computing in 3 sentences."}]
)

print(message.content[0].text)
print(f"Tokens: {message.usage.input_tokens} in, {message.usage.output_tokens} out")
```

### Async Usage

```python
from anthropic import AsyncAnthropic

client = AsyncAnthropic()

async def main():
 message = await client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello"}]
 )
 print(message.content[0].text)

import asyncio
asyncio.run(main())
```

### Async with aiohttp (Better Performance)

```python
from anthropic import AsyncAnthropic, DefaultAioHttpClient

async def main():
 async with AsyncAnthropic(http_client=DefaultAioHttpClient()) as client:
 message = await client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": "Hello"}]
 )
 print(message.content[0].text)

import asyncio
asyncio.run(main())
```

### Platform Integrations

Use Claude through cloud providers with their respective clients:

```python
import anthropic

# Amazon Bedrock
bedrock_client = anthropic.AnthropicBedrock()

# Google Vertex AI
vertex_client = anthropic.AnthropicVertex(
 project_id="your-gcp-project",
 region="us-east5"
)

# Microsoft Foundry
foundry_client = anthropic.AnthropicFoundry()
```

### Enable Debug Logging

```bash
ANTHROPIC_LOG=debug python your_script.py
```

### Configure Retries and Timeouts

```python
import anthropic
import httpx

# Custom retries (default: 2)
client = anthropic.Anthropic(max_retries=5)

# Custom timeout (default: 10 minutes)
client = anthropic.Anthropic(timeout=20.0)

# Fine-grained timeout control
client = anthropic.Anthropic(
 timeout=httpx.Timeout(60.0, read=5.0, write=10.0, connect=2.0)
)
```

## Prevention

1. **Pin your SDK version**: Use `pip install anthropic==X.Y.Z` in production to avoid breaking changes.
2. **Use environment variables**: Never hardcode API keys in source code.
3. **Use a virtual environment**: `python -m venv .venv && source .venv/bin/activate` before installing.
4. **Check Python version**: The SDK requires Python 3.9+. Run `python --version` to verify.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-python-sdk-installation-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

## Related Guides

- [Claude Python SDK Getting Started](/claude-python-sdk-getting-started-example/) -- your first project with error handling and streaming.
- [How to Set ANTHROPIC_API_KEY for Claude](/how-to-set-anthropicapikey-for-claude/) -- detailed API key setup across all platforms.
- [Claude TypeScript SDK Installation Guide](/claude-typescript-sdk-installation-guide/) -- the TypeScript equivalent of this guide.
- [Claude API Error 401 authentication_error Fix](/claude-api-error-401-authenticationerror-explained/) -- troubleshoot API key issues after installation.
- [Claude SDK Timeout Configuration](/claude-sdk-timeout-configuration-customization/) -- tune retry and timeout settings for production.



## Related Articles

- [Claude Code Pulumi Python Infrastructure Guide](/claude-code-pulumi-python-infrastructure-guide/)
- [Claude Code Python SDK Package Guide](/claude-code-python-sdk-package-guide/)
- [How to Use Python Developers](/claude-code-for-chinese-python-developers-guide-2026/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\")."
      }
    }
  ]
}
</script>
