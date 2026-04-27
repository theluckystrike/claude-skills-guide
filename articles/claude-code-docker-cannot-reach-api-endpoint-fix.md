---
sitemap: false
layout: default
title: "Claude Code Docker Cannot Reach API (2026)"
description: "Fix Claude Code Docker container cannot reach API endpoint. Configure DNS and network settings for containers. Step-by-step solution."
permalink: /claude-code-docker-cannot-reach-api-endpoint-fix/
date: 2026-04-20
last_tested: "2026-04-21"
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

- [Claude Code for Docker Image Publishing](/claude-code-for-docker-image-publishing-workflow-guide/)
- [Claude Code for Colima Docker](/claude-code-for-colima-docker-workflow-guide/)
- [Claude Code Docker Compose Development](/claude-code-docker-compose-development-workflow/)
- [Claude Code Docker Compose Test Setup](/claude-code-docker-compose-test-setup-guide/)

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
