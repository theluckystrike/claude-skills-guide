---
layout: default
title: "Fix: Claude Code Auth Fails on Headless"
description: "Claude Code OAuth token refresh blocked by Cloudflare WAF on headless Linux. Fix the permanent lockout after 1 hour with these workarounds."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-headless-linux-auth/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-code, auth, oauth, headless, linux, cloudflare]
geo_optimized: true
---

# Fix: Claude Code Auth Fails on Headless Linux Server

## The Error

After authenticating Claude Code on a headless Linux server (no display server, no browser), everything works for about an hour. Then:

```text
HTTP 403 from Cloudflare WAF on token refresh:

POST https://platform.claude.com/v1/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=<token>&client_id=9d1c250a-e61b-44d9-88ed-5944d1962f5e

Response: 403 Forbidden (Cloudflare)
Subsequent retries: 429 Too Many Requests
```

Claude Code is permanently locked out until you manually re-authenticate, which itself requires the broken browser-based flow on a headless system.

## Quick Fix

Use an API key to bypass OAuth entirely:

```bash
# On the headless server
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"
claude
```

When `ANTHROPIC_API_KEY` is set, Claude Code uses it instead of your subscription, bypassing the browser-based OAuth flow completely. Get an API key from console.anthropic.com.

## What Causes This

Claude Code's OAuth tokens expire after approximately 1 hour (confirmed via the `expiresAt` field in `~/.claude/.credentials.json`). When the CLI attempts to refresh the token, it sends a POST request to `https://platform.claude.com/v1/oauth/token`.

Cloudflare's Web Application Firewall (WAF) classifies this request as automated bot traffic when it originates from a headless Linux server. The key difference from desktop environments: there is no browser context, no cookies, no JavaScript execution environment that would pass Cloudflare's bot detection heuristics.

The failure chain:

1. Access token expires (~1 hour after auth)
2. CLI sends refresh request to OAuth endpoint
3. Cloudflare WAF blocks the request (HTTP 403)
4. CLI retries, hitting rate limits (HTTP 429)
5. All subsequent operations fail
6. Recovery requires full re-authentication, which needs a browser

## Full Solution

### Option 1: API Key Authentication (Most Reliable)

The `ANTHROPIC_API_KEY` environment variable bypasses OAuth entirely. When set, Claude Code uses API key authentication instead of your subscription, even if you are logged in.

```bash
# 1. Get an API key from console.anthropic.com
# Navigate to: Settings > API Keys > Create Key

# 2. Set it on your headless server
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-YOUR-KEY"' >> ~/.bashrc
source ~/.bashrc

# 3. Verify it works
claude -p "hello" --bare
```

For non-interactive use with `-p`, the API key is always used when present. For interactive sessions, Claude Code prompts you to confirm using the key once before it overrides your subscription.

### Option 2: Pre-Generated OAuth Token

On a machine with a browser, authenticate with Claude Code and copy the token for use on the headless server:

```bash
# On the headless server:
export CLAUDE_CODE_OAUTH_TOKEN="your-token-here"

# Add to your shell profile for persistence:
echo 'export CLAUDE_CODE_OAUTH_TOKEN="your-token-here"' >> ~/.bashrc
```

### Option 3: Credential File Transfer

```bash
# On a machine where auth works:
cat ~/.claude/.credentials.json

# Copy the entire JSON to the headless server:
mkdir -p ~/.claude
cat > ~/.claude/.credentials.json << 'CRED'
{paste the JSON content here}
CRED

# Note: This token will expire after ~1 hour and the same
# refresh problem will occur. You will need to repeat this
# process when the token expires.
```

### Option 4: Automate Token Refresh from Desktop

If you frequently work on headless servers, set up a script on your desktop machine that refreshes the token and copies it:

```bash
#!/bin/bash
# refresh-claude-token.sh
# Run this on your desktop machine with a browser

# Extract the current token from credentials
TOKEN=$(cat ~/.claude/.credentials.json | python3 -c "
import json, sys
creds = json.load(sys.stdin)
print(creds.get('oauthToken', ''))
")

# Copy to headless server
ssh user@headless-server "
 mkdir -p ~/.claude
 echo 'export CLAUDE_CODE_OAUTH_TOKEN=\"$TOKEN\"' > ~/.claude/env
"
```

## Prevention

- **Default to API keys on headless servers** -- add `ANTHROPIC_API_KEY` to your server provisioning scripts or dotfiles
- **For CI/CD pipelines**, store the API key as a GitHub Actions secret or equivalent and inject via environment variable
- **Never rely on interactive OAuth** for unattended or headless environments
- **Monitor token expiry**: check `~/.claude/.credentials.json` for `expiresAt` timestamps if you must use OAuth

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-headless-linux-auth)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

## Related Guides

- [Fix: Claude Code OAuth Login Paste Not Working](/claude-code-oauth-login-paste-not-working/)
- [Claude Code Install Guide](/claude-code-install-guide/)
- [Fix: Claude API Error 400 Invalid Request](/claude-api-error-400-invalidrequesterror-explained/)
- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)



## Related Articles

- [Claude Code for Ory Auth — Workflow Guide](/claude-code-for-ory-auth-workflow-guide/)
- [Claude Code for Lucia Auth — Workflow Guide](/claude-code-for-lucia-auth-workflow-workflow-guide/)
- [Claude Code for Hanko Auth — Workflow Guide](/claude-code-for-hanko-auth-workflow-guide/)
- [Linux AppArmor Restricting Access Fix](/claude-code-linux-apparmor-restricting-access-fix-2026/)
