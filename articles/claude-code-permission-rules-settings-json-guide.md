---
layout: default
title: "Claude Code Permission Rules in settings.json"
description: "Configure allow, deny, and ask permission rules in Claude Code settings.json with wildcards for Bash, Read, Edit, and MCP tools."
date: 2026-04-15
permalink: /claude-code-permission-rules-settings-json-guide/
categories: [guides, claude-code]
tags: [permissions, settings, configuration, security, allow-deny]
---

# Claude Code Permission Rules in settings.json

## The Problem

You want Claude Code to auto-approve safe commands like `npm test` and `git commit` while blocking dangerous operations like `rm -rf` and reading `.env` files. Manual approval for every command wastes time, but unrestricted access is risky.

## Quick Fix

Add permission rules to `.claude/settings.json` in your project root:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run test *)",
      "Bash(npm run build)",
      "Bash(git commit *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  }
}
```

## What's Happening

Claude Code uses a tiered permission system. Read-only operations (file reads, grep, glob) require no approval. File modifications and shell commands require manual approval by default. Permission rules let you pre-approve safe operations and block dangerous ones.

Rules are evaluated in order: deny, then ask, then allow. The first matching rule wins. Deny rules always take precedence, so even if a command matches an allow rule, a matching deny rule blocks it.

Rules support the `Tool` or `Tool(specifier)` syntax. For Bash commands, wildcards (`*`) match any sequence of characters including spaces. For Read and Edit rules, patterns follow the gitignore specification.

## Step-by-Step Fix

### Step 1: Understand rule scopes

Permission rules can be defined at multiple levels:

| Location | Scope | Shared? |
|----------|-------|---------|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | This project, all developers | Yes (committed to git) |
| `.claude/settings.local.json` | This project, just you | No (gitignored) |
| Managed settings | Organization-wide | Yes (admin-controlled) |

### Step 2: Configure Bash rules with wildcards

Wildcards can appear at any position in the command:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git commit *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(* --version)",
      "Bash(* --help *)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(rm -rf *)",
      "Bash(curl *)"
    ]
  }
}
```

The space before `*` matters. `Bash(ls *)` matches `ls -la` but not `lsof`. `Bash(ls*)` matches both.

### Step 3: Configure file access rules

Read and Edit rules follow gitignore patterns:

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Edit(/docs/**)"
    ],
    "allow": [
      "Read(~/.zshrc)",
      "Edit(/src/**/*.ts)"
    ]
  }
}
```

Pattern types:
- `//path`: Absolute from filesystem root
- `~/path`: Relative to home directory
- `/path`: Relative to project root
- `./path`: Relative to current directory

### Step 4: Configure MCP tool permissions

Control access to MCP server tools:

```json
{
  "permissions": {
    "allow": [
      "mcp__github__*",
      "mcp__memory__add_memory"
    ],
    "deny": [
      "mcp__filesystem__delete_file"
    ]
  }
}
```

`mcp__servername` matches any tool from that server. `mcp__servername__toolname` matches a specific tool.

### Step 5: Use ask rules for confirmation

The `ask` array creates rules that always prompt for confirmation, even in auto mode:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run test *)"
    ],
    "ask": [
      "Bash(npm run deploy *)"
    ],
    "deny": [
      "Bash(rm -rf *)"
    ]
  }
}
```

### Step 6: Understand compound command handling

Claude Code is aware of shell operators. A rule like `Bash(safe-cmd *)` does not permit `safe-cmd && dangerous-cmd`. Recognized separators include `&&`, `||`, `;`, `|`, `|&`, `&`, and newlines. Each subcommand must match a rule independently.

Process wrappers like `timeout`, `time`, `nice`, `nohup`, and `stdbuf` are automatically stripped before matching. So `Bash(npm test *)` also matches `timeout 30 npm test`.

### Step 7: View and manage rules

Inside Claude Code, run:

```text
/permissions
```

This shows all permission rules and which settings file they come from. Rules from deny take highest priority, then ask, then allow.

## Prevention

Commit `.claude/settings.json` with your project's permission rules to version control. This ensures every developer gets the same safety configuration. Use `.claude/settings.local.json` for personal overrides that should not affect the team.

For enterprise teams, use managed settings to enforce organization-wide deny rules that cannot be overridden:

```json
{
  "permissions": {
    "deny": [
      "Bash(curl *)",
      "Bash(wget *)",
      "Read(./.env)",
      "Read(./secrets/**)"
    ]
  }
}
```

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">
<strong>Built by Michael</strong> · Top Rated Plus on Upwork · $400K+ earned building with AI · 16 Chrome extensions · 3,000+ users · Building with Claude Code since launch.
<a href="https://zovo.one/lifetime?utm_source=ccg&utm_medium=author-bio&utm_campaign=social-proof">See what I ship with →</a>
</div>

---


<div class="before-after">
<div class="before">
<h4>Without CLAUDE.md</h4>
<p>You: "Add authentication to my Next.js app"</p>
<p>Claude Code generates a <code>pages/</code> directory (your App Router uses <code>app/</code>), picks NextAuth v4 (v5 is current), creates <code>.js</code> files in a TypeScript project, and uses <code>getServerSession</code> incorrectly with the wrong adapter pattern.</p>
<p><strong>Result:</strong> You spend 45 minutes fixing what Claude broke.</p>
</div>
<div class="after">
<h4>With a Professional CLAUDE.md</h4>
<p>You: Same prompt.</p>
<p>Claude Code reads CLAUDE.md &rarr; knows App Router + TypeScript strict + NextAuth v5 &rarr; generates <code>app/api/auth/[...nextauth]/route.ts</code> with correct session handling, middleware config, and type-safe session types that match your existing schema.</p>
<p><strong>Result:</strong> It works on the first run. You ship.</p>
</div>
</div>

<div class="mastery-cta">

**You're configuring this manually. There's a faster way.**

Production-ready CLAUDE.md templates for 16 frameworks. Copy into your project, Claude Code immediately understands your stack — right conventions, right patterns, right versions. No more fixing what it gets wrong.

**[Get the production config →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-permission-rules-settings-json-guide)**

$99 once. Yours forever. 47/500 founding spots left.

</div>

---

## Related Guides

- [Understanding Claude Code Hooks System Complete Guide](/understanding-claude-code-hooks-system-complete-guide/)
- [Claude Code Skill Permission Denied Error Fix](/claude-code-skill-permission-denied-error-fix-2026/)
- [Claude Code Docker Permission Denied Fix](/claude-code-docker-permission-denied-bind-mount-error/)
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
