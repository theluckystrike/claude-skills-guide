---
title: "Docker Multi-Stage Build Cache Miss"
permalink: /claude-code-docker-multi-stage-cache-invalidation-fix-2026/
description: "Claude Code cost insight: fix Docker build cache invalidation in multi-stage builds. Order COPY commands correctly and separate dependency install layer."
last_tested: "2026-04-22"
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


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [Claude Code Turborepo Cache Miss — Fix](/claude-code-turborepo-cache-miss-fix/)
- [How to Test and Debug Multi Agent](/how-to-test-and-debug-multi-agent-workflows/)
- [Claude Code for Docker Image Publishing](/claude-code-for-docker-image-publishing-workflow-guide/)
- [Claude Code for Colima Docker](/claude-code-for-colima-docker-workflow-guide/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
