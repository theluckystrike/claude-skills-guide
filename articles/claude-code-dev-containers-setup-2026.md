---
layout: post
title: "Set Up Claude Code in Dev Containers (2026)"
description: "Configure devcontainer.json for Claude Code with pre-installed dependencies, environment variables, and remote development settings for teams."
permalink: /claude-code-dev-containers-setup-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Create a Dev Container configuration that includes Claude Code out of the box. Every developer who opens the project in VS Code, GitHub Codespaces, or any Dev Container-compatible tool gets a working Claude Code environment with zero manual setup.

Expected time: 15 minutes
Prerequisites: VS Code with Dev Containers extension (or compatible tool), Docker Desktop, Anthropic API key

## Setup

### 1. Create the Dev Container Directory

```bash
mkdir -p .devcontainer
```

### 2. Write devcontainer.json

```json
{
  "name": "Project with Claude Code",
  "build": {
    "dockerfile": "Dockerfile",
    "context": ".."
  },
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    },
    "ghcr.io/devcontainers/features/git:1": {
      "version": "latest",
      "ppa": false
    },
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "configureZshAsDefaultShell": true,
      "installOhMyZsh": true
    }
  },
  "postCreateCommand": "bash .devcontainer/post-create.sh",
  "postStartCommand": "claude --version",
  "initializeCommand": "echo 'Building dev container with Claude Code...'",
  "secrets": {
    "ANTHROPIC_API_KEY": {
      "description": "Anthropic API key for Claude Code CLI"
    }
  },
  "containerEnv": {
    "CLAUDE_CODE_THEME": "dark",
    "EDITOR": "code --wait"
  },
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "zsh",
        "terminal.integrated.scrollback": 50000,
        "terminal.integrated.fontSize": 14
      },
      "extensions": [
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "bradlc.vscode-tailwindcss"
      ]
    }
  },
  "forwardPorts": [3000, 5173, 8080],
  "mounts": [
    "source=${localEnv:HOME}/.claude,target=/home/vscode/.claude,type=bind,consistency=cached"
  ],
  "remoteUser": "vscode"
}
```

### 3. Create the Dockerfile

```dockerfile
# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install Claude Code
RUN su vscode -c "npm install -g @anthropic-ai/claude-code" 2>&1

# Install additional language runtimes your project needs
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Pre-create directories
RUN mkdir -p /home/vscode/.claude && chown vscode:vscode /home/vscode/.claude
```

### 4. Create the Post-Create Script

```bash
#!/bin/bash
# .devcontainer/post-create.sh
set -e

echo "Setting up development environment..."

# Install project dependencies
if [ -f "package.json" ]; then
    npm install
fi

if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt
fi

# Verify Claude Code
if command -v claude &> /dev/null; then
    echo "Claude Code version: $(claude --version)"
else
    echo "ERROR: Claude Code not found. Installing..."
    npm install -g @anthropic-ai/claude-code
fi

# Check for CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    echo "Found CLAUDE.md - project context will be available to Claude Code"
else
    echo "TIP: Create a CLAUDE.md file to give Claude Code project context"
fi

echo "Dev container setup complete. Run 'claude' to start."
```

```bash
chmod +x .devcontainer/post-create.sh
```

### 5. Configure Secrets in VS Code

```bash
# For local Dev Containers, set the env var before opening:
export ANTHROPIC_API_KEY="sk-ant-your-key-here"

# For GitHub Codespaces, set as a Codespace secret:
gh secret set ANTHROPIC_API_KEY --app codespaces --body "sk-ant-xxx"
```

### 6. Verify

```bash
# Rebuild the container: Ctrl+Shift+P → "Dev Containers: Rebuild Container"
# Open terminal in VS Code: Ctrl+`

claude --version
# Expected output:
# claude-code x.x.x

claude --print "What project am I in? List the top-level files."
# Expected output:
# Lists your project root files
```

## Usage Example

A team dev container for a full-stack TypeScript project:

```json
{
  "name": "Full-Stack TS + Claude Code",
  "build": { "dockerfile": "Dockerfile" },
  "features": {
    "ghcr.io/devcontainers/features/node:1": { "version": "20" },
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code && npm ci",
  "secrets": {
    "ANTHROPIC_API_KEY": {
      "description": "Claude Code API key"
    },
    "DATABASE_URL": {
      "description": "PostgreSQL connection string"
    }
  },
  "containerEnv": {
    "NODE_ENV": "development"
  },
  "forwardPorts": [3000, 5432, 6379],
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.profiles.linux": {
          "claude": {
            "path": "/usr/local/bin/claude",
            "icon": "robot"
          }
        }
      }
    }
  }
}
```

Using Claude Code inside the container:

```bash
# Open the terminal and start Claude Code
claude

# Ask it to scaffold a new API endpoint
> Create a new TRPC router for managing blog posts with:
> - list (paginated, with cursor)
> - getById
> - create (requires auth)
> - update (requires auth + ownership)
> - delete (requires auth + ownership)
> Use our existing prisma schema for the Post model.
```

Claude Code reads the project context from CLAUDE.md and your existing code, then generates files that match your project's patterns:

```typescript
// src/server/routers/post.ts
import { z } from "zod";
import { router, publicProcedure, protectedProcedure } from "../trpc";
import { TRPCError } from "@trpc/server";

export const postRouter = router({
  list: publicProcedure
    .input(z.object({
      cursor: z.string().nullish(),
      limit: z.number().min(1).max(100).default(20),
    }))
    .query(async ({ ctx, input }) => {
      const posts = await ctx.prisma.post.findMany({
        take: input.limit + 1,
        cursor: input.cursor ? { id: input.cursor } : undefined,
        orderBy: { createdAt: "desc" },
        include: { author: { select: { name: true, image: true } } },
      });

      let nextCursor: string | undefined;
      if (posts.length > input.limit) {
        const next = posts.pop();
        nextCursor = next?.id;
      }

      return { posts, nextCursor };
    }),
});
```

## Common Issues

- **Claude Code not on PATH after container rebuild:** Add the install to the Dockerfile instead of postCreateCommand for faster subsequent builds.
- **Mount permission errors on Linux:** Use `"remoteUser": "vscode"` and ensure the Dockerfile creates directories with correct ownership.
- **API key not injected:** When using VS Code locally, set the environment variable in your host shell before launching VS Code, or use a `.env` file with `"runArgs": ["--env-file", ".devcontainer/.env"]`.

## Why This Matters

Dev Containers ensure every team member has Claude Code configured identically. New developers go from `git clone` to productive AI-assisted coding in under 5 minutes instead of spending an hour on environment setup.



**Get started →** Generate your project setup with our [Project Starter](/starter/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for Gitpod Cloud Dev Workflow Guide](/claude-code-for-gitpod-cloud-dev-workflow-guide/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [How to Share Claude Skills with Your Team](/how-to-share-claude-skills-with-team/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
