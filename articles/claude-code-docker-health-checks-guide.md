---
layout: default
title: "Claude Code Docker Health Checks Guide"
description: "Learn how to implement Docker health checks for your containerized applications with practical examples and best practices."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-docker-health-checks-guide/
---

{% raw %}
Docker health checks provide a standardized way to monitor the health status of your containers. When you integrate health checks into your Docker workflow, you gain automatic detection of failing services, better orchestration decisions from Docker Compose and Swarm, and improved debugging capabilities. This guide walks you through implementing Docker health checks effectively, with practical examples you can apply to your projects.

## Understanding Docker Health Checks

A health check is a command that Docker runs inside your container to determine whether the container is working correctly. Unlike basic container status, health checks evaluate the actual application state. Docker periodically executes the health check command and tracks the result: starting (initial state), healthy, unhealthy, or starting again after a failure.

Health checks become essential when your application has internal dependencies or complex initialization sequences. For instance, a web application might start its process before database connections are ready. Without health checks, Docker considers the container running immediately after the process starts, even if the application isn't actually functional.

## Implementing Health Checks in Your Dockerfile

The HEALTHCHECK instruction defines a command Docker uses to test container health. Here's a practical example for a Node.js application:

```dockerfile
FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "
    const http = require('http');
    const options = { hostname: 'localhost', port: 3000, path: '/health', method: 'GET' };
    const req = http.request(options, (res) => {
      process.exit(res.statusCode === 200 ? 0 : 1);
    });
    req.on('error', () => process.exit(1));
    req.end();
  "

CMD ["node", "server.js"]
```

The `--interval` flag specifies how often Docker runs the health check (30 seconds in this case). The `--timeout` flag limits how long each check can run before being considered failed. The `--start-period` flag gives your application time to initialize before the first health check runs, preventing false negatives during startup. The `--retries` flag determines how many consecutive failures trigger an unhealthy status.

For a Python Flask application, the health check might look different:

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "
    import urllib.request
    import sys
    try:
        response = urllib.request.urlopen('http://localhost:5000/api/health', timeout=5)
        sys.exit(0) if response.getcode() == 200 else sys.exit(1)
    except Exception:
        sys.exit(1)
  "

CMD ["python", "app.py"]
```

## Health Checks with Docker Compose

When running multi-container applications with Docker Compose, health checks enable service dependencies to wait for dependencies to become healthy. This prevents race conditions where one service starts before its dependencies are ready.

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d app"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://user:password@postgres:5432/app

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    depends_on:
      api:
        condition: service_started
```

The key here is the `condition: service_healthy` directive. Docker Compose waits for the postgres container to report healthy status before starting the api service. This eliminates the need for custom wait scripts in your application startup logic.

## Monitoring Container Health

Once health checks are in place, you can inspect container status using the Docker CLI:

```bash
docker ps
```

The output includes a status column showing health check results. For detailed information:

```bash
docker inspect --format='{{.State.Health}}' container_name
```

This returns the full health status object including status, failing streak, and check logs. In production environments, you might want to aggregate this data using monitoring tools. The supermemory skill can help you track health check patterns over time, creating a knowledge base of common failure modes and their resolutions.

For log aggregation, you can filter health check results:

```bash
docker inspect --format='{{range .State.Health.Log}}{{.Output}}{{"\n"}}{{end}}' container_name
```

This extracts just the output from health check commands, useful for debugging why checks are failing.

## Health Checks for Different Application Types

Different application types require different health check strategies. A REST API typically checks an endpoint that validates database connectivity and critical dependencies. A background worker might check that it can connect to message queues and that processing queues are not growing unbounded.

For Redis:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD redis-cli ping
```

For MongoDB:

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD mongosh --quiet --eval "db.adminCommand('ping')"
```

For custom scripts included in your image, ensure they're executable:

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD /app/scripts/healthcheck.sh
```

## Best Practices

Keep health checks lightweight. They're running continuously, so avoid expensive operations. A simple connectivity test to critical dependencies usually suffices.

Place health checks in your application rather than relying on process existence. A process can be running while deadlocked or misbehaving. Application-level health checks catch these scenarios.

Set appropriate start periods for slow-starting applications. Too short, and you'll get false failures during normal startup. Too long, and you delay detection of actual startup failures.

Use descriptive exit codes. Exit 0 means healthy, anything else indicates problems. If your application has multiple failure modes, consider using different exit codes and monitoring the health check output.

Document your health check endpoints. If your API exposes a `/health` endpoint, document what it validates. Teams using the tdd skill often include health check validation in their test suites, ensuring the health endpoint accurately reflects system state.

## Automation with Claude Code

When building Docker-based applications with Claude Code, you can automate health check generation. The supermemory skill stores your project patterns, so health checks for similar services follow consistent patterns. The pdf skill helps generate documentation for your health check configurations. The frontend-design skill ensures any health dashboard you build follows consistent UI patterns.

{% endraw %}
Built by theluckystrike — More at [zovo.one](https://zovo.one)
