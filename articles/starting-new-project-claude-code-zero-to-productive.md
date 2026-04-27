---
sitemap: false
layout: default
title: "Starting a New Project with Claude Code: Zero to Productive (2026)"
description: "Go from zero to productive with Claude Code in 15 minutes: install, run /init, create CLAUDE.md, configure permissions, add MCP servers, write your first feature."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /starting-new-project-claude-code-zero-to-productive/
reviewed: true
categories: [getting-started]
tags: [claude, claude-code, setup, getting-started, tutorial]
---

# Starting a New Project with Claude Code: Zero to Productive

Getting Claude Code productive on a new project takes 15 minutes when you follow the right sequence. Skip steps and you end up with a misconfigured agent that reads irrelevant files, asks for permission on every action, and burns through tokens. This walkthrough covers install through first feature -- in order. Use the [Project Starter](/starter/) to generate your configuration files automatically instead of writing them from scratch.

## Step 1: Install Claude Code (2 minutes)

```bash
# Install globally via npm
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
# Claude Code v1.x.x

# Set your API key (if not using Claude Pro/Max subscription)
export ANTHROPIC_API_KEY="sk-ant-..."

# Add to your shell profile for persistence
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshrc
```

## Step 2: Initialize Your Project (2 minutes)

Navigate to your project root and run the init command:

```bash
cd /path/to/your/project

# Initialize Claude Code for this project
claude /init

# This creates:
# .claude/            -- Claude Code configuration directory
# CLAUDE.md           -- Project instructions file (edit this)
# .claudeignore       -- Files to exclude from context (like .gitignore)
```

The `/init` command scans your project structure and generates a starter CLAUDE.md based on detected languages, frameworks, and build tools. Review and customize it.

## Step 3: Configure CLAUDE.md (5 minutes)

CLAUDE.md is the most important file for Claude Code's effectiveness. It tells the agent how your project works, what conventions to follow, and what to avoid.

```markdown
# CLAUDE.md

## Project
Next.js 15 App Router, TypeScript strict, Tailwind CSS, Supabase

## Commands
- `pnpm dev` -- start dev server
- `pnpm test` -- run Vitest tests
- `pnpm lint` -- run ESLint
- `pnpm typecheck` -- run tsc --noEmit
- `pnpm build` -- production build

## Rules
- Server components by default. Use "use client" only when needed.
- All functions under 60 lines. Extract helpers.
- Explicit return types on all exported functions.
- Never modify files in migrations/ -- create new migrations.
- Tests live next to source: `Component.test.tsx` beside `Component.tsx`.
- Use Zod for all API input validation.

## Structure
- src/app/ -- Next.js App Router pages and layouts
- src/components/ -- Shared React components
- src/lib/ -- Utility functions and shared logic
- src/db/ -- Database queries and Supabase client
- src/types/ -- TypeScript type definitions
```

Keep it concise. Every token in CLAUDE.md is loaded into every conversation. The [Project Starter](/starter/) generates an optimized CLAUDE.md for your stack.

## Step 4: Set Up .claudeignore (1 minute)

Exclude files that waste context tokens:

```bash
# .claudeignore
node_modules/
.next/
dist/
build/
coverage/
.git/
*.lock
*.min.js
*.min.css
*.map
public/assets/images/
```

This prevents Claude Code from reading build artifacts, dependencies, and large binary files. A well-configured `.claudeignore` reduces token usage by 25-40%.

## Step 5: Configure Permissions (3 minutes)

Create `.claude/settings.json` to auto-approve safe tools:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "Bash(pnpm test)",
      "Bash(pnpm lint)",
      "Bash(pnpm typecheck)",
      "Bash(pnpm dev)",
      "Bash(git diff *)",
      "Bash(git status)",
      "Bash(git log *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(sudo *)"
    ]
  }
}
```

With this config, Claude Code auto-approves file operations, tests, and lint. It blocks destructive commands and prompts for anything not listed.

## Step 6: Add an MCP Server (Optional, 2 minutes)

MCP servers extend Claude Code's capabilities. Add one if your project needs it:

```json
// .claude/settings.json -- add mcpServers section
{
  "permissions": { "..." },
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_..."
      }
    }
  }
}
```

Common MCP servers: filesystem, GitHub, PostgreSQL, Slack. See the [MCP Configuration guide](/mcp-config/) for the full list.

## Step 7: Write Your First Feature (5 minutes)

With configuration done, use Claude Code to build something:

```bash
# Start Claude Code
claude

