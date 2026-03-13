---
layout: post
title: "Claude Code Dev Containers: devcontainer.json Setup Guide"
description: "Configure devcontainer.json for Claude Code development environments. Step-by-step setup for VS Code, Docker, and containerized AI development workflows."
date: 2026-03-14
categories: [guides]
tags: [claude-code, devcontainers, vs-code, docker, development-environment]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code Dev Containers: devcontainer.json Setup Guide

Dev containers provide a standardized, containerized development environment that works consistently across machines. When you pair dev containers with Claude Code, you get reproducible AI-assisted development where every team member runs identical toolchain versions. This guide walks through setting up `devcontainer.json` for Claude Code workflows, from basic configuration to advanced multi-service setups. If you're evaluating different cloud-based approaches, see how [Claude Code integrates with GitPod](/claude-skills-guide/articles/claude-code-gitpod-cloud-ide-integration-tutorial-2026/) as well.

## Understanding the Dev Container Workflow

Dev containers let you develop inside a Docker container while using your local IDE. The `.devcontainer/devcontainer.json` file defines the container image, extensions, and settings. When you open a project in VS Code with the Dev Containers extension, it builds the container and reconnects your editor reliably.

For Claude Code users, this approach delivers three key benefits. First, consistency—every developer and CI pipeline uses the exact same Node.js, Python, and Claude Code versions. Second, isolation—skill installations and dependencies stay contained, preventing conflicts with host system packages. Third, portability—clone the repo anywhere with Docker installed, and your environment works immediately.

## Creating Your First devcontainer.json

Place your configuration in `.devcontainer/devcontainer.json` at the repository root. Here's a basic setup for Claude Code development:

```json
{
  "name": "Claude Code Dev Environment",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/devcontainers/features/docker-in-docker:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-azuretools.vscode-docker",
        "anthropic.claude-code"
      ]
    }
  },
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code"
}
```

This configuration starts with an Ubuntu base image, adds Node.js and Docker-in-Docker support, installs VS Code extensions, and runs the Claude Code CLI installation after the container builds.

## Configuring Container Features

Dev Container Features are pre-built, composable units that add functionality to your container. For Claude Code workflows, you'll commonly need these features:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {"version": "20"},
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/docker-in-docker:1": {
      "version": "latest"
    }
  }
}
```

The Node feature lets you pin a specific version—critical when different projects require different Claude Code or toolchain versions. The GitHub CLI feature simplifies authentication for cloning repos and pushing changes. Docker-in-Docker enables building and running containers from within your dev container, essential for testing deployment configurations.

## Setting Up Mounts and Environment Variables

Persistent storage and environment configuration keep your development state across rebuilds. Mount your local SSH keys and Git config to avoid re-authenticating:

```json
{
  "mounts": [
    "source=${env:HOME}/.ssh,target=/root/.ssh,type=bind",
    "source=${env:HOME}/.gitconfig,target=/root/.gitconfig,type=bind"
  ],
  "remoteEnv": {
    "GIT_AUTHOR_NAME": "${localEnv:GIT_AUTHOR_NAME}",
    "GIT_AUTHOR_EMAIL": "${localEnv:GIT_AUTHOR_EMAIL}"
  }
}
```

For skills that require API keys or tokens, use environment variables scoped to the container:

```json
{
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${containerEnv:ANTHROPIC_API_KEY}",
    "GITHUB_TOKEN": "${containerEnv:GITHUB_TOKEN}"
  }
}
```

Never commit actual secrets to your `devcontainer.json`. Instead, set them in your terminal before opening the container, or use Docker secrets for team deployments.

## Installing Claude Skills in Dev Containers

One powerful pattern is pre-installing Claude skills during container creation. Add a `postCreateCommand` that runs skill installations. For large teams, understanding [how to share Claude skills across multiple projects](/claude-skills-guide/articles/how-do-i-share-claude-skills-across-multiple-projects/) ensures everyone works from the same skill versions:

```json
{
  "postCreateCommand": "claude install tdd supermemory pdf frontend-design"
}
```

This approach ensures every team member has the same skill versions. The `tdd` skill provides test-driven development automation, `supermemory` enables persistent context across sessions, `pdf` handles document manipulation, and `frontend-design` assists with UI implementation.

For skills requiring additional dependencies, chain commands:

```json
{
  "postCreateCommand": "claude install tdd && npm install -D vitest jest"
}
```

## Using Compose for Multi-Service Setups

Complex projects often need multiple services—a database, cache, or message queue alongside your main development environment. Dev Containers supports Docker Compose for these scenarios:

```json
{
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}"
}
```

Create a corresponding `docker-compose.yml`:

```yaml
version: '3.8'
services:
  app:
    build: 
      context: .
      dockerfile: Dockerfile
    volumes:
      - ../..:/workspaces/${localWorkspaceFolderBasename}:cached
    command: sleep infinity
    network_mode: service:db

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: dev
```

This setup runs your main development container alongside a PostgreSQL database, with your app able to connect to `db:5432` as if it were a local service.

## Forwarding Ports and Debugging

Access running services from your dev container by forwarding ports:

```json
{
  "forwardPorts": [3000, 5432, 6379],
  "portsAttributes": {
    "3000": {
      "label": "Application Server",
      "onAutoForward": "notify"
    }
  }
}
```

The notification on auto-forward is helpful when working with Claude Code skills that start servers automatically, like the `frontend-design` skill launching a development server.

## Optimizing for Claude Code Performance

Container performance directly impacts your AI-assisted development speed. Consider these settings:

```json
{
  "hostRequirements": {
    "cpus": 4,
    "memory": "8Gb",
    "diskSize": "50Gb"
  },
  "updateContentCommand": "npm install",
  "waitFor": "updateContentCommand"
}
```

Specifying minimum resources ensures Claude Code and its skills run smoothly. The `waitFor` setting blocks further initialization until dependencies install, preventing race conditions where Claude Code starts before the environment is ready.

## Troubleshooting Common Issues

If Claude Code fails to start in your dev container, verify your `postCreateCommand` executed successfully. Check the container logs with `docker logs $(docker ps -q -f name=your-container)`. Common issues include missing Node.js version matching Claude Code requirements or incorrect PATH settings.

For extension-related problems, ensure your VS Code user settings don't conflict with dev container extensions. The `customizations.vscode.settings` key lets you override default VS Code behavior:

```json
{
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
      }
    }
  }
}

