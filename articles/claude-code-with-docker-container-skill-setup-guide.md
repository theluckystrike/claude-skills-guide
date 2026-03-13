---
layout: default
title: "Claude Code with Docker Container Skill Setup Guide"
description: "Complete guide to setting up Claude Code with Docker containers, including containerized skill execution, environment isolation, and multi-service orchestration with Docker Compose."
date: 2026-03-13
author: theluckystrike
---

# Claude Code with Docker Container Skill Setup Guide

Running Claude Code with Docker containers gives you reproducible, isolated skill execution environments that work identically across developer machines, CI runners, and production servers. This guide covers Claude Code with Docker container skill setup from a basic Dockerfile through multi-container orchestration with Compose, including patterns for the `tdd`, `pdf`, `supermemory`, and `frontend-design` skills.

## Why Containerize Claude Code Skills

Running skills in Docker solves several real problems:

- **Reproducibility**: Every team member runs the same Node.js version and CLI version
- **Isolation**: Skill processes cannot interfere with host system state
- **CI/CD compatibility**: The same container image runs locally and in GitHub Actions or any CI platform
- **Service composition**: Claude skill containers can sit alongside databases, queues, and other services in a Compose stack
- **Secret management**: Credentials stay in container environment variables, not host shell profiles

## Prerequisites

- Docker Desktop 4.x+ (or Docker Engine on Linux)
- Docker Compose v2
- Claude API key

## Step 1: Create the Base Dockerfile

```dockerfile
# Dockerfile
FROM node:20-alpine

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Set working directory
WORKDIR /app

# Copy project files if running in app mode
# COPY package*.json ./
# RUN npm ci

# Default command — override per-skill
CMD ["claude", "--version"]
```

Build and verify:
```bash
docker build -t claude-skills:base .
docker run --rm claude-skills:base
```

## Step 2: Add a Skill-Specific Entrypoint

For dedicated skill containers, use an entrypoint script that sets the skill context:

```bash
#!/bin/sh
# docker/entrypoint-tdd.sh
set -e

if [ -z "$CLAUDE_API_KEY" ]; then
  echo "Error: CLAUDE_API_KEY environment variable is required"
  exit 1
fi

# Default to TDD skill if no command override
exec claude --skill tdd "$@"
```

```dockerfile
# Dockerfile.tdd
FROM node:20-alpine

RUN npm install -g @anthropic-ai/claude-code

WORKDIR /workspace

COPY docker/entrypoint-tdd.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
```

Run a code review:
```bash
docker run --rm \
  -e CLAUDE_API_KEY=$CLAUDE_API_KEY \
  -v $(pwd)/src:/workspace/src \
  claude-skills:tdd \
  --prompt "Review all TypeScript files for missing test coverage" \
  src/
```

## Step 3: Docker Compose for Multi-Skill Setup

Create a `docker-compose.yml` for a full skill stack:

```yaml
version: '3.9'

services:
  claude-tdd:
    build:
      context: .
      dockerfile: Dockerfile.tdd
    environment:
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
    volumes:
      - ./src:/workspace/src:ro
    profiles: ["tdd"]

  claude-pdf:
    build:
      context: .
      dockerfile: Dockerfile
    command: ["--skill", "pdf"]
    environment:
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
    volumes:
      - ./documents:/workspace/documents:ro
      - ./output:/workspace/output
    profiles: ["pdf"]

  claude-api:
    build:
      context: .
      dockerfile: Dockerfile.api
    ports:
      - "8080:8080"
    environment:
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

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
docker compose --profile tdd run --rm claude-tdd \
  --prompt "Find untested functions" src/

# Run PDF processing
docker compose --profile pdf run --rm claude-pdf \
  --prompt "Extract action items" documents/meeting-notes.pdf
```

## Step 4: Build an API Container for Skills

Create a persistent HTTP server that exposes skills as REST endpoints:

```javascript
// server.js
const express = require('express');
const { execFile } = require('child_process');
const app = express();

app.use(express.json({ limit: '10mb' }));

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.post('/skill/:name', async (req, res) => {
  const { name } = req.params;
  const { prompt, content } = req.body;
  
  const validSkills = ['tdd', 'pdf', 'supermemory', 'frontend-design'];
  if (!validSkills.includes(name)) {
    return res.status(400).json({ error: `Unknown skill: ${name}` });
  }
  
  const fullPrompt = content ? `${prompt}\n\n${content}` : prompt;
  
  execFile('claude', ['--skill', name, '--prompt', fullPrompt], {
    env: { ...process.env, CLAUDE_API_KEY: process.env.CLAUDE_API_KEY },
    timeout: 60000,
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
  -d '{"prompt": "Review this function", "content": "function add(a,b) { return a+b; }"}'
```

## Step 5: Use BuildKit Cache for Faster Builds

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

## Step 6: Multi-Stage Build for Production

Keep the final image lean by using multi-stage builds:

```dockerfile
# Build stage
FROM node:20-alpine AS builder
RUN npm install -g @anthropic-ai/claude-code
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Runtime stage
FROM node:20-alpine AS runtime
# Copy only what's needed from builder
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin/claude /usr/local/bin/claude
COPY --from=builder /app/node_modules /app/node_modules
WORKDIR /app
COPY server.js .

USER node
EXPOSE 8080
CMD ["node", "server.js"]
```

## Step 7: Secrets Management in Production

Never pass API keys as plain environment variables in production. Use Docker secrets or a secrets manager:

```yaml
# docker-compose.prod.yml
services:
  claude-api:
    environment:
      - CLAUDE_API_KEY_FILE=/run/secrets/claude_api_key
    secrets:
      - claude_api_key

secrets:
  claude_api_key:
    external: true
```

```bash
# Create secret
echo "your_api_key" | docker secret create claude_api_key -

# In your app, read from file:
const apiKey = require('fs').readFileSync(process.env.CLAUDE_API_KEY_FILE, 'utf8').trim();
```

## Step 8: GitHub Actions Integration

Use your container image in CI:

```yaml
jobs:
  claude-review:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/your-org/claude-skills:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    env:
      CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
    steps:
      - uses: actions/checkout@v4
      - name: TDD review
        run: claude --skill tdd --prompt "Review changed files" src/
```

## Conclusion

Running Claude Code with Docker container skill setup gives you portable, reproducible AI skill execution that works from development through production. The API container pattern is especially useful for teams that want to expose skills as services consumed by multiple applications. Start with the base Dockerfile and Compose setup, then move to the API container once you need programmatic access.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
