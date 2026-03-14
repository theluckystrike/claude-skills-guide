---
layout: default
title: "Claude Code Setup on Mac: Step-by-Step Guide for Developers"
description: "A practical walkthrough for setting up Claude Code on macOS. Install CLI, configure authentication, and start using Claude as your terminal assistant."
date: 2026-03-14
author: "Claude Skills Guide"
categories: [getting-started]
tags: [claude-code, claude-skills, macos, installation, setup]
reviewed: true
score: 8
permalink: /claude-code-setup-on-mac-step-by-step/
---

# Claude Code Setup on Mac: Step-by-Step Guide for Developers

Getting Claude Code running on your Mac unlocks a powerful AI assistant directly in your terminal. This guide walks you through every step, from installation to your first commands, with practical examples developers can use immediately. For broader onboarding resources, see the [getting started hub](/claude-skills-guide/getting-started-hub/).

## Prerequisites

Before you begin, ensure you have:

- **macOS 12.0 or later** — Claude Code requires a relatively recent macOS version
- **Node.js 18+** — required for the Claude Code CLI
- **An Anthropic account** — sign up at anthropic.com if you haven't already
- **API key** — obtain from your Anthropic console

Check Node.js is available:

```bash
node --version
```

## Installing Claude Code

Install Claude Code globally using npm:

```bash
npm install -g @anthropic-ai/claude-code
```

This installs the `claude` command globally. Verify the installation:

```bash
claude --version
```

You should see output indicating the installed version, confirming the CLI is accessible.

## Authenticating with Your API Key

Claude Code requires authentication to connect to Anthropic's API. Set your API key as an environment variable. Add this to your shell profile for persistence:

```bash
# Add to ~/.zshrc or ~/.bash_profile
export ANTHROPIC_API_KEY="sk-ant-your-api-key-here"
```

Reload your shell configuration:

```bash
source ~/.zshrc
```

For better security, consider using a `.env` file with a tool like `direnv`, or use macOS Keychain to store your API key securely.

## Project-Level Configuration

Claude Code supports project-specific instructions via a `CLAUDE.md` file in your project root. This file describes your project to Claude at the start of each session. You can also load [Claude Code skills](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) to bring in reusable specialized workflows:

```markdown
# Project Context
This is a TypeScript React application using Vite.
- Prefer functional components with hooks
- Use async/await over promise chains
```

When you start Claude from that directory, it reads `CLAUDE.md` automatically and applies those conventions throughout your session.

## Your First Conversation

Start an interactive session:

```bash
claude
```

You enter a chat interface where you can type prompts naturally. Try a simple request:

```
Explain what this bash command does: find . -name "*.js" -type f
```

Claude responds with a breakdown of the command's purpose and behavior.

## Using Claude Without Interactive Mode

For automation, pipe input directly to Claude:

```bash
echo "Write a Python function that calculates factorial" | claude
```

This outputs the result without entering interactive mode—useful for scripts and pipelines.

## Integrating with Your Development Workflow

### Using Claude with Git

Combine Claude with git for intelligent code reviews:

```bash
git diff | claude "Review these changes and suggest improvements"
```

This pipes your uncommitted changes to Claude, which analyzes them and provides feedback.

### Creating Aliases for Common Tasks

Speed up your workflow with shell aliases in `~/.zshrc`:

```bash
alias claude-review="git diff | claude"
```

Reload your shell, then use `claude-review` to instantly get code review feedback.

## Troubleshooting Common Issues

### API Key Not Recognized

If Claude reports authentication failures, verify your environment variable:

```bash
echo $ANTHROPIC_API_KEY
```

Ensure no leading or trailing spaces when you set the variable.

### Permission Denied Errors

On first run, macOS may block the binary. Open System Settings > Privacy & Security and allow the application to run, or run:

```bash
xattr -rd com.apple.quarantine /usr/local/bin/claude
```

### Slow Responses

If responses feel sluggish, try a faster model by passing the `--model` flag:

```bash
claude --model claude-haiku-4-5 "Your prompt here"
```

Haiku responds faster for straightforward tasks.

## Advanced: Using MCP Servers

For expanded capabilities, [configure Model Context Protocol servers](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/). Create or edit `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/username/projects"]
    }
  }
}
```

This gives Claude access to read and write files in your specified directories through a structured protocol.

Restart your Claude session to load the MCP configuration.

## Summary

Setting up Claude Code on Mac involves four core steps:

1. Install via npm: `npm install -g @anthropic-ai/claude-code`
2. Configure your API key as an environment variable
3. Test with basic commands
4. Integrate into your workflow with aliases and scripts

Once configured, Claude becomes a persistent coding companion in your terminal—ready to explain code, write functions, review changes, and automate repetitive tasks.

## Choosing the Right Model for Your Needs

Claude Code supports multiple models, each suited to different use cases. Pass the `--model` flag to select a model per command:

```bash
# Sonnet: best balance for most development tasks
claude --model claude-sonnet-4-5 "Refactor this function"

# Haiku: fast for simple tasks
claude --model claude-haiku-4-5 "Explain this variable name"

# Opus: most capable for complex architecture decisions
claude --model claude-opus-4-5 "Design a microservices migration plan"
```

Switch models based on the task at hand. For routine work, Haiku keeps things fast. For anything requiring deep reasoning, Sonnet or Opus deliver the necessary capability.

## Practical Example: Automated Code Reviews

A powerful workflow combines Claude with your existing git hooks. Create a script for pre-commit reviews:

```bash
#!/bin/bash
# ~/scripts/claude-review.sh

git diff --cached --name-only | while read file; do
  git diff --cached "$file" | claude "Review this diff for bugs and style issues"
done
```

Make it executable and add to your git hooks:

```bash
chmod +x ~/scripts/claude-review.sh
cp .git/hooks/pre-commit.sample .git/hooks/pre-commit
echo "~/scripts/claude-review.sh" >> .git/hooks/pre-commit
```

Every commit now includes automated code review feedback.

## Performance Tips

Maximize Claude Code efficiency with these practices:

**Use context efficiently.** Provide relevant file paths rather than pasting entire codebases. Claude processes file paths faster and more accurately than raw text.

**Chain commands thoughtfully.** Pipe only the necessary output:

```bash
# Good: specific scope
git diff --name-only src/components/ | claude "Review these component changes"

# Avoid: entire repository
git diff | claude  # May overwhelm context window
```

**Cache common queries.** Save frequently-used prompts to files and reference them:

```bash
# Save to ~/.claude/prompts/explain-code.txt
Explain this code section by section:
1. What does each function do?
2. What are the inputs and outputs?
3. Are there any potential bugs?

# Use it
cat ~/.claude/prompts/explain-code.txt src/utils.js | claude
```

## Related Reading

- [Claude Code for Beginners: Complete Getting Started 2026](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Project Initialization Best Practices](/claude-skills-guide/claude-code-project-initialization-best-practices/)
- [Claude Code MCP Server Setup: Complete Guide 2026](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/)
- [Getting Started Hub](/claude-skills-guide/getting-started-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
