---
layout: default
title: "Claude Code Permissions Guide (2026)"
description: "Complete guide to Claude Code permissions. Configure tool access, file restrictions, and shell command policies for secure usage."
permalink: /claude-code-permissions-complete-guide-2026/
date: 2026-04-26
---

# Claude Code Permissions Guide (2026)

Permissions in Claude Code determine what the agent can and cannot do on your machine. By default, Claude asks before every potentially risky action: writing files, running shell commands, making network requests. But the default is not the only option, and for most workflows it is not the best option either.

This guide covers the entire permissions system from basic concepts to advanced team configuration. For an interactive setup experience, use the [Permissions Configurator tool](/permissions/).

## Permission Modes

Claude Code operates in one of three permission modes. Each represents a different trade-off between safety and convenience.

### Default Mode

Claude asks for explicit approval before every tool invocation that could modify your system. This includes file writes, shell commands, and any external network calls.

**Best for:** First-time users, security-sensitive environments, working with unfamiliar codebases.

**Drawback:** Constant permission prompts interrupt flow. A typical 30-minute session might involve 30-50 approval prompts.

### Allowlist Mode

You pre-approve specific tools and command patterns. Claude executes approved actions without asking and prompts only for unapproved ones.

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(git *)",
      "Bash(pnpm *)",
      "Bash(npm test*)"
    ]
  }
}
```

**Best for:** Experienced users who want to eliminate routine prompts while maintaining control over dangerous operations.

**Configuration:** Use the [Permissions Configurator](/permissions/) to build your allowlist interactively, or edit `settings.json` directly per the [settings.json guide](/claude-code-permission-rules-settings-json-guide/).

### YOLO Mode (dangerously-skip-permissions)

Claude executes all tools without asking. No prompts, no confirmations, no safety net.

```bash
claude --dangerously-skip-permissions
```

**Best for:** Isolated environments (containers, VMs, CI pipelines) where Claude cannot damage anything important.

**Never use for:** Production machines, repositories with sensitive data, or shared development environments. See the [allowedTools vs dangerously-skip guide](/allowedtools-vs-dangerously-skip-permissions-guide/) for a detailed risk comparison.

## Configuring Permissions in settings.json

Permissions are configured in your `settings.json` file. There are three levels, each overriding the one above:

### Global settings (~/.claude/settings.json)

Applies to every project on your machine:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ]
  }
}
```

### Project settings (.claude/settings.json)

Applies to one specific project. Overrides global for that project:

```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm *)",
      "Bash(vitest *)",
      "Write"
    ]
  }
}
```

### Session override (CLI flags)

Applies to a single session:

```bash
claude --allowedTools "Read,Glob,Grep,Bash(git *)"
```

For the complete settings.json reference, see [settings.json explained](/claude-code-settings-json-explained-2026/).

## Permission Rules Syntax

### Tool names

Permissions reference tool names directly:

| Tool | Permission String |
|------|-------------------|
| Read files | `Read` |
| Write files | `Write` |
| Edit files | `Edit` |
| Run shell commands | `Bash(pattern)` |
| File search | `Glob` |
| Content search | `Grep` |
| Web search | `WebSearch` |
| Web fetch | `WebFetch` |

### Bash patterns

The `Bash()` permission supports glob-style patterns for command matching:

```json
"Bash(git *)"        // All git commands
"Bash(pnpm *)"       // All pnpm commands
"Bash(npm test*)"    // npm test and npm test:unit, etc.
"Bash(docker *)"     // All docker commands
"Bash(ls *)"         // All ls commands
```

### Deny rules

Deny rules override allow rules. Use them to block specific dangerous patterns even when broader patterns are allowed:

```json
{
  "permissions": {
    "allow": ["Bash(git *)"],
    "deny": ["Bash(git push --force*)"]
  }
}
```

This allows all git commands except force pushes. Deny rules are your safety net for preventing catastrophic operations.

## Security Best Practices

### Principle of least privilege

Start with minimal permissions and add more as needed. It is easier to grant additional access than to recover from a mistake caused by excessive permissions.

Recommended starting allowlist:
```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)"
    ]
  }
}
```

