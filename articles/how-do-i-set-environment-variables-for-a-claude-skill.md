---
layout: default
title: "How Do I Set Environment Variables for a Claude Skill"
description: "A practical guide to configuring environment variables for Claude Code skills. Learn how to set up API keys, credentials, and custom configurations for ..."
date: 2026-03-14
author: "Claude Skills Guide"
reviewed: true
score: 8
categories: [tutorials]
tags: [claude-code, claude-skills]
---
{% raw %}

# How Do I Set Environment Variables for a Claude Skill

[Claude Code skills are powerful extensions](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) in your AI sessions. Whether you're using the pdf skill for document processing, the tdd skill for test-driven development, or the supermemory skill for knowledge management, understanding how to configure environment variables is essential for getting the most out of these tools.

This guide walks you through the process of setting environment variables for Claude skills, with practical examples for common use cases.

## Where Claude Skills Store Configuration

[Claude skills are stored as Markdown files](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/). The default location is `~/.claude/skills/`. Each skill lives in its own subdirectory or as a standalone `.md` file. When you invoke a skill using its slash command, Claude reads the file and applies the instructions to your session.

Environment variables for skills can be set in several ways:

1. **System-wide environment variables** that Claude inherits from your shell
2. **Skill-specific configuration files** that the skill reads at runtime
3. **Claude Code configuration** in `~/.claude/settings.json`

The method you choose depends on whether the skill requires the variable at invocation time or during skill execution.

## Setting System-Wide Environment Variables

