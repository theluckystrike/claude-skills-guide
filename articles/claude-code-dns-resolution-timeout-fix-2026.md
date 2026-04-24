---
title: "DNS Resolution Timeout Error — Fix"
permalink: /claude-code-dns-resolution-timeout-fix-2026/
description: "Fix DNS resolution timeout for api.anthropic.com. Switch to reliable DNS (1.1.1.1 or 8.8.8.8) and flush DNS cache."
last_tested: "2026-04-22"
render_with_liquid: false
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
