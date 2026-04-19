---
layout: default
title: "Claude Code for Coder — Workflow Guide"
description: "Run Claude Code in Coder remote dev environments. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-coder-remote-dev-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, coder, workflow]
---

## The Setup

You are using Coder to provision remote development environments from templates. Coder gives every developer a consistent cloud workspace with pre-installed tools, and Claude Code runs inside these environments for AI-assisted coding. The key challenge is configuring Claude Code to work within Coder's template system and SSH tunnel setup.

## What Claude Code Gets Wrong By Default

1. **Assumes local file system paths.** Claude references `~/` paths expecting a local home directory. In Coder workspaces, the home directory lives on the remote machine and paths may differ from what Claude expects based on the template configuration.

2. **Installs tools using the host OS package manager.** Claude runs `brew install` or `apt install` for dependencies. In Coder, tools should be pre-installed in the workspace template's Dockerfile or Terraform — runtime installs do not persist across workspace restarts.

3. **Ignores the Coder SSH config.** Claude tries to SSH with raw `ssh user@host` commands. Coder uses `coder ssh workspace-name` which handles authentication and tunneling through the Coder control plane.

4. **Opens browser previews on localhost.** Claude starts dev servers and opens `localhost:3000`. In Coder, ports need to be forwarded through `coder port-forward` or accessed via the Coder dashboard's port forwarding UI.

## The CLAUDE.md Configuration

```
# Coder Remote Development Environment

## Environment
- Platform: Coder (remote dev workspaces)
- Access: coder ssh <workspace> or VS Code Remote
- Persistence: /home/coder is persistent, /tmp is ephemeral
- Ports: Forward via coder port-forward or dashboard

## Coder Rules
- All tool installs go in workspace template, not runtime commands
- Use coder ssh for terminal access, not raw SSH
- Port forwarding: coder port-forward <workspace> --tcp 3000:3000
- Environment variables set in template or coder dotfiles repo
- Git credentials configured via coder gitauth (GitHub/GitLab OAuth)
- Workspace may restart — do not rely on running processes persisting

## Conventions
- Project code in /home/coder/projects/
- Claude Code config in project-level CLAUDE.md
- Use tmux or screen for long-running processes
- Dev server URLs use coder's forwarded port format
- Template changes require coder template push, not manual installs
- Dotfiles repo: github.com/user/dotfiles (auto-applied on workspace create)
```

## Workflow Example

You want to set up Claude Code in a new Coder workspace for a Node.js project. Prompt Claude Code:

"Configure this Coder workspace for the project. Check that Node.js and pnpm are available, set up the dev server with proper port forwarding, and ensure my git credentials are configured through Coder's auth system."

Claude Code should verify the template has Node.js installed, check `coder gitauth` status for GitHub access, suggest the `coder port-forward` command for the dev server port, and configure project-level settings in `CLAUDE.md` rather than modifying system files.

## Common Pitfalls

1. **Modifying system-level configs that do not persist.** Claude edits `/etc/` files or installs system packages. These changes are lost when the Coder workspace rebuilds. Put all customizations in the workspace template or the dotfiles repository.

2. **Background processes dying on workspace stop.** Claude starts services with `&` in the background. When a Coder workspace stops (auto-shutdown on idle), these processes terminate. Use the workspace template's `startup_script` for services that should auto-start.

3. **Git SSH key confusion.** Claude generates SSH keys in the workspace. Coder handles Git authentication through its own OAuth integration (`coder gitauth`), which provides temporary credentials. Manually created SSH keys become stale and conflict with Coder's auth flow.

## Related Guides

- [Claude Code for Gitpod Cloud Dev Workflow Guide](/claude-code-for-gitpod-cloud-dev-workflow-guide/)
- [Claude Code for Devcontainers Workflow Guide](/claude-code-for-devcontainers-workflow-guide/)
- [Why Is Claude Code Terminal Based Not GUI](/why-is-claude-code-terminal-based-not-gui-application/)

## Related Articles

- [Claude Code for Windmill Dev — Workflow Guide](/claude-code-for-windmill-dev-workflow-guide/)
- [Claude Code for GitHub Codespaces — Guide](/claude-code-for-codespaces-dev-environments-workflow-guide/)
- [Claude Code for Bazel Remote Cache Workflow](/claude-code-for-bazel-remote-cache-workflow/)
