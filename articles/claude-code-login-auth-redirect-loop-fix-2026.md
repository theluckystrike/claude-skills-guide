---
layout: default
title: "Login Auth Redirect Loop Error — Fix (2026)"
permalink: /claude-code-login-auth-redirect-loop-fix-2026/
date: 2026-04-20
description: "Fix Claude Code login redirect loop. Clear auth cache, reset OAuth state, and re-authenticate with claude login command."
last_tested: "2026-04-22"
---

## The Error

```
Waiting for authentication...
Opening browser: https://console.anthropic.com/oauth/authorize?...
Error: Authentication callback not received. Timed out after 120 seconds.
Retrying... (attempt 3/3)
Error: Failed to authenticate. Please try again.
```

This error occurs when Claude Code's browser-based OAuth flow loops without completing. The browser opens, you authenticate, but the callback never reaches Claude Code.

## The Fix

1. Clear the auth cache:

```bash
rm -rf ~/.claude/auth.json
rm -rf ~/.claude/.credentials
```

2. Kill any existing Claude Code processes:

```bash
pkill -f "claude" 2>/dev/null
```

3. Re-authenticate:

```bash
claude login
```

4. If the browser does not open, manually copy the URL from the terminal and paste it in your browser.

## Why This Happens

The OAuth flow starts a temporary local HTTP server to receive the callback. The loop occurs when: a firewall blocks localhost connections, another process occupies the callback port, the browser redirects to an incorrect callback URL, or stale auth tokens confuse the handshake. Corporate SSO configurations can also interfere with the OAuth redirect chain.

## If That Doesn't Work

- Use API key authentication instead of OAuth:

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-your-key"
claude "test"
```

- Try a different port for the callback:

```bash
claude login --port 9876
```

- Check if localhost is resolving correctly:

```bash
curl -s http://localhost:9876 2>&1
# Should show "connection refused" (port not in use), not a timeout
```

- Disable any VPN that might intercept localhost traffic.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Authentication
- Prefer API key auth (ANTHROPIC_API_KEY) over OAuth for CI/CD and headless.
- If OAuth loops, clear ~/.claude/auth.json and retry.
- Ensure no firewall rules block localhost on ports 9000-9999.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`
- `ESOCKETTIMEDOUT`
- `ECONNRESET: connection reset by peer`
- `ECONNREFUSED: connection refused`

## Frequently Asked Questions

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.

### Can network latency cause timeouts?

Yes. Corporate proxies, VPNs, and DNS filtering services add round-trip latency. Measure your baseline latency with `curl -o /dev/null -s -w '%{time_total}' https://api.anthropic.com/v1/messages`. If it exceeds 5 seconds, route API traffic outside the proxy.

### Do timeouts consume API credits?

Partially. If the server began processing your request before the client timed out, the input tokens are consumed even though you never received a response. Long timeouts reduce wasted credits by allowing the response to complete.

### Why does Claude Code lose connection during long operations?

Long-running operations can exceed keep-alive timeouts on intermediate proxies and load balancers. If a proxy closes an idle connection after 60 seconds and Claude Code's request takes 90 seconds, the connection is severed before the response arrives.


## Related Guides

- [Claude Code Stuck in Loop Repeating](/claude-code-stuck-in-loop-repeating-same-output-fix/)
- [The Retry Loop Tax](/retry-loop-tax-error-handling-token-cost/)
- [Fix: Claude Code Image 400 Error Loop](/claude-code-image-could-not-process-400/)
- [Fix Claude Code Infinite Loop in Skills](/how-to-fix-claude-skill-infinite-loop-issue/)

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
