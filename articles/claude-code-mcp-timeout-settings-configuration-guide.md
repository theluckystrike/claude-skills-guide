---
layout: default
title: "Fix Claude Code MCP Timeout Settings (2026)"
description: "Fix MCP tool call timeouts in Claude Code. Set transport-level overrides, configure retry logic, and resolve cold-start delays. Tested April 2026."
date: 2026-04-01
last_modified_at: 2026-04-21
last_tested: "2026-04-21"
categories: [troubleshooting]
tags: [claude-code, mcp, timeout, troubleshooting]
author: "theluckystrike"
reviewed: true
score: 8
permalink: /claude-code-mcp-timeout-settings-configuration-guide/
geo_optimized: true
---

# Claude Code MCP Timeout: How to Configure Settings

MCP tool calls are one of the most common sources of timeout errors in Claude Code. When a skill invokes an MCP server to fetch data, run a query, or perform an automation step, that round-trip time counts against the total execution budget. If the server is slow, cold-starting, or simply handling a large payload, the entire skill invocation can fail before the model even begins generating output.

I have spent a significant amount of time debugging MCP timeouts across different server configurations, and the patterns are consistent. This guide covers the defaults, the configuration options that actually exist, and the practical techniques I use to keep MCP-dependent workflows reliable.

## Understanding MCP Timeout Defaults

Claude Code communicates with MCP servers using the Model Context Protocol transport layer. Each tool call initiated by a skill has a window of time to complete before Claude Code considers it failed. The key defaults to be aware of:

The connection timeout for stdio-based MCP servers is generally governed by how quickly the server process starts and responds to the initial handshake. For HTTP-based (SSE) transports, the connection timeout follows standard HTTP client behavior, typically around 30 seconds for the initial connection.

The per-tool-call timeout is not a single configurable number you set in one place. It is a combination of the Anthropic API request timeout (which governs the entire turn, including all tool calls within it) and any transport-level timeouts on the MCP connection itself.

This is an important distinction. You cannot set `MCP_TIMEOUT=120` and have it apply globally. The timeout behavior depends on the transport type, the server implementation, and the overall API request window.

## MCP Server Transport Types and Their Timeout Behavior

### Stdio Transport

Most local MCP servers use stdio transport, where Claude Code spawns the server as a child process and communicates over stdin/stdout. Timeout characteristics:

- Process startup time counts against the overall turn budget
- No network latency, but cold starts on heavy servers (those loading large models or databases) can take several seconds
- If the server process crashes or hangs, Claude Code detects the broken pipe and surfaces a tool error

Configuration in your `settings.json`:

```json
{
 "mcpServers": {
 "my-server": {
 "command": "node",
 "args": ["/path/to/server.js"],
 "env": {
 "SERVER_TIMEOUT": "60000"
 }
 }
 }
}
```

The `env` block passes environment variables to the server process. If your MCP server supports its own internal timeout configuration, this is where you set it. The variable name depends entirely on the server implementation. Check the server's documentation for the supported environment variables.

### SSE (Server-Sent Events) Transport

Remote MCP servers often use SSE transport over HTTP. Timeout characteristics:

- Subject to network latency, DNS resolution, and TLS handshake time
- Proxy and firewall configurations can introduce additional delays
- Long-running tool calls is interrupted by intermediate load balancers with their own idle timeouts

```json
{
 "mcpServers": {
 "remote-server": {
 "url": "https://mcp.example.com/sse",
 "env": {
 "API_KEY": "your-key"
 }
 }
 }
}
```

For SSE servers, one of the most common timeout causes is not the server itself but an intermediate proxy or load balancer that closes idle connections. If your tool calls take longer than 60 seconds and pass through a reverse proxy, check that proxy's idle connection timeout.

## Diagnosing MCP Timeout Issues

### Step 1: Identify Which Tool Call Is Timing Out

Run Claude Code with the `--verbose` flag to see tool call activity:

```bash
claude --verbose "Run the data analysis skill"
```

The verbose output shows each tool invocation, which MCP server it targets, and the elapsed time. Look for the tool call that appears immediately before the timeout error.

### Step 2: Test the MCP Server Independently

