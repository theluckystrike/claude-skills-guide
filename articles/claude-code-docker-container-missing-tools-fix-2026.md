---
title: "Docker Container Missing Tools Fix — Fix (2026)"
permalink: /claude-code-docker-container-missing-tools-fix-2026/
description: "Fix Docker container missing tools needed by Claude Code. Install git, curl, and build essentials in your Dockerfile to enable full CLI functionality."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: spawn git ENOENT
  'git' command not found in Docker container
  Claude Code requires git for version control operations
  Also missing: curl, jq, ripgrep — used by Claude Code tools
```

This appears when Claude Code runs inside a Docker container that lacks common system tools it depends on.

## The Fix

```dockerfile
# Add to your Dockerfile:
RUN apt-get update && apt-get install -y \
  git \
  curl \
  jq \
  ripgrep \
  && rm -rf /var/lib/apt/lists/*
```

1. Add the missing tools to your Dockerfile.
2. Rebuild the container: `docker build -t my-app .`.
3. Restart Claude Code inside the container.

## Why This Happens

Minimal Docker base images (like `node:20-slim` or `alpine`) include only the bare essentials to reduce image size. Claude Code assumes common developer tools are available: `git` for version control, `curl` for network requests, `jq` for JSON processing, and `ripgrep` for fast file search. When these are missing, Claude Code's Bash tool calls fail with "command not found" errors.

## If That Doesn't Work

For Alpine-based images, use `apk` instead of `apt-get`:

```dockerfile
RUN apk add --no-cache git curl jq ripgrep bash
```

Use a full Node.js image instead of slim:

```dockerfile
FROM node:20
# Full image includes git, curl, and other common tools
```

Install Claude Code itself inside the container:

```dockerfile
FROM node:20
RUN npm install -g @anthropic-ai/claude-code
RUN apt-get update && apt-get install -y ripgrep jq && rm -rf /var/lib/apt/lists/*
```

Check which tools are missing:

```bash
docker exec -it my-container bash -c "which git curl jq rg"
```

## Prevention

```markdown
# CLAUDE.md rule
When running in Docker, ensure the container has: git, curl, jq, ripgrep, and bash installed. Use the full node:20 base image, not node:20-slim or alpine, for best Claude Code compatibility.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `fatal: not a git repository`
- `error: failed to push some refs`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.
