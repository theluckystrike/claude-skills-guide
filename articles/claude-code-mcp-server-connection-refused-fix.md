---
title: "Claude Code MCP Server Connection Refused — Fix (2026)"
description: "Fix Claude Code MCP server connection refused error. Verify server process is running and port config matches. Step-by-step solution."
permalink: /claude-code-mcp-server-connection-refused-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error: MCP server "my-server" connection refused
  connect ECONNREFUSED 127.0.0.1:3100
  at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1595:16)

# Or:
MCP Error: Failed to connect to server "my-server"
  Timeout after 30000ms waiting for server initialization
  Server process exited with code 1

# Or:
Error: MCP server "my-server" - spawn npx ENOENT
```

## The Fix

1. **Verify the MCP server process starts correctly outside Claude Code**

```bash
# Check the server command from your config
cat ~/.claude/settings.json | python3 -c "
import sys, json
data = json.load(sys.stdin)
servers = data.get('mcpServers', {})
for name, config in servers.items():
    print(f'{name}: {config.get(\"command\")} {\" \".join(config.get(\"args\", []))}')
"

# Try starting the server manually
npx @modelcontextprotocol/server-filesystem /Users/you/projects
```

2. **Fix the MCP server configuration**

```bash
# Ensure the config uses absolute paths and correct syntax
cat > ~/.claude/settings.json << 'ENDJSON'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/you/projects"],
      "env": {}
    }
  }
}
ENDJSON
```

3. **Verify the fix:**

```bash
# Restart Claude Code and check MCP status
claude -p "/mcp" --trust --yes
# Expected: Lists connected MCP servers with status "connected"
```

## Why This Happens

MCP (Model Context Protocol) servers are external processes that Claude Code spawns and communicates with over stdio or HTTP. Connection refused means either the server process failed to start (wrong command path, missing dependency, bad arguments), it started but exited immediately (crash on initialization), or it's listening on a different port/transport than configured. The most common cause is the `command` field pointing to a binary not in PATH — `npx` works on most systems but requires Node.js to be installed.

## If That Doesn't Work

- **Alternative 1:** Use absolute paths for the command: `"command": "/usr/local/bin/npx"` instead of just `"npx"`
- **Alternative 2:** Install the MCP server globally first: `npm install -g @modelcontextprotocol/server-filesystem` then use the global binary path
- **Check:** Run the server command manually in a terminal and watch for startup errors — check stderr output carefully

## Prevention

Add to your `CLAUDE.md`:
```markdown
Test MCP server commands manually before adding to settings.json. Use absolute paths for command binaries. Include -y flag with npx to auto-confirm installs. Check Claude Code MCP status after config changes with the /mcp command.
```

**Related articles:** [MCP Server Setup Guide](/claude-code-mcp-server-setup/), [MCP Server Connection Closed Fix](/claude-code-mcp-server-connection-closed-fix/), [ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)
