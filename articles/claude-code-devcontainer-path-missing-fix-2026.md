---
layout: default
title: "Devcontainer Claude Code Path Missing — Fix (2026)"
permalink: /claude-code-devcontainer-path-missing-fix-2026/
date: 2026-04-20
description: "Fix Claude Code not found in devcontainer PATH. Add Claude Code install to devcontainer.json features or postCreateCommand for container access."
last_tested: "2026-04-22"
---

## The Error

```
bash: claude: command not found
  Claude Code is not installed inside the devcontainer
  /usr/local/bin/claude does not exist in container filesystem
  Host-installed Claude Code is not accessible from devcontainer
```

This appears when you try to run Claude Code inside a VS Code devcontainer but it is only installed on the host machine, not inside the container.

## The Fix

```json
// .devcontainer/devcontainer.json
{
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code",
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

1. Add Claude Code installation to your `devcontainer.json` postCreateCommand.
2. Forward the API key from your host environment using `remoteEnv`.
3. Rebuild the devcontainer: `Cmd+Shift+P > Dev Containers: Rebuild Container`.

## Why This Happens

VS Code devcontainers run in isolated Docker containers with their own filesystem and PATH. Globally installed npm packages on the host (like Claude Code) do not exist inside the container. The container has its own Node.js and npm installation, which starts empty. The `claude` binary is on the host at `~/.npm-global/bin/claude`, but the container has no access to the host filesystem PATH.

## If That Doesn't Work

Install Claude Code as a devcontainer feature:

```json
// .devcontainer/devcontainer.json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    }
  },
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code"
}
```

Mount the host's Claude Code installation:

```json
// .devcontainer/devcontainer.json
{
  "mounts": [
    "source=${localEnv:HOME}/.claude,target=/home/vscode/.claude,type=bind"
  ]
}
```

Verify Node.js is available inside the container:

```bash
node --version
npm --version
which claude
```

## Prevention

```markdown
# CLAUDE.md rule
When using devcontainers, include Claude Code installation in devcontainer.json postCreateCommand. Always forward ANTHROPIC_API_KEY via remoteEnv. Test Claude Code access after every container rebuild.
```

## See Also

- [Shallow Clone Missing History for Blame Fix](/claude-code-shallow-clone-missing-history-blame-fix-2026/)
- [Declaration File .d.ts Missing Error — Fix (2026)](/claude-code-declaration-file-dts-missing-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `Extension host terminated unexpectedly`
- `Cannot connect to the Claude Code language server`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### What VS Code version does Claude Code require?

Claude Code requires VS Code 1.85 or later. Earlier versions lack the extension API features needed for the Claude Code integration. Check your version with `code --version` and update through the VS Code built-in updater or your package manager.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

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
