---
layout: default
title: "DNS Resolution Timeout Error — Fix (2026)"
permalink: /claude-code-dns-resolution-timeout-fix-2026/
date: 2026-04-20
description: "DNS Resolution Timeout Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
---

## The Error

```
Error: getaddrinfo ETIMEOUT api.anthropic.com
  code: 'ETIMEOUT'
  syscall: 'getaddrinfo'
  hostname: 'api.anthropic.com'
```

This error occurs when your system's DNS resolver cannot resolve api.anthropic.com within the timeout period. No TCP connection is attempted because the hostname cannot be converted to an IP address.

## The Fix

1. Test DNS resolution directly:

```bash
nslookup api.anthropic.com
dig api.anthropic.com
```

2. Switch to a reliable public DNS:

```bash
# macOS — set DNS to Cloudflare
sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1
```

3. Flush the DNS cache:

```bash
# macOS
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

4. Test Claude Code:

```bash
claude "hello"
```

## Why This Happens

DNS resolution fails when: your DNS server is down or overloaded, your corporate DNS blocks external domains, the DNS cache has a stale negative entry, or your network has no internet access. Corporate DNS servers often have longer timeouts and may block certain domains. Node.js uses the system DNS resolver, so system-level DNS issues directly affect Claude Code.

## If That Doesn't Work

- Add a manual hosts entry as a temporary workaround:

```bash
# First, resolve the IP from a working machine:
dig +short api.anthropic.com
# Then add to hosts:
echo "104.18.XX.XX api.anthropic.com" | sudo tee -a /etc/hosts
```

- Check if a VPN or firewall is intercepting DNS:

```bash
scutil --dns | head -20
```

- Try Google's DNS as alternative:

```bash
sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# DNS Configuration
- Use reliable DNS: 1.1.1.1 (Cloudflare) or 8.8.8.8 (Google).
- If DNS fails, flush cache: sudo dscacheutil -flushcache
- Test DNS before debugging API issues: dig api.anthropic.com
```

## See Also

- [Garbage Collection Pause Causing Timeout Fix](/claude-code-gc-pause-causing-timeout-fix-2026/)

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

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Monorepo Workspace Package Resolution](/claude-code-monorepo-workspace-package-resolution-fix-2026/)
- [CLAUDE.md Conflict Resolution](/claude-md-conflict-resolution/)
- [ESM vs CJS Module Resolution Failure — Fix (2026)](/claude-code-esm-vs-cjs-module-resolution-fix-2026/)
- [Claude Code Merge Conflict Resolution](/claude-code-merge-conflict-resolution-guide/)

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
