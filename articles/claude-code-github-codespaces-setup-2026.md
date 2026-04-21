---
layout: post
title: "Use Claude Code with GitHub Codespaces 2026"
description: "Run Claude Code inside GitHub Codespaces with devcontainer config, SSH tunnels, and remote development best practices for cloud workflows."
permalink: /claude-code-github-codespaces-setup-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Run Claude Code inside GitHub Codespaces for cloud-based AI-assisted development. This setup gives you a consistent, pre-configured environment that works identically across machines and team members.

Expected time: 20 minutes for initial setup, instant for subsequent codespaces
Prerequisites: GitHub account with Codespaces access, Anthropic API key

## Setup

### 1. Create devcontainer.json

```json
{
  "name": "Claude Code Development",
  "image": "mcr.microsoft.com/devcontainers/typescript-node:20",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "configureZshAsDefaultShell": true
    },
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    },
    "ghcr.io/devcontainers/features/git:1": {}
  },
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code && claude --version",
  "secrets": ["ANTHROPIC_API_KEY"],
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "zsh",
        "terminal.integrated.scrollback": 50000
      },
      "extensions": [
        "github.copilot",
        "esbenp.prettier-vscode"
      ]
    }
  },
  "forwardPorts": [3000, 5173, 8080],
  "portsAttributes": {
    "3000": {"label": "App", "onAutoForward": "notify"},
    "5173": {"label": "Vite Dev", "onAutoForward": "notify"}
  }
}
```

Place this at `.devcontainer/devcontainer.json` in your repository.

### 2. Configure Codespace Secrets

```bash
# Set your API key as a Codespace secret (via GitHub CLI)
gh secret set ANTHROPIC_API_KEY --app codespaces \
  --body "sk-ant-your-key-here"

# Verify it's set
gh secret list --app codespaces
# Expected output:
# ANTHROPIC_API_KEY  Updated 2026-04-21
```

Secrets are injected as environment variables when the codespace starts.

### 3. Launch Codespace and Verify

```bash
# Create a codespace from your repo
gh codespace create --repo your-org/your-repo --machine standardLinux32gb

# Connect to it
gh codespace ssh --repo your-org/your-repo

# Inside the codespace, verify Claude Code works
claude --version
claude --print "What directory am I in and what files are here?"
# Expected output:
# Shows /workspaces/your-repo and lists repository files
```

### 4. Create a Startup Script for Team Consistency

```bash
cat > .devcontainer/post-start.sh << 'EOF'
#!/bin/bash
set -e

# Verify Claude Code is available
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

# Create project-specific CLAUDE.md if missing
if [ ! -f "CLAUDE.md" ]; then
    echo "Warning: No CLAUDE.md found. Claude Code works best with project context."
fi

echo "Claude Code environment ready. Run 'claude' to start."
EOF
chmod +x .devcontainer/post-start.sh
```

### 5. Verify

```bash
claude --print "Summarize the package.json dependencies"
# Expected output:
# Lists and describes your project's dependencies
```

## Usage Example

Complete workflow for developing a feature in a codespace with Claude Code:

```bash
# Start Claude Code in the codespace terminal
claude

# Work on a feature branch
> I need to add a rate limiter middleware for our Express API.
> It should use a sliding window algorithm with Redis backing.
> The limit is 100 requests per minute per IP.
```

Claude Code reads your project context and generates:

```typescript
// src/middleware/rate-limiter.ts
import { Request, Response, NextFunction } from "express";
import { Redis } from "ioredis";

interface RateLimiterConfig {
  windowMs: number;
  maxRequests: number;
  redis: Redis;
  keyPrefix?: string;
}

export function createRateLimiter(config: RateLimiterConfig) {
  const { windowMs, maxRequests, redis, keyPrefix = "rl:" } = config;

  return async (req: Request, res: Response, next: NextFunction) => {
    const clientIp = req.ip || req.socket.remoteAddress || "unknown";
    const key = `${keyPrefix}${clientIp}`;
    const now = Date.now();
    const windowStart = now - windowMs;

    const pipeline = redis.pipeline();
    pipeline.zremrangebyscore(key, 0, windowStart);
    pipeline.zadd(key, now.toString(), `${now}-${Math.random()}`);
    pipeline.zcard(key);
    pipeline.expire(key, Math.ceil(windowMs / 1000));

    const results = await pipeline.exec();
    const requestCount = results?.[2]?.[1] as number;

    res.setHeader("X-RateLimit-Limit", maxRequests);
    res.setHeader("X-RateLimit-Remaining", Math.max(0, maxRequests - requestCount));
    res.setHeader("X-RateLimit-Reset", new Date(now + windowMs).toISOString());

    if (requestCount > maxRequests) {
      return res.status(429).json({
        error: "Too many requests",
        retryAfter: Math.ceil(windowMs / 1000),
      });
    }

    next();
  };
}
```

The file is written directly in your codespace workspace. Preview it in VS Code, run tests, and commit all without leaving the browser.

```bash
# Run tests to verify
npm test -- --grep "rate-limiter"

# Commit and push from the codespace
git add src/middleware/rate-limiter.ts
git commit -m "Add sliding window rate limiter with Redis"
git push
```

## Common Issues

- **ANTHROPIC_API_KEY not available:** Ensure the secret is scoped to the correct repository or organization in GitHub settings. Codespace secrets are repo-specific by default.
- **Claude Code slow in 2-core machines:** Use `standardLinux32gb` (4-core) or larger machine types. Claude Code's file operations benefit from more CPU.
- **Port forwarding conflicts:** If Claude Code suggests running a dev server, ensure the port matches your `forwardPorts` config in devcontainer.json.

## Why This Matters

Codespaces eliminate "works on my machine" issues for teams using Claude Code. Every developer gets an identical environment with Claude Code pre-configured, reducing onboarding from hours to minutes.

## Related Guides

- [Claude Code for Gitpod Cloud Dev Workflow Guide](/claude-code-for-gitpod-cloud-dev-workflow-guide/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [How to Write Effective CLAUDE.md for Your Project](/how-to-write-effective-claude-md-for-your-project/)
