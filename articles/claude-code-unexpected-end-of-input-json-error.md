---

layout: default
title: "Fixing Claude Code's 'Unexpected End of Input' JSON Error"
description: "A comprehensive guide to understanding and resolving the 'unexpected end of input' JSON error in Claude Code CLI."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-unexpected-end-of-input-json-error/
categories: [troubleshooting]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
---


{% raw %}
# Fixing Claude Code's "Unexpected End of Input" JSON Error

If you're working with Claude Code (claude.ai/cli), you've probably encountered the frustrating "unexpected end of input" JSON error at some point. This error typically occurs when Claude Code tries to parse a configuration file or JSON input and finds that the file is incomplete, malformed, or truncated. In this guide, we'll explore what causes this error, how to identify it, and—most importantly—how to fix it.

## Understanding the Error

The "unexpected end of input" error is a JSON parsing error that happens when the JSON parser reaches the end of the input but expects more data to complete a valid JSON structure. This could be a missing closing bracket, a missing quote, or an incomplete object/array.

In the context of Claude Code, this error commonly appears in several scenarios:

- Configuration files (like `CLAUDE.md`, project settings)
- MCP (Model Context Protocol) server configurations
- Tool responses that return malformed JSON
- Environment variables containing JSON data

## Common Causes and Solutions

### 1. Incomplete Configuration Files

One of the most frequent causes is a malformed `CLAUDE.md` file or other configuration files. This often happens when editing configuration files manually and accidentally deleting a closing bracket or brace.

**Example of invalid JSON (missing closing brace):**

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
    }
  // Missing closing brace here
```

**Fixed version:**

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
    }
  }
}
```

### 2. MCP Server Configuration Issues

When setting up MCP servers in Claude Code, incorrect JSON configuration can trigger this error. The MCP server configuration lives in your Claude Code settings file.

**To check your MCP configuration:**

First, locate your Claude Code configuration directory. On macOS, it's typically at `~/Library/Application Support/Claude/settings.json`. On Linux, it's `~/.config/Claude/settings.json`.

**Example of properly formatted MCP configuration:**

```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./public"]
    }
  }
}
```

Notice how each server object is properly closed with `}` and the entire configuration is wrapped in outer braces.

### 3. Environment Variables with JSON

If you're passing JSON through environment variables, make sure the JSON is properly escaped and quoted.

**Incorrect way:**

```bash
export CLAUDE_CONFIG='{"key": "value"}  # Missing closing quote
```

**Correct way:**

```bash
export CLAUDE_CONFIG='{"key": "value"}'
```

### 4. Project-Specific Configuration

Claude Code respects project-specific configuration through a `CLAUDE.md` file in your project root. If this file contains invalid JSON-like structures (even though it's primarily Markdown), you might encounter issues.

Make sure any JSON code blocks within `CLAUDE.md` are properly formatted:

```markdown
# My Project

Here's my project configuration:

```json
{
  "tools": {
    "Bash": {
      "enabled": true,
      "description": "Run shell commands"
    }
  }
}
```
```

## Debugging Steps

When you encounter this error, follow these systematic debugging steps:

### Step 1: Validate Your JSON

Use a JSON validator to check if your configuration files are valid. You can use online tools or the command line:

```bash
# Validate JSON using python
python3 -c "import json; json.load(open('settings.json'))"

# Or using jq
cat settings.json | jq .
```

### Step 2: Check Recent Changes

If the error appeared after a recent change, review your recent edits to configuration files:

```bash
# Check recent changes to settings
git diff ~/.config/Claude/settings.json

# Or check modification time
ls -la ~/.config/Claude/settings.json
```

### Step 3: Simplify and Rebuild

If you're unsure where the problem is, start with a minimal valid configuration and gradually add back your settings:

```json
{
  "mcpServers": {}
}
```

Then add one MCP server at a time, validating after each addition.

### Step 4: Check File Permissions

Sometimes, Claude Code might not be able to read the full configuration file due to permission issues. Verify file permissions:

```bash
ls -la ~/.config/Claude/settings.json
chmod 644 ~/.config/Claude/settings.json
```

## Preventing Future Errors

### Use a Linter

Set up a linter or pre-commit hook to validate JSON files before committing:

```json
// .git/hooks/pre-commit
#!/bin/bash
python3 -c "import json; json.load(open('settings.json'))" || exit 1
```

### Version Control Your Configurations

Keep your Claude Code configurations in version control (with appropriate .gitignore entries for sensitive data):

```bash
# In your .gitignore
~/.config/Claude/settings.local.json
```

### Use Claude Code's Built-in Validation

Claude Code will often tell you which file has the parsing error. Pay attention to error messages—they usually include the file path.

## Advanced: Debugging MCP Server Responses

If the error comes from an MCP server returning invalid JSON, you can debug it by:

1. Checking the server logs
2. Testing the server independently
3. Verifying the JSON output from the server

```bash
# Test an MCP server directly
npx -y @modelcontextprotocol/server-filesystem /path 2>&1 | head -50
```

## Conclusion

The "unexpected end of input" JSON error in Claude Code is usually caused by malformed configuration files—most commonly missing closing braces or brackets. The fix is straightforward: validate your JSON, check for typos, and ensure all brackets and braces are properly closed.

By following the debugging steps outlined in this guide, you can quickly identify and resolve these JSON parsing errors. Remember to keep your configuration files well-formatted, use validation tools, and make incremental changes so you can easily identify what caused any issues.

If you continue to experience this error after checking your local configurations, it might be worth checking Claude Code's documentation or community forums for known issues with specific versions or configurations.
{% endraw %}


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-skills-guide/claude-code-not-working-after-update-how-to-fix/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Code Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/)

