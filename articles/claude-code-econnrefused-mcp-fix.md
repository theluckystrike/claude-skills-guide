---
layout: default
title: "Fix Claude Code Econnrefused MCP — Quick Guide"
description: "Resolve ECONNREFUSED errors when Claude Code tries to connect to MCP servers. Step-by-step troubleshooting for port conflicts and configuration."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-econnrefused-mcp-fix/
reviewed: true
categories: [troubleshooting, claude-code]
tags: [mcp, econnrefused, connection, server, debugging]
geo_optimized: true
---
# Fix ECONNREFUSED When Connecting to MCP Servers in Claude Code

## The Problem

You configure an MCP server in Claude Code and get an error like this when trying to use it:

```
Error: connect ECONNREFUSED 127.0.0.1:3000
 at TCPConnectWrap.afterConnect [as oncomplete]
```

Claude Code cannot reach your MCP server. Tools from that server show as unavailable, and any prompt that tries to use them fails silently or throws a connection error.

## Quick Fix

Check that your MCP server is actually running and listening on the expected port:

```bash
# Check if anything is listening on the expected port
lsof -i :3000

# If nothing shows up, start your MCP server first
npx @modelcontextprotocol/server-filesystem /path/to/allowed/dir
```

If the server is running but on a different port, update your MCP configuration in `.claude/settings.json`:

```json
{
 "mcpServers": {
 "filesystem": {
 "command": "npx",
 "args": [
 "@modelcontextprotocol/server-filesystem",
 "/path/to/allowed/dir"
 ]
 }
 }
}
```

## What's Happening

ECONNREFUSED means the operating system received a TCP connection request but no process was listening on that port. In the context of Claude Code and MCP, this typically happens because:

1. The MCP server process has not started yet
2. The server crashed during startup
3. The port number in your configuration does not match the server's actual port
4. Another process grabbed the port first
5. The server is binding to a different network interface (e.g., `0.0.0.0` vs `127.0.0.1`)

MCP (Model Context Protocol) servers extend Claude Code's capabilities by providing additional tools. Claude Code connects to these servers either via stdio (spawning a child process) or via HTTP/SSE transport. The ECONNREFUSED error only occurs with network-based transports.

## Step-by-Step Fix

### Step 1: Verify your MCP configuration

Open your settings file and confirm the server entry:

```bash
# Project-level config
cat .claude/settings.json

# User-level config
cat ~/.claude/settings.json
```

For stdio-based servers (most common), the configuration should use `command` and `args`:

```json
{
 "mcpServers": {
 "my-server": {
 "command": "node",
 "args": ["./mcp-server/index.js"],
 "env": {
 "API_KEY": "your-key-here"
 }
 }
 }
}
```

For HTTP/SSE-based servers, the configuration uses a `url` field:

```json
{
 "mcpServers": {
 "remote-server": {
 "url": "http://localhost:3000/sse"
 }
 }
}
```

### Step 2: Check for port conflicts

If your MCP server binds to a specific port, verify no other process is using it:

```bash
# Find what's using port 3000
lsof -i :3000

# Kill a conflicting process if needed
kill -9 <PID>
```

Common conflicts include development servers (Vite, Next.js, Express) that default to port 3000.

### Step 3: Test the server independently

Start the MCP server manually outside of Claude Code to see its startup output:

```bash
# For a Node.js MCP server
node ./mcp-server/index.js

# For a Python MCP server
python -m mcp_server

# For an npx-based server
npx @modelcontextprotocol/server-filesystem /tmp
```

Look for startup errors, missing dependencies, or port binding failures in the output.

### Step 4: Check environment variables

MCP servers often require environment variables for API keys or configuration. Missing variables can cause silent startup failures:

```json
{
 "mcpServers": {
 "database": {
 "command": "npx",
 "args": ["@modelcontextprotocol/server-postgres"],
 "env": {
 "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
 }
 }
 }
}
```

Verify all required environment variables are set in the `env` block or in your shell profile.

### Step 5: Check firewall and network settings

On macOS, the application firewall can block local connections:

```bash
# Check firewall status
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# Allow Node.js through the firewall if needed
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/node
```

On Linux, check iptables or ufw rules:

```bash
sudo ufw status
sudo iptables -L -n
```

### Step 6: Restart Claude Code's MCP connection

After fixing the underlying issue, restart the MCP connection:

```
/mcp
```

This opens the MCP management interface where you can see all configured servers and their status. Select the failing server and choose to restart it.

## Prevention

Prefer stdio transport over HTTP transport when the MCP server runs locally. Stdio-based servers are spawned as child processes by Claude Code, which eliminates port conflicts entirely:

```json
{
 "mcpServers": {
 "filesystem": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"]
 }
 }
}
```

For HTTP-based servers, use a non-standard port (like 9847) to avoid conflicts with common development servers. Add a startup check script to your project that verifies all MCP dependencies are installed before launching Claude Code.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=claude-code-econnrefused-mcp-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

---

## Related Guides

- [Claude Code Error Connection Refused Localhost Fix](/claude-code-error-connection-refused-localhost-fix/)
- [Claude Code Error Connection Timeout During Task Fix](/claude-code-error-connection-timeout-during-task-fix/)
- [Claude Code Subagents Guide](/claude-code-subagents-guide/)



## Related Articles

- [Fix Claude Code MCP Tools Excessive Context — Quick Guide](/claude-code-mcp-tools-excessive-context-fix/)
- [Fix Claude Code MCP Server Connection Closed](/claude-code-mcp-server-connection-closed-fix/)
- [Debug MCP Servers in Claude Code](/claude-code-debugging-mcp/)
- [Claude Code MCP Timeout: How to Configure Settings](/claude-code-mcp-timeout-settings-configuration-guide/)
