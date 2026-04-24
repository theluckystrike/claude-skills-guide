---
title: "Claude API Key Organization Mismatch"
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

## See Also

- [Invalid API Key Format sk-ant — Fix (2026)](/claude-code-api-key-sk-ant-format-invalid-fix-2026/)
- [Claude API Invalid API Key Format Error — Fix (2026)](/claude-api-invalid-api-key-format-error-fix/)
- [ANTHROPIC_API_KEY Not Set in Subprocess Fix](/claude-code-anthropic-api-key-not-set-subprocess-fix-2026/)
- [Organization Billing Suspended Error — Fix (2026)](/claude-code-organization-billing-suspended-fix-2026/)
- [API Key Region Mismatch eu-west-1 — Fix (2026)](/claude-code-anthropic-api-key-region-mismatch-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `AuthenticationError: invalid x-api-key`
- `Error: API key not found in environment`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### Where should I store my Anthropic API key?

Store it in the `ANTHROPIC_API_KEY` environment variable in your shell profile (`~/.bashrc`, `~/.zshrc`). Never hardcode API keys in source code or commit them to version control. For CI/CD, use your platform's secrets manager.
