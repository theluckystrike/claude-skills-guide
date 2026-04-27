---
sitemap: false
layout: default
title: "Claude Code for Just — Workflow Guide (2026)"
description: "Claude Code for Just — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-just-command-runner-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, just, workflow]
---

## The Setup

You are using Just, the command runner that replaces Make for project-specific commands. Just uses a `justfile` with a simpler syntax than Makefiles — no tabs-vs-spaces issues, proper string interpolation, and built-in support for loading `.env` files. Claude Code can generate justfiles and recipes, but it writes Makefile syntax or npm scripts instead.

## What Claude Code Gets Wrong By Default

1. **Writes Makefile syntax with tabs and targets.** Claude generates `build: src/*.ts` with tab-indented shell commands and file dependencies. Just uses `justfile` with recipe-based syntax, no file dependency tracking, and allows spaces or tabs for indentation.

2. **Creates npm scripts in package.json.** Claude adds commands to `"scripts"` in `package.json`. With Just, project commands go in the `justfile` — it handles all languages, not just JavaScript.

{% raw %}3. **Uses Make's variable syntax.** Claude writes `$(VAR)` or `${VAR}` for Make variables. Just uses `{{variable}}` double-brace syntax for recipe parameters and settings.{% endraw %}

4. **Ignores Just's built-in features.** Claude writes manual `source .env` commands. Just has `set dotenv-load` to automatically load `.env` files, `set positional-arguments` for argument handling, and `set shell` for shell selection.

## The CLAUDE.md Configuration

```
{% raw %}
# Just Command Runner Project

## Task Runner
- Tool: Just (justfile at project root)
- Shell: bash (set shell := ["bash", "-cu"])
- Env: Auto-loads .env via set dotenv-load

## Just Rules
- Commands defined in justfile, NOT Makefile or package.json
- Recipe syntax: recipe-name arg='default': (no tabs required)
- Variables: {{variable}} double braces
- String interpolation in recipes uses {{}} not $()
- Default recipe: first recipe in file runs with bare `just`
- List recipes: just --list
- Use set dotenv-load for automatic .env loading
- Dependencies: recipe-a: recipe-b (runs recipe-b first)

## Conventions
- Default recipe lists available commands (using just --list)
- Recipe names use kebab-case: build-frontend, run-tests
- Group related recipes with comments: # === Database ===
- Parameterized recipes: deploy env='staging':
- Private recipes prefixed with underscore: _helper
- Store justfile in project root, commit to version control
{% endraw %}
```

## Workflow Example

You want to create a justfile for a full-stack project. Prompt Claude Code:

"Create a justfile with recipes for: starting the dev server, running tests, building for production, running database migrations, and deploying to staging. Include a default recipe that lists all available commands."

Claude Code should create a `justfile` with `default` recipe running `just --list`, parameterized recipes like `deploy env='staging'`, dependency chains (e.g., `build` depends on `test`), `.env` loading via `set dotenv-load`, and descriptive comments grouping related recipes.

## Common Pitfalls

1. **Tab-sensitive indentation from Makefile habits.** Claude uses hard tabs for recipe bodies because Make requires them. Just accepts both tabs and spaces, but mixing them in the same file causes confusing errors. Pick one and stick with it.

2. **Missing shebang for multi-line recipes.** Claude writes multi-line recipes expecting each line to run in the same shell. By default, Just runs each line in a separate shell. Use `#!/usr/bin/env bash` as the first line of a recipe for multi-line scripts, or set `set shell` globally.

{% raw %}3. **Variable scoping confusion.** Claude defines variables with `VAR := "value"` expecting them to be available as shell environment variables in recipes. Just variables are interpolated into recipes with `{{VAR}}` but are not automatically exported as environment variables. Use `export VAR := "value"` to make them available to subprocesses.{% endraw %}



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Building a CLI Devtool with Claude Code Walkthrough](/building-a-cli-devtool-with-claude-code-walkthrough/)
- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)


## Common Questions

### What AI models work best with this approach?

Claude Opus 4 and Claude Sonnet 4 handle complex reasoning tasks. For simpler operations, Claude Haiku 3.5 offers faster responses at lower cost. Match model capability to task complexity.

### How do I handle AI agent failures gracefully?

Implement retry logic with exponential backoff, set clear timeout boundaries, and design fallback paths for critical operations. Log all failures for pattern analysis.

### Can this workflow scale to production?

Yes. Add rate limiting, request queuing, and monitoring before production deployment. Most AI agent architectures scale horizontally by adding worker instances behind a load balancer.

## Related Resources

- [Claude Code Academic Workflow Guide](/claude-code-academic-workflow-guide-2026/)
- [Claude Code Debugging Workflow Guide](/claude-code-debugging-workflow-guide-2026/)
- [Claude Code for Ark UI — Workflow Guide](/claude-code-for-ark-ui-workflow-guide/)
