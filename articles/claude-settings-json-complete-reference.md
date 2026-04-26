---
layout: default
title: ".claude/settings.json: Complete Configuration Reference (2026)"
description: "Every .claude/settings.json field explained: permissions.allow, permissions.deny, model, mcpServers, hooks, and systemPrompt. Annotated example included."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-settings-json-complete-reference/
reviewed: true
categories: [configuration]
tags: [claude, claude-code, settings-json, configuration, reference]
---

# .claude/settings.json: Complete Configuration Reference

The `.claude/settings.json` file controls how Claude Code behaves in your project. It determines which tools are auto-approved, which are blocked, how MCP servers connect, and what custom rules apply. Every field in this file is optional -- Claude Code works without it -- but configuring it properly transforms your workflow from constant approval clicks to seamless execution. Use the [Permissions Configurator](/permissions/) to generate a settings.json tailored to your project.

## File Locations and Precedence

Claude Code reads settings from three locations, in order of precedence:

```
1. Project:  .claude/settings.json      (highest priority)
2. User:     ~/.claude/settings.json     (personal defaults)
3. Default:  Built-in Claude defaults    (lowest priority)
```

Project settings override user settings. Deny rules from any level are always enforced -- a project deny cannot be overridden by user allow.

```bash
# Create project-level settings
mkdir -p .claude
touch .claude/settings.json

# Create user-level settings (applies to all projects)
mkdir -p ~/.claude
touch ~/.claude/settings.json
```

## Complete Annotated Example

Here is every supported field with explanations:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "NotebookEdit",
      "Bash(npm test)",
      "Bash(npm run lint)",
      "Bash(npm run build)",
      "Bash(npx tsc --noEmit)",
      "Bash(npx prisma generate)",
      "Bash(git diff *)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(wc -l *)",
      "mcp__filesystem__read_file",
      "mcp__git__status"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(sudo *)",
      "Bash(curl * | bash)",
      "Bash(cat .env*)",
      "Bash(echo $*KEY*)"
    ]
  },
  "model": "sonnet",
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/project"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_..."
      }
    }
  },
  "hooks": {
    "preToolUse": [
      {
        "matcher": "Bash",
        "command": "echo 'Running bash command'"
      }
    ],
    "postToolUse": [
      {
        "matcher": "Edit",
        "command": "npm run lint --fix $FILE"
      }
    ]
  },
  "systemPrompt": "You are working on a Next.js 15 project with App Router. Use TypeScript strict mode. All components should be server components by default."
}
```

## Field Reference

### permissions.allow

Auto-approves specific tools without prompting. Accepts tool names and Bash commands with glob patterns.

```json
{
  "permissions": {
    "allow": [
      "Read",                        // All file reads
      "Edit",                        // All file edits
      "Bash(npm test)",              // Exact command match
      "Bash(npm run *)",             // Glob: any npm script
      "Bash(git diff *)",            // Glob: git diff with any args
      "Bash(npx prisma *)",          // Glob: any prisma command
      "mcp__server__tool"            // MCP tool by full name
    ]
  }
}
```

**Available tool names:** `Read`, `Glob`, `Grep`, `Edit`, `Write`, `NotebookEdit`, `Bash`, `WebFetch`, `WebSearch`

**Bash pattern matching:** Use `*` as a wildcard. `Bash(npm run *)` matches `npm run test`, `npm run build`, `npm run lint`, etc.

### permissions.deny

Blocks specific tools and commands. Deny rules always win over allow rules.

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",              // Block recursive delete
      "Bash(git push --force *)",    // Block force push
      "Bash(DROP *)",                // Block SQL drops
      "Bash(sudo *)",                // Block privilege escalation
      "WebFetch"                     // Block all web fetching
    ]
  }
}
```

When Claude Code attempts a denied action, it receives an error and must find an alternative approach.

### model

Sets the default Claude model for the project:

```json
{
  "model": "sonnet"
}
```

**Options:** `"sonnet"`, `"opus"`, `"haiku"`. Can be overridden per session with `claude --model opus`.

### mcpServers

