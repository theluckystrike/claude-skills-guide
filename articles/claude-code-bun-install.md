---
sitemap: false
layout: default
title: "Claude Code Bun Install Setup Guide (2026)"
description: "Install and configure Claude Code with Bun runtime. Fix common installation issues and optimize Bun-based project workflows."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-bun-install/
categories: [guides]
tags: [claude-code, claude-skills, bun, installation, runtime]
reviewed: true
score: 6
geo_optimized: true
---

Installing Claude Code in Bun-based projects requires specific configuration to avoid runtime conflicts and ensure smooth operation. This guide covers installation steps, Bun-specific CLAUDE.md configuration, and fixes for common issues that arise when using Claude Code with the Bun JavaScript runtime.

## The Problem

Bun is a fast JavaScript runtime that replaces Node.js, npm, and webpack in many projects. When installing Claude Code in a Bun project, developers encounter issues: Bun's package resolution differs from npm, certain Node.js APIs behave differently, and Claude Code may default to npm commands when Bun should be used. Without explicit configuration, Claude Code generates npm/yarn commands and misses Bun-specific optimizations.

## Quick Solution

1. Install Claude Code globally (it requires Node.js regardless of your project runtime):

```bash
npm install -g @anthropic/claude-code
```

2. Verify Bun is installed in your project:

```bash
bun --version
# Expected: 1.x.x
```

3. Tell Claude Code to use Bun by configuring CLAUDE.md at your project root:

```markdown
# Package Manager
This project uses Bun as its runtime and package manager.
- Use `bun install` instead of `npm install`
- Use `bun run` instead of `npm run`
- Use `bun test` instead of `npm test`
- Lock file: bun.lockb (binary format)
```

4. Install project dependencies with Bun:

```bash
bun install
```

5. Start Claude Code in your project directory:

```bash
claude
```

## How It Works

Claude Code itself runs on Node.js regardless of your project's runtime. The distinction is important: Claude Code's own process uses Node.js, but it should generate and execute commands using your project's runtime (Bun).

When Claude Code reads your CLAUDE.md and detects Bun configuration, it adjusts its command suggestions. Instead of `npm install express`, it suggests `bun add express`. Instead of `npx prisma migrate`, it suggests `bunx prisma migrate`.

Bun's `bun.lockb` is a binary lockfile that Claude Code cannot read directly. If Claude Code needs to understand your dependencies, it reads `package.json` instead. The lockfile ensures deterministic installs but is not human-readable.

Bun also provides built-in tools that replace separate npm packages: bundling (`bun build`), testing (`bun test`), and a native SQLite driver. Documenting these in CLAUDE.md helps Claude Code use Bun-specific features.

## Common Issues

**Claude Code suggests npm commands**: Without CLAUDE.md configuration, Claude Code defaults to npm. Add explicit package manager instructions to CLAUDE.md as shown in the Quick Solution section.

**Bun binary not found in Claude Code shell**: If Claude Code cannot find `bun`, add the Bun binary path to your shell profile. For macOS: `export BUN_INSTALL="$HOME/.bun"` and `export PATH="$BUN_INSTALL/bin:$PATH"` in `~/.zshrc`.

**Node.js-only packages fail under Bun**: Some npm packages use Node.js APIs that Bun does not yet support. If Claude Code installs a package that crashes at runtime, check Bun's compatibility table and suggest an alternative package.

## Example CLAUDE.md Section

```markdown
# Bun Project Configuration

## Runtime
- Runtime: Bun 1.2.x
- Package manager: bun (NOT npm, NOT yarn, NOT pnpm)
- Lock file: bun.lockb (binary, do not read directly)

## Commands
- Install deps: `bun install`
- Add package: `bun add <pkg>`
- Dev server: `bun run dev`
- Build: `bun build src/index.ts --outdir=dist`
- Test: `bun test`
- Type check: `bunx tsc --noEmit`

## Bun-Specific Features We Use
- Built-in SQLite via `bun:sqlite`
- Built-in test runner (not Jest/Vitest)
- Bun.serve() for HTTP server
- Bun.file() for fast file I/O
- HTMLRewriter for HTML processing

## Compatibility Notes
- Some npm packages need --backend=copyfile flag
- Use `bun:test` imports, not `@jest/globals`
```

## Best Practices

- **Always specify the package manager in CLAUDE.md.** This is the single most impactful setting. Without it, Claude Code defaults to npm for every command.
- **Use `bunx` instead of `npx`.** When Claude Code needs to run a package binary, `bunx` uses Bun's resolution and is significantly faster.
- **Document Bun-specific APIs.** If your project uses `Bun.serve()`, `bun:sqlite`, or `bun:test`, list these so Claude Code generates compatible code.
- **Pin Bun version in CI.** Use `bun-version` in your GitHub Actions workflow and document the version in CLAUDE.md to avoid version drift.
- **Test Node.js compatibility.** Not all npm packages work perfectly with Bun. When Claude Code suggests a new dependency, verify it works with `bun add` before proceeding.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-bun-install)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/)
- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


## Common Questions

### How do I get started with claude code bun install setup?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Resources

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

- [Claude Code Auto Mode Setup Guide](/claude-code-auto-mode-setup-guide/)
- [Claude Code AWS Bedrock Setup Guide](/claude-code-aws-bedrock-setup/)
- [Claude Code AWS MCP Server Setup Guide](/claude-code-aws-mcp-server/)
