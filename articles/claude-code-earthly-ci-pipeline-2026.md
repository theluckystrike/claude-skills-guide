---
layout: default
title: "Claude Code for Earthly CI Pipeline (2026)"
permalink: /claude-code-earthly-ci-pipeline-2026/
date: 2026-04-20
description: "Build reproducible CI pipelines with Earthly and Claude Code. Write Earthfiles, cache dependencies, and run identical builds locally and in CI."
last_tested: "2026-04-22"
domain: "CI/CD"
render_with_liquid: false
---
{% raw %}


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


## Related Guides

- [Claude Code for Embedding Pipeline](/claude-code-for-embedding-pipeline-workflow/)
- [Claude Code for DSP Pipeline](/claude-code-dsp-pipeline-development-2026/)
- [Claude Code Pipeline](/claude-code-agent-pipeline-sequential-vs-parallel/)
- [Claude Code Docker CI/CD Pipeline Setup](/claude-code-docker-ci-cd-pipeline-integration-guide/)

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

{% endraw %}
- [Stop Claude Code Breaking CI Pipelines (2026)](/claude-code-breaks-ci-pipeline-fix-2026/)
- [Claude Code for Genomics GWAS Analysis (2026)](/claude-code-genomics-gwas-pipeline-2026/)
