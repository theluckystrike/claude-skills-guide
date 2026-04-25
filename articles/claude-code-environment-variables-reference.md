---
layout: default
title: "Claude Code Environment Variables"
description: "Complete reference for Claude Code environment variables: API keys, proxy settings, model selection, timeouts, and debug flags."
date: 2026-04-15
permalink: /claude-code-environment-variables-reference/
categories: [guides, claude-code]
tags: [environment-variables, configuration, API-key, proxy, reference]
last_modified_at: 2026-04-17
geo_optimized: true
---

# Claude Code Environment Variables Reference

## The Problem

You need to configure Claude Code behavior through environment variables for proxy settings, API keys, model selection, MCP timeouts, or debug logging, but you do not know which variables exist or how to set them permanently.

## Quick Fix

Set environment variables before launching Claude Code or add them to `settings.json`:

```bash
# One-time use
ANTHROPIC_MODEL=claude-sonnet-4-6 claude

# Permanent via settings
```

```json
{
 "env": {
 "ANTHROPIC_MODEL": "claude-sonnet-4-6",
 "MCP_TIMEOUT": "10000"
 }
}
```

## What's Happening

Claude Code reads environment variables from your shell and from the `env` key in settings.json files. Shell variables apply to the current session; settings.json variables apply to every session. When both are set, the shell environment takes precedence.

Settings.json supports user scope (`~/.claude/settings.json`) for personal configuration, project scope (`.claude/settings.json`) for team configuration, and managed scope for organization-wide enforcement.

## Step-by-Step Fix

### Essential variables

#### API authentication

```bash
# Direct Anthropic API
export ANTHROPIC_API_KEY=sk-ant-...

# Custom API key helper script
# Outputs key to stdout, used as X-Api-Key and Authorization: Bearer
```

In settings.json, use `apiKeyHelper` instead of storing keys directly:

```json
{
 "apiKeyHelper": "/path/to/generate-api-key.sh"
}
```

#### Model selection

```bash
# Override the default model
export ANTHROPIC_MODEL=claude-sonnet-4-6
```

Or set it in settings.json with the `effortLevel` key:

```json
{
 "effortLevel": "medium"
}
```

Effort levels (`low`, `medium`, `high`) are supported on Opus 4.6 and Sonnet 4.6.

#### Proxy and network configuration

```bash
# HTTP proxy for all outbound requests
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080

# Corporate CA certificate for TLS inspection
export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem
```

### MCP configuration variables

```bash
# MCP server startup timeout in milliseconds (default varies)
export MCP_TIMEOUT=10000

# Maximum MCP tool output tokens before warning (default: 10000)
export MAX_MCP_OUTPUT_TOKENS=50000
```

### Provider-specific variables

#### AWS Bedrock

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export ANTHROPIC_MODEL=us.anthropic.claude-sonnet-4-6-20250514-v1:0
```

#### Google Vertex AI

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=your-project-id
export ANTHROPIC_MODEL=claude-sonnet-4-6@20250514
```

### Debug and telemetry variables

```bash
# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# OpenTelemetry metrics exporter
export OTEL_METRICS_EXPORTER=otlp

# Skip writing session transcripts
export CLAUDE_CODE_SKIP_PROMPT_HISTORY=1
```

### Experimental features

```bash
# Enable agent teams
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

# New interactive init flow
export CLAUDE_CODE_NEW_INIT=1
```

### Setting variables permanently

Add variables to `~/.claude/settings.json` for all projects:

```json
{
 "env": {
 "MCP_TIMEOUT": "10000",
 "HTTP_PROXY": "http://proxy.example.com:8080",
 "HTTPS_PROXY": "http://proxy.example.com:8080",
 "NODE_EXTRA_CA_CERTS": "/path/to/corporate-ca.pem"
 }
}
```

Add to `.claude/settings.json` for project-specific variables shared with your team:

```json
{
 "env": {
 "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
 }
}
```

## Prevention

Use `settings.json` for variables that should persist rather than exporting them in your shell configuration. This keeps Claude Code configuration separate from your general shell environment and makes it visible to team members through project settings.

Document required environment variables in your project's CLAUDE.md or README so new team members can configure them quickly.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-environment-variables-reference)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

---

## Related Guides

- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Claude Code Headless Linux Auth](/claude-code-headless-linux-auth/)
- [Claude Code TLS/SSL Connection Error Corporate Proxy Fix](/claude-code-tls-ssl-connection-error-corporate-proxy-fix/)
- [Claude Code Slow Response Fix](/claude-code-slow-response-fix/)


## Common Questions

### How do I get started with claude code environment variables?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Environment Variables for Claude Code](/environment-variables-claude-code-cost-control/)
- [Claude Code Wrong Environment Deploy](/claude-code-deploying-wrong-environment-prevent-mistakes/)
- [Automate Claude Code Environment Setup](/claude-code-environment-setup-automation/)
