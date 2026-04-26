---
layout: default
title: "Claude TypeScript SDK Installation (2026)"
description: "Install and configure the Anthropic TypeScript SDK. Covers npm install, runtime support for Node.js, Deno, Bun, and Cloudflare Workers."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-typescript-sdk-installation-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-api, sdk-typescript, installation, getting-started]
geo_optimized: true
---

# Claude TypeScript SDK Installation Guide

The Anthropic TypeScript SDK provides type-safe access to the Claude API with built-in streaming, retries, and error handling. This guide covers installation, runtime support, and your first API call.

## Quick Fix

Install and run your first Claude API call:

```bash
npm install @anthropic-ai/sdk
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
```

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();
const message = await client.messages.create({
 model: "claude-sonnet-4-6",
 max_tokens: 1024,
 messages: [{ role: "user", content: "Hello, Claude" }]
});
console.log(message.content[0].type === "text" ? message.content[0].text : "");
```

## What You Need

- TypeScript 4.9 or higher
- One of these runtimes: Node.js 20+, Deno v1.28+, Bun 1.0+, Cloudflare Workers, or Vercel Edge Runtime
- An Anthropic API key

## Full Solution

### Install the SDK

```bash
# npm
npm install @anthropic-ai/sdk

# pnpm
pnpm add @anthropic-ai/sdk

# yarn
yarn add @anthropic-ai/sdk
```

### Platform-Specific SDKs

For cloud provider integrations, install the platform-specific package:

```bash
# Amazon Bedrock
npm install @anthropic-ai/bedrock-sdk

# Google Vertex AI
npm install @anthropic-ai/vertex-sdk

# Microsoft Foundry
npm install @anthropic-ai/foundry-sdk
```

### Set Your API Key

The SDK reads `ANTHROPIC_API_KEY` from the environment:

```bash
# Linux / macOS
export ANTHROPIC_API_KEY="sk-ant-your-key-here"

# Windows PowerShell
$env:ANTHROPIC_API_KEY = "sk-ant-your-key-here"
```

Or pass it explicitly:

```typescript
const client = new Anthropic({ apiKey: "sk-ant-your-key-here" });
```

### Basic Usage

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const message = await client.messages.create({
 model: "claude-sonnet-4-6",
 max_tokens: 1024,
 messages: [{ role: "user", content: "Explain quantum computing in 3 sentences." }]
});

for (const block of message.content) {
 if (block.type === "text") {
 console.log(block.text);
 }
}

console.log(`Tokens: ${message.usage.input_tokens} in, ${message.usage.output_tokens} out`);
```

### Streaming

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

// Stream helper with event callbacks
const stream = client.messages.stream({
 model: "claude-sonnet-4-6",
 max_tokens: 4096,
 messages: [{ role: "user", content: "Write a short story" }]
}).on("text", (text) => {
 process.stdout.write(text);
});

const message = await stream.finalMessage();
console.log(`\nDone. Output tokens: ${message.usage.output_tokens}`);
```

### Error Handling

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

try {
 const message = await client.messages.create({
 model: "claude-sonnet-4-6",
 max_tokens: 1024,
 messages: [{ role: "user", content: "Hello" }]
 });
} catch (err) {
 if (err instanceof Anthropic.AuthenticationError) {
 console.error("Invalid API key");
 } else if (err instanceof Anthropic.RateLimitError) {
 console.error("Rate limited -- retry later");
 } else if (err instanceof Anthropic.APIError) {
 console.error(`API error: ${err.status} ${err.message}`);
 }
}
```

### Configure Retries and Timeouts

```typescript
import Anthropic from "@anthropic-ai/sdk";

// Custom retries (default: 2)
const client = new Anthropic({ maxRetries: 5 });

// Custom timeout (default: 10 minutes)
const client2 = new Anthropic({ timeout: 20 * 1000 }); // 20 seconds
```

For large `max_tokens` values without streaming, the SDK dynamically calculates timeouts up to 60 minutes.

### Enable Debug Logging

```bash
# Via environment variable
ANTHROPIC_LOG=debug node your_script.js

# Or set logLevel in the client
```

```typescript
const client = new Anthropic({ logLevel: "debug" });
```

### Browser Usage (Not Recommended)

The SDK can run in browsers but this exposes your API key:

```typescript
const client = new Anthropic({
 apiKey: "sk-ant-...",
 dangerouslyAllowBrowser: true // Required flag
});
```

Use a backend proxy in production instead of exposing your API key client-side.

## Prevention

1. **Pin your SDK version**: Use exact versions in `package.json` for production stability.
2. **Use environment variables**: Never commit API keys to source control.
3. **Check TypeScript version**: Run `npx tsc --version` and verify it is 4.9 or higher.
4. **Use Node.js 20+**: Older Node.js versions may have issues with the SDK's streaming implementation.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-typescript-sdk-installation-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Python SDK Installation Guide](/claude-python-sdk-installation-guide/) -- the Python equivalent of this guide.
- [How to Set ANTHROPIC_API_KEY for Claude](/how-to-set-anthropicapikey-for-claude/) -- detailed environment variable setup.
- [Claude Streaming API Guide](/claude-streaming-api-guide/) -- complete streaming tutorial for TypeScript.
- [Claude API Error 401 authentication_error Fix](/claude-api-error-401-authenticationerror-explained/) -- troubleshoot API key issues.
- [Claude SDK Timeout Configuration](/claude-sdk-timeout-configuration-customization/) -- production timeout and retry tuning.



## Related Articles

- [Claude Code Pulumi TypeScript Infra Guide](/claude-code-pulumi-typescript-infra-guide/)
- [Claude Code for TypeScript Declaration Merging Guide](/claude-code-for-typescript-declaration-merging-guide/)
- [Claude Code JSDoc TypeScript Documentation Guide](/claude-code-jsdoc-typescript-documentation/)
- [How to Stop Claude Code from Using Snake Case in TypeScript](/how-to-stop-claude-code-from-using-snake-case-in-typescript/)
- [Claude Code For TypeScript — Complete Developer Guide](/claude-code-for-typescript-conditional-types-guide/)
- [Claude Code SDK Versioning and Release Guide](/claude-code-sdk-versioning-release-guide/)


## Common Questions

### How do I get started with claude typescript sdk installation?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Python SDK Installation Guide](/claude-python-sdk-installation-guide/)
- [Anthropic SDK TypeScript Tool Results](/anthropic-sdk-typescript-type-mismatch-tool-results-fix/)
- [Use Claude Code with TypeScript](/best-way-to-use-claude-code-with-typescript-projects/)
