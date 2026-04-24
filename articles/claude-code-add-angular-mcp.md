---
layout: default
title: "Add Angular MCP to Claude Code (2026)"
description: "Set up Angular Language Service MCP in Claude Code for intelligent component generation, template validation, and NgModule awareness."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-add-angular-mcp/
categories: [guides]
tags: [claude-code, claude-skills, angular, mcp]
reviewed: true
score: 6
geo_optimized: true
---

Adding Angular MCP to Claude Code gives it direct awareness of your Angular project structure, component tree, and template syntax. This guide shows you how to configure a filesystem MCP server tailored for Angular development so Claude Code generates valid, context-aware Angular code.

## The Problem

Claude Code does not natively understand Angular-specific concepts like NgModules, dependency injection hierarchies, or template syntax rules. It generates components that import from wrong paths, creates standalone components when your project uses NgModules, or misses required provider configurations. Without project-specific context, every Angular generation requires manual corrections.

## Quick Solution

**Step 1: Set up the filesystem MCP server for Angular**

Create `.claude/mcp.json` in your Angular project root:

```json
{
  "mcpServers": {
    "angular-project": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-filesystem",
        "./src",
        "./angular.json",
        "./tsconfig.json",
        "./package.json"
      ]
    }
  }
}
```

**Step 2: Create a CLAUDE.md with Angular conventions**

```bash
touch CLAUDE.md
```

Add your Angular-specific rules (see the Example CLAUDE.md Section below).

**Step 3: Restart Claude Code to load MCP**

```bash
claude
```

Verify the MCP server is running:

```text
> /mcp
```

You should see `angular-project` listed with available filesystem tools.

**Step 4: Test with a component generation request**

```text
> Create a new ProductListComponent that fetches from the ProductService and displays items in a table
```

Claude Code will now read your existing services, modules, and routing config through MCP before generating the component.

## How It Works

The filesystem MCP server gives Claude Code direct read access to your project files without consuming context window tokens upfront. Instead of pasting your entire `app.module.ts` into the prompt, Claude Code can dynamically read files it needs through MCP tool calls. This means it can inspect your `angular.json` to understand build configuration, check `tsconfig.json` for path aliases, and read existing components to match your patterns.

Claude Code's CLAUDE.md file complements MCP by providing rules that cannot be inferred from code alone -- like whether to use standalone components, which state management library to use, or your team's naming conventions. Together, MCP plus CLAUDE.md gives Claude Code deep Angular awareness.

## Common Issues

**Claude Code generates standalone components but your project uses NgModules**
Add an explicit rule to CLAUDE.md: `Always use NgModule-based components, never standalone`. Without this, Claude Code defaults to newer Angular patterns which may not match your codebase.

**Path aliases not resolved correctly**
Ensure `tsconfig.json` is included in your MCP server paths. Claude Code needs to read the `paths` configuration to resolve aliases like `@app/` or `@shared/`. Also add `tsconfig.app.json` if it extends the base config.

**Large projects cause slow MCP responses**
Restrict the MCP filesystem paths to only the directories Claude Code needs. Instead of exposing the entire `src/`, list specific subdirectories like `./src/app/core`, `./src/app/shared`, and the feature module you are working on.

## Example CLAUDE.md Section

```markdown
# Angular Project Configuration

## Framework
- Angular 17 with NgModules (NOT standalone components)
- State management: NgRx Store
- UI library: Angular Material
- Routing: lazy-loaded feature modules

## Conventions
- Components: selector prefix "app-", OnPush change detection
- Services: providedIn: 'root' unless feature-scoped
- File naming: kebab-case (product-list.component.ts)
- Tests: every component has a .spec.ts file using TestBed

## Project Structure
- /src/app/core — singleton services, guards, interceptors
- /src/app/shared — reusable components, pipes, directives
- /src/app/features/ — lazy-loaded feature modules
- /src/assets — static files
- /src/environments — env configs

## Commands
- Serve: `ng serve`
- Test: `ng test --watch=false`
- Build: `ng build --configuration=production`
- Lint: `ng lint`
```

## Best Practices

1. **Expose only relevant directories via MCP** -- Angular projects can be large. Limit the filesystem MCP to `src/app/`, config files, and the specific feature module you are working on to keep responses fast.

2. **Specify Angular version in CLAUDE.md** -- Angular's API changes significantly between versions. Stating `Angular 17` prevents Claude Code from generating v14 patterns or using APIs that do not exist in your version.

3. **Include your path aliases** -- If you use `@app/` or `@env/` aliases, document them in CLAUDE.md so Claude Code uses them consistently in imports.

4. **Regenerate after structural changes** -- After adding new modules or restructuring features, restart Claude Code so the MCP server re-indexes the filesystem.

5. **Use the Angular CLI through Claude Code** -- Let Claude Code run `ng generate` commands rather than creating files manually. This ensures Angular CLI schematics handle module registration automatically.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-add-angular-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/)
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
