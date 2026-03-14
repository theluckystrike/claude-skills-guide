---
layout: default
title: "Claude Code with Docker: Container Setup Guide"
description: "Run Claude Code with Docker for isolated skill execution. Covers Dockerfile setup, Compose stacks, HTTP API containers, and CI/CD integration."
date: 2026-03-13
categories: [guides]
tags: [claude-code, claude-skills, docker, containers, ci-cd, devops]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-with-docker-container-skill-setup-guide/
---


# Claude Code with Docker Container Setup Guide

Running Claude Code with Docker gives you reproducible, isolated execution that works identically across developer machines, CI runners, and production servers. This guide covers the full setup from a basic Dockerfile through multi-container orchestration with Compose, including patterns for the [`tdd`](/claude-skills-guide/best-claude-skills-for-developers-2026/), `pdf`, `supermemory`, and `frontend-design` skills.

## Why Containerize Claude Code

Running Claude Code in Docker solves several real problems:

- **Reproducibility**: Every team member runs the same Node.js version and CLI version
- **Isolation**: Claude Code processes cannot interfere with host system state
- **CI/CD compatibility**: The same container image runs locally and in GitHub Actions or any CI platform
- **Service composition**: Claude containers can sit alongside databases, queues, and other services in a Compose stack
- **Secret management**: Credentials stay in container environment variables, not host shell profiles

## Prerequisites

- Docker Desktop 4.x+ (or Docker Engine on Linux)
- Docker Compose v2
- Anthropic API key

## Step 1: Create the Base Dockerfile

```dockerfile
# Dockerfile
FROM node:20-alpine

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Set working directory
WORKDIR /app

# Default command — override per-use
CMD ["claude", "--version"]
```

Build and verify:

```bash
docker build -t claude-skills:base .
docker run --rm claude-skills:base
```

## Step 2: Run Skills in Print Mode

Claude Code's `-p` flag (print mode) runs a non-interactive session, outputs to stdout, and exits. This is the correct way to use Claude Code in containers:

```dockerfile
# Dockerfile.runner
FROM node:20-alpine

RUN npm install -g @anthropic-ai/claude-code

WORKDIR /workspace

ENTRYPOINT ["claude", "-p"]
```

Run a skill:

```bash
docker run --rm   -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY   -v $(pwd)/src:/workspace/src   claude-skills:runner   "/tdd Write Jest tests for /workspace/src/auth/login.ts"
```

Or for [`pdf` skill](/claude-skills-guide/best-claude-skills-for-data-analysis/) extraction:

```bash
docker run --rm   -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY   -v $(pwd)/documents:/workspace/documents   -v $(pwd)/output:/workspace/output   claude-skills:runner   "/pdf Extract all tables from /workspace/documents/report.pdf and save to /workspace/output/tables.md"
```

## Step 3: Entrypoint Script with Validation

For production use, add an entrypoint script that validates required environment variables:

```bash
#!/bin/sh
# docker/entrypoint.sh
set -e

if [ -z "$ANTHROPIC_API_KEY" ]; then
  echo "Error: ANTHROPIC_API_KEY environment variable is required"
  exit 1
fi

exec claude -p "$@"
```

```dockerfile
# Dockerfile.validated
FROM node:20-alpine

RUN npm install -g @anthropic-ai/claude-code

WORKDIR /workspace

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

## Step 4: Docker Compose for Multi-Skill Workflows

Create a `docker-compose.yml` for running multiple skill jobs:

```yaml
version: '3.9'

services:
  claude-tdd:
    build:
      context: .
      dockerfile: Dockerfile.validated
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    volumes:
      - ./src:/workspace/src:ro
    profiles: ["tdd"]

  claude-pdf:
    build:
      context: .
      dockerfile: Dockerfile.validated
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    volumes:
      - ./documents:/workspace/documents:ro
      - ./output:/workspace/output
    profiles: ["pdf"]

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  redis_data:
```

Run specific profiles:

```bash
# Run TDD review
docker compose --profile tdd run --rm claude-tdd   "/tdd Find untested functions in /workspace/src/"

