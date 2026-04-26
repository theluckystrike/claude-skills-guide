---
layout: default
title: "Claude Code for Bun Runtime (2026)"
description: "Claude Code for Bun Runtime — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-bun-runtime-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, bun, workflow]
---

## The Setup

You are using Bun as your JavaScript/TypeScript runtime, replacing Node.js for faster startup, native TypeScript execution, built-in bundling, and a faster package manager. Claude Code can write Bun-specific code, but it defaults to Node.js APIs and npm commands that miss Bun's native capabilities.

## What Claude Code Gets Wrong By Default

1. **Uses Node.js APIs instead of Bun APIs.** Claude writes `const fs = require('fs')` or `import { readFile } from 'node:fs/promises'`. Bun has native APIs: `Bun.file('path.txt').text()` for file reading, `Bun.serve()` for HTTP servers.

2. **Runs npm/yarn for package management.** Claude uses `npm install` or `yarn add`. Bun has its own package manager: `bun add package` which is significantly faster.

3. **Sets up Jest or Vitest for testing.** Claude configures external test frameworks. Bun has a built-in test runner: `bun test` with Jest-compatible API, no configuration needed.

4. **Uses webpack or esbuild for bundling.** Claude configures external bundlers. Bun has a built-in bundler: `Bun.build({ entrypoints: ['./index.ts'] })` with tree-shaking and code splitting.

## The CLAUDE.md Configuration

```
# Bun Runtime Project

## Runtime
- Runtime: Bun (NOT Node.js)
- Package manager: bun (NOT npm/yarn/pnpm)
- Test runner: bun test (built-in, Jest-compatible)
- Bundler: Bun.build() (built-in)

## Bun Rules
- TypeScript runs natively — no tsc compilation step
- HTTP server: Bun.serve({ port: 3000, fetch(req) { } })
- File I/O: Bun.file('path').text() or .json() or .arrayBuffer()
- Write files: Bun.write('path', content)
- Run scripts: bun run script.ts (native TS execution)
- SQLite: bun:sqlite built-in module
- Password hashing: Bun.password.hash() built-in
- Environment: Bun.env.VARIABLE or process.env.VARIABLE

## Conventions
- Use Bun APIs where available, Node.js compat as fallback
- bun.lockb is the lockfile (binary format, committed to git)
- Scripts in package.json run with bun automatically
- bunfig.toml for Bun-specific configuration
- Use bun:sqlite for local database needs
- Test files: *.test.ts with describe/it/expect (Jest API)
- No compilation step needed for TypeScript
```

## Workflow Example

You want to create an HTTP API using Bun's native APIs. Prompt Claude Code:

"Create a simple REST API using Bun.serve() with routes for GET /users, POST /users, and GET /users/:id. Use Bun's native file I/O for a JSON file-based storage and Bun's built-in password hashing for user creation."

Claude Code should use `Bun.serve({ fetch(req) { } })` with URL pattern matching, `Bun.file('users.json').json()` for reading data, `Bun.write('users.json', JSON.stringify(data))` for persistence, and `Bun.password.hash(password)` for secure password storage.

## Common Pitfalls

1. **Node.js API compatibility gaps.** Claude uses `node:worker_threads` or `node:cluster` assuming full Node.js compatibility. While Bun supports most Node.js APIs, some (especially native addons and certain edge-case APIs) may not work identically. Check Bun's compatibility table.

2. **Binary lockfile confusion.** Claude tries to read or diff `bun.lockb`. Bun's lockfile is binary, not JSON like `package-lock.json`. Use `bun install --yarn` to generate a readable `yarn.lock` alongside if human-readable lockfile is needed for review.

3. **Bun.serve hot reload.** Claude restarts the server process on file changes manually. Use `bun --watch run server.ts` for automatic restart on file changes, or `bun --hot run server.ts` for hot module reloading without restart.

## Related Guides

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

- [Using Claude Code with Bun Runtime JavaScript Projects](/using-claude-code-with-bun-runtime-javascript-projects/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)

## See Also

- [Claude Code for Bun Workspaces — Workflow Guide](/claude-code-for-bun-workspaces-workflow-guide/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
