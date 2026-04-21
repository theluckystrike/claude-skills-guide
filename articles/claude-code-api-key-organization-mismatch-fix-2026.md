---
title: "Claude API Key Organization Mismatch — Fix (2026)"
permalink: /claude-code-api-key-organization-mismatch-fix-2026/
description: "Set correct ANTHROPIC_ORG_ID matching your API key to fix organization mismatch. Remove conflicting environment variables from shell config."
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
API key belongs to organization org-xxx but request specifies org-yyy
```

## The Fix

```bash
# Check which org ID your API key belongs to (visible in Anthropic Console)
# Then set the matching org ID:
export ANTHROPIC_ORG_ID="org-xxx"

# Or remove the org override entirely to use the key's default org:
unset ANTHROPIC_ORG_ID

# Persist in your shell config:
grep -v "ANTHROPIC_ORG_ID" ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc
echo 'export ANTHROPIC_ORG_ID="org-xxx"' >> ~/.zshrc
```

## Why This Works

Anthropic API keys are scoped to a specific organization. When Claude Code sends a request with an explicit organization header that differs from the key's owning organization, the API rejects it. This typically happens when you switch between personal and work accounts, or when environment variables from a previous project linger in your shell.

## If That Doesn't Work

```bash
# Check all places where the org might be set:
env | grep -i anthropic
cat ~/.claude/config.json 2>/dev/null | grep -i org
cat .env 2>/dev/null | grep -i org

# Generate a new API key for the correct organization at:
# https://console.anthropic.com/settings/keys
# Then update:
export ANTHROPIC_API_KEY="sk-ant-api03-new-key-here"
```

Multiple config sources can override each other. Check `.env`, shell rc files, and Claude config in that order.

## Prevention

Add to your CLAUDE.md:
```
Use one API key per project. Set ANTHROPIC_API_KEY and ANTHROPIC_ORG_ID in the project's .env file (gitignored) rather than global shell config to prevent cross-project org conflicts.
```
