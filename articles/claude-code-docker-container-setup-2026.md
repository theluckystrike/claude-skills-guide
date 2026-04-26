---
layout: post
title: "How to Run Claude Code in Docker (2026)"
description: "Run Claude Code in Docker with isolated environments, volume mounts for project files, and Dockerfile examples for reproducible AI development."
permalink: /claude-code-docker-container-setup-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Run Claude Code inside a Docker container for isolated, reproducible AI-assisted development. This approach provides sandboxed file access, consistent environments across machines, and safe experimentation without risk to your host system.

Expected time: 15 minutes
Prerequisites: Docker 24+, Anthropic API key

## Setup

### 1. Create the Dockerfile

```dockerfile
# Dockerfile.claude-code
FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Create workspace directory
RUN mkdir -p /workspace && chown node:node /workspace

# Switch to non-root user
USER node
WORKDIR /workspace

# Set default shell
SHELL ["/bin/bash", "-c"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s \
  CMD claude --version || exit 1

ENTRYPOINT ["claude"]
```

### 2. Build the Image

```bash
docker build -t claude-code:latest -f Dockerfile.claude-code .
```

This creates a reusable image with Claude Code and common development tools pre-installed.

### 3. Run with Project Volume Mount

```bash
# Interactive mode with your project mounted
docker run -it --rm \
  -v "$(pwd):/workspace" \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-code:latest
```

Your project files are accessible inside the container at `/workspace`, and any changes Claude Code makes are reflected on your host filesystem.

### 4. Create a Docker Compose Configuration

```yaml
# docker-compose.claude.yml
version: "3.9"

services:
  claude-code:
    build:
      context: .
      dockerfile: Dockerfile.claude-code
    volumes:
      - .:/workspace
      - claude-config:/home/node/.claude
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    stdin_open: true
    tty: true
    working_dir: /workspace

  claude-code-readonly:
    build:
      context: .
      dockerfile: Dockerfile.claude-code
    volumes:
      - .:/workspace:ro
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    stdin_open: true
    tty: true
    entrypoint: ["claude", "--print"]

volumes:
  claude-config:
```

The `readonly` service variant mounts your project as read-only for safe code review tasks.

### 5. Create a Shell Alias for Quick Access

```bash
# Add to ~/.zshrc or ~/.bashrc
alias claude-docker='docker run -it --rm \
  -v "$(pwd):/workspace" \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-code:latest'

alias claude-docker-print='docker run --rm \
  -v "$(pwd):/workspace:ro" \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-code:latest --print'
```

### 6. Verify

```bash
docker run --rm \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-code:latest --version
# Expected output:
# claude-code x.x.x

docker run --rm \
  -v "$(pwd):/workspace" \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-code:latest --print "List files in /workspace"
# Expected output:
# Lists your current directory's files
```

## Usage Example

Run Claude Code in Docker for a safe refactoring task:

```bash
# Start interactive session with project mounted
docker run -it --rm \
  -v ~/projects/my-api:/workspace \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-code:latest

# Inside the container, Claude Code has full access to /workspace
> Refactor all Express route handlers in src/routes/ to use
> async/await instead of .then() chains. Preserve error handling.
```

For CI/CD integration, use the non-interactive mode:

```bash
# Run a code review in CI
docker run --rm \
  -v "$(pwd):/workspace:ro" \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-code:latest --print \
  "Review the code in src/auth/ for security issues. \
   Check for: SQL injection, XSS, insecure token handling. \
   Output as a JSON array of findings with file, line, severity, description."
```

Multi-language project setup with additional tools:

```dockerfile
# Dockerfile.claude-code-full
FROM node:20-slim

RUN apt-get update && apt-get install -y \
    git curl jq python3 python3-pip \
    golang-go rustc cargo \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code typescript tsx
RUN pip3 install --break-system-packages ruff pytest

USER node
WORKDIR /workspace
ENTRYPOINT ["claude"]
```

```bash
# Build and run the full-stack variant
docker build -t claude-code:full -f Dockerfile.claude-code-full .
docker run -it --rm \
  -v "$(pwd):/workspace" \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-code:full
```

## Common Issues

- **Permission denied on mounted files:** Ensure your Docker user UID matches your host UID. Use `--user $(id -u):$(id -g)` flag or set `USER node` in the Dockerfile.
- **Container can't resolve npm packages:** If behind a corporate proxy, pass `--build-arg HTTP_PROXY=http://proxy:8080` during build.
- **Config not persisting between sessions:** Mount a named volume for `~/.claude` to persist session history and settings across container restarts.

## Why This Matters

Docker isolation guarantees Claude Code cannot access files outside your mounted project directory. Teams use this approach to enforce security boundaries while still benefiting from AI-assisted development.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Docker Image Publishing Workflow](/claude-code-for-docker-image-publishing-workflow-guide/)
- [Claude Code for Colima Docker Workflow Guide](/claude-code-for-colima-docker-workflow-guide/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)

- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to [--dangerously-skip-permissions flag](/claude-dangerously-skip-permissions-flag/) and safer alternatives

## See Also

- [Docker Container Missing Tools Fix](/claude-code-docker-container-missing-tools-fix-2026/)


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