This lets Claude read and search your code, check git status, and view diffs — all read-only operations. Add write permissions only for tools you trust Claude to use unsupervised.

### Directory restrictions

Limit file operations to your project directory. Claude should not be reading or writing files outside your workspace:

```json
{
  "permissions": {
    "deny": [
      "Read(/etc/*)",
      "Read(~/.ssh/*)",
      "Read(~/.aws/*)",
      "Write(/etc/*)"
    ]
  }
}
```

### Audit logging

Enable audit logs to track what Claude does with its permissions:

```json
{
  "auditLog": true
}
```

This creates a record of every tool invocation, which is essential for team environments and compliance requirements. See the [security best practices guide](/claude-code-security-best-practices-2026/) for comprehensive security configuration.

## Try It Yourself

The [Permissions Configurator](/permissions/) walks you through setting up permissions interactively. Answer a few questions about your workflow and it generates the correct `settings.json` configuration.

This is the fastest path to a secure, low-friction permission setup. The configurator covers common patterns for frontend development, backend services, DevOps workflows, and more.

## Common Permission Recipes

### Frontend developer

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep", "Write", "Edit",
      "Bash(pnpm *)", "Bash(npm *)",
      "Bash(git *)", "Bash(vitest *)",
      "Bash(eslint *)", "Bash(tsc *)"
    ],
    "deny": [
      "Bash(rm -rf *)", "Bash(sudo *)",
      "Bash(git push --force*)"
    ]
  }
}
```

### Backend developer

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep", "Write", "Edit",
      "Bash(go *)", "Bash(cargo *)",
      "Bash(docker compose *)", "Bash(curl *)",
      "Bash(git *)", "Bash(make *)"
    ],
    "deny": [
      "Bash(rm -rf *)", "Bash(sudo *)",
      "Bash(docker rm *)"
    ]
  }
}
```

### CI/CD pipeline

```bash
claude --dangerously-skip-permissions -p "Run the test suite and fix any failures"
```

In CI, the environment is disposable. Full permissions are safe because the container is destroyed after the run.

## Frequently Asked Questions

**What is the safest permission configuration?**

Default mode with no allowlist. Claude asks before every action. This is the safest but also the slowest workflow. For a practical balance, use a minimal allowlist that permits read-only operations.

**Can permissions prevent data exfiltration?**

Partially. Denying WebSearch and WebFetch prevents Claude from sending data to external URLs. However, Claude can still include information in tool call parameters. For sensitive environments, use network-level controls alongside permissions.

**Do permission changes take effect immediately?**

Settings.json changes require restarting Claude Code. CLI flag overrides take effect for the current session only. The Permissions Configurator generates the settings.json for you to apply.

**How do team permissions work?**

Commit `.claude/settings.json` to your repository. Every team member who clones the repo gets the same permission configuration. Global settings in `~/.claude/settings.json` can add personal permissions on top.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the safest permission configuration?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Default mode with no allowlist. Claude asks before every action. This is safest but slowest. For practical balance, use a minimal allowlist permitting read-only operations."
      }
    },
    {
      "@type": "Question",
      "name": "Can permissions prevent data exfiltration?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Partially. Denying WebSearch and WebFetch prevents sending data to external URLs. For sensitive environments, use network-level controls alongside Claude Code permissions."
      }
    },
    {
      "@type": "Question",
      "name": "Do permission changes take effect immediately?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Settings.json changes require restarting Claude Code. CLI flag overrides take effect for the current session only."
      }
    },
    {
      "@type": "Question",
      "name": "How do team permissions work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Commit .claude/settings.json to your repository. Every team member who clones the repo gets the same permission configuration. Global settings can add personal permissions on top."
      }
    }
  ]
}
</script>

## Related Guides

- [Permissions Configurator](/permissions/) — Interactive permission setup tool
- [settings.json Explained](/claude-code-settings-json-explained-2026/) — Complete settings reference
- [allowedTools vs dangerously-skip](/allowedtools-vs-dangerously-skip-permissions-guide/) — Risk comparison
- [Permission Rules in settings.json](/claude-code-permission-rules-settings-json-guide/) — Rule syntax reference
- [Claude Code Security Best Practices](/claude-code-security-best-practices-2026/) — Enterprise security guide
