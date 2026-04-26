---

layout: default
title: "Claude Code Docker Compose Development (2026)"
description: "A practical guide to integrating Claude Code with Docker Compose for streamlined local development, testing, and deployment workflows."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-docker-compose-development-workflow/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Docker Compose has become an essential tool for developers managing multi-container applications. When combined with Claude Code, you get a powerful development environment where AI assistance handles container orchestration, debugging, and service configuration while you focus on writing code. This guide shows you how to build an efficient development workflow using Claude Code with Docker Compose, covering everything from initial setup to production-ready patterns.

## Setting Up Your Development Environment

The foundation of a solid Docker Compose workflow starts with a well-structured project. Your directory layout should separate concerns between your application code and container configuration. A more complete project structure looks like this:

```
my-project/
 docker-compose.yml
 docker-compose.override.yml
 docker-compose.prod.yml
 Dockerfile
 Dockerfile.dev
 src/
 api/
 workers/
 tests/
 unit/
 integration/
 scripts/
 entrypoint.sh
 wait-for-it.sh
 .env
 .env.example
 .dockerignore
```

The `.dockerignore` file is often overlooked but matters for build performance. It prevents large directories like `node_modules`, `.git`, and test output from being sent to the Docker build context:

```
node_modules
.git
.env
*.log
coverage/
dist/
```

When you invoke Claude Code to help with this setup, describe your stack clearly. For example, if you're building a web application with a database and caching layer, specify each service:

```bash
claude "Create a docker-compose.yml with a Node.js API service, PostgreSQL database, and Redis cache. Include proper volume mounts for development, health checks, and dependency ordering."
```

Claude Code generates a Compose file tailored to your requirements, including health checks and `depends_on` conditions that prevent your API from starting before the database is ready. You can then refine it interactively: ask Claude to add a worker service, change the base image, or configure resource limits.

## Essential Docker Compose Commands for Development

Claude Code excels at translating your intent into precise Docker commands. Here are the workflows you'll use most frequently:

Starting your development environment:

```bash
docker-compose up -d
```

Starting and watching logs immediately:

```bash
docker-compose up
```

Rebuilding images when your Dockerfile changes:

```bash
docker-compose up -d --build
```

Viewing logs from all services:

```bash
docker-compose logs -f
```

Viewing logs from a single service:

```bash
docker-compose logs -f api
```

Accessing a specific service shell:

```bash
docker-compose exec api sh
or for bash if available
docker-compose exec api bash
```

Running a one-off command without starting the service:

```bash
docker-compose run --rm api npm run migrate
```

Stopping without removing containers:

```bash
docker-compose stop
```

Stopping and removing containers, networks, and volumes:

```bash
docker-compose down -v
```

The difference between `stop` and `down -v` matters: `stop` preserves your database volume so data persists across restarts, while `down -v` wipes everything for a clean slate. Use `down -v` when you need to reset test state or clear a corrupted database.

When you're stuck on a Docker issue, describe the problem to Claude. If your containers fail to start or you encounter networking problems, paste the error output and ask for troubleshooting steps. Claude can analyze the error messages and suggest fixes. whether it's a port conflict, missing environment variable, or volume mounting issue.

## Complete docker-compose.yml for a Production-Grade Dev Stack

Below is a realistic, full-featured Compose file for a Node.js API with PostgreSQL, Redis, and a background worker. This is the kind of output you can ask Claude to generate for you:

```yaml
version: "3.9"

services:
 api:
 build:
 context: .
 dockerfile: Dockerfile.dev
 ports:
 - "${API_PORT:-3000}:3000"
 volumes:
 - ./src:/app/src
 - /app/node_modules
 environment:
 - NODE_ENV=development
 - DATABASE_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
 - REDIS_URL=redis://cache:6379
 depends_on:
 db:
 condition: service_healthy
 cache:
 condition: service_started
 restart: unless-stopped

 worker:
 build:
 context: .
 dockerfile: Dockerfile.dev
 volumes:
 - ./src:/app/src
 - /app/node_modules
 environment:
 - NODE_ENV=development
 - DATABASE_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
 - REDIS_URL=redis://cache:6379
 command: npm run worker
 depends_on:
 db:
 condition: service_healthy
 restart: unless-stopped

 db:
 image: postgres:16-alpine
 environment:
 - POSTGRES_DB=${POSTGRES_DB}
 - POSTGRES_USER=${POSTGRES_USER}
 - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
 volumes:
 - postgres_data:/var/lib/postgresql/data
 - ./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
 healthcheck:
 test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
 interval: 10s
 timeout: 5s
 retries: 5
 ports:
 - "5432:5432"

 cache:
 image: redis:7-alpine
 volumes:
 - redis_data:/data
 command: redis-server --appendonly yes
 ports:
 - "6379:6379"

volumes:
 postgres_data:
 redis_data:
```

