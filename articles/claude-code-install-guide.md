---
layout: default
title: "Install Claude Code (2026)"
description: "Install Claude Code CLI on macOS, Linux, Windows, WSL, and Docker. Includes npm setup, authentication, and verifying your installation works."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-install-guide/
reviewed: true
categories: [Installation & Setup]
tags: ["claude-code", "install", "npm", "setup", "getting-started"]
geo_optimized: true
---

# Install Claude Code — All Platforms Guide

> **TL;DR:** Install with `npm install -g @anthropic-ai/claude-code`, authenticate with `claude /login` or set `ANTHROPIC_API_KEY`, and verify with `claude --version`.

## The Problem

You want to install Claude Code but are unsure which method works for your platform, or your installation attempt failed with errors like:

```
npm ERR! code EACCES
npm ERR! permission denied
```

Or Claude Code installed but does not start.

## Why This Happens

Claude Code is distributed as an npm package that requires Node.js 18+. Installation issues typically stem from missing Node.js, incorrect npm permissions, or platform-specific PATH configuration.

## The Fix

### Step 1 — Install Node.js (if needed)

Claude Code requires Node.js 18 or later.

**macOS:**

```bash
# Using Homebrew
brew install node

# Verify version (must be 18+)
node --version
```

**Ubuntu / Debian:**

```bash
# Using NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

node --version
```

**Windows:**

```powershell
# Using winget
winget install OpenJS.NodeJS

# Or download from https://nodejs.org
```

**WSL:**

```bash
# Same as Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Step 2 — Install Claude Code

```bash
# Install globally
npm install -g @anthropic-ai/claude-code

# If you get EACCES permission errors:
# Option A: Fix npm permissions
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
npm install -g @anthropic-ai/claude-code

# Option B: Use npx (no global install)
npx @anthropic-ai/claude-code
```

### Step 3 — Authenticate

```bash
# Interactive login (opens browser)
claude /login

# Or set API key directly (works in all environments)
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"
```

### Step 4 — Verify Installation

```bash
# Check version
claude --version

# Check auth status
claude auth status

# Run a quick test
echo "What is 2+2?" | claude --print
```

**Expected output:**

```
Claude Code v2.1.107
Authenticated as: you@example.com
4
```

### Docker Installation

```dockerfile
FROM node:20-slim

RUN npm install -g @anthropic-ai/claude-code

# Set API key at runtime, not in Dockerfile
ENV ANTHROPIC_API_KEY=""

ENTRYPOINT ["claude"]
```

```bash
# Build and run
docker build -t claude-code .
docker run -it -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" claude-code
```

### VS Code Extension

1. Open VS Code
2. Go to Extensions (Cmd+Shift+X / Ctrl+Shift+X)
3. Search "Claude Code"
4. Install the official Anthropic extension
5. The extension uses the CLI under the hood — ensure `claude` is on your PATH

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| `npm ERR! EACCES` | Global npm needs root | Use `~/.npm-global` prefix or `npx` |
| `command not found: claude` | Not on PATH | Add npm global bin to PATH |
| Node version too old | <18 installed | Update Node.js via nvm or package manager |
| Works in terminal, not in VS Code | VS Code uses different PATH | Add npm bin to VS Code terminal profile |
| WSL: claude starts but no output | Shell snapshot issue (v2.1.105) | Update to latest version |

## Prevention

- **Use nvm for Node.js management:** `nvm install 20 && nvm use 20` lets you switch versions without sudo.
- **Pin Claude Code version in CI:** Use `npm install -g @anthropic-ai/claude-code@2.1.107` for reproducible builds.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---


<div class="before-after">

**Without a CLAUDE.md — what actually happens:**

You type: "Add auth to my Next.js app"

Claude generates: `pages/api/auth/[...nextauth].js` — wrong directory (you're on App Router), wrong file extension (you use TypeScript), wrong NextAuth version (v4 patterns, you need v5), session handling that doesn't match your middleware setup.

You spend 40 minutes reverting and rewriting. Claude was "helpful."

**With the Zovo Lifetime CLAUDE.md:**

Same prompt. Claude reads 300 lines of context about YOUR project. Generates: `app/api/auth/[...nextauth]/route.ts` with v5 patterns, your session types, your middleware config, your test patterns.

Works on first run. You commit and move on.

That's the difference a $99 file makes.

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-install-guide)**

</div>

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-install-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

## Related Issues

- [Fix Claude Code Login — Cannot Paste Auth Code](/claude-code-login-paste-fix) — Login issues after installation
- [Claude Code Docker CI/CD Pipeline Integration Guide](/claude-code-docker-ci-cd-pipeline-integration-guide/) — Full Docker configuration
- [Claude Code Command Not Found After Install Troubleshooting](/claude-code-command-not-found-after-install-troubleshooting/) — Browse all installation guides
- [Getting Started Guide](/getting-started/). From zero to productive with Claude Code

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*



- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to --dangerously-skip-permissions and safer alternatives
- [--dangerously-skip-permissions flag](/claude-dangerously-skip-permissions-flag/) — Understanding the --dangerously-skip-permissions CLI flag
## Related Articles

- [How to use Claude Code beginner guide](/how-to-use-claude-code-beginner-guide/) — what to do after installing
- [Claude Code status line guide](/claude-code-statusline-guide/) — understand the status bar after first launch
- [CLAUDE.md best practices](/claude-md-best-practices-definitive-guide/) — first configuration step after install
- [Claude Code Bun Install Setup Guide](/claude-code-bun-install/)


