---
layout: default
title: "Claude Code settings.json Explained (2026)"
description: "Every setting in Claude Code's settings.json file explained. Permissions, models, hooks, MCP servers, and configuration hierarchy."
permalink: /claude-code-settings-json-explained-2026/
date: 2026-04-26
---

# Claude Code settings.json Explained (2026)

The `settings.json` file is where Claude Code's behavior is configured. Permissions, default models, tool access, hook scripts, and MCP server connections all live here. Yet most developers either use the defaults or copy-paste a configuration they found online without understanding what each field does.

This reference explains every setting with practical examples. For a guided setup experience, use the [Permissions Configurator](/permissions/) which generates a tailored settings.json for your workflow.

## Where settings.json Lives

Claude Code reads settings from three locations, in order of precedence:

| Level | Path | Scope |
|-------|------|-------|
| Global | `~/.claude/settings.json` | All projects on this machine |
| Project | `.claude/settings.json` | This repository only |
| Local | `.claude/settings.local.json` | This repository, not committed |

**Merge behavior:** Project settings override global settings. Local settings override both. Arrays are replaced, not merged — if you define `permissions.allow` at the project level, it replaces the global `permissions.allow` entirely.

This hierarchy lets you set safe defaults globally and customize per-project. The local file (`.local.json`) is for personal preferences that should not be committed to the repository.

## Permissions Settings