## Team Configuration with Dev Container Templates

Large teams benefit from creating reusable dev container templates. Store a template in `.devcontainer/template/` with its own `devcontainer.json`:

```
.devcontainer/
├── template/
│   ├── base/
│   │   ├── devcontainer.json
│   │   └── Dockerfile
│   └── claude-code/
│       ├── devcontainer.json
│       └── README.md
```

Reference templates when creating new environments:

```json
{
  "templateEnv": {
    "TEMPLATE_VARIANT": "claude-code"
  }
}
```

This approach standardizes onboarding—new team members get a fully configured Claude Code environment with all required skills and dependencies by running "Dev Containers: Clone in Volume" on a repository.

## Conclusion

Dev containers transform Claude Code from a locally-installed tool into a portable, version-controlled development environment. The `devcontainer.json` configuration controls everything from base images and installed features to skill initialization and port forwarding. Start with the basic setup shown earlier, then layer in Compose support, environment variables, and skill installations as your project grows. Once your environment is stable, explore [Claude Code worktrees and skills isolation](/claude-skills-guide/articles/claude-code-worktrees-and-skills-isolation-explained/) to keep experiments separate from production workflows.

For teams adopting Claude Code at scale, investing time in dev container configuration pays dividends in consistency and onboarding speed. Every developer—whether on macOS, Linux, or Windows—gets an identical environment that matches your CI/CD pipeline.

## Related Reading

- [Claude Code GitPod Integration Tutorial 2026](/claude-skills-guide/articles/claude-code-gitpod-cloud-ide-integration-tutorial-2026/) — Set up Claude Code in cloud-based GitPod workspaces for team environments
- [How to Share Claude Skills Across Multiple Projects](/claude-skills-guide/articles/how-do-i-share-claude-skills-across-multiple-projects/) — Keep skill versions consistent across repositories and teams
- [Claude Code Worktrees and Skills Isolation Explained](/claude-skills-guide/articles/claude-code-worktrees-and-skills-isolation-explained/) — Use worktrees to keep experimental skill setups separate from stable ones
- [Claude Code with Docker: Container Setup Guide](/claude-skills-guide/articles/claude-code-with-docker-container-skill-setup-guide/) — Run Claude Code skills inside Docker containers for maximum isolation

Built by theluckystrike — More at [zovo.one](https://zovo.one)