Configures Model Context Protocol servers that extend Claude Code's capabilities:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@package/server-name", "arg1"],
      "env": {
        "API_KEY": "value"
      }
    }
  }
}
```

Each MCP server adds tools that Claude Code can use. The server name becomes a prefix for its tools (e.g., `mcp__filesystem__read_file`).

```json
// Common MCP server configurations
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost:5432/mydb"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxx"
      }
    }
  }
}
```

### hooks

Run custom commands before or after tool execution:

```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "Edit",
        "command": "echo 'About to edit: $FILE'"
      }
    ],
    "postToolUse": [
      {
        "matcher": "Edit",
        "command": "npx eslint --fix $FILE"
      },
      {
        "matcher": "Write",
        "command": "npx prettier --write $FILE"
      }
    ]
  }
}
```

**Hook types:**
- `preToolUse`: Runs before the tool executes. Can be used for logging or validation.
- `postToolUse`: Runs after the tool completes. Useful for auto-formatting or linting edited files.

### systemPrompt

Adds a custom system prompt prepended to every conversation:

```json
{
  "systemPrompt": "This is a Next.js 15 project using App Router and TypeScript strict mode. Follow these rules:\n1. All components are server components by default\n2. Use 'use client' only when necessary\n3. Never use any/unknown types\n4. All functions must have explicit return types"
}
```

Keep the system prompt concise. Every token here is loaded into every message, increasing costs across all sessions.

## Validation

Verify your settings.json is valid:

```bash
# Check JSON syntax
cat .claude/settings.json | python3 -m json.tool > /dev/null

# Or use jq
jq '.' .claude/settings.json > /dev/null

# Test by starting Claude Code and checking for config errors
claude --print "What permissions do I have?" 2>&1 | head -5
```

## Try It Yourself

The [Permissions Configurator](/permissions/) generates a complete settings.json for your project. Select your stack, team size, and security requirements. It outputs a ready-to-commit configuration file with appropriate allow/deny lists, model selection, and MCP server setup.

## Frequently Asked Questions

<details>
<summary>Does settings.json support comments?</summary>
No. JSON does not support comments. If you need documentation alongside your config, create a separate SETTINGS-README.md or add comments as unused JSON keys (e.g., "_comment_permissions": "explanation"). The <a href="/permissions/">Permissions Configurator</a> generates clean JSON with no comments needed.
</details>

<details>
<summary>Can I have different settings for different branches?</summary>
Yes, since settings.json is a regular file in your repository. Different branches can have different .claude/settings.json files. This is useful for feature branches that need temporary permissions (e.g., database migration tools) that should not persist to main. See <a href="/configuration/">Configuration</a> for branch-specific patterns.
</details>

<details>
<summary>What happens if settings.json has invalid JSON?</summary>
Claude Code falls back to default settings (prompt for everything) and displays a warning about the invalid configuration file. Fix the JSON syntax and restart the session. Use jq or python3 -m json.tool to validate before committing.
</details>

<details>
<summary>How do MCP server environment variables work with team settings?</summary>
Do not commit API keys or secrets in the project settings.json. Instead, reference environment variables that each developer sets locally, or use a separate ~/.claude/settings.json for MCP server credentials. The project config can define the server command and args while each developer supplies their own env vars. See the <a href="/mcp-config/">MCP Configuration</a> guide for secure patterns.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does Claude Code settings.json support comments?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. JSON does not support comments. If you need documentation, create a separate README or add comments as unused JSON keys."
      }
    },
    {
      "@type": "Question",
      "name": "Can I have different Claude Code settings for different branches?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Settings.json is a regular file in your repository. Different branches can have different .claude/settings.json files, useful for feature branches that need temporary permissions."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if Claude Code settings.json has invalid JSON?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code falls back to default settings and displays a warning. Fix the JSON syntax and restart the session."
      }
    },
    {
      "@type": "Question",
      "name": "How do MCP server environment variables work with team settings in Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Do not commit API keys in project settings.json. Reference environment variables that each developer sets locally, or use a separate ~/.claude/settings.json for MCP server credentials."
      }
    }
  ]
}
</script>

## Related Guides

- [Permissions Configurator](/permissions/) -- Generate your settings.json interactively
- [Configuration Guide](/configuration/) -- Broader configuration topics beyond settings.json
- [CLAUDE.md Generator](/generator/) -- Create the companion CLAUDE.md file
- [Commands Reference](/commands/) -- CLI flags that interact with settings.json
- [MCP Configuration](/mcp-config/) -- Complete guide to MCP server setup