If you suspect the MCP server is the bottleneck, test it outside of Claude Code. For a local stdio server:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | node /path/to/server.js
```

For an SSE server, check the health endpoint:

```bash
curl -w "Total time: %{time_total}s\n" -s https://mcp.example.com/health
```

If the server takes more than a few seconds to respond to a basic request, the issue is in the server layer, not in Claude Code.

### Step 3: Check for Cold Start Delays

Stdio MCP servers that load large dependencies on startup can introduce a 5-10 second delay on the first invocation. This is particularly common with servers that:

- Load machine learning models into memory
- Initialize database connection pools
- Import heavy Node.js or Python packages

You can measure startup time directly:

```bash
time echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}' | node /path/to/server.js
```

If startup takes more than 3-4 seconds, consider pre-warming the server or reducing its dependency footprint.

## Configuration Strategies That Actually Work

### Set Server-Side Timeouts via Environment Variables

Many MCP servers accept timeout configuration through environment variables. Common patterns I have encountered:

```json
{
 "mcpServers": {
 "database-server": {
 "command": "npx",
 "args": ["-y", "@example/db-mcp-server"],
 "env": {
 "DB_QUERY_TIMEOUT": "30000",
 "DB_CONNECTION_TIMEOUT": "10000"
 }
 }
 }
}
```

These values control the server's internal behavior, which reduces the chance of it hanging indefinitely and consuming the entire API turn budget.

### Scope Down Queries Before They Hit the MCP Server

The most reliable way to avoid MCP timeouts is to reduce the work the server needs to do. If a skill sends a broad query to a database MCP server, the server may scan millions of rows before returning. Restructure the skill prompt to constrain the query:

Instead of "Get all user activity for analysis," use "Get user activity for user ID 12345 in the last 7 days." The MCP server finishes faster, and the overall turn completes within budget.

This is the same principle covered in the [main timeout guide](/claude-code-skill-timeout-error-how-to-increase-the-limit/) for scoping down inputs. It applies equally to MCP tool call payloads.

### Use Retry Logic in Custom MCP Servers

If you maintain your own MCP server, implement retry logic with short timeouts on downstream calls rather than one long timeout:

```typescript
async function queryWithRetry(query: string, maxRetries = 3): Promise<Result> {
 for (let attempt = 1; attempt <= maxRetries; attempt++) {
 try {
 const controller = new AbortController();
 const timeout = setTimeout(() => controller.abort(), 10000);
 const result = await fetch(endpoint, {
 signal: controller.signal,
 method: "POST",
 body: JSON.stringify({ query })
 });
 clearTimeout(timeout);
 return await result.json();
 } catch (err) {
 if (attempt === maxRetries) throw err;
 }
 }
}
```

Three attempts with 10-second timeouts is often more reliable than a single 30-second timeout, because transient failures resolve quickly on retry.

## Common MCP Timeout Scenarios and Fixes

### Puppeteer/Browser MCP Servers

Browser automation servers are among the slowest MCP servers because each tool call may involve page loads, JavaScript execution, and rendering. If you use the [Puppeteer MCP server](/puppeteer-mcp-server-web-automation-workflow/), expect individual tool calls to take 5-15 seconds. Reduce timeout pressure by:

- Navigating to pages and extracting data in separate, focused tool calls
- Avoiding full-page screenshots on complex sites (use element-targeted screenshots instead)
- Setting explicit `waitForSelector` timeouts in the server configuration rather than relying on defaults

### Database MCP Servers

Slow queries are the primary cause of database MCP timeouts. Before assuming the timeout is a Claude Code issue, run the same query directly against your database and check execution time. Add indexes, limit result sets, or paginate large responses.

### GitHub/API MCP Servers

The [GitHub MCP server](/github-mcp-server-advanced-workflow-automation/) and similar API-backed servers depend on third-party API response times. Rate limiting, pagination of large result sets, and API outages all contribute to timeouts. Use the `--verbose` flag to see which specific API call is slow, then scope the request.

## When to Increase API-Level Timeouts

If your MCP server is performing legitimately slow but necessary work (processing a large file, running a complex computation), you may need to adjust expectations rather than configuration. The [Anthropic API enforces its own request timeout](/claude-code-error-rate-limit-429-how-to-handle/) that cannot be extended from the client side. In these cases:

1. Break the work into multiple smaller MCP tool calls
2. Have the MCP server return partial results with a continuation token
3. Pre-compute expensive results and cache them server-side

## Monitoring MCP Server Performance Over Time

For production-grade MCP setups, I recommend adding basic timing instrumentation to your servers. Log the duration of every tool call, and set up alerts when p95 latency exceeds your comfortable threshold. The [MCP server logging guide](/mcp-server-logging-audit-trail-security-guide/) covers audit trail patterns that work well for performance monitoring too.

## Summary

MCP timeouts in Claude Code are almost always caused by slow server responses, not by missing configuration. The effective approach is:

1. Use `--verbose` to identify which tool call is timing out
2. Test the MCP server independently to confirm it is the bottleneck
3. Scope down queries and payloads to reduce server-side work
4. Configure server-side timeouts via environment variables in `settings.json`
5. Implement retry logic in custom servers for transient failures

For general timeout strategies including input scoping and task decomposition, see the [complete timeout troubleshooting guide](/claude-code-skill-timeout-error-how-to-increase-the-limit/). If your timeouts stem from connection instability rather than MCP server slowness, the [connection timeout fix guide](/claude-code-error-connection-timeout-during-task-fix/) covers network-layer solutions.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=claude-code-mcp-timeout-settings-configuration-guide)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Reading

- [Claude Code Skill Timeout Error: How to Increase the Limit](/claude-code-skill-timeout-error-how-to-increase-the-limit/) . The main timeout reference covering all timeout causes and workarounds
- [Top MCP Servers for Claude Code Developers](/top-mcp-servers-for-claude-code-developers-2026/) . Find well-maintained MCP servers with better timeout characteristics
- [Claude Code Error: Connection Timeout During Task Fix](/claude-code-error-connection-timeout-during-task-fix/) . Network-level connection timeout troubleshooting
- [Claude Skills Slow Performance: Speed Up Guide](/claude-skills-slow-performance-speed-up-guide/) . Optimize skill performance before timeouts occur

Related Reading

- [Claude API Timeout Errors: Handling and Retry Guide](/claude-api-timeout-error-handling-retry-guide/)
- [Claude Code Skill Conflicts with MCP Server Resolution Guide](/claude-code-skill-conflicts-with-mcp-server-resolution-guide/)
- [Claude Code Bash Command Not Found in Skill.](/claude-code-bash-command-not-found-in-skill/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


