---
title: "Docker Multi-Stage Build Cache Miss"
permalink: /claude-code-docker-multi-stage-cache-invalidation-fix-2026/
description: "Fix Docker build cache invalidation in multi-stage builds. Order COPY commands correctly and separate dependency install layer."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
$ docker build -t myapp .
 => CACHED [deps 1/3] FROM node:22-slim
 => [deps 2/3] COPY . .                                    0.1s
 => [deps 3/3] RUN npm install                             47.2s
# Every build reinstalls all dependencies (47s) even for code-only changes
```

This is not a crash error but a performance problem. Docker rebuilds the `npm install` layer on every code change because `COPY . .` invalidates the cache whenever any file changes.

## The Fix

1. Restructure the Dockerfile to copy package files first:

```dockerfile
FROM node:22-slim AS deps
WORKDIR /app
# Copy ONLY dependency files first (this layer caches)
COPY package.json package-lock.json ./
RUN npm ci --production

FROM node:22-slim AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:22-slim
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
CMD ["node", "dist/index.js"]
```

2. Build with BuildKit for better caching:

```bash
DOCKER_BUILDKIT=1 docker build -t myapp .
```

3. Verify cache hits:

```bash
docker build -t myapp . 2>&1 | grep "CACHED"
```

## Why This Happens

Docker layer caching invalidates a layer and all subsequent layers when any file in a COPY command changes. If `COPY . .` comes before `RUN npm install`, every code change invalidates the dependency layer. By copying `package.json` separately first, the dependency layer only rebuilds when dependencies actually change.

## If That Doesn't Work

- Use a `.dockerignore` to exclude unnecessary files:

```bash
echo -e "node_modules\n.git\n*.md\n.env" > .dockerignore
```

- Use BuildKit cache mounts for npm:

```dockerfile
RUN --mount=type=cache,target=/root/.npm npm ci --production
```

- For monorepos, use turbo prune to create a minimal Docker context:

```bash
npx turbo prune --scope=@myorg/api --docker
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Dockerfile Best Practices
- Always COPY package.json + lockfile before COPY source code.
- Use multi-stage builds: deps -> build -> runtime.
- Add .dockerignore to exclude node_modules, .git, *.md.
- Use npm ci (not npm install) in Docker for reproducible builds.
```

## See Also

- [Claude Code Docker Multi-Stage Builds (2026)](/claude-code-docker-multi-stage-builds-guide/)
