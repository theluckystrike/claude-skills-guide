---
layout: default
title: "Claude Code MCP Server Connection (2026)"
description: "Fix Claude Code MCP server connection refused error. Verify server process is running and port config matches. Step-by-step solution."
permalink: /claude-code-mcp-server-connection-refused-fix/
date: 2026-04-20
last_tested: "2026-04-21"
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


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Fix WebSocket Connection Failures](/claude-code-websocket-connection-failed-fix/)
- [Connection Reset by Peer Error — Fix](/claude-code-connection-reset-by-peer-fix-2026/)
- [Claude Code VS Code Connection Lost — Fix (2026)](/claude-code-vscode-connection-lost-fix-2026/)
- [Anthropic SDK Streaming Connection](/anthropic-sdk-streaming-connection-dropped-fix/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
