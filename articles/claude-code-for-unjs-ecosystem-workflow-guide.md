---
layout: default
title: "Claude Code for UnJS Ecosystem (2026)"
description: "Claude Code for UnJS Ecosystem — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-unjs-ecosystem-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, unjs, workflow]
---

## The Setup

You are building JavaScript applications with UnJS, a collection of universal JavaScript utilities that work across Node.js, Deno, Bun, Cloudflare Workers, and browsers. UnJS includes packages like ofetch (fetch), consola (logging), defu (object merging), pathe (paths), and many more. Claude Code can write JavaScript utilities, but it reaches for heavy npm packages or Node.js-specific APIs instead of UnJS's lightweight, universal alternatives.

## What Claude Code Gets Wrong By Default

1. **Uses axios for HTTP requests.** Claude installs `axios` with 400KB+ bundle. UnJS `ofetch` is lighter, has automatic JSON parsing, retry support, and works on every runtime — Node.js, Deno, Workers, and browsers.

2. **Uses `path` from Node.js.** Claude imports `import path from 'node:path'`. This breaks in non-Node runtimes. UnJS `pathe` provides the same API but works universally across all JavaScript runtimes.

3. **Writes custom utility functions.** Claude writes deep merge, type checking, and string manipulation helpers from scratch. UnJS has `defu` (deep defaults), `untyped` (runtime type validation), and `scule` (string case conversion) — battle-tested and universal.

4. **Ignores runtime compatibility.** Claude uses Node.js APIs like `process.env`, `fs`, and `child_process` directly. UnJS provides `std-env` for environment detection, `unenv` for polyfilling Node APIs, and `unbuild` for building universal packages.

## The CLAUDE.md Configuration

```
# UnJS Ecosystem Project

## Utilities
- Ecosystem: UnJS (universal JavaScript utilities)
- Runtime: Node.js, Deno, Bun, Workers, browsers
- Philosophy: lightweight, zero-dependency, universal

## UnJS Packages
- ofetch: universal fetch with retry and interceptors
- consola: universal logging with levels and reporters
- defu: deep object defaults merging
- pathe: universal path utilities (replaces node:path)
- scule: string case conversion (camel, pascal, kebab)
- ufo: URL manipulation utilities
- hookable: async hook/plugin system
- unenv: environment-agnostic Node.js polyfills
- std-env: runtime/environment detection
- unbuild: universal build tool for packages

## Conventions
- Prefer UnJS over heavy npm alternatives
- ofetch over axios/node-fetch
- pathe over node:path
- consola over winston/pino for universal code
- defu for config merging with defaults
- Check runtime compatibility for target environments
- Use unbuild for building universal packages
```

## Workflow Example

You want to create a universal configuration system that works across runtimes. Prompt Claude Code:

"Build a configuration loader using UnJS packages. Use defu for merging config defaults, consola for logging, ofetch for fetching remote config, pathe for resolving config file paths, and std-env to detect the runtime environment. It should work in Node.js, Deno, and Cloudflare Workers."

Claude Code should import from UnJS packages, use `std-env` to detect the runtime, `pathe` to resolve config paths (falling back for non-filesystem runtimes), `ofetch` to load remote config, `defu` to merge user config over defaults, and `consola` for structured logging — all without any Node.js-specific APIs.

## Common Pitfalls

1. **Mixing Node.js APIs with UnJS equivalents.** Claude uses `path.join()` alongside `pathe.join()` in the same file. Pick one — mixing Node.js built-ins with UnJS equivalents creates inconsistency and breaks universal compatibility.

2. **Not checking runtime support.** Claude uses `ofetch` features that may not work everywhere. While UnJS packages are universal, some features depend on runtime capabilities. Use `std-env` to detect the runtime and adapt behavior accordingly.

3. **Over-installing UnJS packages.** Claude installs every UnJS package mentioned in documentation. Only install packages you actually use — UnJS packages are small individually but unnecessary dependencies add up.

## Related Guides

- [Claude Code for Hono Framework Workflow Guide](/claude-code-for-hono-framework-workflow-guide/)
- [Claude Code for Nitro Server Engine Workflow Guide](/claude-code-for-nitro-server-engine-workflow-guide/)
- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)
