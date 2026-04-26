---
layout: default
title: "Claude Code Angular MCP Configuration (2026)"
description: "Set up MCP servers for Angular projects in Claude Code to enable component-aware code generation and project navigation. Tested and working in 2026."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-angular-mcp/
categories: [guides]
tags: [claude-code, claude-skills, angular, mcp]
reviewed: true
score: 6
geo_optimized: true
last_tested: "2026-04-22"
---

Configuring MCP for Angular in Claude Code enables project-aware code generation by giving it direct filesystem access to your components, services, and configuration. This guide covers the recommended MCP setup for Angular monorepos, multi-project workspaces, and standalone apps.

## The Problem

Claude Code reads files one at a time through its standard file access, which burns context window tokens on every file read. In Angular projects with dozens of modules, services, and components, you hit context limits before Claude Code understands your project structure. It cannot follow dependency chains across lazy-loaded modules or discover which services are provided where without reading multiple files.

## Quick Solution

**Step 1: Configure filesystem MCP for your Angular workspace**

Create `.claude/mcp.json` in your project root:

```json
{
  "mcpServers": {
    "angular-fs": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-filesystem",
        "./src/app",
        "./angular.json",
        "./tsconfig.json",
        "./tsconfig.app.json",
        "./package.json"
      ]
    }
  }
}
```

**Step 2: For Nx monorepos, expose library paths**

```json
{
  "mcpServers": {
    "angular-fs": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-filesystem",
        "./apps/my-app/src",
        "./libs/shared/src",
        "./libs/ui/src",
        "./nx.json",
        "./tsconfig.base.json"
      ]
    }
  }
}
```

**Step 3: Restart Claude Code**

```bash
claude
```

Verify the server is loaded:

```text
> /mcp
```

**Step 4: Test with a cross-module query**

```text
> Read the AppModule and list all imported feature modules
```

Claude Code will use the filesystem MCP tools to navigate your module tree without consuming context window tokens for file contents.

## How It Works

The filesystem MCP server provides Claude Code with `read_file`, `list_directory`, and `search_files` tools. Unlike inline file reads that paste content directly into the conversation, MCP tool calls fetch file contents on demand and return them as tool results. This is more token-efficient because Claude Code can read a file, extract what it needs, and move on without the full content persisting in the context window.

For Angular specifically, this means Claude Code can follow the import chain from `AppModule` through lazy-loaded routes to feature modules, discovering services and components along the way. It reads `angular.json` to understand build targets and project boundaries. In Nx monorepos, it reads `nx.json` and `project.json` files to understand library dependencies.

The key difference from just using CLAUDE.md alone is dynamic discovery. CLAUDE.md provides static rules and conventions. MCP provides live file access so Claude Code can discover new components, services, and patterns that were added after your CLAUDE.md was last updated.

## Common Issues

**MCP server times out on large monorepos**
The filesystem MCP server can struggle with very large directory trees. Restrict paths to specific apps and libs you are actively working on rather than exposing the entire workspace root.

**"File not found" for files that exist**
The filesystem MCP server restricts access to only the paths specified in `args`. If Claude Code tries to read a file outside those paths, it will get an error. Add the missing directory to your MCP configuration.

**Duplicate MCP configurations cause conflicts**
If you have both a project-level `.claude/mcp.json` and a user-level `~/.claude/mcp.json` with the same server name, the project-level config takes precedence. Remove duplicates to avoid confusion.

## Example CLAUDE.md Section

```markdown
# Angular MCP Workspace

## MCP Configuration
- Filesystem MCP configured in .claude/mcp.json
- Exposed paths: src/app, config files
- Use MCP tools to read files instead of asking me to paste them

## Workspace Structure (Nx Monorepo)
- /apps/web — main Angular application
- /apps/admin — admin panel
- /libs/shared/data-access — API services, state management
- /libs/shared/ui — reusable UI components
- /libs/shared/util — utility functions, pipes

## Angular Conventions
- Angular 17 with standalone components
- Signals for state management (no NgRx)
- Route-level lazy loading with loadComponent
- All components use OnPush change detection
- Functional guards and resolvers (no class-based)

## When Generating Code
- Read existing similar components via MCP before creating new ones
- Match the existing import style and barrel exports
- Check libs/shared/ui for reusable components before creating new ones
- Verify route configuration in app.routes.ts
```

## Best Practices

1. **Scope MCP paths to active work** -- Expose only the app and libraries you are currently modifying. You can update `.claude/mcp.json` as you switch between features without affecting the project.

2. **Combine filesystem MCP with CLAUDE.md** -- MCP handles dynamic file access; CLAUDE.md handles static rules. Use both together for the best results.

3. **Use `search_files` for discovery** -- Instead of telling Claude Code exactly which file to read, let it search for patterns. The filesystem MCP's search tool handles glob patterns and content matching.

4. **Keep config files always accessible** -- Always include `angular.json`, `tsconfig.json`, and `package.json` in your MCP paths. These files are small but contain critical project context that Claude Code references frequently.

5. **Restart after config changes** -- MCP server paths are read at startup. After modifying `.claude/mcp.json`, restart Claude Code for changes to take effect.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-angular-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/)
- [Claude Code ECONNREFUSED MCP Fix](/claude-code-econnrefused-mcp-fix/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