The simplest approach is to set environment variables in your shell configuration. This works for any skill that reads from standard environment variables like `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, or custom variables you define.

### For Zsh Users (macOS Default)

Edit your `~/.zshrc` file:

```bash
export OPENAI_API_KEY="sk-your-key-here"
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
export SUPERMEMORY_API_KEY="your-supermemory-key"
export PDF_SERVICE_API_KEY="your-pdf-service-key"
```

### For Bash Users

Edit your `~/.bashrc` or `~/.bash_profile`:

```bash
export OPENAI_API_KEY="sk-your-key-here"
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
```

After editing, apply the changes:

```bash
source ~/.zshrc  # or source ~/.bashrc
```

These variables are now available to any skill that runs in your terminal session. The pdf skill, for example, might use `PDF_SERVICE_API_KEY` when calling external document processing APIs.

## Skill-Specific Configuration Files

Many skills come with their own configuration mechanism. The [supermemory skill, for instance, often requires a configuration file](/claude-skills-guide/building-stateful-agents-with-claude-skills-guide/) to connect to your personal knowledge base.

### Example: Configuring the Supermemory Skill

The supermemory skill typically stores configuration in `~/.claude/skills/supermemory/config.json` or reads from a `.env` file in the skill directory:

```json
{
  "apiKey": "your-supermemory-api-key",
  "vectorStore": "chroma",
  "collectionName": "claude-notes",
  "embeddingModel": "text-embedding-3-small"
}
```

Some skills also support `.env` file syntax:

```
SUPERMEMORY_API_KEY=your-key-here
SUPERMEMORY_HOST=http://localhost:7933
SUPERMEMORY_INDEX_NAME=my-knowledge-base
```

## Using Claude Code Settings for Skill Configuration

[Claude Code allows you to set environment variables through its settings system](/claude-skills-guide/claude-code-permissions-model-security-guide-2026/). Edit `~/.claude/settings.json` to make variables available specifically to Claude:

```json
{
  "env": {
    "CLAUDE_SKILL_PDF_KEY": "your-pdf-service-key",
    "CLAUDE_SKILL_TDD_TEMPLATE_PATH": "/Users/yourname/claude-templates/tdd",
    "CLAUDE_SKILL_FRONTEND_FRAMEWORK": "react"
  },
  "allowedDirectories": ["/Users/yourname/projects"]
}
```

This approach keeps skill-related variables isolated from your general shell environment, which is useful when working on multiple projects with different configurations.

## Practical Examples by Skill

### PDF Skill Configuration

The pdf skill often requires API keys for services like pdf.co, CloudConvert, or similar tools. Set the appropriate variable:

```bash
export PDF_API_KEY="your-pdf-service-key"
export PDF_OUTPUT_DIR="/Users/yourname/Documents/claude-outputs"
```

Then in your skill configuration or `.env` file:

```
PDF_API_KEY=your-pdf-service-key
PDF_OUTPUT_DIR=/Users/yourname/Documents/claude-outputs
```

When you invoke the skill with `/pdf`, it can access these variables to process documents and save outputs to the correct location.

### TDD Skill Configuration

The tdd skill works with your testing framework of choice. Configure the framework and template paths:

```bash
export TDD_FRAMEWORK="jest"
export TDD_TEST_DIR="tests"
export TDD_TEMPLATE_PATH="/Users/yourname/claude-templates/tdd"
```

Create a template file at `/Users/yourname/claude-templates/tdd/unit-test-template.js`:

```javascript
describe('{{moduleName}}', () => {
  beforeEach(() => {
    // setup
  });

  it('should {{description}}', () => {
    // test implementation
  });
});
```

The tdd skill reads these variables to generate tests in the correct format and location.

### Frontend-Design Skill Configuration

The frontend-design skill can use environment variables to set default frameworks, styling preferences, and output directories:

```bash
export FRONTEND_DEFAULT_FRAMEWORK="nextjs"
export FRONTEND_DEFAULT_STYLING="tailwind"
export FRONTEND_OUTPUT_DIR="/Users/yourname/projects"
export FRONTEND_COMPONENT_LIB="shadcn-ui"
```

### Supermemory Skill Configuration

The supermemory skill requires specific configuration to connect to your knowledge base:

```bash
export SUPERMEMORY_API_KEY="your-api-key"
export SUPERMEMORY_COLLECTION="claude-code-notes"
```

Create the skill configuration at `~/.claude/skills/supermemory/config`:

```
api_key: your-api-key
collection: claude-code-notes
retrieval_limit: 10
```

## Security Considerations

Never commit API keys or secrets to version control. Use `.gitignore` to exclude skill configuration files that contain sensitive data:

```
# .gitignore additions
~/.claude/skills/*/config.json
~/.claude/skills/*/.env
.env
```

Consider using a secrets manager for production environments rather than hardcoding keys in shell configuration files.

## Troubleshooting

If your skill isn't recognizing environment variables:

1. **Verify the variable exists**: Run `echo $VARIABLE_NAME` in your terminal
2. **Check the skill documentation**: Some skills expect variables with specific names
3. **Restart Claude Code**: New shell variables require a fresh session
4. **Use absolute paths**: For file-based configuration, use full paths rather than tildes

You can also debug by adding a debug statement in your skill file to print available variables:

```markdown
# Debug: Show available environment variables
Available variables: $OPENAI_API_KEY, $PDF_API_KEY, etc.
```

## Summary

Setting environment variables for Claude skills involves three main approaches: shell configuration files for system-wide access, skill-specific configuration files for per-skill settings, and Claude Code's settings.json for isolated configurations.

For most skills like pdf, tdd, frontend-design, and supermemory, you'll set variables in your shell profile and optionally create skill-specific configuration files for more granular control. Remember to keep [sensitive keys secure](/claude-skills-guide/getting-started-hub/) after modifying environment variables.

With proper configuration, your Claude skills will have access to the APIs, paths, and settings they need to function effectively in your development workflow.

## Related Reading

- [How to Create a Private Claude Skill Not on GitHub](/claude-skills-guide/how-do-i-create-a-private-claude-skill-not-on-github/) — Keep skills and their credentials local without GitHub exposure
- [Claude Code Permissions Model and Security Guide 2026](/claude-skills-guide/claude-code-permissions-model-security-guide-2026/) — Understand security boundaries when exposing environment variables to skills
- [Claude Code Secret Scanning: Prevent Credential Leaks Guide](/claude-skills-guide/claude-code-secret-scanning-prevent-credential-leaks-guide/) — Ensure API keys and secrets in skills don't leak accidentally
- [Claude Skills Hub](/claude-skills-guide/getting-started-hub/) — Explore essential skill configuration and setup patterns

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