# Give it a focused, specific task:
> Create a health check API route at /api/health that returns
  { status: "ok", timestamp: ISO string, version: from package.json }.
  Include a test file.

# Claude Code will:
# 1. Read package.json for the version field
# 2. Create src/app/api/health/route.ts
# 3. Create src/app/api/health/route.test.ts
# 4. Run pnpm test to verify
```

Notice how Claude Code uses the conventions from your CLAUDE.md -- server component by default, TypeScript types, test file next to source.

## Verification Checklist

After setup, verify everything works:

```bash
# 1. Claude Code reads your CLAUDE.md
claude "What are the project rules from CLAUDE.md?"

# 2. .claudeignore is working (should not read node_modules)
claude "Search for the lodash import in the project"
# Should search only src/, not node_modules/

# 3. Permissions auto-approve safe commands
claude "Run the test suite"
# Should execute pnpm test without prompting

# 4. Deny list blocks dangerous commands
claude "Delete the dist folder with rm -rf"
# Should be blocked by deny rule
```

## Try It Yourself

The [Project Starter](/starter/) automates steps 2-5. Enter your project stack (Next.js, Python, Rust, etc.), and it generates a complete CLAUDE.md, .claudeignore, and settings.json. Drop the files into your project root and start coding immediately.

## Frequently Asked Questions

<details>
<summary>Can I use Claude Code without a CLAUDE.md file?</summary>
Yes. Claude Code works without CLAUDE.md by inferring project details from the file structure. But it will miss your conventions, preferred tools, and project-specific rules. It might use yarn instead of pnpm, write tests in the wrong directory, or use formatting you do not follow. A 5-minute CLAUDE.md setup saves hours of corrections. Generate one with the <a href="/starter/">Project Starter</a>.
</details>

<details>
<summary>Should I commit .claude/settings.json to git?</summary>
Yes, for team projects. The settings.json defines the permission standard for everyone on the team. Commit it alongside your code so all contributors inherit the same allow/deny rules. Personal overrides go in ~/.claude/settings.json (not committed). See <a href="/getting-started/">Getting Started</a> for more.
</details>

<details>
<summary>How do I update CLAUDE.md as the project evolves?</summary>
Treat CLAUDE.md like documentation -- update it when you add new conventions, change build tools, or restructure the project. Claude Code re-reads CLAUDE.md at the start of every session, so changes take effect immediately. A good habit: update CLAUDE.md as part of every PR that changes project structure. Use the <a href="/commands/">Commands Reference</a> to see what /init generates.
</details>

<details>
<summary>What if I work on multiple projects with different stacks?</summary>
Each project has its own .claude/ directory and CLAUDE.md. Claude Code loads the project-local configuration when you start a session in that directory. Your ~/.claude/settings.json provides global defaults (like personal tool preferences) that apply across all projects. See <a href="/configuration/">Configuration</a> for the precedence rules.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I use Claude Code without a CLAUDE.md file?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, but Claude Code will miss your conventions and project-specific rules. A 5-minute CLAUDE.md setup saves hours of corrections."
      }
    },
    {
      "@type": "Question",
      "name": "Should I commit .claude/settings.json to git?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, for team projects. The settings.json defines the permission standard for everyone. Personal overrides go in ~/.claude/settings.json."
      }
    },
    {
      "@type": "Question",
      "name": "How do I update CLAUDE.md as the project evolves?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Treat it like documentation -- update when you add conventions, change tools, or restructure. Claude Code re-reads it at the start of every session. Update CLAUDE.md as part of every PR that changes project structure."
      }
    },
    {
      "@type": "Question",
      "name": "What if I work on multiple projects with different stacks?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Each project has its own .claude/ directory and CLAUDE.md. Your ~/.claude/settings.json provides global defaults that apply across all projects."
      }
    }
  ]
}
</script>



**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related Guides

- [Project Starter](/starter/) -- Auto-generate CLAUDE.md, settings.json, and .claudeignore
- [Getting Started Guide](/getting-started/) -- Broader introduction to Claude Code
- [CLAUDE.md Generator](/generator/) -- Create optimized project instruction files
- [Commands Reference](/commands/) -- All Claude Code commands including /init
- [MCP Configuration](/mcp-config/) -- Set up MCP servers for extended capabilities
