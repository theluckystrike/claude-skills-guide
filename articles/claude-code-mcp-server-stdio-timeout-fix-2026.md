---
title: "MCP Server stdio Timeout 30000ms — Fix (2026)"
permalink: /claude-code-mcp-server-stdio-timeout-fix-2026/
description: "Increase timeout to 60000ms with claude mcp update command for your server entry. Fixes stdio transport initialization hangs on slow MCP servers."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
MCP server did not respond within 30000ms (stdio transport)
```

## The Fix

```bash
# Edit your Claude Code MCP config to increase the server timeout
claude mcp update <server-name> --timeout 60000
```

## Why This Works

MCP servers using stdio transport must complete their initialization handshake within the timeout window. Servers that load large indexes, connect to databases, or compile on first run regularly exceed the 30-second default. Doubling the timeout to 60 seconds accommodates slower startup without masking genuinely broken servers.

## If That Doesn't Work

```bash
# Test if the MCP server starts correctly outside Claude Code
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}' | npx your-mcp-server
# If it hangs, the server itself is broken — check its logs
cat ~/.config/claude-code/mcp-logs/<server-name>.log
```

If the server never responds to the initialize message, the binary path or arguments in your config are wrong. Verify the command runs standalone in your terminal. For Node-based MCP servers, confirm that the installed version matches the one specified in your config — version mismatches after a global npm update frequently cause silent startup failures.

## Prevention

Add to your CLAUDE.md:
```
MCP servers must respond to initialize within 60 seconds. Any server requiring database or network access at startup should implement a lazy connection pattern to avoid blocking the stdio handshake.
```
