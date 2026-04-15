---
layout: default
title: "Fix Claude Code MCP Server Connection Closed"
description: "Resolve MCP server 'Connection closed' errors in Claude Code caused by stdio transport issues, Windows npx problems, and startup timeouts."
date: 2026-04-15
permalink: /claude-code-mcp-server-connection-closed-fix/
categories: [troubleshooting, claude-code]
tags: [mcp, connection-closed, stdio, npx, windows]
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

**[Claude Code Mastery →](https://claudecodeguides.com/mastery/?utm_source=ccg&utm_medium=article&utm_campaign=claude-code-mcp-server-connection-closed-fix)**
Templates, configs, and orchestration playbooks used by a Top Rated Plus developer with $400K+ earned building with Claude Code.

$19/month · $149 lifetime · No fluff, no courses, just tools that ship.

---

## Related Guides

- [Building Your First MCP Tool Integration Guide](/building-your-first-mcp-tool-integration-guide-2026/)
- [Anthropic SDK MCP Empty Arguments Bug](/anthropic-sdk-mcp-empty-arguments-bug/)
- [Claude Code Slow Response Fix](/claude-code-slow-response-fix/)
- [AWS MCP Server Cloud Automation with Claude Code](/aws-mcp-server-cloud-automation-with-claude-code/)
