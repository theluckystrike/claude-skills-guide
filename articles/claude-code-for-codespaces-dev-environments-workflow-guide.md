---
layout: default
title: "Claude Code for GitHub Codespaces"
description: "Set up GitHub Codespaces for Claude Code workflows. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-codespaces-dev-environments-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, codespaces, workflow]
---

## The Setup

You are developing in GitHub Codespaces — cloud-hosted development environments that spin up a full VS Code environment with a container running your project. Codespaces provides a standardized dev environment accessible from any browser or local VS Code. Claude Code runs inside Codespaces, but it assumes a local machine setup and misses Codespaces-specific configuration.

## What Claude Code Gets Wrong By Default

1. **Installs tools with Homebrew.** Claude runs `brew install` for development tools. In Codespaces, tools go in the `devcontainer.json` using Dev Container Features or Dockerfile — Homebrew installs do not persist across rebuilds.

2. **Configures local ports directly.** Claude binds services to `localhost:3000`. In Codespaces, port forwarding is configured through `devcontainer.json` with `forwardPorts` — the port is automatically tunneled and accessible through a Codespaces URL.

3. **Creates `.env` files with secrets.** Claude writes API keys to `.env` files in the project. Codespaces has encrypted secrets managed through GitHub Settings or the `gh` CLI — secrets are injected as environment variables automatically.

4. **Ignores prebuilds configuration.** Claude sets up development environments that build from scratch every time. Codespaces prebuilds cache the container image and setup steps — enabling prebuilds reduces startup from minutes to seconds.

## The CLAUDE.md Configuration

```
# GitHub Codespaces Project

## Environment
- Platform: GitHub Codespaces (cloud dev environments)
- Config: .devcontainer/devcontainer.json
- Editor: VS Code (browser or local client)
- Secrets: GitHub Codespaces encrypted secrets

## Codespaces Rules
- Tools: install via devcontainer.json features, not brew
- Ports: forwardPorts in devcontainer.json
- Secrets: GitHub Settings > Codespaces > Secrets
- Prebuilds: enable for faster startup
- postCreateCommand for project setup (npm install)
- Extensions in devcontainer.json customizations.vscode
- Dotfiles: GitHub dotfiles repo auto-applied

## Conventions
- .devcontainer/ at project root
- Use Features for Node, Python, Docker, etc.
- postCreateCommand: "npm install && npm run build"
- forwardPorts: [3000, 5432] for dev server and DB
- Secrets via gh secret set or GitHub UI
- Prebuild on push to main branch
- Machine type: 4-core for standard, 8-core for monorepos
```

## Workflow Example

You want to set up a Codespace for a full-stack Next.js project with PostgreSQL. Prompt Claude Code:

"Configure a GitHub Codespace for a Next.js 14 project with PostgreSQL. Include Node.js 20, Git, and the ESLint VS Code extension. Set up Docker Compose for PostgreSQL, configure port forwarding for the dev server and database, and add a prebuild configuration."

Claude Code should create `.devcontainer/devcontainer.json` with the Node.js feature, a `docker-compose.yml` for PostgreSQL, `forwardPorts: [3000, 5432]`, `postCreateCommand` for `npm install`, VS Code extensions in customizations, and a `.github/codespaces/prebuild-configuration.json` for prebuilds.

## Common Pitfalls

1. **Secrets not available in prebuilds.** Claude uses secrets in `postCreateCommand`. Codespaces secrets are not injected during prebuild — they are only available when a user opens the Codespace. Move secret-dependent commands to `postAttachCommand` instead.

2. **Large container images.** Claude adds many Features and tools to the devcontainer. Each Feature increases image size and startup time. Only include tools the project actually needs — use prebuilds to cache the build.

3. **Forgetting to persist data.** Claude stores data in the container filesystem. When a Codespace is rebuilt, non-persisted data is lost. Use named volumes in docker-compose or the `/workspaces` directory which persists across rebuilds.

## Related Guides

- [Claude Code for Devcontainers Workflow Guide](/claude-code-for-devcontainers-workflow-guide/)
- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Claude Code for Gitpod Cloud Dev Workflow Guide](/claude-code-for-gitpod-cloud-dev-workflow-guide/)

## Related Articles

- [Claude Code for Windmill Dev — Workflow Guide](/claude-code-for-windmill-dev-workflow-guide/)
- [Claude Code for Coder — Workflow Guide](/claude-code-for-coder-remote-dev-workflow-guide/)
