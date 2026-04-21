---
title: "Node 18+ Required Version Error — Fix (2026)"
permalink: /claude-code-node-version-18-required-fix-2026/
description: "Fix 'Node.js 18 or higher required' error. Upgrade Node with nvm install 22 or update your system Node installation."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Claude Code requires Node.js 18 or higher. Current version: v16.20.2
Please upgrade Node.js: https://nodejs.org/
```

This error appears when you try to run Claude Code on a Node.js version older than 18. Claude Code uses ES module features and APIs that require Node 18+.

## The Fix

1. Check your current Node version:

```bash
node --version
```

2. Upgrade with nvm (recommended):

```bash
nvm install 22
nvm use 22
nvm alias default 22
```

3. Or upgrade with Homebrew on macOS:

```bash
brew update && brew upgrade node
```

4. Reinstall Claude Code on the new Node version:

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

## Why This Happens

Claude Code depends on Node.js features introduced in v18: native fetch API, structuredClone, stable AbortController, and ES module import assertions. These features do not exist in Node 16 or earlier. Many Linux distributions and Docker images ship with older Node versions by default.

## If That Doesn't Work

- If nvm is not installed:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
exec $SHELL
nvm install 22
```

- If using Docker, update your base image:

```dockerfile
FROM node:22-slim
RUN npm install -g @anthropic-ai/claude-code
```

- If system node is managed by your OS package manager and cannot be changed, use nvm to install a parallel version that takes priority in PATH.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Node.js Version
- Minimum: Node 18. Recommended: Node 22 LTS.
- Add .nvmrc file to project root: echo "22" > .nvmrc
- In CI, always specify: node-version: '22' in GitHub Actions.
```
