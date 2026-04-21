---
title: "Devcontainer Claude Code Path Missing Fix"
permalink: /claude-code-devcontainer-path-missing-fix-2026/
description: "Fix Claude Code not found in devcontainer PATH. Add Claude Code install to devcontainer.json features or postCreateCommand for container access."
last_tested: "2026-04-22"
render_with_liquid: false
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
