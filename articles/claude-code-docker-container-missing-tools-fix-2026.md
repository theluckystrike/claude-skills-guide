---
title: "Docker Container Missing Tools — Fix"
permalink: /claude-code-docker-container-missing-tools-fix-2026/
description: "Fix Docker container missing tools needed by Claude Code. Install git, curl, and build essentials in your Dockerfile to enable full CLI functionality."
last_tested: "2026-04-22"
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


## Related Guides

- [Fix: Anthropic SDK MCP Tools Get Empty](/anthropic-sdk-mcp-empty-arguments-bug/)
- [AI Coding Tools Governance Policy](/ai-coding-tools-governance-policy-for-enterprises/)
- [Pruning Unused Claude Tools Saves Real](/pruning-unused-claude-tools-saves-money/)
- [Best Claude Code Security Tools (2026)](/best-claude-code-security-tools-2026/)

## Docker Best Practices for Claude Code Projects

When using Claude Code to manage Dockerized applications, these patterns prevent common issues:

**Layer ordering matters for cache efficiency.** Docker layers build sequentially and cache invalidates forward. Place rarely-changing layers (OS packages, runtime) before frequently-changing layers (application code). This single optimization can reduce build times from minutes to seconds.

**Multi-stage builds reduce image size.** Use separate stages for building (includes dev dependencies, compilers) and running (only production dependencies and compiled output). A typical Node.js application goes from 1.2GB (single stage) to 150MB (multi-stage).

**Use .dockerignore aggressively.** Exclude `node_modules`, `.git`, `*.md`, `.env`, `coverage/`, and `dist/` from the build context. A 500MB build context that takes 10 seconds to transfer can be reduced to 5MB in under a second.

## Troubleshooting Docker Builds in Claude Code

When Claude Code generates a Dockerfile that fails to build:

1. **Read the build output carefully.** The error line number in the Dockerfile tells you exactly which instruction failed. Claude Code sometimes generates commands that work on your host but fail inside the container due to missing packages.

2. **Check the base image.** Ensure the base image includes the tools your build needs. `node:22-slim` does not include `git`, `python3`, or build tools. Use `node:22` (full) for build stages that need native compilation.

3. **Verify network access inside the build.** Corporate proxies and VPNs may block network access during `docker build`. Pass proxy settings as build args: `docker build --build-arg HTTP_PROXY=$HTTP_PROXY .`
