---
layout: default
title: "Install Claude Code — All Platforms Guide"
description: "Install Claude Code CLI on macOS, Linux, Windows, WSL, and Docker. Includes npm setup, authentication, and verifying your installation works."
date: 2026-04-14
last_modified_at: 2026-04-14
author: "Claude Code Guides"
permalink: /claude-code-install-guide/
reviewed: true
categories: [Installation & Setup]
tags: ["claude-code", "install", "npm", "setup", "getting-started"]
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

## Related Issues

- [Fix Claude Code Login — Cannot Paste Auth Code](/claude-code-login-paste-fix) — Login issues after installation
- [Claude Code Docker Setup Guide](/claude-code-docker-setup) — Full Docker configuration
- [Hub: Installation & Setup](/claude-code-installation-hub) — Browse all installation guides

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*
