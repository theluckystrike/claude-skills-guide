---
title: "Claude API Invalid API Key Format Error"
description: "Fix Claude API invalid_api_key format error. Verify key prefix and remove hidden whitespace characters. Step-by-step solution."
permalink: /claude-api-invalid-api-key-format-error-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error 401: Invalid API Key
{
  "type": "error",
  "error": {
    "type": "authentication_error",
    "message": "Invalid API key format. API keys must start with 'sk-ant-api03-'."
  }
}
```

## The Fix

1. **Verify your key format and strip hidden characters**

```bash
# Check the key prefix (first 15 chars only — never print full key)
echo $ANTHROPIC_API_KEY | cut -c1-15
# Expected: sk-ant-api03-

# Check for hidden whitespace or newlines
echo -n "$ANTHROPIC_API_KEY" | wc -c
# A valid key is typically 108 characters
```

2. **Re-export the key with proper quoting**

```bash
# Remove any trailing whitespace/newlines that crept in from copy-paste
export ANTHROPIC_API_KEY=$(echo -n "sk-ant-api03-YOUR_KEY_HERE" | tr -d '[:space:]')
```

3. **Verify the fix:**

```bash
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":5,"messages":[{"role":"user","content":"hi"}]}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin).get('content',[{}])[0].get('text','ERROR'))"
# Expected: A short response (not an error message)
```

## Why This Happens

Anthropic API keys follow a strict format: they must begin with `sk-ant-api03-` and contain only alphanumeric characters plus hyphens. The most common cause of format errors is invisible whitespace — a trailing newline from `pbpaste`, a zero-width space from a web dashboard copy, or carriage returns from Windows line endings. Storing keys in `.env` files without proper quoting also introduces these issues.

## If That Doesn't Work

- **Alternative 1:** Generate a fresh key at `console.anthropic.com/settings/keys` — old keys with `sk-ant-api02-` prefix are deprecated
- **Alternative 2:** Check if your shell config file (`.bashrc`/`.zshrc`) has a conflicting `ANTHROPIC_API_KEY` export that overrides yours
- **Check:** Run `env | grep ANTHRO` to see all Anthropic-related environment variables and spot conflicts

## Prevention

Add to your `CLAUDE.md`:
```markdown
Store API keys in .env files with no trailing whitespace. Always validate key format starts with sk-ant-api03- before making requests. Use a secrets manager for production deployments.
```

**Related articles:** [Claude API 401 Auth Error](/claude-api-error-401-authenticationerror-explained/), [Invalid API Key After Rotation](/claude-code-error-invalid-api-key-after-rotation-fix/), [Claude Code Config File Location](/claude-code-config-file-location/)

## See Also

- [Invalid API Key Format sk-ant — Fix (2026)](/claude-code-api-key-sk-ant-format-invalid-fix-2026/)
