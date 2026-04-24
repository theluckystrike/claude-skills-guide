---
title: "Invalid API Key Format sk-ant — Fix"
permalink: /claude-code-api-key-sk-ant-format-invalid-fix-2026/
description: "Fix 'Invalid API key format' by regenerating your sk-ant key. Claude expects sk-ant-api03 prefix since March 2026."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Invalid API key format. Expected key starting with 'sk-ant-api03-' but received 'sk-ant-api01-...'
```

This error appears when you pass an outdated API key to Claude Code or the Anthropic SDK. Anthropic deprecated the `sk-ant-api01` and `sk-ant-api02` prefixes in early 2026.

## The Fix

1. Go to the Anthropic Console and generate a new key:

```bash
open https://console.anthropic.com/settings/keys
```

2. Replace your old key in your environment:

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-your-new-key-here"
```

3. Update your shell profile so it persists:

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-your-new-key-here"' >> ~/.zshrc
source ~/.zshrc
```

4. Verify the key works:

```bash
claude --version && claude "say hello"
```

## Why This Happens

Anthropic rotates API key prefixes when they change their authentication infrastructure. The `sk-ant-api01` prefix was used during the 2024 beta, and `sk-ant-api02` during 2025. Keys with old prefixes are rejected at the gateway level before they even reach the model.

## If That Doesn't Work

- Check if your key is stored in a `.env` file that overrides the shell export:

```bash
grep -r "sk-ant" .env ~/.claude/ 2>/dev/null
```

- If using the SDK programmatically, ensure you are not hardcoding the key:

```bash
python -c "import anthropic; print(anthropic.Anthropic().messages.create(model='claude-sonnet-4-20250514', max_tokens=10, messages=[{'role':'user','content':'hi'}]))"
```

- Confirm your organization has not been migrated to OAuth-based auth, which uses a different flow entirely.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# API Key Management
- Never hardcode API keys. Always use ANTHROPIC_API_KEY environment variable.
- Verify key prefix matches sk-ant-api03 before deployment.
- Store keys in a secrets manager, not in .env files committed to git.
```

## See Also

- [Claude API Invalid API Key Format Error — Fix (2026)](/claude-api-invalid-api-key-format-error-fix/)
- [Claude API Key Organization Mismatch — Fix (2026)](/claude-code-api-key-organization-mismatch-fix-2026/)
- [ANTHROPIC_API_KEY Not Set in Subprocess Fix](/claude-code-anthropic-api-key-not-set-subprocess-fix-2026/)
- [API Key Region Mismatch eu-west-1 — Fix (2026)](/claude-code-anthropic-api-key-region-mismatch-fix-2026/)
