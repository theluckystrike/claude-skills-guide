---
layout: default
title: "Claude Code allowedTools Config (2026)"
description: "Configure the allowedTools setting in Claude Code. Syntax, patterns, examples, and common recipes for every workflow."
permalink: /claude-code-allowed-tools-config-2026/
date: 2026-04-26
---

# Claude Code allowedTools Config (2026)

The `allowedTools` configuration is where you tell Claude Code which operations it can perform without asking. Get this right and you eliminate dozens of permission prompts per session. Get it wrong and you either block legitimate workflows or expose your system to unintended modifications.

This guide covers the syntax, patterns, and practical recipes. For an interactive setup that generates the right configuration for your workflow, use the [Permissions Configurator](/permissions/).

## How allowedTools Works

When Claude Code wants to use a tool (read a file, run a command, write code), it checks the permission rules in order:

1. **Deny list** — If the tool matches a deny pattern, it is blocked. Always.
2. **Allow list** — If the tool matches an allow pattern, it executes immediately.
3. **Default** — If neither list matches, Claude prompts you for approval.

This means deny rules are your safety net and allow rules are your convenience layer. Everything else falls through to the interactive prompt.

## Configuration Location

Add allowedTools to your `settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)"
    ]
  }
}
```

This lives in one of three places:
- `~/.claude/settings.json` (global, all projects)
- `.claude/settings.json` (project, committed to repo)
- `.claude/settings.local.json` (personal, not committed)

See the [settings.json guide](/claude-code-settings-json-explained-2026/) for the full configuration hierarchy.

## Tool Name Reference

Every tool in Claude Code has a permission identifier:

| Tool | Identifier | What it does |
|------|-----------|-------------|
| Read | `Read` | Read file contents |
| Write | `Write` | Create or overwrite files |
| Edit | `Edit` | Modify specific parts of files |
| Glob | `Glob` | Search for files by name pattern |
| Grep | `Grep` | Search file contents |
| Bash | `Bash(pattern)` | Execute shell commands |
| WebSearch | `WebSearch` | Search the web |
| WebFetch | `WebFetch` | Fetch URL content |
| NotebookEdit | `NotebookEdit` | Edit Jupyter notebooks |

## Bash Pattern Syntax

The `Bash()` identifier supports glob patterns for matching shell commands:

```json
"Bash(git *)"          // Any command starting with "git "
"Bash(pnpm run *)"     // pnpm run followed by anything
"Bash(npm test*)"      // npm test, npm test:unit, npm test:e2e
"Bash(docker compose *)" // docker compose up, down, etc.
"Bash(python -m pytest*)" // pytest with any args
```

### Pattern rules

- `*` matches any sequence of characters
- Patterns match from the start of the command
- Patterns are case-sensitive
- No regex support — only glob-style `*` wildcards

### Escaping

If the command itself contains special characters, the pattern still uses simple glob matching:

```json
"Bash(grep -r \"TODO\" *)"  // Escaping for JSON strings
```

## Common Recipes

### Read-only development

The safest configuration that still eliminates most prompts:

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

Claude can explore your code freely but asks before making any changes.

### Full development (TypeScript)

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git *)",
      "Bash(pnpm *)",
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

### Full development (Python)

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git *)",
      "Bash(python *)",
      "Bash(pip install *)",
      "Bash(pytest *)",
      "Bash(mypy *)",
      "Bash(ruff *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push --force*)",
      "Bash(pip install --user*)"
    ]
  }
}
```

### Full development (Go)

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git *)",
      "Bash(go *)",
      "Bash(make *)",
      "Bash(golangci-lint *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push --force*)"
    ]
  }
}
```

### CI/CD pipeline (maximum speed)

```bash
claude --dangerously-skip-permissions -p "Run tests and fix failures"
```

In disposable environments, skip permissions entirely. See the [permissions guide](/claude-code-permissions-complete-guide-2026/) for when this is appropriate.

## Try It Yourself

The fastest way to get a working configuration is the [Permissions Configurator](/permissions/). It asks about your tech stack and workflow, then generates the exact `settings.json` you need. No manual pattern-writing required.

If you prefer to build manually, start with the read-only recipe above and add permissions as you encounter prompts you want to skip.

## Debugging Permission Issues

### Claude is blocked from something it should be able to do

Check the deny list first. Deny rules override allow rules. If you have `"Bash(git *)"` in allow but `"Bash(git push *)"` in deny, push will be blocked.

Run `/permissions` to see the current active configuration.

### Claude is not prompting for something it should

Check if a broad pattern in the allow list is matching. `"Bash(npm *)"` matches `npm install malicious-package` just as easily as `npm test`. Consider narrowing patterns.

### Settings are not taking effect

Settings.json changes require restarting Claude Code. Run `/doctor` to verify the configuration was loaded correctly.

## Frequently Asked Questions

**Can I use regex in allowedTools patterns?**

No. Only glob-style wildcards (`*`) are supported. For complex matching, use hook scripts that can execute arbitrary validation logic before tool calls.

**Do allow rules apply to MCP server tools?**

Yes. MCP tools can be referenced by their server-qualified name. Check the tool names with `/status` and add them to your allow list if needed.

**What is the performance impact of many allow/deny rules?**

Negligible. Rule matching is a simple string comparison that happens locally. Even hundreds of rules add microseconds of overhead.

**Should I allow Write and Edit, or just one?**

Both, for most development workflows. Write creates and overwrites files; Edit makes surgical changes to existing files. Allowing only Edit prevents Claude from creating new files, which may be desirable for security-sensitive projects.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I use regex in allowedTools patterns?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Only glob-style wildcards (*) are supported. For complex matching, use hook scripts that execute arbitrary validation logic before tool calls."
      }
    },
    {
      "@type": "Question",
      "name": "Do allow rules apply to MCP server tools?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. MCP tools can be referenced by their server-qualified name. Check tool names with /status and add them to your allow list."
      }
    },
    {
      "@type": "Question",
      "name": "What is the performance impact of many allow/deny rules?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Negligible. Rule matching is simple string comparison that happens locally. Even hundreds of rules add microseconds of overhead."
      }
    },
    {
      "@type": "Question",
      "name": "Should I allow Write and Edit, or just one?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Both for most development workflows. Write creates and overwrites files while Edit makes surgical changes. Allowing only Edit prevents creating new files, useful for security-sensitive projects."
      }
    }
  ]
}
</script>

## Related Guides

- [Permissions Configurator](/permissions/) — Interactive configuration generator
- [settings.json Explained](/claude-code-settings-json-explained-2026/) — Every setting documented
- [Permissions Guide](/claude-code-permissions-complete-guide-2026/) — Complete permissions system
- [allowedTools vs dangerously-skip](/allowedtools-vs-dangerously-skip-permissions-guide/) — Risk comparison
- [Secure Claude Code for Teams](/secure-claude-code-for-teams-2026/) — Team security setup
