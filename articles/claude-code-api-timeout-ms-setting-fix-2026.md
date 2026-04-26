---
layout: default
title: "Claude Code Request Timed Out 120000ms — Fix (2026)"
permalink: /claude-code-api-timeout-ms-setting-fix-2026/
date: 2026-04-20
description: "Increase the api_timeout setting to 300000ms with claude config set. Prevents request timeout failures on complex multi-file code operations."
last_tested: "2026-04-21"
---

## The Error

```
Request timed out after 120000ms
```

## The Fix

```bash
# Set a longer timeout in your Claude Code settings
claude config set api_timeout 300000
```

## Why This Works

The default 120-second timeout is insufficient for complex multi-file operations or when the API is under heavy load. Setting the timeout to 300 seconds (5 minutes) gives the server enough time to process large context windows and generate lengthy responses without the client disconnecting prematurely.

## If That Doesn't Work

```bash
# Check if a proxy or VPN is adding latency
curl -o /dev/null -s -w "%{time_total}\n" https://api.anthropic.com/v1/messages
# If latency exceeds 5s, bypass proxy for Anthropic endpoints
export NO_PROXY="api.anthropic.com"
```

Network middleware (corporate proxies, VPNs, or DNS filtering) can add 10-30 seconds of overhead per request. If your base latency to Anthropic is over 5 seconds, route API traffic outside the proxy. Also confirm the timeout was saved correctly by running `claude config get api_timeout` — if it still shows the default value, you may have a read-only config file or a workspace override taking precedence.

## Prevention

Add to your CLAUDE.md:
```
API timeout is set to 300000ms. If operations on files larger than 5000 lines are needed, break them into smaller chunks rather than processing in a single request.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`
- `ESOCKETTIMEDOUT`
- `ECONNREFUSED: connection refused through proxy`
- `Error: unable to verify the first certificate`

## Frequently Asked Questions

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.

### Can network latency cause timeouts?

Yes. Corporate proxies, VPNs, and DNS filtering services add round-trip latency. Measure your baseline latency with `curl -o /dev/null -s -w '%{time_total}' https://api.anthropic.com/v1/messages`. If it exceeds 5 seconds, route API traffic outside the proxy.

### Do timeouts consume API credits?

Partially. If the server began processing your request before the client timed out, the input tokens are consumed even though you never received a response. Long timeouts reduce wasted credits by allowing the response to complete.

### How do I configure Claude Code to use a corporate proxy?

Set the `HTTPS_PROXY` environment variable: `export HTTPS_PROXY=http://proxy.corp.com:8080`. Claude Code respects standard proxy environment variables. Add this to your shell profile for persistence.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
