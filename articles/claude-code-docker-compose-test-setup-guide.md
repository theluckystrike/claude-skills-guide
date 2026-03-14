---
layout: default
title: "Claude Code Docker Compose Test Setup Guide"
description: "Set up Docker Compose environments for testing Claude Code skills. Includes containerized skill execution, test databases, mock services, and CI integration patterns."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, docker, docker-compose, testing, devops]
author: theluckystrike
reviewed: false
score: 0
permalink: /claude-code-docker-compose-test-setup-guide/
---

{% raw %}

# Claude Code Docker Compose Test Setup Guide

Running Claude Code skills inside Docker Compose gives you repeatable test environments where you can spin up databases, mock APIs, and isolated skill executions without polluting your host system. This guide walks through practical setups for testing skills that interact with external services, databases, and CI pipelines.

## Why Use Docker Compose for Skill Testing

When you test Claude Code skills that modify files, call APIs, or manage infrastructure, you need controlled environments. Docker Compose lets you:

- Spin up fresh databases for each test run
- Mock external APIs that your skills depend on
- Run multiple Claude Code instances in isolation
- Reproduce CI failures locally
- Test skills that require specific runtime versions

The `tdd` skill, for example, works best when it can create and destroy test databases without affecting your local setup. Similarly, the `pdf` skill needs controlled file system access that containers provide naturally.

## Basic Docker Compose Setup for Claude Code

Create a `docker-compose.yml` that runs Claude Code in an isolated container with access to your project files:

```yaml
version: '3.8'

services:
  claude-code:
    image: node:20-alpine
    working_dir: /app
    volumes:
      - ./project:/app
      - claude_cache:/root/.cache/claude
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    command: tail -f /dev/null
    networks:
      - claude-network

  test-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: testdb
      POSTGRES_USER: testuser
      POSTGRES_PASSWORD: testpass
    networks:
      - claude-network

  mock-api:
    image: mockserver/mockserver:latest
    environment:
      MOCKSERVER_INITIALIZATION_JSON_PATH: /config/init.json
    ports:
      - "1080:1080"
    networks:
      - claude-network

volumes:
  claude_cache:

networks:
  claude-network:
    driver: bridge
```

This setup gives you three containers: one for Claude Code, one for a PostgreSQL test database, and one for a mock API server. All three share a network so they can communicate.

## Testing the tdd Skill in Docker

The `tdd` skill shines when you need to generate tests against a fresh database. Here's how to test it:

```bash
# Start the environment
docker compose up -d

# Run the tdd skill inside the container
docker compose exec claude-code npx -y @anthropic-ai/claude-code tdd \
  --pattern "src/**/*.ts" \
  --framework jest \
  --database postgres://testuser:testpass@test-db:5432/testdb
```

The skill generates tests that connect to the containerized PostgreSQL instance. Because the database is isolated, you can run destructive tests without worry. After testing, destroy everything with `docker compose down -v` to start fresh.

For the `pdf` skill, mount a volume containing the documents you want to process:

```yaml
services:
  claude-code:
    # ... existing config
    volumes:
      - ./project:/app
      - ./documents:/documents:ro
      - claude_cache:/root/.cache/claude
```

Then run the skill against documents in that folder:

```bash
docker compose exec claude-code npx -y @anthropic-ai/claude-code pdf \
  --operation extract \
  --source /documents/report.pdf \
  --output /app/extracted/
```

## Mocking External Services

Skills that call third-party APIs need mocking. Use the mock-api service to intercept requests:

```json
{
  "httpRequest": {
    "method": "POST",
    "path": "/api/v1/users"
  },
  "httpResponse": {
    "statusCode": 201,
    "body": {
      "id": "usr_123",
      "status": "created"
    },
    "delay": {
      "timeUnit": "MILLISECONDS",
      "value": 100
    }
  }
}
```

Save this as `mockserver/init.json` and the mock-api container initializes with these expectations. Your skill sees realistic responses without hitting real APIs. This approach works well for testing the `supermemory` skill when it calls external storage services, or the `frontend-design` skill when it validates against design system APIs.

## Running Multiple Skill Instances

For testing agent swarms or multi-skill workflows, scale the Claude Code service:

```bash
docker compose up -d --scale claude-code=3
```

Each instance gets its own container but shares the network and volumes. This lets you test how skills coordinate through shared state or message queues:

```yaml
services:
  redis:
    image: redis:7-alpine
    networks:
      - claude-network

  claude-code:
    # ... 
    depends_on:
      - redis
    environment:
      - REDIS_URL=redis://redis:6379
```

The `supermemory` skill can use Redis to share context between instances, simulating a multi-agent workflow on your local machine.

## CI Integration

Once your Compose setup works locally, translate it to CI. GitHub Actions example:

```yaml
jobs:
  test-skill:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Start test environment
        run: docker compose up -d
        
      - name: Run skill tests
        run: |
          docker compose exec -T claude-code npx -y \
            @anthropic-ai/claude-code tdd \
            --pattern "src/**/*.ts" \
            --output /app/tests/
          
      - name: Run test suite
        run: docker compose exec -T test-db \
          psql -U testuser -d testdb -f /app/tests/run.sql
      
      - name: Cleanup
        if: always()
        run: docker compose down -v
```

The `-T` flag disables pseudo-TTY allocation, which works better in CI environments. The `-v` flag removes volumes, ensuring each CI run starts with a completely fresh database.

## Debugging Skills in Containers

When a skill fails inside Docker, attach to the running container:

```bash
docker compose exec claude-code sh
```

From there, you can inspect the skill's output, check environment variables, and manually run commands to reproduce issues. The Alpine-based image keeps the footprint small while providing the tools you need for debugging.

For persistent debugging sessions, override the command in your override file:

```yaml
# docker-compose.override.yml
services:
  claude-code:
    command: sleep infinity
    volumes:
      - ./project:/app
      - ./debug-scripts:/debug
```

Then exec into the container and run your debugging tools from the mounted `/debug` folder.

## Health Checks for Skill Services

Add health checks to ensure services are ready before running skills:

```yaml
services:
  test-db:
    image: postgres:15-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U testuser -d testdb"]
      interval: 5s
      timeout: 5s
      retries: 5

  claude-code:
    depends_on:
      test-db:
        condition: service_healthy
```

Docker Compose waits for the database to be healthy before starting Claude Code, preventing connection failures on startup.

## Cleanup and Resource Management

Always clean up after testing:

```bash
# Remove containers, networks, and named volumes
docker compose down -v

# Remove unused images to save disk space
docker compose build --no-cache && docker image prune -f

# Remove entirely unused volumes
docker volume prune -f
```

For faster subsequent runs, keep the images cached but rebuild the volumes:

```bash
docker compose down
docker compose up -d --build
```

This rebuilds containers with your latest skill code while reusing downloaded layers.

## Summary

Docker Compose provides the isolation and repeatability you need for testing Claude Code skills. Whether you're running the `tdd` skill against a fresh database, the `pdf` skill on isolated documents, or coordinating multiple instances with `supermemory`, containers give you confidence that your skills work correctly before deploying to production.

The key patterns are: isolate each test run with fresh volumes, mock external dependencies, scale horizontally for multi-agent tests, and mirror your local setup in CI for consistent results.

Built by theluckystrike — More at [zovo.one](https://zovo.one)

{% endraw %}
