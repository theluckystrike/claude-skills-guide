---
title: "MCP Server stdio Timeout 30000ms — Fix"
permalink: /claude-code-mcp-server-stdio-timeout-fix-2026/
description: "Increase timeout to 60000ms with claude mcp update command for your server entry. Fixes stdio transport initialization hangs on slow MCP servers."
last_tested: "2026-04-21"
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

## See Also

- [Garbage Collection Pause Causing Timeout Fix](/claude-code-gc-pause-causing-timeout-fix-2026/)
- [DNS Resolution Timeout Error — Fix (2026)](/claude-code-dns-resolution-timeout-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.


## Related Guides

- [Set Up Django MCP Server for Claude](/claude-code-django-mcp/)
- [Claude Code vLLM Inference Server](/claude-code-vllm-inference-server-deployment-workflow/)
- [Claude Code GCP MCP Server Setup](/claude-code-gcp-mcp/)
- [How to Use Telegram MCP Server](/telegram-mcp-server-bot-automation-workflow/)

## Timeout Configuration Reference

Claude Code has several timeout settings that interact with each other:

| Setting | Default | Controls | How to Change |
|---------|---------|----------|---------------|
| Bash timeout | 120s | Maximum time for a single bash command | `CLAUDE_CODE_BASH_TIMEOUT=600` |
| API timeout | 300s | Maximum time waiting for API response | Network-level setting |
| Session timeout | None | Auto-close after inactivity | Not currently configurable |
| MCP server init | 30s | Time allowed for MCP server startup | Set in settings.json |

## Diagnosing Slow Operations

When Claude Code appears to hang, determine which component is slow:

**Step 1: Check CPU and memory.** Run `top -l 1 | grep -E "node|claude"` (macOS) or `top -bn1 | grep -E "node|claude"` (Linux). High CPU suggests active computation. High memory (over 1GB) suggests the conversation context is too large.

**Step 2: Check network connectivity.** Run `curl -s -o /dev/null -w "%{time_total}" https://api.anthropic.com/v1/messages`. Response times over 2 seconds indicate network issues between you and the API.

**Step 3: Check disk I/O.** Run `iostat 1 3` to see if disk is a bottleneck. Claude Code performs significant file reads when scanning large projects. An SSD reduces file scanning from minutes to seconds.

**Step 4: Reduce context size.** If the session has been running for many turns, accumulated context can slow API responses. Use `/clear` to reset the conversation and start fresh with a smaller context window.
