---
layout: default
title: "Claude Code for Devcontainers (2026)"
description: "Claude Code for Devcontainers — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-devcontainers-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, devcontainers, workflow]
---

## The Setup

You are using Dev Containers (the open spec supported by VS Code, GitHub Codespaces, and other tools) to create reproducible development environments. Dev Containers define your toolchain in a `devcontainer.json` file that builds a Docker container with everything pre-installed. Claude Code runs inside these containers, but it generates configuration for the host machine instead.

## What Claude Code Gets Wrong By Default

1. **Installs tools on the host machine.** Claude runs `brew install` or `apt install` for system tools. In Dev Containers, tools are installed in the container via the Dockerfile or features — host installs are irrelevant.

2. **Creates Docker Compose for development.** Claude writes `docker-compose.yml` for dev services. Dev Containers support Docker Compose integration natively through `devcontainer.json` — the compose file defines services, and devcontainer.json specifies which service is the dev container.

3. **Ignores Dev Container Features.** Claude writes Dockerfile RUN commands for common tools. Dev Container Features (`"features": { "ghcr.io/devcontainers/features/node:1": {} }`) install tools without Dockerfile modifications.

4. **Configures VS Code extensions globally.** Claude adds extensions to the global VS Code config. Dev Containers specify extensions per project in `devcontainer.json` with `"customizations": { "vscode": { "extensions": [...] } }`.

## The CLAUDE.md Configuration

```
# Dev Container Project

## Environment
- Platform: Dev Containers (open spec)
- Config: .devcontainer/devcontainer.json
- Dockerfile: .devcontainer/Dockerfile (optional)
- Docker Compose: .devcontainer/docker-compose.yml (optional)

## Dev Container Rules
- All tools installed in container, not host
- Features for common tools: Node, Python, Docker, Git
- VS Code extensions in devcontainer.json customizations
- Post-create command for project setup (npm install, etc.)
- Environment variables in containerEnv or .env file
- Mount volumes for persistent data outside container
- Forward ports for dev server access

## Conventions
- .devcontainer/ directory at project root
- devcontainer.json as primary config
- Use Features over Dockerfile RUN for standard tools
- postCreateCommand: "npm install" for setup after build
- forwardPorts: [3000, 5432] for service access
- Mount .ssh and .gitconfig for Git credentials
- Container user: vscode (non-root by default)
```

## Workflow Example

You want to create a Dev Container for a full-stack project. Prompt Claude Code:

"Create a Dev Container config for a Next.js project with PostgreSQL. Include Node.js 20, Git, and the ESLint extension. Set up Docker Compose for the database and configure port forwarding for the dev server."

Claude Code should create `.devcontainer/devcontainer.json` with Node.js feature, `.devcontainer/docker-compose.yml` with PostgreSQL service, configure the dev container to use the compose file, add `forwardPorts: [3000, 5432]`, and specify the `postCreateCommand` for `npm install`.

## Common Pitfalls

1. **Git credentials not available in container.** Claude commits from inside the container but Git has no identity. Mount SSH keys and gitconfig: `"mounts": ["source=${localEnv:HOME}/.ssh,target=/home/vscode/.ssh,type=bind"]` or use the Git credential manager feature.

2. **Node modules persistence across rebuilds.** Claude installs packages but they are lost when the container rebuilds. Use a named volume for `node_modules`: `"mounts": ["source=node_modules,target=${containerWorkspaceFolder}/node_modules,type=volume"]`.

3. **Port conflicts with host services.** Claude forwards port 5432 but PostgreSQL is already running on the host. Use non-standard ports in the container compose or stop host services. Dev Container port forwarding maps container ports to host ports.

## Related Guides

- [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/)
- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Claude Code for Gitpod Cloud Dev Workflow Guide](/claude-code-for-gitpod-cloud-dev-workflow-guide/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
