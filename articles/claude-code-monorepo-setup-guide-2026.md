---
layout: default
title: "Claude Code Monorepo Setup (2026)"
description: "Configure Claude Code for monorepos. Turborepo, pnpm workspaces, and Nx setups with CLAUDE.md and permission patterns."
permalink: /claude-code-monorepo-setup-guide-2026/
date: 2026-04-26
---

# Claude Code Monorepo Setup (2026)

Monorepos are challenging for AI coding tools. The codebase is large, dependencies are interconnected, and the context window fills up faster because there are more files to track. Claude Code handles monorepos well when configured properly, but the defaults are not enough.

This guide covers monorepo-specific configuration for Claude Code, including CLAUDE.md strategies, permission patterns, and workspace navigation. For a guided monorepo setup, use the [Project Starter tool](/starter/).

## The Monorepo Challenge

In a monorepo, Claude Code faces unique problems:

1. **Context overload** — The project has hundreds or thousands of files across multiple packages
2. **Ambiguous commands** — "Run tests" could mean any of a dozen test suites
3. **Cross-package dependencies** — Changes in one package affect others
4. **Multiple tech stacks** — The frontend might be React while the API is Go

Solving these problems requires a CLAUDE.md that clearly maps the monorepo structure and permissions that match your build tools.

## CLAUDE.md for Monorepos

A monorepo CLAUDE.md needs more structure than a single-project one. Organize it by workspace:

```markdown
# My Platform Monorepo

## Structure
- apps/web — Next.js frontend (port 3000)
- apps/api — Express API (port 4000)
- apps/admin — React admin panel (port 3001)
- packages/shared — Shared TypeScript types and utilities
- packages/ui — Shared React component library
- packages/config — Shared ESLint, TypeScript, and Tailwind configs

## Package Manager
pnpm with workspaces (pnpm-workspace.yaml)

## Build System
Turborepo (turbo.json)

## Global Commands
- pnpm dev — start all apps in development
- pnpm build — build all packages and apps
- pnpm test — run all tests
- pnpm lint — lint all packages

## Per-Package Commands
- pnpm --filter web dev — start only the web app
- pnpm --filter api test — test only the API
- pnpm --filter shared build — build shared package

## Conventions
- Shared types go in packages/shared
- UI components go in packages/ui
- Each app has its own .env.example
- Cross-package imports use workspace: protocol
- All packages use TypeScript strict mode
```

Keep it under 400 words. Every word costs tokens on every API call, and monorepo sessions tend to be longer than single-project ones. See [CLAUDE.md templates](/10-claude-md-templates-project-types/) for more examples.

## Workspace-Specific Context

For large monorepos, consider placing additional `CLAUDE.md` files in each workspace:

```
apps/
  web/
    CLAUDE.md    # Web-specific context
  api/
    CLAUDE.md    # API-specific context
packages/
  shared/
    CLAUDE.md    # Shared package context
CLAUDE.md        # Root-level overview
```

Claude Code reads the root `CLAUDE.md` plus any `CLAUDE.md` files in directories it is working in. This layered approach keeps context relevant without bloating the root file.

## Permission Configuration

Monorepo permissions need to cover multiple build tools:

### Turborepo + pnpm

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git *)",
      "Bash(pnpm *)",
      "Bash(turbo *)",
      "Bash(tsc *)",
      "Bash(vitest *)",
      "Bash(eslint *)",
      "Bash(prettier *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push --force*)",
      "Bash(pnpm publish*)"
    ]
  }
}
```

### Nx monorepo

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git *)",
      "Bash(nx *)",
      "Bash(pnpm *)",
      "Bash(jest *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ]
  }
}
```

Generate your configuration with the [Permissions Configurator](/permissions/).

## Navigating the Monorepo

### Guide Claude to the right workspace

Always specify which package or app you are working on:

```
In apps/api, add a new endpoint for user preferences.
The types should go in packages/shared/src/types/preferences.ts.
```

Without this guidance, Claude might create files in the wrong package or duplicate existing shared code.

### Use the filter flag

Teach Claude to use pnpm filters for targeted operations:

