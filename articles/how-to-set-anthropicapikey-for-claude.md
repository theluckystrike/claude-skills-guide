---
layout: default
title: "How to Set ANTHROPIC_API_KEY for Claude (2026)"
last_tested: "2026-04-22"
description: "Set the ANTHROPIC_API_KEY environment variable on macOS, Linux, and Windows. Covers shell configuration, .env files, and platform-specific clients."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /how-to-set-anthropicapikey-for-claude/
reviewed: true
score: 7
categories: [guides]
tags: [claude-api, sdk-python, sdk-typescript, getting-started]
geo_optimized: true
---

# How to Set ANTHROPIC_API_KEY for Claude

The Anthropic Python and TypeScript SDKs read your API key from the `ANTHROPIC_API_KEY` environment variable. This guide covers every way to set it across macOS, Linux, and Windows.

## Quick Fix

```bash
# macOS / Linux
export ANTHROPIC_API_KEY="sk-ant-your-key-here"

# Windows PowerShell
$env:ANTHROPIC_API_KEY = "sk-ant-your-key-here"
```

Then test it:

```python
import anthropic
client = anthropic.Anthropic()
message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=100,
 messages=[{"role": "user", "content": "Say hello"}]
)
print(message.content[0].text)
```

## Full Solution

### Get Your API Key

1. Go to the Anthropic Console.
2. Navigate to API Keys.
3. Click "Create Key" and copy the key. It starts with `sk-ant-`.
4. Store it securely. You cannot view the key again after creation.

### macOS / Linux: Temporary (Current Session)

```bash
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
```

This is lost when you close the terminal.

### macOS / Linux: Permanent

Add the export to your shell configuration file:

```bash
# For bash (most Linux systems)
echo 'export ANTHROPIC_API_KEY="sk-ant-your-key-here"' >> ~/.bashrc
source ~/.bashrc

# For zsh (macOS default)
echo 'export ANTHROPIC_API_KEY="sk-ant-your-key-here"' >> ~/.zshrc
source ~/.zshrc
```

### Windows: PowerShell (Current Session)

```powershell
$env:ANTHROPIC_API_KEY = "sk-ant-your-key-here"
```

### Windows: PowerShell (Permanent)

```powershell
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "sk-ant-your-key-here", "User")
```

Restart PowerShell after setting.

### Windows: Command Prompt (Current Session)

```cmd
set ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### Windows: System Environment Variables (Permanent)

1. Open System Properties (Win + Pause, or search "Environment Variables").
2. Click "Environment Variables".
3. Under User variables, click "New".
4. Variable name: `ANTHROPIC_API_KEY`
5. Variable value: `sk-ant-your-key-here`
6. Click OK. Restart any open terminals.

### Using .env Files (Python)

For project-specific keys, use `python-dotenv`:

```bash
pip install python-dotenv
```

Create a `.env` file in your project root:

```ini
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

Load it in your Python script:

```python
from dotenv import load_dotenv
load_dotenv()

import anthropic
client = anthropic.Anthropic() # Reads from environment
```

Add `.env` to your `.gitignore`:

```text
# .gitignore
.env
```

### Using .env Files (TypeScript / Node.js)

```bash
npm install dotenv
```

Create `.env`:

```ini
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

```typescript
import "dotenv/config";
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic(); // Reads from environment
```

### Passing the Key Explicitly

If you cannot use environment variables:

```python
import anthropic
client = anthropic.Anthropic(api_key="sk-ant-your-key-here")
```

```typescript
import Anthropic from "@anthropic-ai/sdk";
const client = new Anthropic({ apiKey: "sk-ant-your-key-here" });
```

This is not recommended for production. Hardcoded keys can be accidentally committed to version control.

### Platform-Specific Clients

Bedrock, Vertex AI, and Foundry use their own authentication and do NOT use `ANTHROPIC_API_KEY`:

```python
import anthropic

# Amazon Bedrock (uses AWS credentials from environment/config)
client = anthropic.AnthropicBedrock()

# Google Vertex AI (uses Google Cloud credentials)
client = anthropic.AnthropicVertex(
 project_id="your-project",
 region="us-east5"
)

# Microsoft Foundry
client = anthropic.AnthropicFoundry()
```

### Verify Your Key Is Set

```bash
# Check if the variable is set
echo $ANTHROPIC_API_KEY

# Test with a Python one-liner
python3 -c "import anthropic; print(anthropic.Anthropic().messages.create(model='claude-haiku-4-5', max_tokens=50, messages=[{'role':'user','content':'Say hi'}]).content[0].text)"
```

### Debug Authentication Issues

```bash
# Enable SDK debug logging to see headers
ANTHROPIC_LOG=debug python your_script.py
```

## Prevention

1. **Never commit keys to git**: Always use `.env` files that are in `.gitignore`, or use environment variables directly.
2. **Use different keys per environment**: Create separate keys for development, staging, and production.
3. **Rotate keys regularly**: Generate a new key, update all deployments, then revoke the old key.
4. **Use workspace API keys**: Workspace-scoped keys limit the blast radius if a key is compromised.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=how-to-set-anthropicapikey-for-claude)**

$99 once. Free forever. 47/500 founding spots left.

</div>

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude API Error 401 authentication_error Fix](/claude-api-error-401-authenticationerror-explained/) -- troubleshoot when your key is rejected.
- [Claude Python SDK Installation Guide](/claude-python-sdk-installation-guide/) -- full Python SDK setup.
- [Claude TypeScript SDK Installation Guide](/claude-typescript-sdk-installation-guide/) -- full TypeScript SDK setup.
- [Claude Python SDK Getting Started](/claude-python-sdk-getting-started-example/) -- your first API call after setting the key.
- [Claude SDK Timeout Configuration](/claude-sdk-timeout-configuration-customization/) -- configure the client after authentication.



## Related Articles

- [Best Free VPN for Chrome + Always-On Android Guide](/how-to-set-up-always-on-vpn-on-android-technically/)


## Common Questions

### How do I get started with how to set anthropic_api_key for claude?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Best Way To Set Up Claude Code For New](/best-way-to-set-up-claude-code-for-new-project/)
- [ANTHROPIC_API_KEY Not Set in Subprocess](/claude-code-anthropic-api-key-not-set-subprocess-fix-2026/)
- [Set Up Claude Code in Dev Containers](/claude-code-dev-containers-setup-2026/)
