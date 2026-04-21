---
title: "Login Auth Redirect Loop Error — Fix (2026)"
permalink: /claude-code-login-auth-redirect-loop-fix-2026/
description: "Fix Claude Code login redirect loop. Clear auth cache, reset OAuth state, and re-authenticate with claude login command."
last_tested: "2026-04-22"
render_with_liquid: false
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
