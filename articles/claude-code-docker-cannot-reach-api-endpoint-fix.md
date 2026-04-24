---
title: "Claude Code Docker Cannot Reach API"
description: "Fix Claude Code Docker container cannot reach API endpoint. Configure DNS and network settings for containers. Step-by-step solution."
permalink: /claude-code-docker-cannot-reach-api-endpoint-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error: getaddrinfo ENOTFOUND api.anthropic.com
    at GetAddrInfoReqWrap.onlookup [as oncomplete] (node:dns:108:26)

# Or:
FetchError: request to https://api.anthropic.com/v1/messages failed,
  reason: connect ENETUNREACH 2606:4700::6812:50 - Local (:::0)

# Or:
curl: (6) Could not resolve host: api.anthropic.com
```

## The Fix

1. **Use host networking or configure DNS in your container**

```bash
# Option A: Use host networking (simplest)
docker run --network host \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v $(pwd):/workspace \
  your-image claude -p "Hello"

# Option B: Specify DNS servers explicitly
docker run --dns 8.8.8.8 --dns 8.8.4.4 \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v $(pwd):/workspace \
  your-image claude -p "Hello"
```

2. **For docker-compose, add DNS config**

```yaml
# docker-compose.yml
services:
  claude:
    image: your-image
    dns:
      - 8.8.8.8
      - 8.8.4.4
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    volumes:
      - .:/workspace
```

3. **Verify the fix:**

```bash
docker run --rm --dns 8.8.8.8 node:20-slim \
  sh -c "node -e \"fetch('https://api.anthropic.com').then(r => console.log('Reachable:', r.status))\""
# Expected: Reachable: 405 (Method Not Allowed is fine — it means the API is reachable)
```

## Why This Happens

Docker containers use an internal DNS resolver that forwards to the host's DNS. When the host uses a local DNS resolver (like `systemd-resolved` on Linux at `127.0.0.53`), the container cannot reach it because `127.0.0.53` inside the container refers to the container itself, not the host. On macOS with Docker Desktop, the DNS forwarding usually works but can fail when the host's VPN or firewall blocks Docker's virtual network. IPv6 resolution failures (ENETUNREACH) happen when the container has no IPv6 route but DNS returns AAAA records first.

## If That Doesn't Work

- **Alternative 1:** Add the API IP to `/etc/hosts` inside the container: `echo "104.18.0.1 api.anthropic.com" >> /etc/hosts`
- **Alternative 2:** Use `--add-host host.docker.internal:host-gateway` and route through a host-side proxy
- **Check:** Run `docker run --rm alpine nslookup api.anthropic.com` to test DNS resolution inside a container

## Prevention

Add to your `CLAUDE.md`:
```markdown
Always specify DNS servers (8.8.8.8, 8.8.4.4) in Docker configurations using Claude Code. Test API connectivity with curl before running long Claude Code sessions in containers. Use --network host when running on Linux for simplest networking.
```

**Related articles:** [Docker Build Failed Fix](/claude-code-docker-build-failed-fix/), [Docker Container Setup](/claude-code-with-docker-containers-guide/), [Docker Networking Troubleshooting](/claude-code-docker-networking-troubleshooting-guide/)