The `service_healthy` condition on `depends_on` is critical. Without it, your API container starts immediately after PostgreSQL's container starts, but the database process inside may not be accepting connections yet. The health check ensures your API only starts when the database is truly ready.

## Integrating Claude Skills for Docker Workflows

Several Claude skills enhance your Docker Compose development:

- tdd: Write tests alongside your containerized services
- pdf: Generate documentation about your architecture
- frontend-design: Design UIs that run in development containers
- supermemory: Recall Docker troubleshooting solutions across projects

The tdd skill pairs well with Docker Compose because you can run tests inside containers without polluting your host system. Define a test service in your Compose file that shares the same build but runs in test mode:

```yaml
services:
 api:
 build: .
 volumes:
 - ./src:/app/src
 command: npm run dev

 test:
 build: .
 volumes:
 - ./src:/app/src
 - ./tests:/app/tests
 command: npm test
 environment:
 - NODE_ENV=test
 - DATABASE_URL=postgres://test_user:test_pass@db_test:5432/test_db
 depends_on:
 db_test:
 condition: service_healthy

 db_test:
 image: postgres:16-alpine
 environment:
 - POSTGRES_DB=test_db
 - POSTGRES_USER=test_user
 - POSTGRES_PASSWORD=test_pass
 tmpfs:
 - /var/lib/postgresql/data
 healthcheck:
 test: ["CMD-SHELL", "pg_isready -U test_user -d test_db"]
 interval: 5s
 timeout: 3s
 retries: 10
```

Using `tmpfs` for the test database stores data in memory rather than on disk. Integration tests run faster and the database resets automatically each time the container stops.

Run your test container in isolation: `docker-compose run --rm test`. This approach keeps your testing environment identical across all team members regardless of their local setup.

## Debugging Containerized Applications

Debugging inside Docker containers requires a different approach than local development. Here is a structured way to diagnose the most common failure modes with Claude's help:

## Container exits immediately

Check logs with `docker-compose logs service-name`. The most common causes are missing dependencies, syntax errors in environment variables, or an entrypoint script exiting non-zero. Paste the full log output to Claude for analysis.

```bash
docker-compose logs api --tail=50
```

## Network connectivity issues

In Docker Compose, services communicate using their service names as hostnames. not `localhost`. If your API tries to connect to `localhost:5432`, it fails because Postgres is in a different container. The correct connection string is:

```
postgres://user:password@db:5432/myapp
```

You can verify DNS resolution from inside a container:

```bash
docker-compose exec api nslookup db
docker-compose exec api curl -v http://cache:6379
```

## Permission problems on volume mounts

Containers often run as a non-root user, but mounted host files may have different ownership. Fix this by matching UIDs in your Dockerfile:

```dockerfile
FROM node:20-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --chown=appuser:appgroup package*.json ./
RUN npm ci
COPY --chown=appuser:appgroup . .
USER appuser
```

## Port already in use

When a port is taken, Docker fails with `Bind for 0.0.0.0:5432 failed: port is already allocated`. Find what process holds it and either stop that process or change the host-side port mapping in Compose:

```bash
Find the process using port 5432
lsof -i :5432
Then kill it or change the Compose mapping to "5433:5432"
```

When debugging, provide Claude with specific error messages and your Compose configuration. The more context you give, the more accurate the troubleshooting guidance.

## Environment Configuration Best Practices

Environment variables are critical for Docker Compose workflows. A well-organized `.env` file covers all services:

