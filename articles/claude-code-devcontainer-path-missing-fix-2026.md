---
title: "Devcontainer Claude Code Path Missing"
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
