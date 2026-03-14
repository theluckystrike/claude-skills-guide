---
layout: default
title: "Claude Code Error Invalid API Key After Rotation Fix"
description: Fix the invalid API key error that occurs after rotating your Anthropic API key. Step-by-step solutions for environment variables, config files, and skill updates.
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-error-invalid-api-key-after-rotation-fix/
reviewed: true
score: 7
categories: [troubleshooting]
tags: [claude-code, claude-skills]
---

# Claude Code Error Invalid API Key After Rotation Fix

Rotating API keys is a security best practice, but it often breaks your Claude Code workflow when the old credentials remain cached or stored in multiple locations. This guide provides practical solutions for resolving the invalid API key error after rotation, covering environment variables, configuration files, and skill-specific credentials.

## Why API Key Rotation Breaks Claude Code

When you rotate your Anthropic API key in the console, any application storing the old key will continue using invalid credentials until you update all references. Claude Code reads API keys from multiple sources, and if any location still contains the old key, authentication will fail. Understanding these sources helps you systematically track down every place that needs updating.

Common scenarios causing the error after rotation include environment variables pointing to expired keys, configuration files with cached credentials, MCP servers holding stale authentication, and skills that store API keys directly in their configuration.

## Identifying the Error

After rotating your API key, you may encounter error messages like:

```
Error: Invalid API key for Anthropic
Authentication failed: API key not recognized
401 Unauthorized: Invalid credentials
```

The error typically appears when starting Claude Code, initializing a skill that requires API access, or running any task that calls the Anthropic API. If you recently rotated your key and now see these errors, the solution involves updating credential storage across your system.

## Solution 1: Update Environment Variables

The first and most common place to check is your shell environment. Many developers store API keys in `.bashrc`, `.zshrc`, or `.env` files.

Check your current environment variables:

```bash
# View API-related environment variables
env | grep -i anthropic
env | grep -i api
```

If you find the old key still set, update it:

```bash
# For bash/zsh
export ANTHROPIC_API_KEY="sk-ant-your-new-key-here"

# Add to your shell config for persistence
echo 'export ANTHROPIC_API_KEY="sk-ant-your-new-key-here"' >> ~/.zshrc
source ~/.zshrc
```

For projects using `.env` files, open your project's `.env` file and update the key:

```bash
# .env file
ANTHROPIC_API_KEY=sk-ant-your-new-key-here
```

After updating, verify the change took effect:

```bash
echo $ANTHROPIC_API_KEY
```

## Solution 2: Update Claude Code Configuration File

Claude Code stores authentication settings in its configuration file. The location varies by operating system:

- **macOS/Linux**: `~/.claude/settings.json`
- **Windows**: `%APPDATA%\Claude\settings.json`

Open this file and locate the authentication section:

```json
{
  "anthropic": {
    "api_key": "sk-ant-old-key-here"
  }
}
```

Replace the old key with your new API key. If the entire section is missing, you can add it:

```json
{
  "anthropic": {
    "api_key": "sk-ant-your-new-key-here"
  }
}
```

Some users prefer removing this section entirely and relying on environment variables, which eliminates synchronization issues between different credential sources.

## Solution 3: Update MCP Server Credentials

If you use MCP (Model Context Protocol) servers that connect to external APIs, they may store their own credentials. Common MCP servers requiring API keys include brave-search, tavily, and custom servers you may have configured.

Check your MCP server configuration files, typically located in:

- `~/.claude/mcp.json`
- `~/.mcp/servers/`
- Project-specific `.mcp/` directories

Update any stored API keys in these configurations:

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "your-new-brave-key"
      }
    }
  }
}
```

Restart Claude Code after updating MCP credentials to ensure the new keys load correctly.

## Solution 4: Update Skill-Specific Credentials

Many Claude skills include their own API key configuration. When rotating keys, you must update each skill that uses the Anthropic API or other services.

Skills that commonly require API key updates include:
- The `pdf` skill for document processing
- The `xlsx` skill for spreadsheet automation
- The `pptx` skill for presentation generation
- The `frontend-design` skill for UI development
- The `tdd` skill for test-driven development workflows

Check each skill's configuration or documentation for environment variable requirements. Skills typically document their required credentials in their `skill.md` files or README documentation.

For skills storing credentials in custom configuration files, locate the file and update the API key:

```bash
# Find configuration files in your skills directory
find ~/.claude/skills -name "*.json" -o -name ".env" | xargs grep -l "sk-ant"
```

Update any matches with your new API key.

## Solution 5: Clear Cached Credentials

Claude Code may cache credentials in memory during extended sessions. If updating credentials doesn't resolve the error immediately, restart Claude Code entirely to clear cached authentication state.

Additionally, some systems maintain credential caches at the OS level. On macOS, you can reset keychain entries if you stored API keys there:

```bash
# macOS keychain (if applicable)
security find-internet-password -s "anthropic.com"
security delete-internet-password -s "anthropic.com"
```

## Preventing Future Rotation Issues

To avoid this problem in the future, consider these practices:

1. **Use environment variables exclusively** rather than storing keys in multiple locations
2. **Document your API key locations** in a secure note or password manager
3. **Use a credential manager** like 1Password or HashiCorp Vault to centralize API key storage
4. **Implement a rotation script** that updates all credential locations simultaneously

Here's an example rotation script:

```bash
#!/bin/bash
# rotate-api-key.sh

NEW_KEY=$1

# Update environment variable
export ANTHROPIC_API_KEY="$NEW_KEY"

# Update Claude config
sed -i '' "s/sk-ant-.*/sk-ant-.../" ~/.claude/settings.json

# Update project .env files
find . -name ".env" -exec sed -i '' "s/ANTHROPIC_API_KEY=.*/ANTHROPIC_API_KEY=$NEW_KEY/" {} \;

echo "API key rotated across all locations"
```

## Verification Steps

After applying fixes, verify that Claude Code recognizes your new API key:

1. Restart Claude Code completely
2. Run a simple command that triggers an API call
3. Check for any remaining authentication errors
4. Confirm environment variables display the new key

If errors persist, systematically check each credential location again—it's easy to miss a configuration file storing the old key.


## Related Reading

- [Claude Code Error: Invalid API Key Troubleshoot Guide](/claude-skills-guide/claude-code-error-invalid-api-key-troubleshoot-guide/) — See also
- [How Do I Set Environment Variables for a Claude Skill?](/claude-skills-guide/how-do-i-set-environment-variables-for-a-claude-skill/) — See also
- [Claude Code Secret Scanning: Prevent Credential Leaks Guide](/claude-skills-guide/claude-code-secret-scanning-prevent-credential-leaks-guide/) — See also
- [Claude Skills Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/) — See also

Built by theluckystrike — More at [zovo.one](https://zovo.one)