```bash
.env file. never commit this
Application
API_PORT=3000
NODE_ENV=development

Database
POSTGRES_DB=myapp
POSTGRES_USER=developer
POSTGRES_PASSWORD=dev_password_change_me

Redis
REDIS_PASSWORD=

Feature flags
ENABLE_EMAIL_VERIFICATION=false
LOG_LEVEL=debug
```

Reference these in your Compose file using variable substitution with defaults:

```yaml
services:
 api:
 build: .
 ports:
 - "${API_PORT:-3000}:3000"
 environment:
 - DATABASE_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
 - LOG_LEVEL=${LOG_LEVEL:-info}
 depends_on:
 - db

 db:
 image: postgres:16-alpine
 environment:
 - POSTGRES_DB=${POSTGRES_DB}
 - POSTGRES_USER=${POSTGRES_USER}
 - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
 volumes:
 - postgres_data:/var/lib/postgresql/data

volumes:
 postgres_data:
```

The `:-` default syntax (`${API_PORT:-3000}`) provides a fallback when the variable is not set, making the Compose file usable without a `.env` file in some contexts.

Never commit `.env` to version control. Add it to `.gitignore` and maintain a `.env.example` with placeholder values and comments:

```bash
.env.example. commit this, it documents required variables
API_PORT=3000
NODE_ENV=development
POSTGRES_DB=myapp
POSTGRES_USER=developer
POSTGRES_PASSWORD=CHANGE_ME
REDIS_PASSWORD=
LOG_LEVEL=debug
```

## Optimizing Development Speed

Slow builds and restarts kill developer productivity. These patterns keep iteration fast:

## Multi-stage Dockerfiles for dev vs. production

A `Dockerfile.dev` installs dev dependencies and uses nodemon for hot reloading:

```dockerfile
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

FROM base AS development
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

FROM base AS production
RUN npm ci --only=production
COPY src/ ./src/
CMD ["node", "src/index.js"]
```

## Hot-reload volume mounts

```yaml
services:
 api:
 build:
 context: .
 dockerfile: Dockerfile.dev
 target: development
 volumes:
 - ./src:/app/src
 - /app/node_modules
 environment:
 - NODE_ENV=development
 - CHOKIDAR_USEPOLLING=true
```

The anonymous volume `/app/node_modules` prevents the host's `node_modules` directory (or its absence) from overwriting the container's installed packages. `CHOKIDAR_USEPOLLING=true` is needed on some macOS and Windows hosts where inotify events do not propagate into containers reliably.

## Comparison: volume mount strategies

| Strategy | Use case | Tradeoff |
|---|---|---|
| `./src:/app/src` (bind mount) | Source code hot reload | Slightly slower I/O on macOS |
| Named volume for `node_modules` | Preserve container packages | Cannot inspect from host easily |
| `tmpfs` for test database | Fast throwaway test DB | Data lost on container stop |
| Anonymous volume | Ephemeral scratch space | Cannot be reused across runs |
| No volume (copy only) | Production builds | Immutable, no live reload |

## Managing Multiple Projects

As you work on multiple Docker Compose projects simultaneously, container and network names collide unless you use project names. There are two ways to set the project name:

Using the `-p` flag:

```bash
docker-compose -p myproject up -d
docker-compose -p myproject logs -f
docker-compose -p myproject down
```

Using the `COMPOSE_PROJECT_NAME` variable in `.env`:

```bash
COMPOSE_PROJECT_NAME=myproject
```

Setting it in `.env` is more convenient because every `docker-compose` command in that directory automatically uses the right project name without extra flags.

To see all running Compose projects at a glance:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

You can also use `docker-compose ls` (available in Compose v2) to list active projects:

```bash
docker compose ls
```

The supermemory skill helps you remember project-specific Docker configurations across different work sessions. Ask Claude to index your Compose files, common debugging patterns, and the specific quirks of each project so you can retrieve them by name in future sessions.

## Splitting Configuration with Override Files

Docker Compose supports layered configuration through override files. The base `docker-compose.yml` defines the canonical architecture, while environment-specific files add or change settings without touching the base:

`docker-compose.yml` (base. committed):

```yaml
services:
 api:
 build: .
 environment:
 - NODE_ENV=production
 db:
 image: postgres:16-alpine
```

`docker-compose.override.yml` (dev. committed, auto-merged):

