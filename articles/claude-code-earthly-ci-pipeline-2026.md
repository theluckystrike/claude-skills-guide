---
title: "Claude Code for Earthly CI Pipeline Development (2026)"
permalink: /claude-code-earthly-ci-pipeline-2026/
description: "Build reproducible CI pipelines with Earthly and Claude Code. Write Earthfiles, cache dependencies, and run identical builds locally and in CI."
last_tested: "2026-04-22"
domain: "CI/CD"
render_with_liquid: false
---

## Why Claude Code for Earthly

Earthly combines the best of Dockerfiles and Makefiles into a single build tool that produces identical results locally and in CI. Unlike traditional CI configs (GitHub Actions YAML, Jenkins Groovy), Earthfiles use a familiar Dockerfile-like syntax with targets, dependencies, and caching that works on any CI platform. The challenge is writing efficient Earthfiles that properly layer caching, handle multi-language monorepos, and orchestrate parallel build targets. Most teams underuse Earthly's satellite builds, secrets handling, and artifact sharing.

Claude Code generates Earthfiles with optimal caching layers, proper dependency graphs between targets, and CI integration configurations that eliminate the "works on my machine" problem entirely.

## The Workflow

### Step 1: Install and Initialize Earthly

```bash
# Install Earthly
brew install earthly/earthly/earthly  # macOS
# or: curl -fsSL https://earthly.dev/get | sh

# Initialize in project root
earthly bootstrap

# Verify installation
earthly --version
```

### Step 2: Write a Multi-Stage Earthfile

```dockerfile
# Earthfile - Reproducible builds for a Node.js + Python monorepo
VERSION 0.8

# Base images as reusable targets
node-base:
    FROM node:20-slim
    WORKDIR /app
    ENV PNPM_HOME="/pnpm"
    ENV PATH="$PNPM_HOME:$PATH"
    RUN corepack enable

python-base:
    FROM python:3.12-slim
    WORKDIR /app
    RUN pip install --no-cache-dir poetry
    ENV POETRY_VIRTUALENVS_IN_PROJECT=true

# Frontend build with layer caching
frontend-deps:
    FROM +node-base
    COPY frontend/package.json frontend/pnpm-lock.yaml ./frontend/
    RUN cd frontend && pnpm install --frozen-lockfile
    SAVE IMAGE --cache-hint

frontend-build:
    FROM +frontend-deps
    COPY frontend/ ./frontend/
    RUN cd frontend && pnpm run build
    RUN cd frontend && pnpm run test -- --ci
    SAVE ARTIFACT frontend/dist /dist AS LOCAL ./frontend/dist

frontend-lint:
    FROM +frontend-deps
    COPY frontend/ ./frontend/
    RUN cd frontend && pnpm run lint
    RUN cd frontend && pnpm run typecheck

# Backend build with poetry caching
backend-deps:
    FROM +python-base
    COPY backend/pyproject.toml backend/poetry.lock ./backend/
    RUN cd backend && poetry install --no-root --no-interaction
    SAVE IMAGE --cache-hint

backend-build:
    FROM +backend-deps
    COPY backend/ ./backend/
    RUN cd backend && poetry run pytest --tb=short -q
    RUN cd backend && poetry run mypy src/ --strict
    SAVE ARTIFACT backend/ /backend

backend-lint:
    FROM +backend-deps
    COPY backend/ ./backend/
    RUN cd backend && poetry run ruff check src/
    RUN cd backend && poetry run ruff format --check src/

# Docker image build
docker:
    FROM python:3.12-slim
    WORKDIR /app
    COPY +backend-build/backend ./
    COPY +frontend-build/dist ./static/
    RUN pip install --no-cache-dir -r requirements.txt
    EXPOSE 8000
    ENTRYPOINT ["gunicorn", "main:app", "-b", "0.0.0.0:8000"]
    SAVE IMAGE --push myregistry/myapp:latest

# Integration tests using service containers
integration-test:
    FROM +backend-deps
    COPY backend/ ./backend/
    WITH DOCKER --compose docker-compose.test.yml
        RUN cd backend && \
            poetry run pytest tests/integration/ \
            --tb=short -q \
            --timeout=60
    END

# Orchestration targets
lint:
    BUILD +frontend-lint
    BUILD +backend-lint

test:
    BUILD +frontend-build   # includes tests
    BUILD +backend-build    # includes tests

all:
    BUILD +lint
    BUILD +test
    BUILD +integration-test
    BUILD +docker
```

### Step 3: Configure CI Integration

```yaml
# .github/workflows/earthly.yml
name: Earthly CI
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: earthly/actions-setup@v1
        with:
          version: v0.8.15

      # Optional: Earthly Satellite for shared caching
      - name: Login to Earthly Satellite
        if: github.event_name != 'pull_request'
        run: |
          earthly account login --token ${{ secrets.EARTHLY_TOKEN }}
          earthly org select myorg

      - name: Lint (parallel)
        run: earthly +lint

      - name: Test (parallel)
        run: earthly +test

      - name: Integration Test
        run: earthly +integration-test

      - name: Build and Push Docker Image
        if: github.ref == 'refs/heads/main'
        run: earthly --push +docker
```

### Step 4: Verify

```bash
# Run full build locally (identical to CI)
earthly +all

# Run specific target with verbose output
earthly --verbose +backend-build

# Debug a failing target interactively
earthly --interactive +integration-test

# Check cache effectiveness
earthly --verbose +frontend-deps 2>&1 | grep -i cache
```

## CLAUDE.md for Earthly CI Pipelines

```markdown
# Earthly CI Pipeline Standards

## Domain Rules
- Every target must have a clear single responsibility
- Dependency installation targets separate from build targets (caching)
- Use SAVE IMAGE --cache-hint on dependency targets
- Use SAVE ARTIFACT for inter-target file sharing
- Integration tests use WITH DOCKER for service containers
- Never install dependencies in build targets (cache invalidation)
- Use VERSION 0.8+ for latest features

## File Patterns
- Earthfile (project root)
- Earthfile (per-service in monorepo)
- .earthly/config.yml (global configuration)
- docker-compose.test.yml (for WITH DOCKER)

## Common Commands
- earthly +target (run specific target)
- earthly +all (run orchestration target)
- earthly --push +docker (build and push image)
- earthly --interactive +target (debug mode)
- earthly --verbose +target (detailed output)
- earthly prune (clean local cache)
- earthly account login --token TOKEN
```

## Common Pitfalls in Earthly Development

- **Cache invalidation cascade:** Copying source files before dependency installation invalidates the dependency cache on every change. Claude Code structures Earthfiles to copy lockfiles first, install dependencies, then copy source code.

- **WITH DOCKER networking:** Service containers in WITH DOCKER need explicit networking. Claude Code uses docker-compose files for complex service topologies rather than inline Docker commands.

- **SAVE ARTIFACT path confusion:** The `SAVE ARTIFACT src /dest AS LOCAL ./local` syntax has three path components with different meanings. Claude Code uses explicit path comments to prevent source/destination confusion.

## Related

- [Claude Code for Bazel Build System](/claude-code-bazel-build-system-2026/)
- [Claude Code for Turborepo Monorepo Management](/claude-code-turborepo-monorepo-management-2026/)
- [Claude Code for Pulumi Infrastructure as Code](/claude-code-pulumi-infrastructure-as-code-2026/)