The most important section. Controls what Claude can do without asking.

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(git *)",
      "Bash(pnpm *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push --force*)"
    ]
  }
}
```

### allow

An array of tool patterns Claude can execute without prompting. Patterns can be exact tool names (`Read`, `Write`) or Bash command patterns with globs (`Bash(git *)`).

### deny

An array of tool patterns Claude must never execute, even if they match an allow rule. Deny always wins over allow. Use this for dangerous operations you want blocked regardless of other settings.

See the [permissions guide](/claude-code-permissions-complete-guide-2026/) for recipes and best practices, or generate your configuration with the [Permissions Configurator](/permissions/).

## Model Settings

Configure which model Claude Code uses by default:

```json
{
  "model": "claude-sonnet-4",
  "thinkingModel": "claude-opus-4"
}
```

### model

The default model for all interactions. Can be overridden per-session with the `/model` command.

### thinkingModel

The model used for extended thinking operations. If not set, Claude Code uses the default model for everything.

Using Sonnet as default and Opus for thinking is a cost-effective pattern. Routine operations use the cheaper model while complex reasoning gets the more capable one. See the [cost optimization guide](/claude-code-cost-optimization-15-techniques/) for model selection strategies.

## Hook Settings

Hooks are scripts that run at specific points in Claude Code's lifecycle:

```json
{
  "hooks": {
    "preSession": "bash .claude/hooks/pre-session.sh",
    "postSession": "bash .claude/hooks/post-session.sh",
    "preToolCall": "bash .claude/hooks/pre-tool.sh",
    "postToolCall": "bash .claude/hooks/post-tool.sh"
  }
}
```

### preSession

Runs when a Claude Code session starts. Use it to validate environment, check prerequisites, or load context.

### postSession

Runs when a session ends. Use it for cleanup, logging session costs, or running post-work checks.

### preToolCall

Runs before every tool invocation. Receives the tool name and parameters as arguments. Can block the call by returning a non-zero exit code. Use for audit logging or additional safety checks.

### postToolCall

Runs after every tool invocation. Receives the tool result. Use for logging or triggering follow-up actions.

Hooks enable custom workflows without modifying Claude Code itself. See the [hooks for code quality guide](/best-claude-code-hooks-code-quality-2026/) for practical examples.

## MCP Server Settings

Connect external tool servers via the Model Context Protocol:

```json
{
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@mcp/postgres-server"],
      "env": {
        "DATABASE_URL": "postgresql://localhost/mydb"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@mcp/github-server"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

Each MCP server provides Claude with additional tools. The `command` and `args` specify how to start the server. The `env` object passes environment variables.

**Performance note:** Each MCP server adds tool definitions to the context, consuming tokens on every API call. Only enable servers you actively use. See [building token-efficient MCP servers](/building-token-efficient-mcp-servers-claude-code/) for optimization tips.

## Cost Settings

Configure spending controls:

```json
{
  "costAlerts": {
    "sessionWarning": 5.00,
    "dailyWarning": 25.00
  },
  "auditLog": true
}
```

### costAlerts

Set dollar thresholds for warnings. Claude Code notifies you when approaching these limits. See the [cost alerts guide](/claude-code-cost-alerts-notifications-budget/) for configuration options.

### auditLog

When enabled, Claude Code logs every tool invocation with timestamps, parameters, and results. Essential for teams and compliance.

## Display and Interface Settings

```json
{
  "theme": "dark",
  "verbose": false,
  "showTokenCount": true
}
```

### showTokenCount

When enabled, shows token counts alongside responses. Useful for building intuition about token costs without running `/cost` constantly. Pairs well with the [Token Estimator](/token-estimator/).

## Complete Example

Here is a full settings.json for a TypeScript web project:

```json
{
  "model": "claude-sonnet-4",
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git *)",
      "Bash(pnpm *)",
      "Bash(vitest *)",
      "Bash(tsc --noEmit)",
      "Bash(eslint *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push --force*)",
      "Bash(pnpm publish*)"
    ]
  },
  "hooks": {
    "postSession": "bash .claude/hooks/log-cost.sh"
  },
  "costAlerts": {
    "sessionWarning": 3.00,
    "dailyWarning": 15.00
  },
  "showTokenCount": true
}
```

## Try It Yourself

Use the [Permissions Configurator](/permissions/) to generate a settings.json tailored to your project. Answer questions about your tech stack, team size, and security requirements, and it produces a complete configuration file ready to use.

You can also start from the complete example above and modify it to match your specific tools and workflows.

## Frequently Asked Questions

**Where should I put settings.json for a team project?**

Put shared settings in `.claude/settings.json` and commit it to your repository. Team members can add personal overrides in `.claude/settings.local.json` which should be in `.gitignore`.

**What happens if settings.json has a syntax error?**

Claude Code falls back to default settings and logs a warning. Run `/doctor` to check for configuration issues. Keep a backup of your working configuration.

**Can I have different settings for different branches?**

Yes. Since `.claude/settings.json` is a repository file, different branches can have different configurations. This is useful for production branches (stricter permissions) versus development branches (more permissive).

**Do MCP server settings support environment variable expansion?**

Yes. Use `${VAR_NAME}` syntax in env values. This lets you reference secrets stored in your shell environment without hardcoding them in settings.json.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Where should I put settings.json for a team project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Put shared settings in .claude/settings.json and commit to your repository. Team members add personal overrides in .claude/settings.local.json which should be in .gitignore."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if settings.json has a syntax error?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code falls back to default settings and logs a warning. Run /doctor to check for configuration issues. Keep a backup of your working configuration."
      }
    },
    {
      "@type": "Question",
      "name": "Can I have different settings for different branches?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Since .claude/settings.json is a repository file, different branches can have different configurations. Useful for stricter production versus permissive development."
      }
    },
    {
      "@type": "Question",
      "name": "Do MCP server settings support environment variable expansion?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Use ${VAR_NAME} syntax in env values to reference secrets stored in your shell environment without hardcoding them in settings.json."
      }
    }
  ]
}
</script>



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

- [Permissions Configurator](/permissions/) — Generate settings.json interactively
- [Claude Code Permissions Guide](/claude-code-permissions-complete-guide-2026/) — Complete permissions reference
- [Configuration Hierarchy](/claude-code-configuration-hierarchy-explained-2026/) — How settings layer together
- [Permission Rules in settings.json](/claude-code-permission-rules-settings-json-guide/) — Rule syntax reference
- [Hooks for Code Quality](/best-claude-code-hooks-code-quality-2026/) — Hook configuration examples
