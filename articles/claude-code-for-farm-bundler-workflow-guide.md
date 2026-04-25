---
layout: default
title: "Claude Code for Farm Bundler (2026)"
description: "Claude Code for Farm Bundler — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-farm-bundler-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, farm, workflow]
---

## The Setup

You are using Farm, the Rust-based web bundler that is compatible with the Vite plugin ecosystem while being significantly faster. Farm handles both development and production builds with near-instant HMR. Claude Code can configure Farm and write plugins, but it generates Vite or Webpack configurations that are syntactically different from Farm's config format.

## What Claude Code Gets Wrong By Default

1. **Generates `vite.config.ts` instead of `farm.config.ts`.** Claude creates Vite configuration when asked about bundler setup. Farm uses `farm.config.ts` with its own configuration schema, though it is similar in structure.

2. **Uses Webpack loader syntax.** Claude writes `module.rules` with `test` regex patterns. Farm uses a plugin-based approach like Vite, but with its own Rust plugin system alongside JS plugin compatibility.

3. **Installs Vite plugins directly.** Claude adds Vite plugins to the Farm config without the compatibility layer. Farm supports most Vite plugins through `@farmfe/js-plugin-*` wrappers, but not all are directly compatible.

4. **Configures dev server with Webpack DevServer options.** Claude writes `devServer: { proxy: {...} }` with Webpack syntax. Farm's dev server configuration uses a different format under `server` in `farm.config.ts`.

## The CLAUDE.md Configuration

```
# Farm Bundler Project

## Build Tool
- Bundler: Farm (@farmfe/core)
- Config: farm.config.ts at project root
- Dev server: built-in, configured in farm.config.ts
- Plugins: Farm plugins + Vite plugin compatibility

## Farm Rules
- Config file is farm.config.ts, NOT vite.config.ts
- Use defineConfig from @farmfe/core
- Plugins array in compilation.plugins (Farm) or vitePlugins (Vite compat)
- Dev server config under "server" key
- Static assets in "public" directory by default
- Output configured under compilation.output
- Partial bundling (Farm's tree-shaking) enabled by default

## Conventions
- Entry point: src/index.tsx or src/main.tsx
- Environment variables: FARM_* prefix for client-side exposure
- Proxy config: server.proxy with target/changeOrigin
- CSS modules work out of the box (.module.css)
- Use Farm's built-in Sass/Less support, no extra loaders
- Plugin order matters — Farm plugins before Vite compat plugins
```

## Workflow Example

You want to configure Farm for a React project with API proxying. Prompt Claude Code:

"Set up farm.config.ts for a React TypeScript project. Configure the dev server to proxy /api requests to localhost:8080, enable CSS modules, and set up path aliases for @/ pointing to src/."

Claude Code should create `farm.config.ts` using `defineConfig` from `@farmfe/core`, configure `server.proxy` with the `/api` target, set up `compilation.resolve.alias` for the `@/` path prefix, and ensure the React JSX transform is configured.

## Common Pitfalls

1. **Environment variable prefix mismatch.** Claude uses `VITE_` prefix for client-side env vars. Farm uses `FARM_` prefix. Variables without the correct prefix are not exposed to client-side code, causing undefined values at runtime.

2. **Plugin compatibility assumptions.** Claude installs any Vite plugin and puts it in Farm's config. Some Vite plugins use Vite-specific APIs not available in Farm. Check Farm's documentation for compatible plugins or use the `vitePlugins` array with tested plugins only.

3. **Build output path configuration.** Claude sets `build.outDir` like Vite. Farm uses `compilation.output.path` for the output directory. Using the Vite config key silently does nothing, and output goes to the default location.

## Related Guides

- [Claude Code for Rspack Bundler Workflow Guide](/claude-code-for-rspack-bundler-workflow-guide/)
- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Claude Code CI/CD Pipeline Optimization Guide](/claude-code-ci-cd-pipeline-optimization-guide/)

## See Also

- [Claude Code for Rolldown — Workflow Guide](/claude-code-for-rolldown-bundler-workflow-guide/)
- [Configuration Reference](/configuration/). Complete Claude Code settings and configuration guide

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
        "text": "You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\")."
      }
    }
  ]
}
</script>
