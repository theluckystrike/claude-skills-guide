---
layout: default
title: "Using Claude Code with Docker"
description: "Run Claude Code inside Docker containers and devcontainers for isolated development, CI/CD, and sandbox environments."
date: 2026-04-15
permalink: /claude-code-with-docker-containers-guide/
categories: [guides, claude-code]
tags: [docker, containers, devcontainer, sandbox, CI-CD]
last_modified_at: 2026-04-17
geo_optimized: true
---

# Using Claude Code with Docker Containers

## The Problem

You want to run Claude Code inside a Docker container for isolated development, reproducible environments, or CI/CD pipelines. But installation hangs, authentication fails, or Claude cannot access your project files.

## Quick Fix

Set a `WORKDIR` before installing Claude Code in a Dockerfile to prevent the installer from scanning the entire filesystem:

```dockerfile
FROM node:20
WORKDIR /tmp
RUN curl -fsSL https://claude.ai/install.sh | bash
WORKDIR /app
COPY . .
```

## What's Happening

Running Claude Code in Docker introduces three challenges. First, installing as root from `/` causes the installer to scan the entire filesystem, leading to excessive memory usage and hangs. Setting `WORKDIR /tmp` limits the scan to a small directory.

Second, Claude Code requires at least 4 GB of RAM. Docker Desktop's default memory limit is lower than this, causing OOM kills during installation.

Third, interactive authentication (OAuth login) does not work in headless containers. You need to pass an API key via environment variable or use the headless authentication flow.

## Step-by-Step Fix

### Step 1: Create a Dockerfile

```dockerfile
FROM node:20

# Set workdir before install to prevent filesystem scan
WORKDIR /tmp
RUN curl -fsSL https://claude.ai/install.sh | bash

# Set up your project
WORKDIR /app
COPY . .

# Claude needs this for non-interactive mode
ENV PATH="/root/.local/bin:$PATH"
```

### Step 2: Build with sufficient memory

```bash
docker build --memory=4g -t my-claude-project .
```

### Step 3: Run with API key authentication

Pass your API key as an environment variable:

```bash
docker run -it \
 -e ANTHROPIC_API_KEY=your-key-here \
 -v $(pwd):/app \
 my-claude-project \
 claude -p "Analyze this codebase"
```

### Step 4: Use bypassPermissions mode in containers

In isolated containers where Claude cannot cause external damage, use bypassPermissions mode to skip permission prompts:

```bash
docker run -it \
 -e ANTHROPIC_API_KEY=your-key-here \
 -v $(pwd):/app \
 my-claude-project \
 claude --permission-mode bypassPermissions -p "Implement the feature described in TASK.md"
```

This mode skips all permission prompts except writes to protected directories like `.git` and `.claude`.

### Step 5: Mount project files correctly

Mount your project directory as a volume:

```bash
docker run -it \
 -e ANTHROPIC_API_KEY=your-key-here \
 -v /path/to/project:/app \
 my-claude-project \
 claude
```

If you encounter permission denied errors on bind mounts, ensure the container user has write access:

```dockerfile
RUN chown -R node:node /app
USER node
```

### Step 6: Set up devcontainers

For VS Code devcontainers, add Claude Code to your `.devcontainer/devcontainer.json`:

```json
{
 "name": "Claude Code Dev",
 "image": "node:20",
 "postCreateCommand": "curl -fsSL https://claude.ai/install.sh | bash",
 "containerEnv": {
 "PATH": "/root/.local/bin:${PATH}"
 },
 "mounts": [
 "source=${localEnv:HOME}/.claude,target=/root/.claude,type=bind"
 ]
}
```

Mounting `~/.claude` from the host preserves your Claude Code configuration and authentication inside the container.

### Step 7: CI/CD pipeline usage

For GitHub Actions or other CI environments, use the non-interactive `-p` flag:

```bash
claude -p "Run tests and fix any failures" \
 --permission-mode bypassPermissions \
 --max-turns 10
```

Set `--max-turns` to limit the number of agent iterations and control costs.

### Step 8: Enable sandbox mode

Claude Code supports sandboxing that restricts file system access. In container environments, this provides an additional layer of protection:

```bash
claude --sandbox
```

This uses the container's own isolation plus Claude Code's built-in restrictions.

## Prevention

Always set `WORKDIR` before running the Claude Code installer in Docker. Allocate at least 4 GB of memory to Docker containers running Claude Code. Use environment variables for authentication instead of interactive OAuth in container environments.

For production CI/CD, set explicit `--max-turns` limits and use `--permission-mode dontAsk` with pre-configured allow rules for predictable behavior.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-with-docker-containers-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

---

## Related Guides

- [Claude Code Docker Permission Denied Fix](/claude-code-docker-permission-denied-bind-mount-error/)
- [Claude Code Dev Containers Setup Guide](/claude-code-dev-containers-devcontainer-json-setup-guide/)
- [Claude Code Headless Linux Auth](/claude-code-headless-linux-auth/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)