# Run PDF processing
docker compose --profile pdf run --rm claude-pdf   "/pdf Extract action items from /workspace/documents/meeting-notes.pdf"
```

## Step 5: Build an HTTP API Container for Skills

Create a persistent HTTP server that exposes skills as REST endpoints for other services:

```javascript
// server.js
const express = require('express');
const { execFile } = require('child_process');
const app = express();

app.use(express.json({ limit: '10mb' }));

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.post('/skill/:name', async (req, res) => {
  const { name } = req.params;
  const { prompt } = req.body;
  
  const validSkills = ['tdd', 'pdf', 'supermemory', 'frontend-design', 'docx', 'xlsx'];
  if (!validSkills.includes(name)) {
    return res.status(400).json({ error: `Unknown skill: ${name}` });
  }
  
  if (!prompt) {
    return res.status(400).json({ error: 'prompt is required' });
  }
  
  const fullPrompt = `/${name} ${prompt}`;
  
  execFile('claude', ['-p', fullPrompt], {
    env: { ...process.env },
    timeout: 120000,
  }, (err, stdout, stderr) => {
    if (err) {
      return res.status(500).json({ error: err.message, stderr });
    }
    res.json({ result: stdout.trim() });
  });
});

app.listen(8080, () => console.log('Claude Skills API running on :8080'));
```

```dockerfile
# Dockerfile.api
FROM node:20-alpine

RUN npm install -g @anthropic-ai/claude-code
RUN npm install express

WORKDIR /app
COPY server.js .

EXPOSE 8080
CMD ["node", "server.js"]
```

Call it:

```bash
curl -X POST http://localhost:8080/skill/tdd \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Review function add(a,b) { return a+b; } for missing tests"}'
```

## Step 6: Use BuildKit Cache for Faster Builds

```dockerfile
# syntax=docker/dockerfile:1.4
FROM node:20-alpine

# Mount npm cache between builds
RUN --mount=type=cache,target=/root/.npm \
    npm install -g @anthropic-ai/claude-code

WORKDIR /app
```

Enable BuildKit:

```bash
DOCKER_BUILDKIT=1 docker build -t claude-skills:latest .
```

## Step 7: Multi-Stage Build for Production

Keep the final image lean:

```dockerfile
# Build stage
FROM node:20-alpine AS builder
RUN npm install -g @anthropic-ai/claude-code
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Runtime stage
FROM node:20-alpine AS runtime
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin/claude /usr/local/bin/claude
COPY --from=builder /app/node_modules /app/node_modules
WORKDIR /app
COPY server.js .

USER node
EXPOSE 8080
CMD ["node", "server.js"]
```

## Step 8: Secrets Management

Never pass API keys as plain environment variables in production. Use Docker secrets:

```yaml
# docker-compose.prod.yml
services:
  claude-api:
    environment:
      - ANTHROPIC_API_KEY_FILE=/run/secrets/anthropic_api_key
    secrets:
      - anthropic_api_key

secrets:
  anthropic_api_key:
    external: true
```

```bash
# Create secret
echo "your_api_key" | docker secret create anthropic_api_key -
```

Read the key from the file in your app:

```javascript
const apiKey = require('fs').readFileSync(process.env.ANTHROPIC_API_KEY_FILE, 'utf8').trim();
process.env.ANTHROPIC_API_KEY = apiKey;
```

## Step 9: GitHub Actions Integration

Use your container image in CI:

```yaml
jobs:
  claude-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: TDD review via Docker
        run: |
          docker run --rm \
            -e ANTHROPIC_API_KEY=${{ secrets.ANTHROPIC_API_KEY }} \
            -v ${{ github.workspace }}/src:/workspace/src \
            ghcr.io/your-org/claude-skills:latest \
            "/tdd Find untested public functions in /workspace/src/"
```

---

## Related Reading

- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/best-claude-skills-for-devops-and-deployment/) — Deployment-oriented skills that benefit from containerized execution
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Skills worth containerizing with guidance on each
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — When running skills in containers at scale, token cost management becomes critical

Built by theluckystrike — More at [zovo.one](https://zovo.one)
