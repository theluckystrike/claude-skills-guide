---
layout: default
title: "Claude Code Hidden Commands (2026)"
description: "Discover lesser-known Claude Code commands that most developers miss. Custom commands, debug flags, and advanced features explained."
permalink: /claude-code-hidden-commands-2026/
date: 2026-04-26
---

# Claude Code Hidden Commands (2026)

Claude Code has more commands than the ones listed in `/help`. Some are undocumented, some are new in 2026, and some are technically available but so rarely mentioned that they might as well be hidden. This guide covers the commands that most developers never discover.

For the complete interactive reference, use the [Command Reference tool](/commands/).

## Custom Slash Commands

The most powerful "hidden" feature is that you can create your own slash commands. Place a markdown file in `.claude/commands/` in your project, and its filename becomes a command.

```
mkdir -p .claude/commands
```

Create `.claude/commands/review-security.md`:

```markdown
Review the current codebase changes for security vulnerabilities:
1. Check for hardcoded secrets or API keys
2. Verify input validation on all user-facing endpoints
3. Check for SQL injection, XSS, and CSRF vulnerabilities
4. Verify authentication and authorization checks
5. Report findings as severity / location / recommended fix
```

Now type `/review-security` in any Claude Code session within this project. Claude executes the instructions in the markdown file as if you had typed them. This turns repetitive multi-line prompts into single commands.

### Team-wide custom commands

Place commands in `.claude/commands/` at the repository root and commit them. Every team member who clones the repo gets the same commands. This standardizes workflows across the team.

Common team commands:

- `/pr-description` — Generate a pull request description from staged changes
- `/test-plan` — Create a test plan for the current feature
- `/deploy-checklist` — Run through pre-deployment verification steps
- `/onboard` — Explain the project structure to a new developer

For more examples, see [best commands you are not using](/best-claude-code-commands-you-are-not-using-2026/).

## Debug and Diagnostic Commands

### /doctor with verbose output

While `/doctor` is documented, most developers do not know it can reveal detailed diagnostic information about tool registration, MCP server connections, and permission state.

```
/doctor
```

The output includes:
- API key validation status
- Available tools and their registration state
- MCP server connection health
- Configuration file parse status
- Environment variable validation

When Claude Code behaves unexpectedly, `/doctor` should be your first step. It catches configuration problems that would otherwise require manual debugging.

### /status deep dive

The `/status` command shows more than most developers realize. Beyond the active model, it reveals:

- Current permission mode (default, allowlist, or YOLO)
- Loaded CLAUDE.md files (project, parent directories, global)
- Active MCP servers and their tool counts
- Memory entries in effect
- Session token consumption

This tells you exactly what context Claude is working with, which matters when responses seem off-base.

## Context Management Commands

### /compact with focus directives

Most developers use `/compact` without arguments. Adding a focus directive makes the compression significantly better:

```
/compact focus on the authentication refactor
/compact preserve all database schema decisions
/compact keep error handling patterns, drop exploration
```

The focus parameter tells Claude what to prioritize when compressing the conversation history. Without it, Claude makes its own judgment calls about what to keep, which may not match your priorities.

This is critical for long sessions where you have explored multiple approaches but only one path matters. See the [context window management guide](/claude-code-context-window-management-2026/) for strategies.

### /memory for persistent preferences

The `/memory` command creates entries that persist across sessions. Most developers do not know this exists:

```
/memory add "Use TypeScript strict mode in all new files"
/memory add "Run tests with pnpm test, not npm test"
/memory add "Prefer functional components over class components"
/memory list
/memory remove 2
```

Memory entries supplement `CLAUDE.md` with personal preferences that apply across all projects. They are stored locally and never sent to Anthropic's servers.

## CLI Flags as Hidden Commands

Claude Code accepts flags that change its behavior before the session starts. These are not slash commands but command-line arguments:

```bash
# Start with a specific model
claude --model claude-sonnet-4

# Run a single command and exit (non-interactive)
claude -p "explain this error: ${ERROR_MESSAGE}"

# Pipe input to Claude
cat error.log | claude -p "what went wrong?"

# Resume the previous conversation
claude --continue

# Start with specific permission mode
claude --dangerously-skip-permissions
```

The `-p` flag is particularly powerful for automation. It lets you use Claude Code in shell scripts, CI pipelines, and git hooks. Combine it with the [Token Estimator](/token-estimator/) to predict costs for scripted usage.

## Advanced Tool Control

### Allowing and blocking tools inline

You can control which tools Claude has access to without modifying `settings.json`:

```bash
claude --allowedTools "Bash,Read,Write"
```

This restricts Claude to only the specified tools for that session. Useful for security-sensitive tasks where you want to prevent file writes or command execution.

For persistent tool configuration, use the [Permissions Configurator](/permissions/) or edit [settings.json directly](/claude-code-permission-rules-settings-json-guide/).

## Try It Yourself

Explore all commands, both documented and lesser-known, with the [Command Reference tool](/commands/). The interactive search helps you discover commands by what they do, not just by name. Type "context" to find context management commands, or "permission" to see access control options.

Start by creating one custom slash command for a task you repeat often. The five minutes you invest pays back in every future session.

## Frequently Asked Questions

**Where are custom commands stored?**

Project commands live in `.claude/commands/` inside your repository. Personal commands can be placed in `~/.claude/commands/` for commands that apply to all projects.

**Can custom commands accept parameters?**

Yes. Use `$ARGUMENTS` in your markdown file. When you type `/my-command some text`, the "some text" replaces `$ARGUMENTS` in the template.

**Do hidden commands work in all Claude Code versions?**

Most features described here work in Claude Code 1.0 and later. Custom slash commands were introduced in late 2025. Check your version with `claude --version`.

**How many custom commands can I create?**

There is no hard limit. Claude loads command files at session start, so hundreds of files could slow initialization, but in practice most projects use fewer than twenty.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Where are custom commands stored?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Project commands live in .claude/commands/ inside your repository. Personal commands can be placed in ~/.claude/commands/ for commands that apply to all projects."
      }
    },
    {
      "@type": "Question",
      "name": "Can custom commands accept parameters?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Use $ARGUMENTS in your markdown file. When you type /my-command some text, the text replaces $ARGUMENTS in the template."
      }
    },
    {
      "@type": "Question",
      "name": "Do hidden commands work in all Claude Code versions?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Most features described here work in Claude Code 1.0 and later. Custom slash commands were introduced in late 2025. Check your version with claude --version."
      }
    },
    {
      "@type": "Question",
      "name": "How many custom commands can I create?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "There is no hard limit. Claude loads command files at session start, so hundreds of files could slow initialization, but in practice most projects use fewer than twenty."
      }
    }
  ]
}
</script>

## Related Guides

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).

- [Command Reference](/commands/) — Interactive command explorer with search
- [Every Claude Code Slash Command](/every-claude-code-slash-command-explained/) — Official command reference
- [Best Commands You Are Not Using](/best-claude-code-commands-you-are-not-using-2026/) — Top 10 overlooked commands
- [Claude Code Configuration Hierarchy](/claude-code-configuration-hierarchy-explained-2026/) — How settings layer together
- [Permissions Configurator](/permissions/) — Interactive permission setup
