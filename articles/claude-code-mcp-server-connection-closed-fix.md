---
layout: default
title: "Fix Claude Code MCP Server Connection (2026)"
description: "Resolve Claude Code MCP Server Connection Closed issues with tested solutions, step-by-step debugging, and production-ready code examples verified for..."
date: 2026-04-15
permalink: /claude-code-mcp-server-connection-closed-fix/
categories: [troubleshooting, claude-code]
tags: [mcp, connection-closed, stdio, npx, windows]
last_modified_at: 2026-04-17
geo_optimized: true
last_tested: "2026-04-22"
---

# Fix Claude Code MCP Server Connection Closed

## The Error

When launching Claude Code with an MCP server configured, the server fails to start and you see:

```text
MCP server "my-server" failed to start: Connection closed
```

Or in the `/mcp` status panel, the server shows a red status with "Connection closed" instead of the expected green checkmark.

## Quick Fix

If you are on Windows, wrap your `npx` command with `cmd /c`:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

If you are on macOS or Linux, increase the MCP startup timeout:

```bash
MCP_TIMEOUT=10000 claude
```

## What's Happening

MCP servers using stdio transport communicate with Claude Code through stdin and stdout pipes. The "Connection closed" error means the pipe broke before the MCP handshake completed. Three common causes exist.

First, on Windows, the shell cannot directly execute `npx` as a child process. Windows requires the `cmd /c` wrapper to resolve the `npx` binary through the system PATH. Without it, the process spawns but immediately exits because the OS cannot find the executable.

Second, the MCP server may take longer to initialize than the default timeout allows. Claude Code waits for the MCP handshake within a configurable window controlled by the `MCP_TIMEOUT` environment variable. Servers that download dependencies on first run (like `npx -y` packages) often exceed the default timeout.

Third, the server process itself may crash during startup due to missing dependencies, wrong Node.js version, or environment variable issues.

## Step-by-Step Fix

### Step 1: Check server status

Inside Claude Code, run:

```text
/mcp
```

This shows all configured MCP servers with their connection status. Note which server is failing.

### Step 2: Test the server command manually

Run the MCP server command directly in your terminal to see its actual error output:

```bash
npx -y @some/mcp-package
```

If you see a Node.js error, missing module, or version incompatibility, fix that first.

### Step 3: Fix Windows npx issues

On Windows, always use the `cmd /c` wrapper for stdio MCP servers:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

Without `cmd /c`, Windows cannot execute `npx` directly as a child process.

### Step 4: Increase the startup timeout

Set the `MCP_TIMEOUT` environment variable before launching Claude Code. The value is in milliseconds:

```bash
MCP_TIMEOUT=10000 claude
```

Or add it permanently to your settings:

```json
{
 "env": {
 "MCP_TIMEOUT": "10000"
 }
}
```

This gives the MCP server 10 seconds to complete the handshake instead of the default.

### Step 5: Verify environment variables

If your MCP server requires API keys or configuration, pass them with `--env` flags:

```bash
claude mcp add --transport stdio --env API_KEY=your-key my-server -- npx -y @some/package
```

Missing environment variables often cause silent crashes that manifest as "Connection closed."

### Step 6: Check server scope

List your configured servers to verify the configuration:

```bash
claude mcp list
```

Get details for the specific server:

```bash
claude mcp get my-server
```

Confirm the command, arguments, and environment variables are correct.

## Prevention

Add MCP timeout configuration to your project settings so your entire team avoids this issue:

```json
{
 "env": {
 "MCP_TIMEOUT": "10000"
 }
}
```

For Windows teams, document the `cmd /c` requirement in your project CLAUDE.md file. Consider using remote HTTP transport instead of stdio for servers that support it, as HTTP connections are more reliable across platforms:

```bash
claude mcp add --transport http my-server https://api.example.com/mcp
```

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---

---


<div class="before-after">

**Without a CLAUDE.md — what actually happens:**

You type: "Add auth to my Next.js app"

Claude generates: `pages/api/auth/[...nextauth].js` — wrong directory (you're on App Router), wrong file extension (you use TypeScript), wrong NextAuth version (v4 patterns, you need v5), session handling that doesn't match your middleware setup.

You spend 40 minutes reverting and rewriting. Claude was "helpful."

**With the Zovo Lifetime CLAUDE.md:**

Same prompt. Claude reads 300 lines of context about YOUR project. Generates: `app/api/auth/[...nextauth]/route.ts` with v5 patterns, your session types, your middleware config, your test patterns.

Works on first run. You commit and move on.

That's the difference a $99 file makes.

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-mcp-server-connection-closed-fix)**

</div>

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=claude-code-mcp-server-connection-closed-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

---

## Related Guides

- [Building Your First MCP Tool Integration Guide](/building-your-first-mcp-tool-integration-guide-2026/)
- [Anthropic SDK MCP Empty Arguments Bug](/anthropic-sdk-mcp-empty-arguments-bug/)
- [Claude Code Slow Response Fix](/claude-code-slow-response-fix/)
- [AWS MCP Server Cloud Automation with Claude Code](/aws-mcp-server-cloud-automation-with-claude-code/)

## See Also

- [HTTP/2 Stream Error During Request -- Fix (2026)](/claude-code-http2-stream-error-fix-2026/)