```
Run tests only for the API package: pnpm --filter api test
Build only the shared package: pnpm --filter shared build
```

This prevents expensive full-monorepo builds when you only changed one package.

## Context Management in Monorepos

Monorepo sessions consume context faster because:
- More files need to be read to understand cross-package dependencies
- Build output is larger (multiple packages building)
- The CLAUDE.md and package.json files are bigger

### Compact more aggressively

In single-project work, compact at 40% context. In monorepos, compact at 30%:

```
/cost
/compact focus on the API endpoint changes in apps/api
```

### Session segmentation

Work on one workspace at a time:

1. Session 1: Build the API endpoint (apps/api)
2. `/clear`
3. Session 2: Build the frontend component (apps/web)
4. `/clear`
5. Session 3: Update shared types (packages/shared)

This keeps each session focused and prevents context from spanning multiple unrelated workspaces. Use the [Token Estimator](/token-estimator/) to track context usage.

## Try It Yourself

The [Project Starter](/starter/) includes monorepo configurations for Turborepo, Nx, and plain pnpm workspaces. Select "monorepo" as your project type and it generates:

- Root CLAUDE.md with workspace map
- Per-workspace CLAUDE.md files
- Permission configuration for your build tools
- Custom commands for monorepo-specific operations
- turbo.json or nx.json configuration

This saves the tedious setup work and ensures your monorepo is optimized for Claude Code from day one.

## Custom Commands for Monorepos

Create commands that simplify monorepo workflows:

`.claude/commands/test-affected.md`:
```markdown
Determine which packages were affected by recent changes using
`pnpm turbo run test --filter=...[HEAD~1]` and run their tests.
Report results for each affected package separately.
```

`.claude/commands/check-deps.md`:
```markdown
Check for circular dependencies between packages.
List any packages that import from each other (A imports B and B imports A).
Suggest which direction to break the cycle.
```

## Frequently Asked Questions

**What is the maximum monorepo size Claude Code can handle?**

Claude Code works with monorepos of any size because it reads files on demand. The constraint is the context window (200K tokens), which limits how many files can be active in one session. For very large monorepos, strict workspace segmentation is essential.

**Should I use Turborepo or Nx with Claude Code?**

Both work well. Turborepo is simpler and lighter, which means less configuration for Claude to understand. Nx has more features but a steeper learning curve for Claude. Choose based on your team needs, not Claude compatibility.

**How do I prevent Claude from modifying the wrong package?**

Be explicit in every prompt: "In apps/api, do X." Additionally, you can use file-path-based deny rules in settings.json to make certain packages read-only during specific work sessions.

**Does Claude understand pnpm workspace protocol?**

Yes. Claude understands `workspace:*` and `workspace:^` version specifiers in package.json and can correctly manage cross-package dependencies.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the maximum monorepo size Claude Code can handle?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with monorepos of any size because it reads files on demand. The constraint is the 200K token context window which limits active files per session. For large monorepos, strict workspace segmentation is essential."
      }
    },
    {
      "@type": "Question",
      "name": "Should I use Turborepo or Nx with Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Both work well. Turborepo is simpler and lighter, Nx has more features. Choose based on team needs, not Claude Code compatibility."
      }
    },
    {
      "@type": "Question",
      "name": "How do I prevent Claude from modifying the wrong package?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Be explicit in every prompt with the target package path. You can also use file-path-based deny rules in settings.json to make certain packages read-only."
      }
    },
    {
      "@type": "Question",
      "name": "Does Claude understand pnpm workspace protocol?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude understands workspace:* and workspace:^ version specifiers and can correctly manage cross-package dependencies."
      }
    }
  ]
}
</script>

## Related Guides

- [Project Starter](/starter/) — Monorepo project scaffolding
- [CLAUDE.md Templates](/10-claude-md-templates-project-types/) — Templates including monorepo
- [Turborepo Monorepo Setup](/claude-code-with-turborepo-monorepo-setup-guide/) — Turborepo-specific guide
- [Token Estimator](/token-estimator/) — Track context usage in large projects
- [Permissions Configurator](/permissions/) — Generate monorepo permissions
