---
layout: default
title: "Claude Code with Azure OpenAI Setup (2026)"
description: "Claude Code with Azure OpenAI Setup — practical setup steps, configuration examples, and working code you can use in your projects today."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-azure-openai/
categories: [guides]
tags: [claude-code, claude-skills, azure, openai, ai-models]
reviewed: true
score: 6
geo_optimized: true
---

Using Claude Code in projects that also rely on Azure OpenAI requires careful configuration of API keys, endpoints, and model routing. This guide covers how to set up Claude Code alongside Azure OpenAI services, manage multiple AI providers, and build workflows that use both platforms effectively.

## The Problem

Many enterprise teams use Azure OpenAI for production inference (GPT-4, embeddings, completions) while wanting Claude Code for development assistance. Managing two sets of API credentials, keeping model references consistent, and avoiding accidental cross-contamination of keys creates friction. Developers need a clean separation between their coding assistant and their application's AI backend.

## Quick Solution

1. Set up Azure OpenAI credentials as environment variables for your application:

```bash
export AZURE_OPENAI_API_KEY="your-azure-openai-key"
export AZURE_OPENAI_ENDPOINT="https://your-resource.openai.azure.com"
export AZURE_OPENAI_DEPLOYMENT="gpt-4"
export AZURE_OPENAI_API_VERSION="2024-10-21"
```

2. Keep Claude Code's Anthropic API key separate:

```bash
export ANTHROPIC_API_KEY="your-anthropic-key"
```

3. Create a `.env` file for your application (not for Claude Code):

```bash
# .env - Application AI config (Azure OpenAI)
AZURE_OPENAI_API_KEY=your-azure-openai-key
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_DEPLOYMENT=gpt-4
AZURE_OPENAI_API_VERSION=2024-10-21
```

4. Add `.env` to your `.gitignore` to prevent credential leaks:

```bash
echo ".env" >> .gitignore
```

5. Document the dual-provider setup in CLAUDE.md so Claude Code understands the architecture.

## How It Works

Claude Code uses the Anthropic API for its own operation and has no direct interaction with Azure OpenAI. The separation is architectural: Claude Code is your development tool, while Azure OpenAI is your application's AI backend.

When Claude Code reads your codebase, it sees Azure OpenAI SDK calls, endpoint configurations, and deployment names. By documenting these in CLAUDE.md, Claude Code understands the distinction and can help you write, debug, and optimize your Azure OpenAI integration code without confusing its own API context.

For teams using Claude Code with an Anthropic API key alongside Azure OpenAI in production, the key insight is environment isolation. Your application reads from `.env` or Azure Key Vault. Claude Code reads from its own configuration. The two never overlap.

## Common Issues

**API key confusion**: Claude Code may suggest using `OPENAI_API_KEY` when your setup uses `AZURE_OPENAI_API_KEY`. Add explicit notes in CLAUDE.md about which environment variable names your project uses.

**SDK version mismatch**: Azure OpenAI SDK versions change frequently. If Claude Code suggests API calls that fail, specify the exact SDK version in your CLAUDE.md so it generates compatible code.

**Endpoint format errors**: Azure OpenAI endpoints follow the pattern `https://{resource}.openai.azure.com/openai/deployments/{deployment}/chat/completions?api-version={version}`. Claude Code may default to the standard OpenAI format. Document the exact URL pattern.

## Example CLAUDE.md Section

```markdown
# AI Provider Architecture

## Development Tool (Claude Code)
- Uses Anthropic API via ANTHROPIC_API_KEY
- Not part of the application runtime

## Application AI Backend (Azure OpenAI)
- Endpoint: https://acme-ai.openai.azure.com
- Deployment: gpt-4-turbo (model: gpt-4-1106-preview)
- Embedding deployment: text-embedding-3-large
- API Version: 2024-10-21
- SDK: @azure/openai v2.1.0

## Code Patterns
- All Azure OpenAI calls go through src/lib/ai-client.ts
- Use AzureOpenAI class, NOT OpenAI class
- Always pass deployment name, not model name
- Retry with exponential backoff on 429 errors
- Token counting uses tiktoken with cl100k_base encoding
```

## Best Practices

- **Never mix API keys in the same config file.** Keep Anthropic credentials for Claude Code separate from Azure OpenAI credentials for your application.
- **Pin SDK versions.** Azure OpenAI SDK changes can break your code. Lock versions in `package.json` and note them in CLAUDE.md.
- **Use Azure Key Vault for production secrets.** Do not hardcode Azure OpenAI keys. Reference Key Vault in your deployment configuration and document this pattern for Claude Code.
- **Document the deployment-model mapping.** Azure OpenAI uses deployment names, not model names. Map these explicitly so Claude Code generates correct API calls.
- **Test with both providers independently.** Use separate test scripts for Azure OpenAI integration tests and keep Claude Code development assistance separate.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-azure-openai)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Anthropic API Error 429 Rate Limit](/anthropic-api-error-429-rate-limit/)
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Best Way to Use Claude Code for Debugging Sessions](/best-way-to-use-claude-code-for-debugging-sessions/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


## Common Questions

### What AI models work best with this approach?

Claude Opus 4 and Claude Sonnet 4 handle complex reasoning tasks. For simpler operations, Claude Haiku 3.5 offers faster responses at lower cost. Match model capability to task complexity.

### How do I handle AI agent failures gracefully?

Implement retry logic with exponential backoff, set clear timeout boundaries, and design fallback paths for critical operations. Log all failures for pattern analysis.

### Can this workflow scale to production?

Yes. Add rate limiting, request queuing, and monitoring before production deployment. Most AI agent architectures scale horizontally by adding worker instances behind a load balancer.



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Resources

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

- [Claude Code Azure DevOps MCP Setup](/claude-code-azure-devops-mcp/)
- [Claude Code Offline Mode Setup](/best-way-to-use-claude-code-offline-without-internet-access/)
- [Claude Code Auto Mode Setup Guide](/claude-code-auto-mode-setup-guide/)