```yaml
services:
 api:
 build:
 dockerfile: Dockerfile.dev
 volumes:
 - ./src:/app/src
 - /app/node_modules
 environment:
 - NODE_ENV=development
 ports:
 - "3000:3000"
 db:
 ports:
 - "5432:5432"
```

`docker-compose.prod.yml` (production. explicit):

```yaml
services:
 api:
 image: myregistry/myapp:${IMAGE_TAG}
 deploy:
 replicas: 2
 resources:
 limits:
 cpus: "0.5"
 memory: 512M
```

Run production locally for testing:

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

This pattern keeps your development ergonomics (exposed ports, volume mounts, debug logging) completely separate from production concerns (resource limits, image tags, replica counts).

## Production Considerations

While Docker Compose excels at local development, production deployments typically use Kubernetes or managed container services. However, your Compose files still serve as valuable documentation for your architecture and can drive CI/CD pipelines.

## Using Compose in CI pipelines

GitHub Actions can spin up your full stack to run integration tests:

```yaml
.github/workflows/test.yml
jobs:
 integration-tests:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - name: Start services
 run: docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d
 - name: Wait for health checks
 run: docker-compose run --rm wait
 - name: Run integration tests
 run: docker-compose run --rm test
 - name: Collect logs on failure
 if: failure()
 run: docker-compose logs
 - name: Tear down
 if: always()
 run: docker-compose down -v
```

Use the pdf skill to generate architecture documentation from your Compose configuration:

```bash
claude "Use the pdf skill to create an architecture diagram from this docker-compose.yml showing service relationships, dependencies, port mappings, and data flows."
```

Keep development and production configurations separate using the override pattern described above. This avoids the common mistake of accidentally running production containers with development volume mounts that expose source code.

## Compose v1 vs. Compose v2 command syntax

| Action | Compose v1 | Compose v2 |
|---|---|---|
| Start services | `docker-compose up` | `docker compose up` |
| List projects | Not available | `docker compose ls` |
| Copy files | `docker-compose cp` | `docker compose cp` |
| Profile support | Limited | `--profile` flag |
| Config merge | Manual | `docker compose config` |

Compose v2 ships as a Docker CLI plugin (note: no hyphen in `docker compose`). It is the current standard and adds features like profiles, which let you define optional services that only start when requested:

```yaml
services:
 api:
 build: .

 adminer:
 image: adminer
 profiles: ["tools"]
 ports:
 - "8080:8080"
```

Start everything including tools: `docker compose --profile tools up -d`. By default, `docker compose up -d` starts only `api`, keeping your dev environment lean.

## Conclusion

Claude Code transforms Docker Compose from a manual orchestration tool into an intelligent development partner. By describing your goals and problems in natural language, you get actionable Docker commands, debugging guidance, and complete Compose configurations tailored to your stack. The key practices covered here. layered override files, health check dependencies, hot-reload volume mounts, per-project naming, and CI integration. make the difference between a fragile local setup and one that works consistently across your entire team. Combined with skills like tdd for containerized testing, pdf for architecture documentation, and supermemory for knowledge retention, you build a development workflow that is both powerful and maintainable from day one.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-docker-compose-development-workflow)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code DevOps Engineer Docker Container Workflow Tips](/claude-code-devops-engineer-docker-container-workflow-tips/)
- [Claude Code Docker Compose API Tutorial Guide](/claude-code-docker-compose-api-tutorial-guide/)
- [Claude Code Docker Compose Production Guide](/claude-code-docker-compose-production-guide/)
- [Claude Code Azure Functions Development Workflow](/claude-code-azure-functions-development-workflow/)
- [Claude Code Docker Secrets Management Guide](/claude-code-docker-secrets-management-guide/)
- [How to Use GitHub Actions OIDC Workflow (2026)](/claude-code-for-github-actions-oidc-workflow-guide/)
- [Claude Code GitHub Actions Environment Protection](/claude-code-github-actions-environment-protection/)
- [Claude Code for Helm Hooks Workflow Tutorial](/claude-code-for-helm-hooks-workflow-tutorial/)
- [Claude Code GitHub Actions Composite Actions](/claude-code-github-actions-composite-actions/)
- [Claude Code For Act Local GitHub — Complete Developer Guide](/claude-code-for-act-local-github-actions-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

