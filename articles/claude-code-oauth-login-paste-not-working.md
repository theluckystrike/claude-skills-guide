---
sitemap: false
layout: default
title: "Fix Claude Code OAuth Login Paste Not (2026)"
description: "Fix the Claude Code OAuth login paste bug where pasting the auth code into the terminal prompt silently fails. Workaround and root cause explained."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-oauth-login-paste-not-working/
reviewed: true
categories: [troubleshooting]
tags: [claude-code, oauth, authentication, error, troubleshooting]
geo_optimized: true
last_tested: "2026-04-22"
---
# Fix: Claude Code OAuth Login Paste Not Working

## The Error

You run `claude` on a fresh machine, choose **Claude account with subscription**, copy the OAuth authorization URL into a browser, complete the flow, and try to paste the auth code back into the terminal prompt:

```
Paste code here if prompted >
```

Nothing appears. Pressing Enter does nothing or submits an empty value. The login flow cannot complete.

## Quick Fix

Skip the broken login widget entirely using `CLAUDE_CODE_OAUTH_TOKEN`:

```bash
# On a machine where login works (e.g., your Mac)
claude setup-token
# Copy the printed sk-ant-oat01-... token

# On the affected machine
export CLAUDE_CODE_OAUTH_TOKEN="sk-ant-oat01-..."
claude
```

Claude Code recognizes the environment variable, bypasses the login screen, and starts normally.

## What's Happening

The OAuth login screen uses a different TUI input widget than the main Claude Code chat prompt. This widget does not properly handle **bracketed paste** escape sequences that modern terminals send when you paste from clipboard.

When you paste text, your terminal wraps it in escape markers:

```
\x1b[200~<pasted text>\x1b[201~
```

The main chat prompt handles these correctly. The login input widget does not. Each character of the bracketed-paste payload is processed as an individual keystroke, and:

1. The leading `\x1b[200~` is interpreted as an escape-then-command-key sequence and discarded
2. The input reader has length or character validation that rejects the burst of characters
3. Per-keystroke re-renders race with the input buffer and drop characters

This is confirmed by the fact that **typing the auth code one character at a time works** (but is impractical for 100+ character codes), and **pasting into the main chat prompt in the exact same terminal session works fine**.

## Step-by-Step Solution

### Option 1: Environment Variable (Recommended)

```bash
# Step 1: On a working machine, generate a long-lived token
claude setup-token

# Step 2: On the affected machine, set the env var persistently
echo 'export CLAUDE_CODE_OAUTH_TOKEN="sk-ant-oat01-YOUR-TOKEN-HERE"' >> ~/.bashrc
source ~/.bashrc

# Step 3: Verify
claude --version
```

### Option 2: Copy Credentials File

```bash
# On a working machine, after successful login
cat ~/.claude/.credentials.json

# Copy the JSON content to the affected machine
mkdir -p ~/.claude
# Paste the credentials JSON into ~/.claude/.credentials.json
```

### Option 3: Type the Code Manually

If you have no other machine available, you can type the auth code character by character. The code from the OAuth callback URL looks like:

```
https://platform.claude.com/oauth/callback?code=AUTH_CODE_HERE
```

Copy just the `code` parameter value. Type it into the prompt one character at a time. This works but is tedious for long codes.

### Option 4: Use an API Key Instead

If you have API access via console.anthropic.com:

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
claude
```

This bypasses OAuth entirely and uses direct API authentication.

## Prevention

- When setting up Claude Code on remote or headless servers, use `CLAUDE_CODE_OAUTH_TOKEN` from the start rather than relying on the interactive login flow
- Add the token export to your shell profile (`~/.bashrc`, `~/.zshrc`) so it persists across sessions
- For CI/CD environments, store the token as a secret and inject it via environment variable

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-oauth-login-paste-not-working)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

## Related Issues

- [Fix: Claude Code Headless Linux Auth Blocked by Cloudflare](/claude-code-headless-linux-auth)
- [Fix: Claude Code Headless Linux Auth](/claude-code-headless-linux-auth/)
- [Fix: Claude API Error 401 Unauthorized](/claude-api-error-401-fix/)

## Tools That Help

If you are debugging authentication issues across multiple development environments, a browser extension dev tool can help inspect OAuth callback URLs and extract auth codes from redirect chains.


## Common Questions

### What causes fix claude code oauth login paste not issues?

Common causes include misconfigured settings, outdated dependencies, and environment conflicts. Check your project configuration and ensure all dependencies are up to date.

### How do I prevent this error from recurring?

Set up automated checks in your development workflow. Use Claude Code's built-in validation tools to catch configuration issues before they reach production.

### Does this fix work on all operating systems?

The core fix applies to macOS, Linux, and Windows. Some path-related adjustments may be needed depending on your OS. Check the platform-specific notes in the guide above.

## Related Resources

- [Claude Code CLAUDE.md Not Found Fix](/claude-code-claude-md-not-found-parent-directories-fix/)
- [Fix Claude Code Not Understanding](/claude-code-doesnt-understand-codebase-fix-2026/)
- [Claude Code .env File Not Loaded — Fix](/claude-code-env-file-not-loaded-project-scope-fix/)
